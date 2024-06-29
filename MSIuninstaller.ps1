# Install Cato SDP Client with logging quiet no restart



msiexec.exe /i setup.msi /qn /norestart /L*v C:\temp\catovpn.log




# Intialize array of display names for the programs to check

$display_names = @("Absolute", "Netmotion", "DNSFilter")

 

# Intialize array of Registry directory to check for GUID code

$registry_paths = "HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall", "HKLM:\\Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall"




# Kill VPN Service before Uninstall

$vpnClient = Get-Service -Name MESSERV

Stop-Service -InputObject $vpnClient -Force 






# Loop through display names to detect an uninstall string and procced with quiet uninstall of software.

foreach ($names in $display_names) {

    $UninstallString = Get-ChildItem -Path $registry_paths | Get-ItemProperty | Where-Object { $_.DisplayName -match $names } |  Select-Object -ExpandProperty UninstallString

    if($null -ne $UninstallString) {

        $guid = $UninstallString -replace 'MsiExec.exe /X', ''

        msiexec.exe /X $($guid) /qn /norestart /lv c:\temp\uninstall__$($names).log

    }

}