param (
    [string]
    [Parameter(Mandatory=$true)]
    $SolutionDir,

    [string]
    [Parameter(Mandatory=$true)]
    $TargetDir,

    [string]
    [Parameter(Mandatory=$true)]
    $TargetFileName,

    [string]
    [Parameter(Mandatory=$true)]
    $ConfigurationName,

    [string]
    $CertificatePath,

    [string]
    $CertificatePassword,

    [string[]]
    $ExcludeFromSigning
)

. "$PSScriptRoot\github_functions.ps1"

Write-Output ""
Write-Output "+===========================================================================================+"
Write-Output "|                          Beginning mRemoteNG Installer Post Build                         |"
Write-Output "+===========================================================================================+"
Format-Table -AutoSize -Wrap -InputObject @{
    "SolutionDir" = $SolutionDir
    "TargetDir" = $TargetDir
    "TargetFileName" = $TargetFileName
    "ConfigurationName" = $ConfigurationName
    "CertificatePath" = $CertificatePath
    "ExcludeFromSigning" = $ExcludeFromSigning
}

& "$PSScriptRoot\sign_binaries.ps1" -TargetDir $TargetDir -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword -ConfigurationName $ConfigurationName -Exclude $ExcludeFromSigning -SolutionDir $SolutionDir

& "$PSScriptRoot\verify_binary_signatures.ps1" -TargetDir $TargetDir -ConfigurationName $ConfigurationName -CertificatePath $CertificatePath -SolutionDir $SolutionDir

& "$PSScriptRoot\rename_and_copy_installer.ps1" -SolutionDir $SolutionDir -BuildConfiguration $ConfigurationName.Trim()

if ( ![string]::IsNullOrEmpty($env:WEBSITE_TARGET_OWNER) -and ![string]::IsNullOrEmpty($env:WEBSITE_TARGET_REPOSITORY) ) {

    & "$PSScriptRoot\create_upg_chk_files.ps1" -WebsiteTargetOwner $env:WEBSITE_TARGET_OWNER -WebsiteTargetRepository $env:WEBSITE_TARGET_REPOSITORY -PreTagName $env:NightlyBuildTagName -TagName $env:APPVEYOR_BUILD_VERSION -ProjectName $env:APPVEYOR_PROJECT_NAME

    & "$PSScriptRoot\update_and_upload_website_release_json_file.ps1" -WebsiteTargetOwner $env:WEBSITE_TARGET_OWNER -WebsiteTargetRepository $env:WEBSITE_TARGET_REPOSITORY -PreTagName $env:NightlyBuildTagName -TagName $env:APPVEYOR_BUILD_VERSION -ProjectName $env:APPVEYOR_PROJECT_NAME
}


$env:postbuild_installer_executed -ne "true"
if (!([string]::IsNullOrEmpty($Env:APPVEYOR_BUILD_FOLDER))) {
    New-Item -Path 'HKLM:\Software\AppVeyor_mRemoteNG' -Force;
    Get-Item -Path 'HKLM:\Software\AppVeyor_mRemoteNG' | New-Item -Name 'postbuild_installer_executed' -Force;
    New-ItemProperty -Path 'HKLM:\Software\AppVeyor_mRemoteNG' -Name 'postbuild_installer_executed' -Value "false" -Force
}

Write-Output "End mRemoteNG Installer Post Build"
Write-Output ""
