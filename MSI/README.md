# MSI Scripts

Reusable MSI install and uninstall wrappers for Intune Win32 app packages.

## Files

- `MSIinstaller.ps1`: Installs an MSI and returns the native `msiexec` exit code.
- `MSIuninstaller.ps1`: Finds MSI product codes by uninstall display name and runs `msiexec /x`.

## Intune Commands

Install:

```text
%WINDIR%\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\MSIinstaller.ps1
```

Uninstall:

```text
%WINDIR%\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\MSIuninstaller.ps1 -DisplayNamePattern "Absolute","NetMotion"
```

## Notes

- `MSIinstaller.ps1` defaults to `setup.msi` in the same folder, with logs written to `C:\Windows\Temp`.
- `MSIuninstaller.ps1` returns `0` when the product is already absent and preserves `3010` for reboot-required removals.
- Keep the MSI package and any related install content in the same Intune source folder as the scripts unless you pass a custom path.
