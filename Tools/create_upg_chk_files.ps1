﻿#Requires -Version 4.0
param (
    [string]
    [Parameter(Mandatory=$true)]
    $TagName,

    [string]
    [Parameter(Mandatory=$true)]
    $ProjectName
)


function New-MsiUpdateFileContent {
    param (
        [System.IO.FileInfo]
        [Parameter(Mandatory=$true)]
        $MsiFile,

        [string]
        [Parameter(Mandatory=$true)]
        $TagName
    )
    
    $version = $MsiFile.BaseName -replace "[a-zA-Z-]*"
    $certThumbprint = (Get-AuthenticodeSignature -FilePath $MsiFile).SignerCertificate.Thumbprint
    $hash = Get-FileHash -Algorithm SHA512 $MsiFile | % { $_.Hash }

    $fileContents = `
"Version: $version
dURL: https://github.com/mRemoteNG/mRemoteNG/releases/download/$TagName/$($MsiFile.Name)
clURL: https://raw.githubusercontent.com/mRemoteNG/mRemoteNG/$TagName/CHANGELOG.md
CertificateThumbprint: $certThumbprint
Checksum: $hash"
    Write-Output $fileContents
}


function New-ZipUpdateFileContent {
    param (
        [System.IO.FileInfo]
        [Parameter(Mandatory=$true)]
        $ZipFile,

        [string]
        [Parameter(Mandatory=$true)]
        $TagName
    )
    
    $version = $ZipFile.BaseName -replace "[a-zA-Z-]*"
    $hash = Get-FileHash -Algorithm SHA512 $ZipFile | % { $_.Hash }

    $fileContents = `
"Version: $version
dURL: https://github.com/mRemoteNG/mRemoteNG/releases/download/$TagName/$($ZipFile.Name)
clURL: https://raw.githubusercontent.com/mRemoteNG/mRemoteNG/$TagName/CHANGELOG.TXT
Checksum: $hash"
    Write-Output $fileContents
}


function Resolve-UpdateCheckFileName {
    param (
        [string]
        [Parameter(Mandatory=$true)]
        [ValidateSet("Stable","Preview","Nightly")]
        $UpdateChannel,

        [string]
        [Parameter(Mandatory=$true)]
        [ValidateSet("Normal","Portable")]
        $Type
    )

    $fileName = ""

    if ($UpdateChannel -eq "Preview") { $fileName += "preview-" }
    elseif ($UpdateChannel -eq "Nightly") { $fileName += "nightly-" }

    $fileName += "update"

    if ($Type -eq "Portable") { $fileName += "-portable" }

    $fileName += ".txt"

    Write-Output $fileName
}

$body = @'
{
	"stable": {
		"name": "",
		"published_at": "",
		"html_url": "",
		"assets": {
			"installer": {
				"browser_download_url": "",
				"checksum": "",
				"size": 
			},
			"portable": {
				"browser_download_url": "",
				"checksum": "",
				"size": 
			}
		}
	},
    "prerelease": {
		"name": "",
		"published_at": "",
		"html_url": "",
		"assets": {
			"installer": {
				"browser_download_url": "",
				"checksum": "",
				"size": 
			},
			"portable": {
				"browser_download_url": "",
				"checksum": "",
				"size": 
			}
		}
	},
	"nightlybuild": {
		"name": "",
		"published_at": "",
		"html_url": "",
		"assets": {
			"installer": {
				"browser_download_url": "",
				"checksum": "",
				"size": 
			},
			"portable": {
				"browser_download_url": "",
				"checksum": "",
				"size": 
			}
		}
	}
}
'@


Write-Output "Begin create_upg_chk_files.ps1"

# determine update channel
if ($env:APPVEYOR_PROJECT_NAME -match "(Nightly)") {
    write-host "UpdateChannel = Nightly"
    $UpdateChannel = "Nightly"
} elseif ($env:APPVEYOR_PROJECT_NAME -match "(Preview)") {
    write-host "UpdateChannel = Preview"
    $UpdateChannel = "Preview"
} elseif ($env:APPVEYOR_PROJECT_NAME -match "(Stable)") {
    write-host "UpdateChannel = Stable"
    $UpdateChannel = "Stable"
} else {
    $UpdateChannel = ""
}

$buildFolder = Join-Path -Path $PSScriptRoot -ChildPath "..\mRemoteNG\bin\x64\Release" -Resolve -ErrorAction Ignore


