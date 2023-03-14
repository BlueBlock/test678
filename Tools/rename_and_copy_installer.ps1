param (
    [string]
    $SolutionDir,
    [string]
    $BuildConfiguration
)

Write-Output "===== Beginning rename_and_copy_installer.ps1 ====="

$targetVersionedFile = "$SolutionDir\mRemoteNG\bin\x64\$BuildConfiguration\mRemoteNG.exe"
#$fileversion = &"$SolutionDir\Tools\exes\sigcheck.exe" /accepteula -q -n $targetVersionedFile
$prodversion = ((Get-Item -Path $targetVersionedFile).VersionInfo | Select-Object -Property ProductVersion)."ProductVersion"
$fileversion = ((Get-Item -Path $targetVersionedFile).VersionInfo | Select-Object -Property FileVersion)."FileVersion"
$msiversion = $fileversion
if ($prodversion.Contains("Nightly")) {
    $msiversion = "$msiversion-NB"
} elseif ($prodversion.Contains("Preview")) {

    $msiversion = "$msiversion-PB"
}
$src = $SolutionDir + "mRemoteNGInstaller\Installer\bin\x64\$BuildConfiguration\en-US\mRemoteNG-Installer.msi"
$dst = $SolutionDir + "mRemoteNG\bin\x64\$BuildConfiguration\mRemoteNG-Installer-" + $msiversion + ".msi"

# Copy file
Write-Host $prodversion
Write-Host $fileversion
Write-Host $msiversion
Write-Host $src
Write-Host $dst
Copy-Item $src -Destination $dst -Force
