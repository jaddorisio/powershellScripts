Import-Module ActiveDirectory

# Creates a list of disabled users
$disabled_users = Get-ADUser -Filter "Enabled -eq 'False'" -SearchBase "DC=TEST,DC=COM"  | Select-Object -Property "Name"

#Prints to PS
Write-Output "Disabled Users: `n"
Write-Output $disabled_users