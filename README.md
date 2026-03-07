# PowerShell Script Library

This repository contains Windows-first PowerShell scripts for:

- Intune Win32 app install and uninstall packaging
- Intune detection and remediation workflows
- Active Directory reporting
- Basic service configuration

The recent updates focus on making the scripts easier to reuse by moving
environment-specific values into parameters, standardizing output, and documenting
execution context.

## Folder Map

- `AD-Detection`: Manual AD audit and reporting scripts
- `fix-onedriveFolder-JCA`: Intune detection and remediation for shell folder cleanup
- `MSI`: MSI install and uninstall wrappers for packaged deployments
- `Service-Startup.ps1`: Standalone service startup configuration script

## Reuse Conventions

- Prefer parameters over hard-coded company values.
- Return objects for admin and reporting scripts so results can be piped to
  `Export-Csv`, `Format-Table`, or other tooling.
- Preserve process exit codes for Intune install, uninstall, detection, and
  remediation scenarios.
- Use `Get-Help .\script.ps1 -Detailed` after you update a script header.

## Intune Guidance

- Detection scripts should return `0` when compliant and `1` when remediation is
  needed.
- Remediation scripts should return `0` on success and non-zero on failure.
- For Win32 app packaging, use `Sysnative` so Intune launches 64-bit PowerShell:

```text
%WINDIR%\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\script.ps1
```

## Azure Automation Guidance

- Scripts that depend on `HKCU`, user profile paths, or local application state
  are better suited for Intune or another endpoint execution method.
- AD scripts require the `ActiveDirectory` module and domain connectivity. If you
  need them in Azure Automation, run them on a Hybrid Runbook Worker or another
  domain-joined host with the required modules and rights.

## Recommended Validation

Run basic syntax validation before shipping updates:

```powershell
[System.Management.Automation.Language.Parser]::ParseFile(".\Service-Startup.ps1", [ref]$null, [ref]$null)
```

If `PSScriptAnalyzer` is available in your environment, use it as a second pass.

