# AD Detection Scripts

These scripts generate manual AD reports and are intended for admin execution, not
for Intune detection rules.

## Requirements

- Windows PowerShell 5.1 or PowerShell 7 with the `ActiveDirectory` module available
- Network access to a domain controller
- Rights to query the target OU or domain

## Scripts

- `AD-Department-Audit.ps1`: Finds enabled users with missing or invalid department values.
- `AD-Disabled-Users.ps1`: Lists disabled AD user accounts.
- `AD-Inactive-Users.ps1`: Flags enabled users inactive longer than a threshold or never logged on.
- `AD-Location-Audit.ps1`: Finds enabled users with missing or invalid city values.

## Usage

All scripts now accept `-SearchBase` so they can be reused outside the original
domain layout.

```powershell
.\AD-Inactive-Users.ps1 -SearchBase "OU=Users,DC=contoso,DC=com" -InactiveDays 60
.\AD-Department-Audit.ps1 -AllowedDepartments "IT","HR","Finance" |
    Export-Csv .\department-audit.csv -NoTypeInformation
```

## Azure Automation Notes

These scripts depend on the `ActiveDirectory` module and domain connectivity. If
you run them from Azure Automation, use a Hybrid Runbook Worker or another
domain-joined execution host with the required module installed.
