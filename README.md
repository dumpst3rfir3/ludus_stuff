# Ludus Stuff

This is just a personal repo to store configurations, scripts, etc. that I am using for my homelab [Ludus](https://ludus.cloud/) setup. I am a fan of using Ludus for deploying Active Directory ranges in my homelab, it's worth checking out if you haven't yet.

## Configs

* **basic-ad-config.yml:** This is my config for a very basic Active Directory setup. It sets up:
    - A domain: dumpster.fire 
    - A DC running Windows Server 2022
    - A basic Windows 2019 server
    - 2 workstations, one running Windows 10 and the other running Windows 11
        * The workstations include the Ludus additional tools (Office, Chrome, etc.)
    - 2 OUs, US and CA
    - 3 groups: Sales US, Sales CA, and IT
    - 5 user accounts in addition to the Ludus defaults (1 in Sales US, 1 in Sales CA, 3 in IT - one of whom is a DA)
    - 1 additional domain account used intended to be used as service account for IIS (e.g., if you set up the [basic kerberoasting lab](kerberoasting/README.md))
    - **OPTIONALLY** you can run the [Add-ExtraConfigForBasicAD.ps1](scripts/Add-ExtraConfigForBasicAD.ps1) script in the scripts folder (see description below) for some additional configurations

## Specific Labs

* [**Kerberoasting**](./kerberoasting): Very basic kerberoasting lab - navigate to the folder to see more info

## Additional Scripts, etc.

* [**Fix-Bginfo.ps1**](scripts/Fix-Bginfo.ps1): I found that when RDPing (if that can be used as a verb?) into my VMs, bginfo would do lots of funky stuff, and apparently this is a known issue when you run bginfo on a machine using a high display resolution. This script will replace the ludus `set-bg.ps1` script with a modified version that will NOT use bginfo if a high resolution is detected. **Run this as a domain admin from the DC** and it will modify `set-bg.ps1` on all machines.
* [**Add-ExtraConfigForBasicAD.ps1**](scripts/Add-ExtraConfigForBasicAD.ps1): This is an optional script written **specifically for the Basic AD configuration** \([basic-ad.config.yml](basic-ad-config.yml)\) that will add both of the Sales groups to the local `Remote Desktop Users` group on all domain machines except domain controllers so that you can use those accounts for RDP. Additionally, this will add all users in the `IT` group to the local `Administrators` group on all machines except domain controllers. **Note that this script will prompt you for credentials** - you'll need to enter creds for a user who has local admin on all machines, such as a domain admin.
    - **NOTE:** Sometimes I had issues with this script not being able to connect to the workstations via winRM. If that happens, on the workstations you can simply run the [Add-LocalExtraConfigForBasicAD.ps1](scripts/Add-LocalExtraConfigForBasicAD.ps1) script on each machine individually to manually make the above group configurations on workstations
