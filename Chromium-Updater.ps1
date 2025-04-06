# Define variables with new installation path
$executablePath = "C:\Program Files\Chromium\Application\chrome.exe"
$installDir = "C:\Program Files\Chromium"
$repoUrl = "https://api.github.com/repos/ungoogled-software/ungoogled-chromium-windows/releases/latest"

# Check and request admin privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process pwsh "-File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    exit
}

function Close-Chromium {
    Write-Host "Closing Chromium..."
    Get-Process | Where-Object { $_.Name -like "chrome*" } | Stop-Process -Force -ErrorAction SilentlyContinue

    # Wait until all Chromium processes exit
    $maxRetries = 30  # 15 seconds max
    $retryCount = 0
    while ((Get-Process | Where-Object { $_.Name -like "chrome*" }) -and ($retryCount -lt $maxRetries)) {
        Start-Sleep -Milliseconds 500
        $retryCount++
    }

    if ($retryCount -ge $maxRetries) {
        Write-Host "Warning: Chromium might still be running!"
    } else {
        Write-Host "Chromium closed successfully."
    }
}

function Get-InstalledVersion {
    if (Test-Path -Path $executablePath) {
        (Get-Item $executablePath).VersionInfo.ProductVersion
    } else {
        return $null
    }
}

function Get-LatestVersion {
    $response = Invoke-RestMethod -Uri $repoUrl -UseBasicParsing
    $response.tag_name.TrimStart("v") -replace "-.*$", ""
}

function Install-LatestVersion {
    param (
        [string]$latestVersion,
        [string]$downloadUrl
    )

    $exePath = "$env:TEMP\ungoogled-chromium-$latestVersion.exe"

    # Download the installer
    Write-Host "Downloading version $latestVersion..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $exePath

    # Close Chromium before installation
    Close-Chromium

    # Run the installer with admin privileges
    Write-Host "Installing version $latestVersion to Program Files..."
    $installProcess = Start-Process -FilePath $exePath -ArgumentList "--system-level" -Wait -PassThru

    if ($installProcess.ExitCode -ne 0) {
        Write-Host "Installation failed with exit code $($installProcess.ExitCode)"
        return
    }

    # Cleanup installer
    Remove-Item $exePath -Force
    Write-Host "Installed version $latestVersion successfully!"

    # Reopen Chromium
    Start-Process -FilePath $executablePath
    Write-Host "Chromium restarted!"
}

# Main script
$installedVersion = Get-InstalledVersion
$latestVersion = Get-LatestVersion

Write-Host "Installed version: $installedVersion"
Write-Host "Latest version: $latestVersion"

if ($installedVersion -ne $latestVersion) {
    Write-Host "A newer version is available. Proceeding with the update..."

    $response = Invoke-RestMethod -Uri $repoUrl -UseBasicParsing
    $asset = $response.assets | Where-Object { $_.name -like "*_installer_x64.exe" }

    if ($asset) {
        Install-LatestVersion -latestVersion $latestVersion -downloadUrl $asset.browser_download_url
    } else {
        Write-Host "Could not find the EXE installer asset for the latest version."
    }
} else {
    Write-Host "You already have the latest version installed."
}

Read-Host -Prompt "Press Enter to exit"
