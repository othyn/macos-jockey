<div align="center">
    <img src="art/icon/Icon-1024.png" alt="logo" width="250" height="auto" />
    <h1>Jockey for macOS</h1>
    <p>A simple SMB (Samba) mount keep-alive menu bar app for macOS Sequoia (15) built with ♥️ in Swift & SwiftUI.</p>
    <p></p>
</div>

<div align="center">
    <p>
        <a href="https://github.com/othyn/macos-jockey/actions/workflows/cicd.yml">
            <img src="https://github.com/othyn/macos-jockey/actions/workflows/cicd.yml/badge.svg" alt="build" />
        </a>
        <a href="https://github.com/othyn/macos-jockey/actions/workflows/swiftlint.yml">
            <img src="https://github.com/othyn/macos-jockey/actions/workflows/swiftlint.yml/badge.svg" alt="lint" />
        </a>
        <a href="https://github.com/othyn/macos-jockey/releases">
            <img src="https://img.shields.io/github/downloads/othyn/macos-jockey/total" alt="lint" />
        </a>
        <a href="https://github.com/othyn/macos-jockey/graphs/contributors">
            <img src="https://img.shields.io/github/contributors/othyn/macos-jockey" alt="contributors" />
        </a>
        <a href="https://github.com/othyn/macos-jockey/network/members">
            <img src="https://img.shields.io/github/forks/othyn/macos-jockey" alt="forks" />
        </a>
        <a href="https://github.com/othyn/macos-jockey/stargazers">
            <img src="https://img.shields.io/github/stars/othyn/macos-jockey" alt="stars" />
        </a>
        <a href="https://github.com/othyn/macos-jockey/issues/">
            <img src="https://img.shields.io/github/issues/othyn/macos-jockey" alt="open issues" />
        </a>
        <a href="https://github.com/othyn/macos-jockey/blob/master/LICENSE">
            <img src="https://img.shields.io/github/license/othyn/macos-jockey.svg" alt="license" />
        </a>
    </p>
</div>

<div align="center">
    <h4>
        <a href="#floppy_disk-download">Download Latest Version</a>
        <span> · </span>
        <a href="https://github.com/othyn/macos-jockey/issues">Report a Bug</a>
        <span> · </span>
        <a href="https://github.com/othyn/macos-jockey/issues">Request a Feature</a>
    </h4>
</div>

<br />

<!-- Table of Contents -->

# :notebook_with_decorative_cover: Table of Contents

- [About the Project](#star2-about-the-project)
  - [Screenshot](#camera-screenshot)
  - [Tech Stack](#space_invader-tech-stack)
  - [Features](#dart-features)
- [Download](#floppy_disk-download)
- [Contributing](#memo-contributing)
- [Changelog](https://github.com/othyn/macos-jockey/releases)
- [License](#warning-license)
- [Acknowledgements](#gem-acknowledgements)

<!-- About the Project -->

## :star2: About the Project

Jockey is a macOS menu bar utility that helps keep your SMB network shares mounted and connected, preventing the common issue of disconnections that can disrupt your workflow, or that aggravating 'Unavailable' on Plex when you've just got into bed.

Designed as an Open Source alternative to [AutoMounter](https://www.pixeleyes.co.nz/automounter/).

<!-- Screenshots -->

### :camera: Screenshot

<div align="center">
    <img alt="screenshot" src="art/screenshot.png" width="70%" />
</div>

<!-- TechStack -->

### :space_invader: Tech Stack

<ul>
    <li>Swift</li>
    <li>Swift UI</li>
</ul>

<!-- Features -->

### :dart: Features

- **Menu Bar Integration**: Runs efficiently in the menu bar with minimal resource usage
- **Connection Status**: Shows connection status and uptime for all configured shares
- **Auto-reconnect**: Automatically attempts to reconnect shares when they disconnect
- **Configurable Polling**: Set how frequently Jockey checks connection status
- **Custom Mount Points**: Configure shares with specific mount points
- **System Integration**: Detects existing system SMB mounts

#### Usage

1. Launch Jockey, and it will appear in your menu bar
2. Click the menu bar icon to see the status of your shares
3. Open Settings to add or manage SMB shares
4. Adjust the polling interval to control how often Jockey checks your connections
5. Accept the prompt to allow Finder permissions, as is required to allow Jockey to mount shares on your behalf

<!-- Download -->

## :floppy_disk: Download

**Download for macOS Sequoia (15) and higher:** [v1.0.1](https://github.com/othyn/macos-jockey/releases/download/v1.0.1/Jockey.zip)

### Using the app for the first time

When first using the app, you will need to right click the app and click 'Open', then on the macOS popup window select 'Open' again to trust this version of the app going forward. This is as at the moment I don't have a paid Apple developer account in order to notarize the app.

#### First time use for macOS Sequoia (15) users

If you are using macOS Sequoia, there are increased barriers in place to stop you running un-notarized apps. To open the app you will need to do the following;

1. Try to open the app, and when presented with the options to 'Move to trash' or otherwise, close out of that prompt:

<div align=center>
    <img width="50%" src="art/ref/0_readme_macOS_error.png"/>
</div>

2. Head over to System Settings > Privacy & Security > Security, and scroll all the way at the bottom, you should see the following:

<div align=center>
    <img width="100%" src="art/ref/1_readme_macOS_settings.png"/>
</div>

3. Click on the 'Open Anyway' button.
4. When prompted with the following dialogue, click 'Open Anyway':

<div align=center>
    <img width="40%" src="art/ref/2_readme_macOS_prompt.png"/>
</div>

5. Head back to the Jockey app and try opening it again, it should now work as normal.
6. When Jockey first attempts to mount a share, it will pop-up and prompt for Finder access, which you will need to grant in order for Jockey to mount shares in your behalf.
    - Alternatively, you can grant Jockey 'Full Disk Access' within System Settings > Privacy & Security, but I will leave that down to your best judgement.

<!-- Contributing -->

## :memo: Contributing

See the [contribution guide](CONTRIBUTING.md) on how to get started. Thank you for contributing!

Detailed within that guide are steps on how...

- ... issues should be used.
- ... to setup the project.
- ... to contribute new languages via the app's localisation support.
- ... branches should be used.
- ... commits should be formatted.
- ... pull requests should be submitted.
- ... the build process works and the automation that drives it.

<!-- License -->

## :warning: License

Distributed under the MIT License. See [LICENSE](https://github.com/othyn/macos-jockey/blob/main/LICENSE) for more information.

<!-- Acknowledgments -->

## :gem: Acknowledgements

Useful resources and libraries that have been used in the making of this project.

- Readme: [shields.io](https://shields.io/)
- Readme: [ikatyang/emoji-cheat-sheet](https://github.com/ikatyang/emoji-cheat-sheet)
- Readme: [Louis3797/awesome-readme-template](https://github.com/Louis3797/awesome-readme-template)
