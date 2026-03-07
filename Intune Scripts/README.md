# Intune Scripts

This folder groups scripts by how they are typically used in Intune.

## Folders

- `Proactive Remediations`: Detection and remediation pairs intended for endpoint compliance or cleanup workflows.
- `Win32 Apps`: Install and uninstall wrappers intended for packaged app deployments.

## Notes

- Use user context for scripts that read or modify `HKCU`.
- Preserve non-zero exit codes where Intune needs them for reporting or remediation targeting.
