# OneDrive Folder Fix

Scripts in this folder are intended for Intune detection and remediation when
known folder paths still reference an on-prem location or the wrong profile path.

## Files

- `onpremfilepathDetection.ps1`: Detects stale shell folder references and exits `1` when remediation is needed.
- `onedriveFolderRemediate.ps1`: Repoints Desktop, Documents, and Pictures to the user's OneDrive folder and exits `0` on success.

## Example Intune Commands

Detection:

```text
%WINDIR%\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\onpremfilepathDetection.ps1 -KnownFileServers "\\fileserver01","\\legacydfs"
```

Remediation:

```text
%WINDIR%\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\onedriveFolderRemediate.ps1 -TenantName "Contoso"
```

## Notes

- Both scripts are written for user-context execution because they modify or read `HKCU`.
- If your OneDrive folder name does not follow `OneDrive - <TenantName>`, pass `-OneDriveRoot` explicitly to the remediation script.
