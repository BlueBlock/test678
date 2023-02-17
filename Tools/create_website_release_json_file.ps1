#Requires -Version 4.0
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


Write-Output "Begin create_website_release_json_file.ps1"

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

if ($UpdateChannel -ne "" -and $buildFolder -ne "") {

    $releaseFolder = Join-Path -Path $PSScriptRoot -ChildPath "..\Release" -Resolve
    $websiteJsonReleaseFile = Join-Path -Path $PSScriptRoot -ChildPath "..\..\mRemoteNG.github.io\_data\releases.json" -Resolve
    $GithubTag = "$((Get-Date).ToUniversalTime().ToString("yyyy.MM.dd"))-$TagName"
    $published_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $html_url = "https://github.com/mRemoteNG/mRemoteNG/releases/tag/$GithubTag"
    $change_log = "https://raw.githubusercontent.com/mRemoteNG/mRemoteNG/$GithubTag/CHANGELOG.md"

    Get-Content $websiteJsonReleaseFile

    # installer
    $msiFile = Get-ChildItem -Path "$buildFolder\*.msi" | Sort-Object LastWriteTime | Select-Object -last 1
    if (![string]::IsNullOrEmpty($msiFile)) {
        $browser_download_url = "https://github.com/mRemoteNG/mRemoteNG/releases/download/$GithubTag/$($msiFile.Name)"
        $change_log = "clURL: https://raw.githubusercontent.com/mRemoteNG/mRemoteNG/$GithubTag/CHANGELOG.md"
        $checksum = (Get-FileHash $msiFile -Algorithm SHA512).Hash
        $file_size = (Get-ChildItem $msiFile).Length

        $a = Get-Content $websiteJsonReleaseFile | ConvertFrom-Json

        switch ($UpdateChannel) {
            "Nightly" {$b = $a.nightlybuild; break}
            "Preview" {$b = $a.prerelease; break}
            "Stable"  {$b = $a.stable; break}
        }

        $b.name = "v$TagName"
        $b.published_at = $published_at
        $b.html_url = $html_url
        $b.assets.installer.browser_download_url = $browser_download_url
        $b.assets.installer.checksum = $checksum
        $b.assets.installer.size = $file_size
        $a | ConvertTo-Json -Depth 10 | set-content $websiteJsonReleaseFile

        Get-Content $websiteJsonReleaseFile
    }

    # portable
    $zipFile = Get-ChildItem -Path "$releaseFolder\*.zip" -Exclude "*-symbols-*.zip" | Sort-Object LastWriteTime | Select-Object -last 1
    if (![string]::IsNullOrEmpty($zipFile)) {

        $browser_download_url = "https://github.com/mRemoteNG/mRemoteNG/releases/download/$GithubTag/$($zipFile.Name)"
        $change_log = "clURL: https://raw.githubusercontent.com/mRemoteNG/mRemoteNG/$GithubTag/CHANGELOG.md"
        $checksum = (Get-FileHash $zipFile -Algorithm SHA512).Hash
        $file_size = (Get-ChildItem $zipFile).Length
        
        # switch ($UpdateChannel) {
        #     "Nightly" {$b = $a.nightlybuild; break}
        #     "Preview" {$b = $a.prerelease; break}
        #     "Stable"  {$b = $a.stable; break}
        # }

        # $b.name = "v$TagName"
        # $b.published_at = $published_at
        # $b.html_url = $html_url
        # $b.assets.portable.browser_download_url = $browser_download_url
        # $b.assets.portable.checksum = $checksum
        # $b.assets.portable.size = $file_size
                
        switch ($UpdateChannel) {
            "Nightly" {
                $b.nightlybuild.name = "v$TagName"
                $b.nightlybuild.published_at = $published_at
                $b.nightlybuild.html_url = $html_url
                $b.nightlybuild.assets.portable.browser_download_url = $browser_download_url
                $b.nightlybuild.assets.portable.checksum = $checksum
                $b.nightlybuild.assets.portable.size = $file_size
                break
            }
            "Preview" {
                $b.prerelease.name = "v$TagName"
                $b.prerelease.published_at = $published_at
                $b.prerelease.html_url = $html_url
                $b.prerelease.assets.portable.browser_download_url = $browser_download_url
                $b.prerelease.assets.portable.checksum = $checksum
                $b.prerelease.assets.portable.size = $file_size
                break
            }
            "Stable" {
                $b.stable.name = "v$TagName"
                $b.stable.published_at = $published_at
                $b.stable.html_url = $html_url
                $b.stable.assets.portable.browser_download_url = $browser_download_url
                $b.stable.assets.portable.checksum = $checksum
                $b.stable.assets.portable.size = $file_size
                break
            }
        }


        $a | ConvertTo-Json -Depth 10 | set-content $websiteJsonReleaseFile

        Get-Content $websiteJsonReleaseFile

    }
} else {
    write-host "BuildFolder not found"
}

Write-Output "End create_website_release_json_file.ps1"
