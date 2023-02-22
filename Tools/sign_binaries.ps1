param (
    [string]
    [Parameter(Mandatory=$true)]
    $TargetDir,

    [string]
    [Parameter(Mandatory=$true)]
    $ConfigurationName,

    [string[]]
    # File names to exclude from signing
    $Exclude,

    [string]
    [AllowEmptyString()]
    # The code signing certificate to use when signing the files.
    $CertificatePath,

    [string]
    # Password to unlock the code signing certificate.
    $CertificatePassword,
    
    [string]
    $SolutionDir
)

Write-Output "===== Beginning $($PSCmdlet.MyInvocation.MyCommand) ====="

$timeserver = "http://timestamp.verisign.com/scripts/timstamp.dll"

Write-Output "1"

# $current_path = Get-Location
# Write-Output "aaa: 0a"
# Set-Location "$Env:APPVEYOR_BUILD_FOLDER\..\"
# Write-Output "aaa: 0b"
# #Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/appveyor/secure-file/master/install.ps1'))
# #Invoke-WebRequest "https://raw.githubusercontent.com/appveyor/secure-file/master/install.ps1" | Invoke-Expression
# Write-Output "aaa: 0c"
# Set-Location $current_path
# Write-Output "aaa: 0d"


# decrypt cert if on appveyor
if ($ConfigurationName -match "Release" -And ("$($Env:CERT_PATH).enc")) {
	Write-Output "2"
	if(-Not ([string]::IsNullOrEmpty($Env:APPVEYOR_BUILD_FOLDER)) ) {
		Write-Output "3"
		Write-Output $Env:APPVEYOR_BUILD_FOLDER
		Write-Output "Decrypting cert.."
		Write-Output "......"
		$current_path = Get-Location
		Set-Location "$Env:APPVEYOR_BUILD_FOLDER\..\"
		Write-Output "Get-Location = $(Get-Location)"
		Write-Output "$Env:APPVEYOR_BUILD_FOLDER\..\appveyor-tools\secure-file.exe"
		Write-Output "$($Env:CERT_PATH).enc"
		Write-Output "$Env:APPVEYOR_BUILD_FOLDER\..\appveyor-tools\secure-file.exe -decrypt '$Env:APPVEYOR_BUILD_FOLDER\$($Env:CERT_PATH).enc' "
		Write-Output "......"
		"$Env:APPVEYOR_BUILD_FOLDER\..\appveyor-tools\secure-file.exe -decrypt '$Env:APPVEYOR_BUILD_FOLDER\$($Env:CERT_PATH).enc' -secret '$Env:CERT_DECRYPT_PWD' "
		#$Env:APPVEYOR_BUILD_FOLDER\..\appveyor-tools\secure-file.exe -decrypt "$($Env:CERT_PATH).enc" -secret "$Env:CERT_DECRYPT_PWD"
		$CertificatePath = Join-Path -Path $SolutionDir -ChildPath $CertificatePath
		Set-Location $current_path
	}
}

#  validate release versions and if the certificate value was passed
if ($ConfigurationName -match "Release" -And ($CertificatePath)) {
	Write-Output "2a"
	# make sure the cert is actually available
	if ($CertificatePath -eq "" -or !(Test-Path -Path $CertificatePath -PathType Leaf))
	{
	    Write-Output "Certificate is not present - we won't sign files."
	    return
	}

	if ($CertificatePassword -eq "") {
	    Write-Output "No certificate password was provided - we won't sign files."
	    return
	}

	try {
	    $certKeyStore = [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::MachineKeySet
	    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($CertificatePath, $CertificatePassword, $certKeyStore) -ErrorAction Stop
	} catch {
	    Write-Output "Error loading certificate file - we won't sign files."
	    Write-Output $Error[0]
	    return
	}

	# Sign MSI if we are building a release version and the certificate is available
	Write-Output "Signing Binaries"
	Write-Output "Getting files from path: $TargetDir"
	$signableFiles = Get-ChildItem -Path $TargetDir -Recurse | ?{$_.Extension -match "dll|exe|msi"} | ?{$Exclude -notcontains $_.Name}

	$excluded_files = Get-ChildItem -Path $TargetDir -Recurse | ?{$_.Extension -match "dll|exe|msi"} | ?{$Exclude -contains $_.Name}
	$excluded_files | ForEach-Object `
	    -Begin { Write-Output "The following files were excluded from signing due to being on the exclusion list:" } `
	    -Process { Write-Output "-- $($_.FullName)" }

	Write-Output "Signable files count: $($signableFiles.Count)"


	foreach ($file in $signableFiles) {
	    Set-AuthenticodeSignature -Certificate $cert -TimestampServer $timeserver -IncludeChain all -FilePath $file.FullName
	}


	# Release certificate
	if ($null -ne $cert) {
	    $cert.Dispose()
	}
} else {
    Write-Output "This is not a release build or CertificatePath wasn't provided - we won't sign files."
    Write-Output "Config: $($ConfigurationName)`tCertPath: $($CertificatePath)"
}

Write-Output ""