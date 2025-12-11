<#
.SYNOPSIS
Complete script for API-driven runs in Terraform Cloud/Enterprise.

.DESCRIPTION
This script packages a content directory, finds a target workspace,
creates a new configuration version, uploads the content, and initiates a run.
Requires the $env:TOKEN environment variable to be set with your TFC/TFE API token.

.PARAMETER ContentDirectory
The path to the content directory (e.g., a directory containing your .tf files).

.PARAMETER OrganizationAndWorkspace
The organization and workspace names, separated by a forward slash (e.g., "my-org/my-workspace").
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ContentDirectory,

    [Parameter(Mandatory=$true)]
    [string]$OrganizationAndWorkspace
)

# 1. Define Variables
$APIBaseUrl = "https://app.terraform.io/api/v2"

# Ensure the required environment variable is set
if (-not $env:TOKEN) {
    Write-Error "The environment variable 'TOKEN' (your TFC/TFE API token) must be set."
    exit 1
}

$OrgName = ($OrganizationAndWorkspace -split '/')[0]
$WorkspaceName = ($OrganizationAndWorkspace -split '/')[1]

# 2. Create the File for Upload
$Timestamp = Get-Date -UFormat "%s"
$UploadFileName = ".\content-$Timestamp.tar.gz"

Write-Host "Compressing content from '$ContentDirectory' into '$UploadFileName'..."

# PowerShell doesn't have a native 'tar' command (unless using WSL/Linux tools)
# We use the built-in .NET GZipStream and Tar APIs for native zipping/tarring.
# Note: This requires PowerShell 5.0+ and is different from native tar behavior.
# A simpler, common alternative for complex zipping on Windows is 7-Zip/WinRAR.
# A more robust and simple approach for this specific TFC/TFE requirement:
# If you have Windows 10/11, you can often use the native 'tar' utility:
if (-not (Get-Command tar -ErrorAction SilentlyContinue)) {
    Write-Error "The 'tar' utility is not found. Ensure you are on a system with 'tar' or replace this step with a different compression method."
    exit 1
}

# The -C flag (change directory) needs special handling in Windows tar utility,
# but the easiest way to mimic the original script's behavior is:
# 1. Change to the content directory.
# 2. Run tar to compress everything in the current directory (which is now $ContentDirectory).
# 3. Change back.
$CurrentLocation = Get-Location
try {
    Set-Location -Path $ContentDirectory
    tar -zcvf $UploadFileName .
}
finally {
    Set-Location -Path $CurrentLocation
}
# The resulting archive will be in the *original* directory, not $ContentDirectory.


# 3. Look Up the Workspace ID
Write-Host "Looking up Workspace ID for '$OrgName/$WorkspaceName'..."
$WorkspaceUrl = "$APIBaseUrl/organizations/$OrgName/workspaces/$WorkspaceName"

try {
    $WorkspaceResponse = Invoke-RestMethod -Uri $WorkspaceUrl `
        -Headers @{
            "Authorization" = "Bearer $env:TOKEN"
            "Content-Type" = "application/vnd.api+json"
        } -Method Get

    $WorkspaceId = $WorkspaceResponse.data.id

    if (-not $WorkspaceId) {
        Write-Error "Could not find Workspace ID. Check organization/workspace name and token."
        exit 1
    }
    Write-Host "Found Workspace ID: $WorkspaceId"
}
catch {
    Write-Error "Error looking up workspace: $($_.Exception.Message)"
    exit 1
}


# 4. Create a New Configuration Version
Write-Host "Creating a new Configuration Version..."
$ConfigVersionUrl = "$APIBaseUrl/workspaces/$WorkspaceId/configuration-versions"
$Body = @{
    data = @{
        type = "configuration-versions"
    }
} | ConvertTo-Json

try {
    $ConfigResponse = Invoke-RestMethod -Uri $ConfigVersionUrl `
        -Headers @{
            "Authorization" = "Bearer $env:TOKEN"
            "Content-Type" = "application/vnd.api+json"
        } -Method Post -Body $Body

    $UploadUrl = $ConfigResponse.data.attributes."upload-url"

    if (-not $UploadUrl) {
        Write-Error "Could not retrieve upload-url from API response."
        exit 1
    }
    Write-Host "Received Upload URL."
}
catch {
    Write-Error "Error creating configuration version: $($_.Exception.Message)"
    exit 1
}


# 5. Upload the Configuration Content File
Write-Host "Uploading configuration content to TFC/TFE..."
try {
    Invoke-RestMethod -Uri $UploadUrl `
        -Headers @{
            "Content-Type" = "application/octet-stream"
        } -Method Put `
        -InFile $UploadFileName

    Write-Host "Upload successful! Run should start shortly."
}
catch {
    Write-Error "Error uploading file: $($_.Exception.Message)"
    exit 1
}


# 6. Delete Temporary Files
Write-Host "Cleaning up temporary files..."
Remove-Item -Path $UploadFileName -Force
# The JSON file was only generated in-memory in this PowerShell version, so no need to delete.

Write-Host "Script finished."