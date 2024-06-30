# Install Cato SDP Client with logging quiet no restart, log to temp folder
Start-Process C:\Windows\System32\msiexec.exe  -ArgumentList '/i "setup.msi" /qn /norestart /lv C:\temp\catovpn.log' -Wait 

# Intialize array of display names for the programs to check
$display_names = @("Absolute", "Netmotion", "DNSFilter")

# Intialize array of Registry directory to check for GUID code
$registry_paths = "HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall", "HKLM:\\Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall"

# Kill VPN Service before Uninstall
$vpnClient = Get-Service -Name MESSERV
Stop-Service -InputObject $vpnClient -Force 

# Loop through display names to detect a product code via pschildname
# if the product code exist pass it msiexec.exe for uninstall

foreach ($names in $display_names) {
    
    $guid = Get-ChildItem -Path $registry_paths | Get-ItemProperty | Where-Object { $_.DisplayName -match $names } |  Select-Object -ExpandProperty PsChildName

    if($null -ne $guid) {
       Start-Process C:\Windows\System32\msiexec.exe -ArgumentList "/X `"$guid`" /qn /norestart /lv c:\temp\uninstall_$($names).log" -Wait
    }

}