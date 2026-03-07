<#
.SYNOPSIS
Reports enabled Active Directory users with missing or unexpected department values.

.PARAMETER SearchBase
The AD search base used for the report.

.PARAMETER AllowedDepartments
Optional approved department values. When provided, any other value is flagged as invalid.

.EXAMPLE
.\AD-Department-Audit.ps1 -SearchBase "OU=Users,DC=contoso,DC=com"

.EXAMPLE
.\AD-Department-Audit.ps1 -SearchBase "OU=Users,DC=contoso,DC=com" -AllowedDepartments "IT","HR","Finance" |
    Export-Csv .\department-audit.csv -NoTypeInformation
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SearchBase,

    [string[]]$AllowedDepartments
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

    if ($AllowedDepartments -and $AllowedDepartments -cnotcontains $adUser.Department) {
        [pscustomobject]@{
            Name           = $adUser.Name
            SamAccountName = $adUser.SamAccountName
            Department     = $adUser.Department
            Issue          = "InvalidDepartment"
        }
    }
}

$results | Sort-Object Issue, Name
