<#
.SYNOPSIS
Sets one or more Windows services to Automatic startup.

.DESCRIPTION
Use this script when you need a reusable way to standardize service startup
configuration on Windows endpoints or servers. It must be run with
administrative privileges.

.PARAMETER ServiceName
One or more service names to update.

.EXAMPLE
.\Service-Startup.ps1 -ServiceName RemoteRegistry

.EXAMPLE
.\Service-Startup.ps1 -ServiceName Spooler, BITS | Format-Table -AutoSize
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [Alias("Name")]
    [string[]]$ServiceName
)

begin {
    $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdministrator = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdministrator) {
        throw "Administrator privileges are required to change service startup types."
    }
}

process {
    foreach ($service in $ServiceName) {
        try {
            $existingService = Get-Service -Name $service -ErrorAction Stop
            $escapedName = $existingService.Name.Replace("'", "''")
            $serviceConfig = Get-CimInstance -ClassName Win32_Service -Filter "Name='$escapedName'" -ErrorAction Stop
            $wasAutomatic = $serviceConfig.StartMode -eq "Auto"

            if (-not $wasAutomatic -and $PSCmdlet.ShouldProcess($existingService.Name, "Set startup type to Automatic")) {
                Set-Service -Name $existingService.Name -StartupType Automatic -ErrorAction Stop
            }

            [pscustomobject]@{
                ServiceName = $existingService.Name
                DisplayName = $existingService.DisplayName
                StartupType = "Automatic"
                Changed     = -not $wasAutomatic
            }
        }
        catch {
            Write-Error ("Failed to update service '{0}'. {1}" -f $service, $_.Exception.Message)
        }
    }
}
