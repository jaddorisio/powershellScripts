# Introduction 
This Powershell Script will Install an MSI package. This script was created for Intune Win32 APP install packages.

# Files
- MSIinstaller Powershell Script

# Intune Run Command
Install Command for intune WIN 32 package
%WINDIR%\Sysnative\WindowsPowershell\v1.0\powershell.exe -Executionpolicy Bypass -File .\<scirptNAME>.ps1

# Uninstallation
Uninstall Command
msiexec /x "{<ProductCodeofApp>}" /qn