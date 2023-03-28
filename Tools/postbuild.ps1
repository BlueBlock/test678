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
Write-Output "|             Beginning mRemoteNG Post Build                 |"
Write-Output "+===========================================================================================+"
Format-Table -AutoSize -Wrap -InputObject @{
    "SolutionDir" = $SolutionDir
    "TargetDir" = $TargetDir
    "TargetFileName" = $TargetFileName
    "ConfigurationName" = $ConfigurationName
    "CertificatePath" = $CertificatePath
    "ExcludeFromSigning" = $ExcludeFromSigning
}


$dstPath = "$($SolutionDir)Release"
New-Item -Path $dstPath -ItemType Directory -Force

# $RunInstaller = $TargetDir -match "\\mRemoteNGInstaller\\Installer\\bin\\"
# $RunPortable = ( ($Targetdir -match "\\mRemoteNG\\bin\\") -and -not ($TargetDir -match "\\mRemoteNGInstaller\\Installer\\bin\\") )

write-host "ConfigurationName: $ConfigurationName"

if ( [string]::IsNullOrEmpty($env:IS_CI_BUILD).ToUpper() -eq "TRUE" ) {

    Write-Output "-Begin Release CI"

    & "$PSScriptRoot\postbuild_installer.ps1" -SolutionDir "$(SolutionDir)\" -TargetDir "$(TargetDir)\" -TargetFileName "mRemoteNG.exe" -ConfigurationName "$(ConfigurationName)" -CertificatePath "$(CertPath)" -CertificatePassword "$(CertPassword)" -ExcludeFromSigning "PuTTYNG.exe"

    Write-Output "-End Release CI"

} else {

    Write-Output "-Begin Release Portable"

    & "$PSScriptRoot\tidy_files_for_release.ps1" -TargetDir $TargetDir -ConfigurationName $ConfigurationName

    & "$PSScriptRoot\sign_binaries.ps1" -TargetDir $TargetDir -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword -ConfigurationName $ConfigurationName -Exclude $ExcludeFromSigning -SolutionDir $SolutionDir

    & "$PSScriptRoot\verify_binary_signatures.ps1" -TargetDir $TargetDir -ConfigurationName $ConfigurationName -CertificatePath $CertificatePath -SolutionDir $SolutionDir

    & "$PSScriptRoot\zip_files.ps1" -SolutionDir $SolutionDir -TargetDir $TargetDir -ConfigurationName $ConfigurationName

    if ( ![string]::IsNullOrEmpty($env:WEBSITE_TARGET_OWNER) -and ![string]::IsNullOrEmpty($env:WEBSITE_TARGET_REPOSITORY) ) {

        & "$PSScriptRoot\create_upg_chk_files.ps1" -WebsiteTargetOwner $env:WEBSITE_TARGET_OWNER -WebsiteTargetRepository $env:WEBSITE_TARGET_REPOSITORY -PreTagName $env:NightlyBuildTagName -TagName $env:APPVEYOR_BUILD_VERSION -ProjectName $env:APPVEYOR_PROJECT_NAME

        & "$PSScriptRoot\update_and_upload_website_release_json_file.ps1" -WebsiteTargetOwner $env:WEBSITE_TARGET_OWNER -WebsiteTargetRepository $env:WEBSITE_TARGET_REPOSITORY -PreTagName $env:NightlyBuildTagName -TagName $env:APPVEYOR_BUILD_VERSION -ProjectName $env:APPVEYOR_PROJECT_NAME
    }

    Write-Output "-End Release Portable"
}

# write-host "RunInstaller: $RunInstaller"
# write-host (Test-Path -Path "$($SolutionDir)mRemoteNGInstaller\Installer\bin\x64\Release")
# write-host "RunPortable: $RunPortable"
# write-host (Test-Path -Path "$($SolutionDir)mRemoteNG\bin\x64\Release")

# if ($RunInstaller) {

#     Write-Output "-Begin Release Installer"

#     & "$PSScriptRoot\sign_binaries.ps1" -TargetDir $TargetDir -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword -ConfigurationName $ConfigurationName -Exclude $ExcludeFromSigning -SolutionDir $SolutionDir

#     & "$PSScriptRoot\verify_binary_signatures.ps1" -TargetDir $TargetDir -ConfigurationName $ConfigurationName -CertificatePath $CertificatePath -SolutionDir $SolutionDir

#     & "$PSScriptRoot\rename_and_copy_installer.ps1" -SolutionDir $SolutionDir -BuildConfiguration $ConfigurationName.Trim()

#     if ( ![string]::IsNullOrEmpty($env:WEBSITE_TARGET_OWNER) -and ![string]::IsNullOrEmpty($env:WEBSITE_TARGET_REPOSITORY) ) {

#         & "$PSScriptRoot\create_upg_chk_files.ps1" -WebsiteTargetOwner $env:WEBSITE_TARGET_OWNER -WebsiteTargetRepository $env:WEBSITE_TARGET_REPOSITORY -PreTagName $env:NightlyBuildTagName -TagName $env:APPVEYOR_BUILD_VERSION -ProjectName $env:APPVEYOR_PROJECT_NAME

#         & "$PSScriptRoot\update_and_upload_website_release_json_file.ps1" -WebsiteTargetOwner $env:WEBSITE_TARGET_OWNER -WebsiteTargetRepository $env:WEBSITE_TARGET_REPOSITORY -PreTagName $env:NightlyBuildTagName -TagName $env:APPVEYOR_BUILD_VERSION -ProjectName $env:APPVEYOR_PROJECT_NAME

#         & "$PSScriptRoot\update_and_upload_assemblyinfocs.ps1" -WebsiteTargetOwner $env:WEBSITE_TARGET_OWNER -WebsiteTargetRepository $env:WEBSITE_TARGET_REPOSITORY -PreTagName $env:NightlyBuildTagName -TagName $env:APPVEYOR_BUILD_VERSION -ProjectName $env:APPVEYOR_PROJECT_NAME
#     }

#     Write-Output "-End Release Installer"
# }

# if ($RunPortable) {

#     Write-Output "-Begin Release Portable"

#     & "$PSScriptRoot\tidy_files_for_release.ps1" -TargetDir $TargetDir -ConfigurationName $ConfigurationName

#     & "$PSScriptRoot\zip_files.ps1" -SolutionDir $SolutionDir -TargetDir $TargetDir -ConfigurationName $ConfigurationName

#     if ( ![string]::IsNullOrEmpty($env:WEBSITE_TARGET_OWNER) -and ![string]::IsNullOrEmpty($env:WEBSITE_TARGET_REPOSITORY) ) {

#         & "$PSScriptRoot\create_upg_chk_files.ps1" -WebsiteTargetOwner $env:WEBSITE_TARGET_OWNER -WebsiteTargetRepository $env:WEBSITE_TARGET_REPOSITORY -PreTagName $env:NightlyBuildTagName -TagName $env:APPVEYOR_BUILD_VERSION -ProjectName $env:APPVEYOR_PROJECT_NAME

#         & "$PSScriptRoot\update_and_upload_website_release_json_file.ps1" -WebsiteTargetOwner $env:WEBSITE_TARGET_OWNER -WebsiteTargetRepository $env:WEBSITE_TARGET_REPOSITORY -PreTagName $env:NightlyBuildTagName -TagName $env:APPVEYOR_BUILD_VERSION -ProjectName $env:APPVEYOR_PROJECT_NAME
#     }

#     Write-Output "-End Release Portable"
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


Write-Output "End mRemoteNG Post Build"
Write-Output ""
