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
                        Button(action: {}) {
                            HStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(share.name)

                                    HStack(spacing: 4) {
                                        Text(share.url.absoluteString)
                                            .font(.caption)
                                            .foregroundColor(.secondary)

                                        Text(share.formattedConnectionTime.isEmpty ? "" : "(\(share.formattedConnectionTime))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .disabled(true)
                    } else {
                        Button {
                            shareManager.mountShare(share)
                        } label: {
                            HStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(share.name)
                                    Text(share.url.absoluteString)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
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
