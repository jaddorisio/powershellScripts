# Define the registry paths
$registryPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
)
 
$knownFileServers = @("InsertFileServersHere")
$staleFilePaths = "On-prem reference found: " 
$containsOldFileserver = $false
 
foreach ($path in $registryPaths) {
    $regdirectorys = Get-ItemProperty -Path $path
 
    foreach ($property in $regdirectorys.PSObject.Properties) {
        $regdirValue = $property.Value
        $regDirName = $property.Name
 
        foreach ($fileserver in $knownFileServers) {
            try {
                if ($regdirValue -like "*$fileserver*") {
                    $containsOldFileserver = $true
                    $staleFilePaths += " $regdirValue in $regDirName , "
                }
            } catch {
                Write-Output "An error occurred while processing the value '$regdirValue' in path '$path'."
            }
        }
    }
}
 


if ($containsOldFileserver -eq $true){
    Write-Output $staleFilePaths
    exit 1
    
}
else{
    Write-Output "No on-prem locations found"
    exit 0
}