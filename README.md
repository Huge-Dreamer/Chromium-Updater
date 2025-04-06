# Chromium-Updater 🔄

A PowerShell script to automatically check and update UnGoogled Chromium for Windows. Handles process termination, version comparison, installer download, and privileged installation. Keep your privacy-focused browser up-to-date effortlessly.

## Features

- Automatically checks for new UnGoogled Chromium releases
- Closes running Chromium processes safely
- Compares installed vs. latest versions
- Downloads and installs updates with system-level privileges
- Automatic cleanup of installer files
- Administrative rights verification

## Prerequisites

- Windows 10/11
- PowerShell 5.1 or newer
- Administrative privileges

## Installation

1. Clone repository or download `Chromium-Updater.ps1`
```powershell
git clone https://github.com/Huge-Dreamer/Chromium-Updater.git
```

## Usage

1. Run PowerShell as Administrator
2. Execute the script:
```powershell
.\Chromium-Updater.ps1
```
3. Follow on-screen prompts

The script will:
1. Check current installation
2. Compare with GitHub release
3. Download and install if newer version exists
4. Restart Chromium automatically

## License

[MIT License](LICENSE)

## Disclaimer

⚠️ This is an unofficial project not affiliated with Ungoogled Chromium developers.  
    Use at your own risk. Always verify scripts from untrusted sources.
