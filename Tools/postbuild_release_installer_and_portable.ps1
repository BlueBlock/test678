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

write-host "ConfigurationName: $ConfigurationName"
if ($ConfigurationName -eq "Release Installer") {

}

# Write-Output ""
# Write-Output "+===========================================================================================+"
# Write-Output "|             Beginning mRemoteNG Release Installer and Portable Post Build                 |"
# Write-Output "+===========================================================================================+"
# Format-Table -AutoSize -Wrap -InputObject @{
#     "SolutionDir" = $SolutionDir
#     "TargetDir" = $TargetDir
#     "TargetFileName" = $TargetFileName
#     "ConfigurationName" = $ConfigurationName
#     "CertificatePath" = $CertificatePath
#     "ExcludeFromSigning" = $ExcludeFromSigning
# }

# Write-Output "-Begin Release Installer"

# & "$PSScriptRoot\sign_binaries.ps1" -TargetDir $TargetDir -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword -ConfigurationName $ConfigurationName -Exclude $ExcludeFromSigning -SolutionDir $SolutionDir

# & "$PSScriptRoot\verify_binary_signatures.ps1" -TargetDir $TargetDir -ConfigurationName $ConfigurationName -CertificatePath $CertificatePath -SolutionDir $SolutionDir

# & "$PSScriptRoot\rename_and_copy_installer.ps1" -SolutionDir $SolutionDir -BuildConfiguration $ConfigurationName.Trim()

# if ( ![string]::IsNullOrEmpty($env:WEBSITE_TARGET_OWNER) -and ![string]::IsNullOrEmpty($env:WEBSITE_TARGET_REPOSITORY) ) {

#     & "$PSScriptRoot\create_upg_chk_files.ps1" -WebsiteTargetOwner $env:WEBSITE_TARGET_OWNER -WebsiteTargetRepository $env:WEBSITE_TARGET_REPOSITORY -PreTagName $env:NightlyBuildTagName -TagName $env:APPVEYOR_BUILD_VERSION -ProjectName $env:APPVEYOR_PROJECT_NAME

#     & "$PSScriptRoot\update_and_upload_website_release_json_file.ps1" -WebsiteTargetOwner $env:WEBSITE_TARGET_OWNER -WebsiteTargetRepository $env:WEBSITE_TARGET_REPOSITORY -PreTagName $env:NightlyBuildTagName -TagName $env:APPVEYOR_BUILD_VERSION -ProjectName $env:APPVEYOR_PROJECT_NAME
# }

# Write-Output "-End Release Installer"


# Write-Output "-Begin Release Portable"

# & "$PSScriptRoot\tidy_files_for_release.ps1" -TargetDir $TargetDir -ConfigurationName $ConfigurationName

# & "$PSScriptRoot\zip_files.ps1" -SolutionDir $SolutionDir -TargetDir $TargetDir -ConfigurationName $ConfigurationName

# if ( ![string]::IsNullOrEmpty($env:WEBSITE_TARGET_OWNER) -and ![string]::IsNullOrEmpty($env:WEBSITE_TARGET_REPOSITORY) ) {

#     & "$PSScriptRoot\create_upg_chk_files.ps1" -WebsiteTargetOwner $env:WEBSITE_TARGET_OWNER -WebsiteTargetRepository $env:WEBSITE_TARGET_REPOSITORY -PreTagName $env:NightlyBuildTagName -TagName $env:APPVEYOR_BUILD_VERSION -ProjectName $env:APPVEYOR_PROJECT_NAME

#     & "$PSScriptRoot\update_and_upload_website_release_json_file.ps1" -WebsiteTargetOwner $env:WEBSITE_TARGET_OWNER -WebsiteTargetRepository $env:WEBSITE_TARGET_REPOSITORY -PreTagName $env:NightlyBuildTagName -TagName $env:APPVEYOR_BUILD_VERSION -ProjectName $env:APPVEYOR_PROJECT_NAME

# }

# Write-Output "-End Release Portable"

# Write-Output "End mRemoteNG Release Installer and Portable Post Build"
# Write-Output ""
