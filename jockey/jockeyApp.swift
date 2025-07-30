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
            Text("Jockey • \(Bundle.main.appVersion) (\(Bundle.main.buildNumber))")
                .font(.headline)

            Divider()

            // Shares section
            if shareManager.shares.isEmpty {
                Text("No shares configured")
                    .foregroundColor(.secondary)
            } else {
                ForEach(shareManager.shares) { share in
                    if share.isConnected {
                        HStack {
                            Text("\(share.displayName) • Connected for \(share.formattedConnectionTime)")
                            Text("\(share.url.absoluteString) • \(share.mountPoint?.path ?? "/Volumes/\(share.name)")")
                        }
                    } else {
                        Button {
                            shareManager.mountShare(share)
                        } label: {
                            Text("\(share.displayName) • \(share.url.host ?? "")")
                        }
                    }

                    Divider()
                }
            }

            // Divider()

            // Button("Refresh connections") {
            //     shareManager.checkConnectionStatus()
            // }
            // .keyboardShortcut("r")

            SettingsLink {
                Text("Configure...")
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
        .windowLevel(.floating)
    }
}
