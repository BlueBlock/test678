[CmdletBinding()]

param (
    [string]
    # Name of the file to find
    $FileName
)



function EditBinCertificateIsValid() {
    param (
        [string]
        $Path
    )

    # Verify file certificate
    $valid_microsoft_cert_thumbprints = @(
        "3BDA323E552DB1FDE5F4FBEE75D6D5B2B187EEDC",
        "98ED99A67886D020C564923B7DF25E9AC019DF26",
        "108E2BA23632620C427C570B6D9DB51AC31387FE",
        "5EAD300DC7E4D637948ECB0ED829A072BD152E17",
        "97221B97098F37A135DCC212E2B41E452BCE51F2"
    )
    $file_signature = Get-AuthenticodeSignature -FilePath $Path
    write-host "Path: $Path"
    Write-Host "file_signature.SignerCertificate.Thumbprint: $($file_signature.SignerCertificate.Thumbprint)"
    if (($file_signature.Status -ne "Valid") -or ($valid_microsoft_cert_thumbprints -notcontains $file_signature.SignerCertificate.Thumbprint)) {
        Write-Warning "Could not validate the signature of $Path"
        return $false
    } else {
        return $true
    }
}


function ToolCanBeExecuted {
    param (
        [string]
        $Path
    )
    $null = & $Path
    Write-Output ($LASTEXITCODE -gt 0)
}

$rootSearchPaths = @(
    [System.IO.Directory]::EnumerateFileSystemEntries("C:\Program Files", "*Visual Studio*", [System.IO.SearchOption]::TopDirectoryOnly),
    [System.IO.Directory]::EnumerateFileSystemEntries("C:\Program Files (x86)", "*Visual Studio*", [System.IO.SearchOption]::TopDirectoryOnly)
)

# Returns the first full path to the $FileName that our search can find
foreach ($searchPath in $rootSearchPaths) {
    Write-Host "searchPath: $searchPath"
    foreach ($visualStudioFolder in $searchPath) {
        Write-Verbose "Searching in folder '$visualStudioFolder'"
        Write-Host "Searching in folder '$visualStudioFolder'"
        Write-Host "$FileName"
        $matchingExes = [System.IO.Directory]::EnumerateFileSystemEntries($visualStudioFolder, $FileName, [System.IO.SearchOption]::AllDirectories)
        foreach ($matchingExe in $matchingExes) {
            Write-Host "Match found"
            write-host "visualStudioFolder: $visualStudioFolder"
            if ((ToolCanBeExecuted -Path $matchingExe)) {
                write-host "can be executed: $matchingExe"
            }
            if ((EditBinCertificateIsValid -Path $matchingExe)) {
                write-host "cert is valid: $matchingExe"
            }
            if ((EditBinCertificateIsValid -Path $matchingExe) -and (ToolCanBeExecuted -Path $matchingExe)) {
                return $matchingExe
            }
        }
    }
}

Write-Error "Could not find any valid file by the name $FileName." -ErrorAction Stop