# "name": "v1.76.20",
# 		"published_at": "2019-04-12T14:10:45Z",
# 		"html_url": "https://github.com/mRemoteNG/mRemoteNG/releases/tag/v1.76.20",
# 		"assets": {
# 			"installer": {
# 				"browser_download_url": "https://github.com/mRemoteNG/mRemoteNG/releases/download/v1.76.20/mRemoteNG-Installer-1.76.20.24615.msi",
# 				"checksum": "AE7406070F1B4C328C716356A6E1DE3CBA0EAEEAA8F0F490C82073BA511968CF97583D0136B38D69C15EA5C1EF0C41F74A974A7200D13099522867FF6B387338",
# 				"size": 43593728


if ($UpdateChannel -ne "" -and $buildFolder -ne "") {

    $releaseFolder = Join-Path -Path $PSScriptRoot -ChildPath "..\Release" -Resolve
    $websiteJsonReleaseFile = Join-Path -Path $PSScriptRoot -ChildPath "..\..\mRemoteNG.github.io\_data\releases.json" -Resolve
    $GithubTag = "$((Get-Date).ToUniversalTime().ToString("yyyy.MM.dd"))-$TagName"
    $published_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $html_url = "https://github.com/mRemoteNG/mRemoteNG/releases/tag/$GithubTag"
    $change_log = "https://raw.githubusercontent.com/mRemoteNG/mRemoteNG/$GithubTag/CHANGELOG.md"
    
    Write-Output "websiteJsonReleaseFile = $websiteJsonReleaseFile"

    # installer
    $msiFile = Get-ChildItem -Path "$buildFolder\*.msi" | Sort-Object LastWriteTime | Select-Object -last 1
    if (![string]::IsNullOrEmpty($msiFile)) {
        $browser_download_url = "https://github.com/mRemoteNG/mRemoteNG/releases/download/$GithubTag/$($msiFile.Name)"
        $change_log = "clURL: https://raw.githubusercontent.com/mRemoteNG/mRemoteNG/$GithubTag/CHANGELOG.md"
        $hash = (Get-FileHash $msiFile -Algorithm SHA512).Hash
        $file_size = (Get-ChildItem $msiFile).Length
        
    }

    # portable
    $zipFile = Get-ChildItem -Path "$releaseFolder\*.zip" -Exclude "*-symbols-*.zip" | Sort-Object LastWriteTime | Select-Object -last 1
    if (![string]::IsNullOrEmpty($zipFile)) {

        $browser_download_url = "https://github.com/mRemoteNG/mRemoteNG/releases/download/$GithubTag/$($zipFile.Name)"
        $change_log = "clURL: https://raw.githubusercontent.com/mRemoteNG/mRemoteNG/$GithubTag/CHANGELOG.md"
        $hash = (Get-FileHash $zipFile -Algorithm SHA512).Hash
        $file_size = (Get-ChildItem $zipFile).Length
        
        # $pathToJson = "C:\projects\mRemoteNG.github.io\_data\releases.json"        
        # $pathToNewJson = "C:\projects\releasesNew.json"
        $a = Get-Content $websiteJsonReleaseFile | ConvertFrom-Json
        $a = $body | ConvertFrom-Json

        # $i = Get-Content "$buildFolder\nightly-update-portable.txt"
        # $p = Get-Content "$buildFolder\nightly-update-portable.txt"

        $a.nightlybuild.name = "v$TagName"
        $a.nightlybuild.published_at = $published_at
        $a.nightlybuild.html_url = $html_url

        $a.nightlybuild.assets.installer.browser_download_url = $browser_download_url
        $a.nightlybuild.assets.portable.browser_download_url = $hash

        $a | ConvertTo-Json -Depth 10 | set-content $websiteJsonReleaseFile

        # Get-Content $a
        Get-Content $websiteJsonReleaseFile


        $zipUpdateContents = New-ZipUpdateFileContent -ZipFile $zipFile -TagName $TagName
        $zipUpdateFileName = Resolve-UpdateCheckFileName -UpdateChannel $UpdateChannel -Type Portable
        Write-Output "`n`nZip Update Check File Contents ($zipUpdateFileName)`n------------------------------"
        Tee-Object -InputObject $zipUpdateContents -FilePath "$releaseFolder\$zipUpdateFileName"
        write-host "zipUpdateFileName $releaseFolder\$zipUpdateFileName"
    }
} else {
    write-host "BuildFolder not found"
}

Write-Output "End create_upg_chk_files.ps1"
