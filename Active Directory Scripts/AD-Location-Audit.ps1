<#
.SYNOPSIS
Reports enabled Active Directory users with missing or unexpected city values.

.PARAMETER SearchBase
The AD search base used for the report.

.PARAMETER AllowedLocations
Optional approved values for the City attribute. When provided, any other value is flagged as invalid.

.EXAMPLE
.\AD-Location-Audit.ps1 -SearchBase "OU=Users,DC=contoso,DC=com" -AllowedLocations "Remote","New York","Chicago"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SearchBase,

    [string[]]$AllowedLocations
)

Import-Module ActiveDirectory -ErrorAction Stop

$companyUsers = Get-ADUser -Filter "Enabled -eq 'True'" -SearchBase $SearchBase -Properties City | Sort-Object Name

$results = foreach ($adUser in $companyUsers) {
    if ([string]::IsNullOrWhiteSpace($adUser.City)) {
        [pscustomobject]@{
            Name           = $adUser.Name
            SamAccountName = $adUser.SamAccountName
            City           = $null
            Issue          = "MissingLocation"
        }
        continue
    }

    if ($AllowedLocations -and $AllowedLocations -cnotcontains $adUser.City) {
        [pscustomobject]@{
            Name           = $adUser.Name
            SamAccountName = $adUser.SamAccountName
            City           = $adUser.City
            Issue          = "InvalidLocation"
        }
    }
}

$results | Sort-Object Issue, Name
