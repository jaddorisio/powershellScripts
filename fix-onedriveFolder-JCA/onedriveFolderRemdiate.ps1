# Define the registry paths
$registryPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
)


#Intialize one drive variable and currentuser
$containsOnedrive = $false
$currentUser = whoami
$currentUser = $currentUser.Split('\')[1]



# Loop through each registry path and set key values for pictures,documents and desktop
foreach ($path in $registryPaths) {
    try {
        
        $newDesktopPath = "C:\Users\$currentUser\OneDrive - CompanyNAME\Desktop"
        $newPicturesPath = "C:\Users\$currentUser\OneDrive - CompanyNAME\Pictures"
        $newDocumentsPath = "C:\Users\$currentUser\OneDrive - CompanyNAME\Documents"
        $newMusicPath = "C:\Users\$currentUser\Music"
        $newVideoPath = "C:\Users\$currentUser\Videos"


        Set-ItemProperty -Path $path -Name "Desktop" -Value $newDesktopPath
        Set-ItemProperty -Path $path -Name "Personal" -Value $newDocumentsPath
        Set-ItemProperty -Path $path -Name "My Pictures" -Value $newPicturesPath
        Set-ItemProperty -Path $path -Name "My Music" -Value $newMusicPath
        Set-ItemProperty -Path $path -Name "My Video" -Value $newVideoPath
        
        }

     catch {
        Write-Output "The one or more keys were not was not found in $path."
    }
}



#Verify paths have been changed correctly
foreach ($path in $registryPaths) {
    try {



        $keyValue = Get-ItemProperty -Path $path -Name "Desktop"
        $desktopPath = $keyValue.Desktop
        $keyValue = Get-ItemProperty -Path $path -Name "Personal"
        $documentPath = $keyValue.Personal
        $keyValue = Get-ItemProperty -Path $path -Name "My Pictures"
        $picturePath = $keyValue."My Pictures"
        $keyValue = Get-ItemProperty -Path $path -Name "My Video"
        $videoPath = $keyValue."My Video"
        $keyValue = Get-ItemProperty -Path $path -Name "My Music"
        $musicPath = $keyValue."My Music"
       

        if($desktopPath -like "*OneDrive*" -and $documentPath -like "*OneDrive*" -and $picturePath -like "*OneDrive*"){
            $containsOnedrive = $true
            Write-Output "The Desktop value is $desktopPath in $path"
            Write-Output "The Document value is $documentPath in $path"
            Write-Output "The Picture value is $picturePath in $path"
            Write-Output "The Music value is $musicPath in $path"
            Write-Output "The Video value is $videoPath in $path"
        }
        else{
            $containsOnedrive = $false
            Write-Output "The Desktop value is $desktopPath in $path"
            Write-Output "The Document value is $documentPath in $path"
            Write-Output "The Picture value is $picturePath in $path"
            Write-Output "The Music value is $musicPath in $path"
            Write-Output "The Video value is $videoPath in $path"
        } 



    } catch {
        Write-Output "One or more key was not found in $path."
    }
}



# Return succes if path change completed
if ($containsOnedrive -eq $true){
    exit 0
}
else{
    exit 1
} 

