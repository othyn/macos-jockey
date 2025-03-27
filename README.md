# Jockey

Jockey is a simple macOS menu bar app that helps keep your SMB shares mounted and connected, preventing the common issue of shares getting disconnected.

## Features

- **Menu Bar Integration**: Runs silently in the menu bar with minimal resource usage
- **Connection Status**: Shows a green indicator for active connections with uptime
- **Auto-reconnect**: Automatically attempts to reconnect to configured shares when they disconnect
- **System Integration**: Can import your existing system SMB mounts
- **Custom Mounting**: Configure custom SMB shares with specific mount points

## How It Works

Jockey regularly checks the connection status of your configured SMB shares and attempts to reconnect them if they disconnect. It uses native macOS APIs to interact with the file system and maintains a persistent list of your shares.

## Requirements

- macOS 11.0 or later
- Access to SMB shares on your network

## Setup

1. Launch the app, and it will appear in your menu bar
2. Click the menu bar icon and select "Settings"
3. Add SMB shares either from your system mounts or manually
4. Jockey will keep an eye on your connections and ensure they stay mounted

## Permissions

Jockey requires the following permissions to function properly:

- Network access to connect to shares
- File system access to mount and monitor shares
- The ability to run in the background
