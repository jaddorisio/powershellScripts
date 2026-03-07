<#
.SYNOPSIS
Detects shell folder registry values that still reference on-prem file servers.

.DESCRIPTION
Designed for Intune detection scenarios. The script exits `1` when stale paths are
found and `0` when the device is clean.

.PARAMETER KnownFileServers
One or more file server names or UNC fragments to look for.

.EXAMPLE
.\onpremfilepathDetection.ps1 -KnownFileServers "\\fileserver01","\\legacydfs"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$KnownFileServers,

    [string[]]$RegistryPaths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
    )
)

$matches = foreach ($registryPath in $RegistryPaths) {
    try {
        $registryValues = Get-ItemProperty -Path $registryPath -ErrorAction Stop
    }
    catch {
        Write-Error ("Failed to read registry path '{0}'. {1}" -f $registryPath, $_.Exception.Message)
        exit 1
    }

    foreach ($property in $registryValues.PSObject.Properties) {
        $value = [string]$property.Value

        if ([string]::IsNullOrWhiteSpace($value)) {
            continue
        }

        foreach ($fileServer in $KnownFileServers) {
            if ($value -match [regex]::Escape($fileServer)) {
                [pscustomobject]@{
                    RegistryPath  = $registryPath
                    PropertyName  = $property.Name
                    PropertyValue = $value
                    MatchedServer = $fileServer
                }
                break
            }
        }
    }
}

if ($matches) {
    $matches | Sort-Object RegistryPath, PropertyName -Unique
    exit 1
}

Write-Output "No on-prem locations found."
exit 0
