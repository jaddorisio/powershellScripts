Import-Module ActiveDirectory

#Create an array of all mclane users in AD
$mclane_users = Get-ADUser -Filter "Enabled -eq 'True'" -SearchBase "DC=MCLANE,DC=COM" -Properties "Department"


#List of Allowed Department Names
$Departments= @("Accounting", 
                "Admin Law", "Admin Law/Litigation", "Administration", 
                "Corporate", "Corporate/IP", "Corporate/Trusts & Estates", 
                "GPS", "Human Resources", "Information Technology", 
                "Library", "Litigation", "Marketing", "RE/Corp Lending", 
                "Real Estate", "Records", "Tax", "Trust Services Group", 
                "Trusts & Estates") 

#Intialize Arrays to Store Data
$noDepartment = @()
$incorrectDepartment = @{}



foreach ($aduser in $mclane_users) {
    # Account for user with No Department Names and users with department names that dont match against official dep list
    if ($null -eq $aduser.Department){
        $noDepartment += ($aduser.Name)
               
    }
    elseif ($Departments -cnotcontains $aduser.Department ){
      
     $incorrectDepartment.Add($aduser.Name, $aduser.Department)
    }
    

}

#Prints to PS
Write-Output "Users with No Department: `n"
$noDepartment
Write-Output "`nUser with Incorrect Department: `n"
$incorrectDepartment