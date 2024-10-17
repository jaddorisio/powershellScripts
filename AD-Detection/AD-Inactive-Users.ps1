Import-Module ActiveDirectory

#Create an array of all mclane users in AD
$mclane_users = Get-ADUser -Filter "Enabled -eq 'True'" -SearchBase "DC=MCLANE,DC=COM" -Properties "LastLogonDate"

#Generate Current System Time
$CurrentTime = Get-Date

#Intialize Arrays to Store Data
$noLoginDate = @()
$inactive = @()

#Loop through to build a list of last Login Dates
foreach ($aduser in $mclane_users) {
    

    #Compute Days since last login for user with a login date
    if ($null -ne $aduser.LastLogonDate){
        $newDateTime = $CurrentTime - $aduser.LastLogonDate
        
        if($newDateTime.Days -gt 90){
            $inactive += ($aduser.Name)
        }
    }

    #Account for Users with no login date 
    else{
        $noLoginDate += ($aduser.Name)
    }

}


#Prints to PS
Write-Output "A list of users inactive over 90 days:`n"
Write-Output $inactive
Write-Output "`nA list of Never Logged in Users: `n"
Write-Output $noLoginDate





