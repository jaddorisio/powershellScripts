<#
.SYNOPSIS
Reports enabled Active Directory users with missing or unexpected department values.

.PARAMETER SearchBase
The AD search base used for the report.

.PARAMETER AllowedDepartments
Approved department values. Any other value is flagged as invalid.

.EXAMPLE
.\AD-Department-Audit.ps1 -SearchBase "OU=Users,DC=contoso,DC=com"

.EXAMPLE
.\AD-Department-Audit.ps1 | Export-Csv .\department-audit.csv -NoTypeInformation
#>
[CmdletBinding()]
param(
    [string]$SearchBase = "DC=TEST,DC=COM",
    [string[]]$AllowedDepartments = @(
        "Accounting",
        "Real Estate",
        "Records",
        "Tax",
        "Trust Services Group",
        "Trusts & Estates"
    )
)

Import-Module ActiveDirectory -ErrorAction Stop

$companyUsers = Get-ADUser -Filter "Enabled -eq 'True'" -SearchBase $SearchBase -Properties Department | Sort-Object Name

$results = foreach ($adUser in $companyUsers) {
    if ([string]::IsNullOrWhiteSpace($adUser.Department)) {
        [pscustomobject]@{
            Name           = $adUser.Name
            SamAccountName = $adUser.SamAccountName
            Department     = $null
            Issue          = "MissingDepartment"
        }
        continue
    }

    if ($AllowedDepartments -cnotcontains $adUser.Department) {
        [pscustomobject]@{
            Name           = $adUser.Name
            SamAccountName = $adUser.SamAccountName
            Department     = $adUser.Department
            Issue          = "InvalidDepartment"
        }
    }
}

$results | Sort-Object Issue, Name
