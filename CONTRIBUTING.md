# Contributing

## Scope

This repository contains reusable PowerShell automation for Windows administration,
Intune, Azure Automation, and Active Directory reporting.

## Folder Placement

- `Active Directory Scripts`: Scripts that query or report against Active Directory.
- `Intune Scripts\Proactive Remediations`: Detection and remediation pairs intended for Intune proactive remediation workflows.
- `Intune Scripts\Win32 Apps`: Install and uninstall helpers intended for Intune Win32 app packaging.
- `General Purpose`: Reusable scripts that are not tied to one management platform.

## Script Standards

- Use parameters for tenant names, domains, search bases, file servers, package names, and other environment-specific values.
- Do not hard-code company names, UNC paths, domains, or product identifiers unless the script is intentionally single-purpose and documented as such.
- Add comment-based help with at least `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, and `.EXAMPLE` sections.
- Return structured output for admin and reporting scripts so results can be piped to other commands.
- Preserve exit code behavior for Intune detection, remediation, install, and uninstall scenarios.
- Prefer `Write-Output` for usable output and `Write-Error` for failures.

## Intune Conventions

- Detection scripts should return `0` when compliant and `1` when remediation is required.
- Remediation scripts should return `0` on success and non-zero on failure.
- Win32 app wrappers should preserve the native installer or uninstaller exit code whenever possible.
- When a script depends on `HKCU` or the signed-in user's profile, document that it must run in user context.

## Azure Automation Conventions

- Document required modules and permissions.
- If a script requires domain connectivity or the `ActiveDirectory` module, note that it should run on a Hybrid Runbook Worker or another domain-joined host.
- Avoid interactive prompts unless the script is specifically for manual use.

## Validation

Run a parser check before committing:

```powershell
$errors = @()
Get-ChildItem -Recurse -Filter *.ps1 | ForEach-Object {
    [void][System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$null, [ref]$errors)
}
$errors
```

If `PSScriptAnalyzer` is installed, run it against changed scripts before opening a pull request.
