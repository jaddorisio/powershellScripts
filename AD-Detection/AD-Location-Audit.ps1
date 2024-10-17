Import-Module ActiveDirectory

#Create an array of all active mclane users in AD and include city property
$company_users = Get-ADUser -Filter "Enabled -eq 'True'" -SearchBase "DC=Test,DC=COM" -Properties "City"

#List of Allowed Location in city field
$Locations= @("City", "Remote")

#Intialize Arrays to Store Data
$noCity = @()
$incorrectCity = @{}

foreach ($aduser in $company_users) {
    # Account for user with no city property and users with city property that dont match against official allowed location list
    if ($null -eq $aduser.City){
        $noCity += ($aduser.Name)
               
    }
    elseif ($Locations -cnotcontains $aduser.City ){
      
     $incorrectCity.Add($aduser.Name, $aduser.City)
    }
    

}

#Prints to PS
Write-Output "Users with No Location: `n"
$noCity
Write-Output "`nUser with Incorrect Location: `n"
$incorrectCity