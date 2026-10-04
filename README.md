# ESET Safe Mode Uninstaller

PowerShell utility for removing installed ESET products from a Windows machine by booting into Safe Mode, running the official ESET Uninstaller tool in forced mode, and returning the machine to normal boot mode.

## Provenance

The original PowerShell automation was created by **SysTech**. This repository is a public maintained copy that adds repository documentation, safety guidance, provenance disclosure, and non-executing syntax validation.

This repository does not claim that Mornex authored the original script. The imported copy did not contain a verifiable upstream license notice, so this repository does not invent or relicense upstream rights. See [`LICENSE`](LICENSE) for the current rights notice.

The ESET Uninstaller executable is not redistributed here. The script downloads the official ESET tool at runtime, and that executable remains subject to ESET's own terms and documentation.

> [!WARNING]
> Do not run this script on an ESET management server, including ERA or ESET PROTECT.
> Running this script on a management server may remove critical ESET management components and disrupt endpoint management.

## Repository Contents

```text
eset-safe-mode-uninstaller/
├── .github/
│   └── workflows/
│       └── validate-powershell.yml
├── .gitignore
├── CHANGELOG.md
├── LICENSE
├── README.md
├── SECURITY.md
└── Uninstall ALL ESET PRODUCT In Safe Mode.ps1
```

## Overview

The script `Uninstall ALL ESET PRODUCT In Safe Mode.ps1` automates the following workflow:

1. Checks whether PowerShell is running with Administrator privileges.
2. Relaunches itself as Administrator if required.
3. Creates the temporary working directory `C:\esettemp`.
4. Exports current network interface settings to `C:\esettemp\NetworkSettings.txt`.
5. Downloads the official ESET Uninstaller tool.
6. Creates a batch file that runs the ESET Uninstaller with `/force` three times.
7. Creates a shortcut to the batch file.
8. Creates a temporary Windows service named `ESET Removal`.
9. Registers the service under the SafeBoot Minimal registry path.
10. Configures Windows to boot into Safe Mode Minimal.
11. Forces a reboot.
12. Runs the ESET removal process in Safe Mode.
13. Removes the Safe Mode boot value.
14. Deletes the temporary service.
15. Forces another reboot back to normal Windows mode.

## Intended Use

Use this tool when standard ESET removal fails or when a full cleanup of ESET products is required before reinstalling or replacing endpoint protection.

This tool is intended for authorized IT administrators only.

## Supported Targets

This script can be used on:

- Windows workstations
- Windows servers that are not ESET management servers
- Machines with installed ESET endpoint products
- Machines requiring forced ESET cleanup through Safe Mode

## Do Not Use On

Do not use this script on:

- ESET Remote Administrator servers
- ESET PROTECT servers
- Critical production servers without an approved maintenance window
- Machines with BitLocker enabled unless the recovery key is available
- Remote machines where access after reboot cannot be guaranteed

## Prerequisites

Before running the script, confirm the following:

- You have local Administrator permissions.
- The machine is not an ERA or ESET PROTECT server.
- The customer or system owner approved the removal.
- Internet access is available to download the ESET Uninstaller.
- You have physical or reliable remote access after reboot.
- BitLocker recovery key is available, if BitLocker is enabled.
- A maintenance window is approved for servers or business-critical systems.

## Downloaded Tool

The script downloads the ESET Uninstaller from:

```text
https://download.eset.com/com/eset/tools/installers/eset_apps_remover/latest/esetuninstaller.exe
```

The file is saved to:

```text
C:\esettemp\esetuninstaller.exe
```

## Usage

1. Copy the script locally to the target machine.

Recommended path:

```text
C:\Temp\Uninstall ALL ESET PRODUCT In Safe Mode.ps1
```

2. Open PowerShell as Administrator.

3. Run:

```powershell
powershell.exe -ExecutionPolicy Bypass -File "C:\Temp\Uninstall ALL ESET PRODUCT In Safe Mode.ps1"
```

Alternatively, right-click the script and select:

```text
Run with PowerShell
```

## What the Script Creates

The script creates the following items:

```text
C:\esettemp
C:\esettemp\NetworkSettings.txt
C:\esettemp\esetuninstaller.exe
C:\esettemp\uninstall.bat
C:\esettemp\uninstall.lnk
```

It also creates a temporary Windows service:

```text
ESET Removal
```

And a SafeBoot registry entry:

```text
HKLM:\SYSTEM\CurrentControlSet\Control\SafeBoot\Minimal\ESET Removal
```

## Verification After Completion

After the machine returns to normal mode, verify that ESET components were removed.

Check services:

```powershell
Get-Service *ESET*
```

Check installed applications:

```powershell
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
Where-Object {$_.DisplayName -like "*ESET*"} |
Select-Object DisplayName, DisplayVersion
```

Check 32-bit uninstall registry path:

```powershell
Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
Where-Object {$_.DisplayName -like "*ESET*"} |
Select-Object DisplayName, DisplayVersion
```

Check network connectivity:

```cmd
ipconfig /all
ping 8.8.8.8
ping google.com
```

## Troubleshooting

### Machine Remains in Safe Mode

Open Command Prompt as Administrator and run:

```cmd
bcdedit /deletevalue {current} safeboot
shutdown -r -f -t 0
```

If the issue continues, run:

```cmd
bcdedit /deletevalue {default} safeboot
shutdown -r -f -t 0
```

### Temporary Service Still Exists

Run Command Prompt as Administrator:

```cmd
sc delete "ESET Removal"
```

Then reboot the machine:

```cmd
shutdown -r -f -t 0
```

### Network Connectivity Issues

Review the exported network configuration:

```text
C:\esettemp\NetworkSettings.txt
```

Compare it with the current adapter configuration and restore IP, DNS, gateway, VLAN, or routing settings if required.

## Validation

GitHub Actions performs a **syntax-only** PowerShell AST parse of the script on pull requests and pushes to `main`. The workflow never executes the script, changes boot configuration, creates services, downloads ESET software, or reboots a runner.

This validation is intentionally limited because the script is operationally destructive by design. Functional testing must be performed only in an approved disposable Windows test environment with an explicit recovery path.

## Important Notes

- The script changes PowerShell execution policy to `Unrestricted`.
- The script forces immediate system reboots.
- The script does not validate whether the machine is an ERA or ESET PROTECT server.
- The script does not check BitLocker status.
- The script exports network settings but does not restore them automatically.
- The script runs `esetuninstaller.exe /force` three times.
- The script should be used only by authorized IT administrators.
