<#
.SYNOPSIS
Remediates shell folder registry values so Desktop, Documents, and Pictures point
to the signed-in user's OneDrive folder.

.DESCRIPTION
Designed for Intune remediation scenarios where known folder paths still point to
the wrong location. The script exits `0` on success and `1` on failure.

.PARAMETER TenantName
The OneDrive tenant display name used in the local folder name, for example
"Contoso".

.PARAMETER OneDriveRoot
Optional explicit path to the OneDrive sync root. If not provided, the script
uses `OneDrive - <TenantName>` under the current user's profile.

.EXAMPLE
.\onedriveFolderRemediate.ps1 -TenantName "Contoso"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TenantName,

    [string]$OneDriveRoot,

    [string[]]$RegistryPaths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
    )
)

if (-not $OneDriveRoot) {
    $OneDriveRoot = Join-Path -Path $env:USERPROFILE -ChildPath ("OneDrive - {0}" -f $TenantName)
}

if (-not (Test-Path -Path $OneDriveRoot)) {
    Write-Error ("OneDrive root not found: {0}" -f $OneDriveRoot)
    exit 1
}

$targetPaths = [ordered]@{
    "Desktop"     = Join-Path -Path $OneDriveRoot -ChildPath "Desktop"
    "Personal"    = Join-Path -Path $OneDriveRoot -ChildPath "Documents"
    "My Pictures" = Join-Path -Path $OneDriveRoot -ChildPath "Pictures"
    "My Music"    = Join-Path -Path $env:USERPROFILE -ChildPath "Music"
    "My Video"    = Join-Path -Path $env:USERPROFILE -ChildPath "Videos"
}

foreach ($path in $targetPaths.Values) {
    if (-not (Test-Path -Path $path)) {
        New-Item -Path $path -ItemType Directory -Force | Out-Null
    }
}

foreach ($registryPath in $RegistryPaths) {
    try {
        foreach ($propertyName in $targetPaths.Keys) {
            Set-ItemProperty -Path $registryPath -Name $propertyName -Value $targetPaths[$propertyName] -ErrorAction Stop
        }
    }
    catch {
        Write-Error ("Failed to update registry path '{0}'. {1}" -f $registryPath, $_.Exception.Message)
        exit 1
    }
}

$verificationResults = foreach ($registryPath in $RegistryPaths) {
    try {
        $item = Get-ItemProperty -Path $registryPath -ErrorAction Stop

        foreach ($propertyName in $targetPaths.Keys) {
            [pscustomobject]@{
                RegistryPath = $registryPath
                PropertyName = $propertyName
                ExpectedPath = $targetPaths[$propertyName]
                ActualPath   = [string]$item.$propertyName
                Matches      = ([string]$item.$propertyName) -eq $targetPaths[$propertyName]
            }
        }
    }
    catch {
        Write-Error ("Failed to verify registry path '{0}'. {1}" -f $registryPath, $_.Exception.Message)
        exit 1
    }
}

$verificationResults

if ($verificationResults.Where({ -not $_.Matches }).Count -gt 0) {
    exit 1
}

exit 0
