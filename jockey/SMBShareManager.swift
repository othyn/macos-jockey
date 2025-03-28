//
//  SMBShareManager.swift
//  jockey
//
//  Created by Ben Tindall on 26/03/2025.
//

import Foundation
import Combine

final class SMBShareManager: ObservableObject {
    struct SMBShare: Identifiable, Codable {
        var id = UUID()
        var name: String
        var url: URL
        var mountPoint: URL?
        var isConnected: Bool = false
        var connectedSince: Date?
        var lastChecked: Date?

        var formattedConnectionTime: String {
            guard let connectedSince = connectedSince else {
                return ""
            }
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day, .hour, .minute]
            formatter.unitsStyle = .abbreviated
            formatter.maximumUnitCount = 2
            return formatter.string(from: connectedSince, to: Date()) ?? ""
        }

        var formattedLastCheckedTime: String {
            guard let lastChecked = lastChecked else {
                return "Never"
            }
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            return formatter.localizedString(for: lastChecked, relativeTo: Date())
        }
    }

    @Published var shares: [SMBShare] = []
    @Published var pollingInterval: TimeInterval = 30 // Default 30 seconds polling interval
    private var checkTimer: Timer?
    private let saveKey = "configuredShares"
    private let pollingIntervalKey = "pollingInterval"

    init() {
        loadShares()
        loadPollingInterval()
        startMonitoring()
    }

    private func loadShares() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let savedShares = try? JSONDecoder().decode([SMBShare].self, from: data) {
            shares = savedShares
        }
        checkConnectionStatus()
    }

    private func loadPollingInterval() {
        pollingInterval = UserDefaults.standard.double(forKey: pollingIntervalKey)
        // Default to 30 seconds if not set or invalid
        if pollingInterval <= 0 {
            pollingInterval = 30
        }
    }

    private func savePollingInterval() {
        UserDefaults.standard.set(pollingInterval, forKey: pollingIntervalKey)
    }

    private func saveShares() {
        if let encoded = try? JSONEncoder().encode(shares) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    func startMonitoring() {
        checkTimer?.invalidate()
        checkTimer = Timer.scheduledTimer(withTimeInterval: pollingInterval, repeats: true) { [weak self] _ in
            self?.checkConnectionStatus()
            self?.keepSharesMounted()
        }
        checkConnectionStatus()
        keepSharesMounted() // Try to connect all shares on startup
    }

    func stopMonitoring() {
        checkTimer?.invalidate()
        checkTimer = nil
    }

    func addShare(name: String, url: URL, mountPoint: URL? = nil) -> (success: Bool, message: String) {
        // Check if a share with this URL already exists
        if shares.contains(where: { $0.url.absoluteString == url.absoluteString }) {
            logInfo("Share with URL \(url.absoluteString) already exists. Not adding duplicate.")
            return (false, "A share with this URL already exists.")
        }

        // Set the mount point to the default system location if not specified
        let finalMountPoint = mountPoint ?? URL(fileURLWithPath: "/Volumes/\(name)")

        let newShare = SMBShare(name: name, url: url, mountPoint: finalMountPoint)
        shares.append(newShare)
        saveShares()
        checkConnectionStatus()
        return (true, "Share \(name) added successfully.")
    }

    func removeShare(at index: Int) {
        if index < shares.count {
            shares.remove(at: index)
            saveShares()
        }
    }

    func updateShare(_ share: SMBShare) {
        if let index = shares.firstIndex(where: { $0.id == share.id }) {
            shares[index] = share
            saveShares()
        }
    }

    func checkConnectionStatus() {
        // Get mounted volumes
        let fileManager = FileManager.default
        guard let mountedVolumeURLs = fileManager.mountedVolumeURLs(includingResourceValuesForKeys: [.volumeURLForRemountingKey, .volumeNameKey], options: [.skipHiddenVolumes]) else {
            return
        }

        logInfo("Checking connection status for \(shares.count) shares...")

        // Check each share
        for shareIndex in 0..<shares.count {
            var share = shares[shareIndex]
            logDebug("Checking share: \(share.name) with URL: \(share.url.absoluteString)")

            // Update last checked time
            share.lastChecked = Date()

            // First, always check if it's mounted at the system volume path, regardless of the stored mount point
            var isConnected = fileManager.fileExists(atPath: "/Volumes/\(share.name)")
            if isConnected {
                logDebug("  Found at system default path: /Volumes/\(share.name)")

                // Update the mount point to use the system path
                if share.mountPoint?.path != "/Volumes/\(share.name)" {
                    share.mountPoint = URL(fileURLWithPath: "/Volumes/\(share.name)")
                    logInfo("  Updated mount point to system default: /Volumes/\(share.name)")
                }
            }

            // Then check the specified mount point if not already found and if one is specified
            if !isConnected, let mountPoint = share.mountPoint {
                isConnected = fileManager.fileExists(atPath: mountPoint.path)
                logDebug("  Mount point check: \(mountPoint.path) exists: \(isConnected)")
            }

            // Finally, check mounted volumes as a fallback
            if !isConnected {
                for volumeURL in mountedVolumeURLs {
                    let shareHost = share.url.host?.lowercased() ?? ""
                    let sharePathLower = share.url.path.lowercased()

                    // Try to extract the name for this volume
                    var volumeName = ""
                    do {
                        if let resourceValues = try? volumeURL.resourceValues(forKeys: [.volumeNameKey]),
                           let name = resourceValues.volumeName {
                            volumeName = name.lowercased()
                        }
                    }

                    // Try to match by network path, host, or volume name
                    let volumePathLower = volumeURL.absoluteString.lowercased()
                    if volumePathLower.contains(shareHost) && !shareHost.isEmpty {
                        isConnected = true
                        logDebug("  Found by host match: \(volumeURL)")
                        break
                    } else if !sharePathLower.isEmpty && volumePathLower.contains(sharePathLower) {
                        isConnected = true
                        logDebug("  Found by path match: \(volumeURL)")
                        break
                    } else if volumeName == share.name.lowercased() {
                        isConnected = true
                        logDebug("  Found by name match: \(volumeURL)")
                        break
                    }
                }
            }

            // Update connection status
            if isConnected && !share.isConnected {
                share.isConnected = true
                share.connectedSince = Date()
                logInfo("  Share \(share.name) is now connected!")
            } else if !isConnected && share.isConnected {
                share.isConnected = false
                share.connectedSince = nil
                logInfo("  Share \(share.name) is now disconnected!")
            } else {
                logDebug("  Share \(share.name) connection status unchanged: \(share.isConnected)")
            }

            shares[shareIndex] = share
        }

        // Save updated status
        saveShares()
    }

    func keepSharesMounted() {
        let disconnectedShares = shares.filter { !$0.isConnected }
        if !disconnectedShares.isEmpty {
            logInfo("Attempting to reconnect \(disconnectedShares.count) disconnected shares...")
        }

        for share in shares where !share.isConnected {
            mountShare(share)
        }
    }

    func mountShare(_ share: SMBShare) {
        guard share.url.host != nil else {
            return
        }

        // Prepare mount command
        var mountPoint = share.mountPoint
        if mountPoint == nil {
            // Use system default Volumes directory instead of creating a custom one
            let volumeName = share.name
            mountPoint = URL(fileURLWithPath: "/Volumes/\(volumeName)")
        }

        guard let mountPoint = mountPoint else {
            return
        }
        let mountPath = mountPoint.path

        // No need to create the mount point directory - mount_smbfs will handle this
        // for system default locations

        // Build the mount command - try different approaches

        // First try with mount_smbfs
        var success = false

        // With mount_smbfs
        do {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/sbin/mount_smbfs")
            process.arguments = [share.url.absoluteString, mountPath]

            try process.run()
            process.waitUntilExit()

            if process.terminationStatus == 0 {
                success = true
                logInfo("Successfully mounted \(share.url.absoluteString) to \(mountPath)")
            } else {
                logWarning("mount_smbfs failed with status: \(process.terminationStatus)")
            }
        } catch {
            logError("Error with mount_smbfs: \(error.localizedDescription)")
        }

        // If that fails, try with /usr/bin/osascript
        if !success {
            do {
                logInfo("Trying AppleScript mount for \(share.url.absoluteString)")

                let scriptText = """
                tell application "Finder"
                    try
                        mount volume "\(share.url.absoluteString)"
                        return true
                    on error errMessage
                        return false
                    end try
                end tell
                """

                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")

                let pipe = Pipe()
                process.standardInput = pipe
                let outputPipe = Pipe()
                process.standardOutput = outputPipe
                process.standardError = Pipe()

                try process.run()

                if let data = scriptText.data(using: .utf8) {
                    pipe.fileHandleForWriting.write(data)
                    pipe.fileHandleForWriting.closeFile()
                }

                process.waitUntilExit()

                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let outputString = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

                if process.terminationStatus == 0 && outputString == "true" {
                    success = true
                    logInfo("Successfully mounted with AppleScript")

                    // After an AppleScript mount, we need to update the connection status immediately
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        self?.checkConnectionStatus()
                    }
                } else {
                    logWarning("AppleScript mount failed with status: \(process.terminationStatus), output: \(outputString)")
                }
            } catch {
                logError("Error with AppleScript mount: \(error.localizedDescription)")
            }
        }

        // Update share status after mount attempt
        DispatchQueue.main.async {
            // First check immediately
            self.checkConnectionStatus()

            // Then check again after a delay to allow for mounting to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                self?.checkConnectionStatus()
            }
        }
    }

    func unmountShare(_ share: SMBShare) {
        guard share.isConnected, let mountPoint = share.mountPoint else {
            return
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/sbin/umount")
        process.arguments = [mountPoint.path]

        do {
            try process.run()
            process.waitUntilExit()

            // Check status after unmount attempt
            DispatchQueue.main.async {
                self.checkConnectionStatus()
            }
        } catch {
            logError("Failed to unmount share: \(error.localizedDescription)")
        }
    }

    func updatePollingInterval(_ interval: TimeInterval) {
        guard interval > 0 else {
            return
        }

        pollingInterval = interval
        savePollingInterval()

        // Restart monitoring with the new interval
        startMonitoring()
    }

    func getSystemSMBShares() -> [String: URL] {
        // Get list of SMB shares from system
        var systemShares: [String: URL] = [:]

        // Try different possible paths for the mount command
        let mountPaths = ["/sbin/mount", "/bin/mount", "/usr/bin/mount", "/usr/sbin/mount"]

        var mountPath: String?
        for path in mountPaths where FileManager.default.fileExists(atPath: path) {
            mountPath = path
            break
        }

        guard let mountPath = mountPath else {
            logError("mount command not found")
            return systemShares
        }

        // Use the mount command to list mounted volumes
        let process = Process()
        process.executableURL = URL(fileURLWithPath: mountPath)

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                let lines = output.components(separatedBy: "\n")
                for line in lines where line.contains("smbfs") {
                    // Parse mount output to extract share info
                    // Format usually: //user@server/share on /path (smbfs, ...)
                    let components = line.components(separatedBy: " on ")
                    if components.count >= 2 {
                        let shareURLString = components[0]
                        let mountPathComponents = components[1].components(separatedBy: " (")
                        if mountPathComponents.count >= 1 {
                            _ = mountPathComponents[0]
                            let shareName = (shareURLString as NSString).lastPathComponent

                            // Create a proper SMB URL
                            var urlString = shareURLString
                            if !urlString.hasPrefix("smb://") {
                                // Convert //server/share to smb://server/share
                                urlString = "smb:" + urlString
                            }

                            if let url = URL(string: urlString) {
                                systemShares[shareName] = url
                            }
                        }
                    }
                }
            }
        } catch {
            logError("Error getting system shares: \(error.localizedDescription)")
        }

        // If no shares found via mount, fallback to checking /Volumes
        if systemShares.isEmpty {
            do {
                let volumes = try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/Volumes"), includingPropertiesForKeys: [.volumeIsLocalKey, .volumeURLForRemountingKey])
                for volume in volumes {
                    // Only include network volumes - exclude local drives
                    let resourceValues = try volume.resourceValues(forKeys: [.volumeIsLocalKey, .volumeURLForRemountingKey])
                    let isLocalVolume = resourceValues.volumeIsLocal ?? true

                    // Skip local volumes
                    if isLocalVolume {
                        continue
                    }

                    // If we get here, it's a network volume
                    let shareName = volume.lastPathComponent

                    // Get remount URL if available
                    if let remountURL = resourceValues.volumeURLForRemounting,
                       remountURL.scheme == "smb" {
                        systemShares[shareName] = remountURL
                    } else {
                        // Fallback if remount URL isn't available or isn't SMB, create a placeholder
                        // But mark it as "smb://" for clarity
                        if let url = URL(string: "smb://unknown/\(shareName)") {
                            systemShares[shareName] = url
                        }
                    }
                }
            } catch {
                logError("Error listing volumes: \(error.localizedDescription)")
            }
        }

        return systemShares
    }
}
