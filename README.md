# PowerShell Script Library

This repository is organized by execution context so it is easier to find the
right script for Intune, Active Directory, or general Windows administration.

## Folder Map

- `Active Directory Scripts`: Manual AD audit and reporting scripts
- `Intune Scripts`: Endpoint-focused scripts for proactive remediations and Win32 app packaging
- `General Purpose`: Reusable scripts that are not tied to a single platform workflow

## Reuse Conventions

- Prefer parameters over hard-coded company values.
- Return objects for admin and reporting scripts so results can be piped to `Export-Csv`, `Format-Table`, or other tooling.
- Preserve process exit codes for Intune install, uninstall, detection, and remediation scenarios.
- Use `Get-Help .\script.ps1 -Detailed` after you update a script header.

## Intune Guidance

- Detection scripts should return `0` when compliant and `1` when remediation is needed.
- Remediation scripts should return `0` on success and non-zero on failure.
- For Win32 app packaging, use `Sysnative` so Intune launches 64-bit PowerShell.

```text
%WINDIR%\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\script.ps1
```

## Azure Automation Guidance

- Scripts that depend on `HKCU`, user profile paths, or local application state are better suited for Intune or another endpoint execution method.
- AD scripts require the `ActiveDirectory` module and domain connectivity. If you need them in Azure Automation, run them on a Hybrid Runbook Worker or another domain-joined host with the required modules and rights.

## Recommended Validation

```powershell
[System.Management.Automation.Language.Parser]::ParseFile('.\General Purpose\Service-Startup.ps1', [ref]$null, [ref]$null)
```

If `PSScriptAnalyzer` is available in your environment, use it as a second pass.
