<#
.SYNOPSIS
Installs an MSI package and returns the native `msiexec` exit code.

.DESCRIPTION
Useful for Intune Win32 app packaging when the MSI should be staged next to the
script. The default package name is `setup.msi`, but you can override it.

.PARAMETER PackagePath
Path to the MSI package. Relative paths resolve from the script directory.

.PARAMETER LogDirectory
Directory used for the MSI install log.

.PARAMETER LogName
Optional MSI log file name. If omitted, one is derived from the package name.

.PARAMETER AdditionalArguments
Extra `msiexec` arguments to append.

.EXAMPLE
.\MSIinstaller.ps1

.EXAMPLE
.\MSIinstaller.ps1 -PackagePath ".\VendorApp.msi" -AdditionalArguments "ALLUSERS=1"
#>
[CmdletBinding()]
param(
    [string]$PackagePath = (Join-Path -Path $PSScriptRoot -ChildPath "setup.msi"),
    [string]$LogDirectory = "C:\Windows\Temp",
    [string]$LogName,
    [string[]]$AdditionalArguments = @()
)

if (-not (Test-Path -Path $PackagePath)) {
    throw ("MSI package not found: {0}" -f $PackagePath)
}

$resolvedPackagePath = (Resolve-Path -Path $PackagePath).Path

if (-not $LogName) {
    $LogName = "{0}.install.log" -f [System.IO.Path]::GetFileNameWithoutExtension($resolvedPackagePath)
}

if (-not (Test-Path -Path $LogDirectory)) {
    New-Item -Path $LogDirectory -ItemType Directory -Force | Out-Null
}

$logPath = Join-Path -Path $LogDirectory -ChildPath $LogName
$argumentList = @(
    "/i"
    "`"$resolvedPackagePath`""
    "/qn"
    "/norestart"
    "/lv"
    "`"$logPath`""
) + $AdditionalArguments

$process = Start-Process -FilePath "$env:WINDIR\System32\msiexec.exe" -ArgumentList $argumentList -Wait -PassThru

[pscustomobject]@{
    PackagePath = $resolvedPackagePath
    LogPath     = $logPath
    ExitCode    = $process.ExitCode
}

exit $process.ExitCode
