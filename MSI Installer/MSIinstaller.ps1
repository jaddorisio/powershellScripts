# Create Path for MSI Installer
# Change setup.msi to match the name of your MSI file. 
$MSIinstaller = Join-Path $PSScriptRoot -ChildPath ('setup.msi')

# Install MSI application with logging quiet no restart, log to temp folder
# Change the "changeme.log" to name of your application ex Office365.log
Start-Process C:\Windows\System32\msiexec.exe  -ArgumentList "/i $MSIinstaller /qn /norestart /lv C:\temp\changeme.log" -Wait 
