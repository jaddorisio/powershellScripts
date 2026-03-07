# Active Directory Scripts

These scripts generate manual AD reports and are intended for admin execution, not
for Intune detection rules.

## Requirements

- Windows PowerShell 5.1 or PowerShell 7 with the `ActiveDirectory` module available
- Network access to a domain controller
- Rights to query the target OU or domain
- A `-SearchBase` value appropriate for your environment

## Scripts

- `AD-Department-Audit.ps1`: Finds enabled users with missing departments and optionally invalid department values.
- `AD-Disabled-Users.ps1`: Lists disabled AD user accounts.
- `AD-Inactive-Users.ps1`: Flags enabled users inactive longer than a threshold or never logged on.
- `AD-Location-Audit.ps1`: Finds enabled users with missing city values and optionally invalid location values.

## Usage

`-SearchBase` is required for every script so the caller must provide a domain or OU scope explicitly.
If you do not pass `-AllowedDepartments` or `-AllowedLocations`, the audit scripts only report missing values.

```powershell
.\AD-Inactive-Users.ps1 -SearchBase "OU=Users,DC=contoso,DC=com" -InactiveDays 60
.\AD-Department-Audit.ps1 -SearchBase "OU=Users,DC=contoso,DC=com" -AllowedDepartments "IT","HR","Finance" |
    Export-Csv .\department-audit.csv -NoTypeInformation
```

## Azure Automation Notes

These scripts depend on the `ActiveDirectory` module and domain connectivity. If
you run them from Azure Automation, use a Hybrid Runbook Worker or another
domain-joined execution host with the required module installed.
