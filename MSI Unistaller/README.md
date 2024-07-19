# Introduction 
This Powershell Script will Uninstall MSI Installed software. This script was created for Intune Win32 APP install packages. Powershell 64 Bit is Required for Uninstall

# Files
- MSIunistaller Powershell Script

# Installation
Install Command for intune WIN 32 pac
%WINDIR%\Sysnative\WindowsPowershell\v1.0\powershell.exe -Executionpolicy Bypass -File .\<scirptNAME>.ps1

# Uninstallation
Uninstall Command
msiexec /x "{D5590D86-1E09-4B85-A6E7-51CC42614EB6}" /qn
