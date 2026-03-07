<#
.SYNOPSIS
Uninstalls one or more MSI-based applications by display name match.

.DESCRIPTION
Designed for Intune Win32 app uninstall packaging. The script returns `0` when no
matching application is installed, `3010` when a reboot is required, or the first
unexpected `msiexec` error code.

.PARAMETER DisplayNamePattern
One or more regular expression patterns used to match uninstall registry
DisplayName values.

.PARAMETER ServiceNameToStop
Optional services to stop before uninstalling software.

.PARAMETER LogDirectory
Directory used for uninstall logs.

.EXAMPLE
.\MSIuninstaller.ps1 -DisplayNamePattern "Absolute","NetMotion"

.EXAMPLE
.\MSIuninstaller.ps1 -DisplayNamePattern "VPN Client" -ServiceNameToStop "MESSERV"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$DisplayNamePattern,

    [string[]]$RegistryPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    ),

    [string[]]$ServiceNameToStop = @(),

    [string]$LogDirectory = "C:\Windows\Temp"
)

if (-not (Test-Path -Path $LogDirectory)) {
    New-Item -Path $LogDirectory -ItemType Directory -Force | Out-Null
}

foreach ($serviceName in $ServiceNameToStop) {
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($null -ne $service -and $service.Status -ne "Stopped") {
        Stop-Service -Name $serviceName -Force -ErrorAction Stop
    }
}

$installedProducts = foreach ($registryPath in $RegistryPaths) {
    Get-ChildItem -Path $registryPath -ErrorAction SilentlyContinue |
        Get-ItemProperty -ErrorAction SilentlyContinue |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_.DisplayName) } |
        Select-Object DisplayName, PSChildName
}

$matches = foreach ($pattern in $DisplayNamePattern) {
    foreach ($product in $installedProducts) {
        if ($product.DisplayName -match $pattern) {
            [pscustomobject]@{
                DisplayName = $product.DisplayName
                ProductCode = $product.PSChildName
            }
        }
    }
}

$uniqueMatches = $matches | Sort-Object ProductCode -Unique

if (-not $uniqueMatches) {
    Write-Output "No matching MSI products found."
    exit 0
}

$exitCodes = @()

foreach ($product in $uniqueMatches) {
    $safeName = ($product.DisplayName -replace "[^a-zA-Z0-9._-]", "_")
    $logPath = Join-Path -Path $LogDirectory -ChildPath ("uninstall_{0}.log" -f $safeName)
    $argumentList = @(
        "/x"
        "`"$($product.ProductCode)`""
        "/qn"
        "/norestart"
        "/lv"
        "`"$logPath`""
    )

    $process = Start-Process -FilePath "$env:WINDIR\System32\msiexec.exe" -ArgumentList $argumentList -Wait -PassThru
    $exitCodes += $process.ExitCode

    [pscustomobject]@{
        DisplayName = $product.DisplayName
        ProductCode = $product.ProductCode
        LogPath     = $logPath
        ExitCode    = $process.ExitCode
    }
}

$unexpectedExitCode = $exitCodes | Where-Object { $_ -notin @(0, 1605, 3010) } | Select-Object -First 1

if ($null -ne $unexpectedExitCode) {
    exit $unexpectedExitCode
}

if ($exitCodes -contains 3010) {
    exit 3010
}

exit 0
