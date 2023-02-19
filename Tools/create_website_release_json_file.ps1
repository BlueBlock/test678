﻿#Requires -Version 4.0
param (
    [string]
    [Parameter(Mandatory=$false)]
    $PreTagName = "",

    [string]
    [Parameter(Mandatory=$true)]
    $TagName,

    [string]
    [Parameter(Mandatory=$true)]
    $ProjectName
)


Write-Output "Begin create_website_release_json_file.ps1"

# determine update channel
if ($env:APPVEYOR_PROJECT_NAME -match "(Nightly)") {
    write-host "UpdateChannel = Nightly"
    $UpdateChannel = "Nightly"
    $ModifiedTagName = "$PreTagName-$TagName-NB"
} elseif ($env:APPVEYOR_PROJECT_NAME -match "(Preview)") {
    write-host "UpdateChannel = Preview"
    $UpdateChannel = "Preview"
    $ModifiedTagName = "v$TagName-PB"
} elseif ($env:APPVEYOR_PROJECT_NAME -match "(Stable)") {
    write-host "UpdateChannel = Stable"
    $UpdateChannel = "Stable"
    $ModifiedTagName = "v" + $TagName.Split("-")[0]
} else {
    $UpdateChannel = ""
}

Set-GitHubContent -OwnerName blueblock -RepositoryName mRemoteNG.github.io  -Path README4.md -CommitMessage 'Adding README.md' -Content '# README' -BranchName main


$buildFolder = Join-Path -Path $PSScriptRoot -ChildPath "..\mRemoteNG\bin\x64\Release" -Resolve -ErrorAction Ignore

if ($UpdateChannel -ne "" -and $buildFolder -ne "") {

    $releaseFolder = Join-Path -Path $PSScriptRoot -ChildPath "..\Release" -Resolve
    $websiteJsonReleaseFile = Join-Path -Path $PSScriptRoot -ChildPath "..\..\mRemoteNG.github.io\_data\releases.json" -Resolve
    $published_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

    # installer
    $msiFile = Get-ChildItem -Path "$buildFolder\*.msi" | Sort-Object LastWriteTime | Select-Object -last 1
    if (![string]::IsNullOrEmpty($msiFile)) {
        $checksum = (Get-FileHash $msiFile -Algorithm SHA512).Hash
        $file_size = (Get-ChildItem $msiFile).Length
        $a = Get-Content $websiteJsonReleaseFile | ConvertFrom-Json
        switch ($UpdateChannel) {
            "Nightly" {
                $GithubTag = "$((Get-Date).ToUniversalTime().ToString("yyyyMMdd"))-$TagName-NB"
                $html_url = "https://github.com/mRemoteNG/mRemoteNG/releases/tag/$GithubTag"
                $browser_download_url = "https://github.com/mRemoteNG/mRemoteNG/releases/download/$GithubTag/$($msiFile.Name)"
                $a.nightlybuild.name = "v$TagName"
                $a.nightlybuild.published_at = $published_at
                $a.nightlybuild.html_url = $html_url
                $a.nightlybuild.assets.installer.browser_download_url = $browser_download_url
                $a.nightlybuild.assets.installer.checksum = $checksum
                $a.nightlybuild.assets.installer.size = $file_size
                break
            }
            "Preview" {
                $GithubTag = "$TagName-PB"
                $html_url = "https://github.com/mRemoteNG/mRemoteNG/releases/tag/$GithubTag"
                $browser_download_url = "https://github.com/mRemoteNG/mRemoteNG/releases/download/$GithubTag/$($msiFile.Name)"
                $a.prerelease.name = "v$TagName"
                $a.prerelease.published_at = $published_at
                $a.prerelease.html_url = $html_url
                $a.prerelease.assets.installer.browser_download_url = $browser_download_url
                $a.prerelease.assets.installer.checksum = $checksum
                $a.prerelease.assets.installer.size = $file_size
                break
            }
            "Stable" {
                $GithubTag = "$TagName"
                $html_url = "https://github.com/mRemoteNG/mRemoteNG/releases/tag/$GithubTag"
                $browser_download_url = "https://github.com/mRemoteNG/mRemoteNG/releases/download/$GithubTag/$($msiFile.Name)"
                $a.stable.name = "v$TagName"
                $a.stable.published_at = $published_at
                $a.stable.html_url = $html_url
                $a.stable.assets.installer.browser_download_url = $browser_download_url
                $a.stable.assets.installer.checksum = $checksum
                $a.stable.assets.installer.size = $file_size
                break
            }
        }
    }

    # https://github.com/BlueBlock/mRemoteNG/releases/tag/20230218-1.77.3.405-NB
    # https://github.com/mRemoteNG/mRemoteNG/releases/download//mRemoteNG-Installer-1.77.3.405.msi


    # portable
    $zipFile = Get-ChildItem -Path "$releaseFolder\*.zip" -Exclude "*-symbols-*.zip" | Sort-Object LastWriteTime | Select-Object -last 1
    if (![string]::IsNullOrEmpty($zipFile)) {
        $checksum = (Get-FileHash $zipFile -Algorithm SHA512).Hash
        $file_size = (Get-ChildItem $zipFile).Length
        $a = Get-Content $websiteJsonReleaseFile | ConvertFrom-Json
        switch ($UpdateChannel) {
            "Nightly" {
                $GithubTag = "$((Get-Date).ToUniversalTime().ToString("yyyyMMdd"))-$TagName-NB"
                $html_url = "https://github.com/mRemoteNG/mRemoteNG/releases/tag/$GithubTag"
                $browser_download_url = "https://github.com/mRemoteNG/mRemoteNG/releases/download/$GithubTag/$($zipFile.Name)"
                $a.nightlybuild.name = "v$TagName"
                $a.nightlybuild.published_at = $published_at
                $a.nightlybuild.html_url = $html_url
                $a.nightlybuild.assets.portable.browser_download_url = $browser_download_url
                $a.nightlybuild.assets.portable.checksum = $checksum
                $a.nightlybuild.assets.portable.size = $file_size
                break
            }
            "Preview" {
                $GithubTag = "$TagName-PB"
                $html_url = "https://github.com/mRemoteNG/mRemoteNG/releases/tag/$GithubTag"
                $browser_download_url = "https://github.com/mRemoteNG/mRemoteNG/releases/download/$GithubTag/$($zipFile.Name)"
                $a.prerelease.name = "v$TagName"
                $a.prerelease.published_at = $published_at
                $a.prerelease.html_url = $html_url
                $a.prerelease.assets.portable.browser_download_url = $browser_download_url
                $a.prerelease.assets.portable.checksum = $checksum
                $a.prerelease.assets.portable.size = $file_size
                break
            }
            "Stable" {
                $GithubTag = "$TagName"
                $html_url = "https://github.com/mRemoteNG/mRemoteNG/releases/tag/$GithubTag"
                $browser_download_url = "https://github.com/mRemoteNG/mRemoteNG/releases/download/$GithubTag/$($zipFile.Name)"
                $a.stable.name = "v$TagName"
                $a.stable.published_at = $published_at
                $a.stable.html_url = $html_url
                $a.stable.assets.portable.browser_download_url = $browser_download_url
                $a.stable.assets.portable.checksum = $checksum
                $a.stable.assets.portable.size = $file_size
                break
            }
        }
    }

    $a | ConvertTo-Json -Depth 10 | set-content $websiteJsonReleaseFile

} else {
    write-host "BuildFolder not found"
}

Write-Output "End create_website_release_json_file.ps1"
