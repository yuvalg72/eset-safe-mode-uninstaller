# Security Policy

## Authorized Use Only

This repository contains a PowerShell script that removes ESET products from Windows machines using Safe Mode and the official ESET Uninstaller tool.

Use this script only on systems you are authorized to manage.

## High-Risk Actions

The script performs the following high-impact actions:

- Changes PowerShell execution policy to `Unrestricted`
- Downloads an executable from the internet
- Creates a temporary Windows service
- Modifies SafeBoot registry configuration
- Changes Windows boot configuration
- Forces immediate system reboots
- Removes endpoint security software

## Required Controls

Before running the script:

- Confirm written or ticket-based approval
- Verify the target machine is not an ESET management server
- Verify BitLocker recovery information is available
- Confirm reliable access after reboot
- Use an approved maintenance window for servers

## Reporting Issues

Report issues internally to the IT or Security team responsible for endpoint management.
