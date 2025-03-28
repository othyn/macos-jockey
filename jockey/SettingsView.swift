//
//  SettingsView.swift
//  jockey
//
//  Created by Ben Tindall on 26/03/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var shareManager: SMBShareManager
    @State private var systemShares: [String: URL] = [:]
    @State private var hoveredShare: String?
    @State private var hoveredManagedShare: UUID?
    @State private var isRefreshButtonHovered = false
    @State private var hoveredAddButton: String?
    @State private var pollingInterval: Double = 60
    @State private var defaultMountPath: String = "/Volumes"

    var body: some View {
        TabView {
            managedSharesView
                .tabItem {
                    Label("Managed Shares", systemImage: "externaldrive.connected.to.line.below.fill")
                }

            systemSharesView
                .tabItem {
                    Label("System Shares", systemImage: "desktopcomputer.and.macbook")
                }

            generalSettingsView
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .frame(width: 500, height: 400)
        .onAppear {
            refreshSystemShares()
            pollingInterval = shareManager.pollingInterval
            // Load saved mount path or use default
            defaultMountPath = UserDefaults.standard.string(forKey: "defaultMountPath") ?? "/Volumes"
        }
    }

    private var managedSharesView: some View {
        VStack {
            HStack {
                Text("These are your managed shares. You can view their connection status and remove shares that you no longer need to be kept alive.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)

                Button("Refresh", systemImage: "arrow.clockwise", action: shareManager.checkConnectionStatus)
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(.leading, 15)
                    .focusable(false)
                    .foregroundColor(isRefreshButtonHovered ? .accentColor : .primary)
                    .onHover { isHovered in
                        isRefreshButtonHovered = isHovered
                    }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 4)

            Divider()

            ScrollView {
                VStack(spacing: 10) {
                    if shareManager.shares.isEmpty {
                        Text("You don't have any managed shares yet. Add shares from the System Shares tab to keep them connected.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                    } else {
                        ForEach(shareManager.shares) { share in
                            VStack {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(share.name)
                                            .font(.headline)
                                        Text(share.url.absoluteString)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        if let mountPoint = share.mountPoint {
                                            Text("Mount point: \(mountPoint.path)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }

                                    Spacer()

                                    // Connection status indicator
                                    if share.isConnected {
                                        HStack {
                                            Circle()
                                                .fill(Color.green)
                                                .frame(width: 8, height: 8)
                                            Text("Connected")
                                                .foregroundColor(.secondary)
                                            if !share.formattedConnectionTime.isEmpty {
                                                Image(systemName: "clock")
                                                    .foregroundColor(.secondary)
                                                    .font(.caption)
                                                Text(share.formattedConnectionTime)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    } else {
                                        HStack {
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 8, height: 8)
                                            Text("Disconnected")
                                                .foregroundColor(.secondary)
                                        }
                                    }

                                    Spacer()
                                        .frame(width: 10)

                                    Button(action: {
                                        if let index = shareManager.shares.firstIndex(where: { $0.id == share.id }) {
                                            shareManager.removeShare(at: index)
                                        }
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    .focusable(false)
                                }
                                .padding(10)
                            }
                            .background(hoveredManagedShare == share.id ? Color.gray.opacity(0.1) : Color.clear)
                            .contentShape(Rectangle())
                            .cornerRadius(10)
                            .onHover { isHovered in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    hoveredManagedShare = isHovered ? share.id : nil
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var systemSharesView: some View {
        VStack {
            HStack {
                Text("System shares must be mounted to appear in this list. Click the + button to add a share to your managed shares.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)

                Button("Refresh", systemImage: "arrow.clockwise", action: refreshSystemShares)
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(.leading, 15)
                    .focusable(false)
                    .foregroundColor(isRefreshButtonHovered ? .accentColor : .primary)
                    .onHover { isHovered in
                        isRefreshButtonHovered = isHovered
                    }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 4)

            Divider()

            ScrollView {
                VStack(spacing: 10) {
                    if systemShares.isEmpty {
                        Text("No system shares found. Mount SMB shares in Finder to make them appear here. You can then add them to your managed shares.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                    } else {
                        ForEach(Array(systemShares.keys.sorted()), id: \.self) { shareName in
                            VStack {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(shareName)
                                            .font(.headline)

                                        if let url = systemShares[shareName] {
                                            Text(url.absoluteString)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }

                                        // Display mount point with verification
                                        if let mountPath = getMountPoint(for: shareName) {
                                            Text("Mount point: \(mountPath)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        } else {
                                            Text("Not currently mounted")
                                                .font(.caption)
                                                .foregroundColor(.red)
                                        }
                                    }

                                    Spacer()

                                    if let url = systemShares[shareName], isShareAlreadyMonitored(url: url) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .padding(.trailing, 4)
                                    } else {
                                        Button(action: {
                                            if let url = systemShares[shareName] {
                                                // Get the actual mount point to pass to addShare
                                                let mountPath = getMountPoint(for: shareName)
                                                let mountPointURL = mountPath != nil ? URL(fileURLWithPath: mountPath!) : nil
                                                addShare(name: shareName, url: url, mountPoint: mountPointURL)
                                            }
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                        .focusable(false)
                                        .foregroundColor(hoveredAddButton == shareName ? .accentColor : .primary)
                                        .onHover { isHovered in
                                            hoveredAddButton = isHovered ? shareName : nil
                                        }
                                    }
                                }
                                .padding(10)
                            }
                            .background(hoveredShare == shareName ? Color.gray.opacity(0.1) : Color.clear)
                            .contentShape(Rectangle())
                            .cornerRadius(10)
                            .onHover { isHovered in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    hoveredShare = isHovered ? shareName : nil
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var generalSettingsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Connection Check Interval")
                    .font(.subheadline)
                    .bold()

                Text("How often to check connection status and reconnect shares (in seconds)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Range: 5-300 seconds (lower values may increase CPU usage)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack {
                    Slider(value: $pollingInterval, in: 5...300, step: 5)
                        .frame(maxWidth: .infinity)
                        .onChange(of: pollingInterval) { _, newValue in
                            if newValue < 5 {
                                pollingInterval = 5
                            } else if newValue > 300 {
                                pollingInterval = 300
                            }
                            shareManager.updatePollingInterval(pollingInterval)
                        }

                    Text("\(Int(pollingInterval))s")
                        .frame(width: 45)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Default Mount Path")
                    .font(.subheadline)
                    .bold()

                Text("Base directory where SMB shares are mounted")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack {
                    TextField("Default mount path", text: $defaultMountPath)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: .infinity)
                        .onChange(of: defaultMountPath) { _, newValue in
                            UserDefaults.standard.set(newValue, forKey: "defaultMountPath")
                        }
                }
            }

            Spacer()

            VStack(alignment: .leading) {
                Text("About Jockey")
                    .font(.subheadline)
                    .bold()

                HStack(spacing: 4) {
                    Text("Version")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(Bundle.main.appVersion)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if !Bundle.main.buildNumber.isEmpty {
                        Text("(\(Bundle.main.buildNumber))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 20)
    }

    private func refreshSystemShares() {
        systemShares = shareManager.getSystemSMBShares()
    }

    private func deleteShares(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            shareManager.removeShare(at: index)
        }
    }

    private func isShareAlreadyMonitored(url: URL) -> Bool {
        shareManager.shares.contains(where: { $0.url.absoluteString == url.absoluteString })
    }

    private func addShare(name: String, url: URL, mountPoint: URL? = nil) {
        _ = shareManager.addShare(name: name, url: url, mountPoint: mountPoint)

        refreshSystemShares()
    }

    private func getMountPoint(for shareName: String) -> String? {
        // First check the configured location
        let standardPath = "\(defaultMountPath)/\(shareName)"
        if FileManager.default.fileExists(atPath: standardPath) {
            return standardPath
        }

        // Then check for alternative locations using mount command output
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/sbin/mount")

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()

            // Add a timeout to prevent hanging
            let timeout = DispatchWorkItem {
                process.terminate()
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + 2.0, execute: timeout)

            process.waitUntilExit()

            // Cancel the timeout since we didn't need it
            timeout.cancel()

            // Check if process was terminated
            if process.terminationStatus != 0 {
                return nil
            }

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                let lines = output.components(separatedBy: "\n")
                for line in lines {
                    // Check if the line contains the share name
                    if line.contains(shareName) && line.contains("smbfs") {
                        // Extract the mount point from the line
                        // Format: //user@server/share on /path (smbfs, ...)
                        let components = line.components(separatedBy: " on ")
                        if components.count >= 2 {
                            let mountPathComponents = components[1].components(separatedBy: " (")
                            if mountPathComponents.count >= 1 {
                                return mountPathComponents[0]
                            }
                        }
                    }
                }
            }
        } catch {
            // Handle error silently
            return nil
        }

        return nil
    }
}

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.second, .minute, .hour, .day], from: self, to: now)

        if let day = components.day, day > 0 {
            return day == 1 ? "1 day ago" : "\(day) days ago"
        } else if let hour = components.hour, hour > 0 {
            return hour == 1 ? "1 hour ago" : "\(hour) hours ago"
        } else if let minute = components.minute, minute > 0 {
            return minute == 1 ? "1 minute ago" : "\(minute) minutes ago"
        } else if let second = components.second, second > 0 {
            return second < 5 ? "just now" : "\(second) seconds ago"
        } else {
            return "just now"
        }
    }
}
