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
    $msiFile = Get-ChildItem -Path "$buildFolder\*.msi" | Sort-Object LastWriteTime | Select-Object -last 1
    if (![string]::IsNullOrEmpty($msiFile)) {
        $msiUpdateContents = New-MsiUpdateFileContent -MsiFile $msiFile -TagName $TagName
        $msiUpdateFileName = Resolve-UpdateCheckFileName -UpdateChannel $UpdateChannel -Type Normal
        Write-Output "`n`nMSI Update Check File Contents ($msiUpdateFileName)`n------------------------------"
        Tee-Object -InputObject $msiUpdateContents -FilePath "$releaseFolder\$msiUpdateFileName"
        write-host "msiUpdateFileName $releaseFolder\$msiUpdateFileName"        
    }

    # build zip update file
    $releaseFolder = Join-Path -Path $PSScriptRoot -ChildPath "..\Release" -Resolve
    $zipFile = Get-ChildItem -Path "$releaseFolder\*.zip" -Exclude "*-symbols-*.zip" | Sort-Object LastWriteTime | Select-Object -last 1
    if (![string]::IsNullOrEmpty($zipFile)) {

        Write-Output "---------------"
        Write-Output $ProjectName
        Write-Output "v$TagName"
        Write-Output (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        Write-Output "https://github.com/mRemoteNG/mRemoteNG/releases/tag/v$TagName"
        Write-Output "dURL: https://github.com/mRemoteNG/mRemoteNG/releases/download/v$TagName/$($zipFile.Name)"
        Write-Output "clURL: https://raw.githubusercontent.com/mRemoteNG/mRemoteNG/v$TagName/CHANGELOG.md"
        Write-Output "---------------"

        
        # $pathToJson = "C:\projects\mRemoteNG.github.io\_data\releases.json"        
        # $pathToNewJson = "C:\projects\releasesNew.json"
        # $a = Get-Content $pathToJson | ConvertFrom-Json
        # $a = $body | ConvertFrom-Json

        # $i = Get-Content "$buildFolder\nightly-update-portable.txt"
        # $p = Get-Content "$buildFolder\nightly-update-portable.txt"

        # $a.nightlybuild.name = $i[0].Replace("Version: ", "v")
        # $a.nightlybuild.published_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        # $a.nightlybuild.html_url = "https://github.com/mRemoteNG/mRemoteNG/releases/tag/$env:APPVEYOR_REPO_TAG_NAME" 

        # $a.nightlybuild.assets.installer.browser_download_url = $i[1].Replace("dURL: ", "")
        # $a.nightlybuild.assets.portable.browser_download_url = $i[4].Replace("Checksum: ", "")

        # $a | ConvertTo-Json -Depth 10 | set-content $pathToNewJson

        # Get-Content $a
        #Get-Content $pathToNewJson


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
