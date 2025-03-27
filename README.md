# Jockey

Jockey is a macOS menu bar utility that helps keep your SMB network shares mounted and connected, preventing the common issue of disconnections that can disrupt your workflow.

Designed as an Open Source alternative to [AutoMounter](https://www.pixeleyes.co.nz/automounter/).

## Features

- **Menu Bar Integration**: Runs efficiently in the menu bar with minimal resource usage
- **Connection Status**: Shows connection status and uptime for all configured shares
- **Auto-reconnect**: Automatically attempts to reconnect shares when they disconnect
- **Configurable Polling**: Set how frequently Jockey checks connection status
- **Custom Mount Points**: Configure shares with specific mount points
- **System Integration**: Detects existing system SMB mounts

## How It Works

Jockey regularly checks the connection status of your configured SMB shares at your specified polling interval and attempts to reconnect them if they become disconnected. It uses native macOS APIs to interact with the file system and maintains a persistent list of your shares.

## Requirements

- macOS 14.0 or later (14 Sonoma, 15 Sequoia)
- Access to SMB shares on your network

## Usage

1. Launch Jockey, and it will appear in your menu bar
2. Click the menu bar icon to see the status of your shares
3. Open Settings to add or manage SMB shares
4. Adjust the polling interval to control how often Jockey checks your connections

## Technical Details

- Written in SwiftUI for modern macOS integration
- Locally stores share configuration in user preferences
- Efficient polling system to minimize resource usage
- Compatible with custom SMB authentication

## Permissions

Jockey requires the following permissions to function properly:

- Network access to connect to shares
- File system access to mount and monitor shares
- The ability to run in the background
