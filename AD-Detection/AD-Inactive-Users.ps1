<#
.SYNOPSIS
Reports enabled Active Directory users who have been inactive beyond a threshold
or have never logged on.

.PARAMETER SearchBase
The AD search base used for the report.

.PARAMETER InactiveDays
Users older than this number of days since last logon are flagged as inactive.

.EXAMPLE
.\AD-Inactive-Users.ps1 -InactiveDays 90
#>
[CmdletBinding()]
param(
    [string]$SearchBase = "DC=TEST,DC=COM",
    [ValidateRange(1, 3650)]
    [int]$InactiveDays = 90
)

Import-Module ActiveDirectory -ErrorAction Stop

$currentTime = Get-Date
$cutoffDate = $currentTime.AddDays(-$InactiveDays)
$companyUsers = Get-ADUser -Filter "Enabled -eq 'True'" -SearchBase $SearchBase -Properties LastLogonDate | Sort-Object Name

$results = foreach ($adUser in $companyUsers) {
    if ($null -eq $adUser.LastLogonDate) {
        [pscustomobject]@{
            Name               = $adUser.Name
            SamAccountName     = $adUser.SamAccountName
            LastLogonDate      = $null
            DaysSinceLastLogon = $null
            Issue              = "NeverLoggedOn"
        }
        continue
    }

    if ($adUser.LastLogonDate -lt $cutoffDate) {
        [pscustomobject]@{
            Name               = $adUser.Name
            SamAccountName     = $adUser.SamAccountName
            LastLogonDate      = $adUser.LastLogonDate
            DaysSinceLastLogon = [int](($currentTime - $adUser.LastLogonDate).TotalDays)
            Issue              = "Inactive"
        }
    }
}

$results | Sort-Object Issue, Name
