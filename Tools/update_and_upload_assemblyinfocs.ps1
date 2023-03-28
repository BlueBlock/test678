#Requires -Version 4.0

Write-Output ""
Write-Output "===== Begin $($PSCmdlet.MyInvocation.MyCommand) ====="

$MainRepository = $Env:APPVEYOR_REPO_NAME.Split("/\")[1]

# determine update channel
if ($env:APPVEYOR_PROJECT_NAME -match "(Nightly)") {
    Write-Output "UpdateChannel = Nightly"
    $UpdateChannel = "Nightly"
    $ModifiedTagName = "$PreTagName-$TagName-NB"
} elseif ($env:APPVEYOR_PROJECT_NAME -match "(Preview)") {
    Write-Output "UpdateChannel = Preview"
    $UpdateChannel = "Preview"
    $ModifiedTagName = "v$TagName-PB"
} elseif ($env:APPVEYOR_PROJECT_NAME -match "(Stable)") {
    Write-Output "UpdateChannel = Stable"
    $UpdateChannel = "Stable"
    $ModifiedTagName = "v" + $TagName.Split("-")[0]
} else {
    $UpdateChannel = ""
}

$buildFolder = Join-Path -Path $PSScriptRoot -ChildPath "..\" -Resolve -ErrorAction Ignore
#$ReleaseFolder = Join-Path -Path $PSScriptRoot -ChildPath "..\Release" -Resolve

if ($UpdateChannel -ne "" -and $MainRepository -ne "" ) {

    $published_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    
    # commit AssemblyInfo.cs change
    Write-Output "publish AssemblyInfo.cs"
    Write-Output $buildFolder
    Write-Output (Test-Path -Path "$buildFolder\mRemoteNG")
    Write-Output (Test-Path -Path "$buildFolder\mRemoteNG\Properties")
    Write-Output (Test-Path -Path "$buildFolder\mRemoteNG\Properties\AssemblyInfo.cs")
    Write-Output "publish AssemblyInfo.cs"

    if (Test-Path -Path "$buildFolder\mRemoteNG\Properties\AssemblyInfo.cs") {
        $assemblyinfocs_content = (Get-Content "$buildFolder\mRemoteNG\Properties\AssemblyInfo.cs").ToString()
        #$assemblyinfocs_content = "Testing"
        
        #Set-GitHubContent -OwnerName $MainRepository -RepositoryName $MainRepository -Path "mRemoteNG\Properties\AssemblyInfo.cs" -CommitMessage "AssemblyInfo.cs updated for $UpdateChannel $ModifiedTagName" -Content $assemblyinfocs_content -BranchName main

        Set-GitHubContent -OwnerName "BlueBlock" -RepositoryName "test678" -Path "mRemoteNG\Properties\AssemblyInfo2.txt" -CommitMessage "AssemblyInfo.cs updated for  $UpdateChannel $ModifiedTagName" -Content $assemblyinfocs_content -BranchName main

        Write-Output "publish completed"
    }
} else {
    Write-Output "Source folder not found"
}


Write-Output "End $($PSCmdlet.MyInvocation.MyCommand)"
Write-Output ""
