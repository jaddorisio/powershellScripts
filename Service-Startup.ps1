function Set-ServiceStartupToAutomatic {
    <#
    .SYNOPSIS
        Sets Windows services to automatic startup mode.
    
    .DESCRIPTION
        This function changes the startup type of specified Windows services to Automatic.
        It requires administrative privileges to modify service configurations.
    
    .PARAMETER ServiceName
        Name of the service(s) to set to automatic startup. Accepts pipeline input and multiple service names.
    
    .EXAMPLE
        Set-ServiceStartupToAutomatic -ServiceName "wuauserv"
        Changes the Windows Update service to automatic startup.
    
    .EXAMPLE
        "Spooler", "BITS" | Set-ServiceStartupToAutomatic
        Changes both the Print Spooler and Background Intelligent Transfer Service to automatic startup.
    
    .EXAMPLE
        Set-ServiceStartupToAutomatic -ServiceName "RemoteRegistry"
        Changes the Remote Registry service to automatic startup.
    
    .NOTES
        Requires administrative privileges to run successfully.
    #>
    
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    param(
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]]$ServiceName
    )
    
    begin {
        # Check if running with admin privileges
        $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $isAdmin) {
            Write-Warning "This function requires administrative privileges to change service startup types."
        }
    }
    
    process {
        foreach ($service in $ServiceName) {
            try {
                $svc = Get-Service -Name $service -ErrorAction Stop
                $currentStartType = (Get-WmiObject -Class Win32_Service -Filter "Name='$service'").StartMode
                
                if ($currentStartType -eq "Auto") {
                    Write-Output "Service '$service' is already set to automatic startup."
                } else {
                    if ($PSCmdlet.ShouldProcess("Service '$service'", "Set to automatic startup")) {
                        Set-Service -Name $service -StartupType Automatic
                        Write-Output "Service '$service' startup type set to automatic."
                    }
                }
            } catch {
                Write-Error "Failed to set service '$service' to automatic startup. Error: $_"
            }
        }
    }
}

# To change Remote Registry to automatic startup
Set-ServiceStartupToAutomatic -ServiceName "RemoteRegistry"