//
//  jockeyApp.swift
//  jockey
//
//  Created by Ben Tindall on 26/03/2025.
//

import SwiftUI
import Foundation

@main
struct jockeyApp: App {
    @StateObject private var shareManager = SMBShareManager()

    init() {
        Logger.shared.setLoggingEnabled(true)

        logInfo("Jockey app starting...")
        logInfo("Attempting to reconnect all configured shares during startup...")
    }

    var body: some Scene {
        MenuBarExtra("", systemImage: "externaldrive.connected.to.line.below.fill") {
            // When using .menu style, use simple views that translate to native menu items
            // Title (non-interactive)
            Text("Jockey")
                .font(.headline)

            Divider()

            // Shares section
            if shareManager.shares.isEmpty {
                Text("No shares configured")
                    .foregroundColor(.secondary)
            } else {
                ForEach(shareManager.shares) { share in
                    if share.isConnected {
                        Text("\(share.name) • \(share.url.absoluteString ?? "") • \(share.mountPoint?.path ?? "/Volumes/\(share.name)")")
                            .foregroundColor(.primary)
                    } else {
                        Button {
                            shareManager.mountShare(share)
                        } label: {
                            Text("\(share.name) • \(share.url.host ?? "")")
                        }
                    }
                }
            }

            Divider()

            Button("Refresh") {
                shareManager.checkConnectionStatus()
            }
            .keyboardShortcut("r")

            SettingsLink {
                Text("Settings...")
            }
            .keyboardShortcut(",")

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .menuBarExtraStyle(.menu)

        Settings {
            SettingsView()
                .environmentObject(shareManager)
        }
    }
}
