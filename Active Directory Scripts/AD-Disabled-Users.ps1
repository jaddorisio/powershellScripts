<#
.SYNOPSIS
Returns disabled Active Directory users from a search base.

.PARAMETER SearchBase
The AD search base used for the report.

.EXAMPLE
.\AD-Disabled-Users.ps1 -SearchBase "OU=Users,DC=contoso,DC=com"
#>
[CmdletBinding()]
param(
    [string]$SearchBase = "DC=TEST,DC=COM"
)

Import-Module ActiveDirectory -ErrorAction Stop

Get-ADUser -Filter "Enabled -eq 'False'" -SearchBase $SearchBase |
    Select-Object Name, SamAccountName, DistinguishedName |
    Sort-Object Name
