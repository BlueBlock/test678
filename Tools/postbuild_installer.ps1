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

Install-Module -Name PowerShellForGitHub
$PSDefaultParameterValues["*-GitHub*:AccessToken"] = "$env:auth_token"

& "$PSScriptRoot\sign_binaries.ps1" -TargetDir $TargetDir -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword -ConfigurationName $ConfigurationName -Exclude $ExcludeFromSigning -SolutionDir $SolutionDir
& "$PSScriptRoot\verify_binary_signatures.ps1" -TargetDir $TargetDir -ConfigurationName $ConfigurationName -CertificatePath $CertificatePath -SolutionDir $SolutionDir
& "$PSScriptRoot\rename_and_copy_installer.ps1" -SolutionDir $SolutionDir -BuildConfiguration $ConfigurationName.Trim()
& "$PSScriptRoot\create_upg_chk_files.ps1" -PreTagName $env:NightlyBuildTagName -TagName $env:APPVEYOR_BUILD_VERSION -ProjectName $env:APPVEYOR_PROJECT_NAME
& "$PSScriptRoot\create_website_release_json_file.ps1" -PreTagName $env:NightlyBuildTagName -TagName $env:APPVEYOR_BUILD_VERSION -ProjectName $env:APPVEYOR_PROJECT_NAME
