# Ludus Stuff

This is just a personal repo to store configurations, scripts, etc. that I am
using for my homelab [Ludus](https://ludus.cloud/) setup. I am a fan of using
Ludus for deploying Active Directory ranges, it's worth checking
out if you haven't yet.

## Configs

### Basic AD Config

**[basic-ad-config.yml](basic-ad-config.yml)** 

This is my config for a very basic Active Directory setup that simulates a small company with presence in the US and CA. It sets up:
  - A domain: dumpster.fire 
  - A DC running Windows Server 2022
  - A separate Windows 2022 server (non-DC)
  - 2 Windows 11 workstations
      * The workstations include the Ludus additional tools (Office, Chrome, etc.)
  - 3 OUs:  People (for "employee" accounts), US, and CA
  - 3 groups: Sales US, Sales CA, and IT
  - 5 user accounts in addition to the Ludus defaults (1 in Sales US, 1 in
    Sales CA, 3 in IT - one of whom is a DA), all of which are placed in the
    People OU
  - 2 additional domain accounts intended to be used as service accounts for IIS (e.g., if you set up the [basic kerberoasting lab](kerberoasting/README.md))
    
> [!IMPORTANT]
> To use this config, you will need to first add the `ludus-ad-content` Ansible role. Just clone [the repo](https://github.com/Cyblex-Consulting/ludus-ad-content) locally, then add it with:
>
> `ludus ansible role add -d /path/to/ludus-ad-content`
>
> See the [Ludus documentation](https://docs.ludus.cloud/docs/roles) for more info. 

## Basic AD Config with "Extras"

**[basic-ad-config-with-extras.yml](basic-ad-config-with-extras.yml)** 

This is still a pretty basic AD setup, but it adds a few things to the `basic-ad-config.yml` above:
  - Two Kali "attacker" machines:
    * `{{ range_id }}-kali-internal`: a Kali machine on the "internal" network
      (i.e., the same network as the Active Directory machines) for testing
      internal attacks (hash relaying, etc.)
    * `{{ range_id }}-kali-internal`: a Kali machine on an "external" network,
        simulating an outside attacker
  - A Debian server that runs [Bloodhound CE](https://specterops.io/oodhound-community-edition/) on port 8080 with a default admin password of loodhoundpassword`
  - Three SMB shares on `SRV01`: a public share for all employees, one for sales ployees, and one for admins
  - Both of Sales groups are added to the local `Remote Desktop Users` group on workstations so that those accounts can be used for RDP
  - The `IT` group is added to the local `Administrators` group on all machines except the domain controller

> [!IMPORTANT]
> To use this config, you will need to first add the `ludus-ad-content` Ansible role, just like the Basic AD Config above (see the instructions there), but the `extra-ad-config` must also be added:
>
> ```
> # Assuming this is executed from the root of this repo
> ludus ansible role add -d ./roles/extra-ad-config --force
> ```
>
> Additionally, for Bloodhound, the publicly-available `badsectorlabs.ludus_bloodhound_ce` role needs to be added:
>
> `ludus ansible role add badsectorlabs.ludus_bloodhound_ce`


## Specific Labs

* [**Kerberoasting**](./kerberoasting): See the Kerberoasting README for more details

## Additional Scripts, etc.

These are scripts that I no longer use for the most part, but I'm leaving them in here as backup, or in case I ever decide to do anything with them later:

* [**Add-ExtraConfigForBasicAD.ps1**](scripts/Add-ExtraConfigForBasicAD.ps1): This is what I used to use for the `basic-ad-config-with-extras` config when I used to set it up manually (after deploying the basic AD lab). Here is the original description:
>  This is an optional script written **specifically for the Basic AD
>  configuration** \([basic-ad.config.yml](basic-ad-config.yml)\) that will add
>  both of the Sales groups to the local `Remote Desktop Users` group on
>  workstations so that you can use those accounts for RDP. Additionally, this
>  will add all users in the `IT` group to the local `Administrators` group on
>  all machines except domain controllers. It will also set up 3 SMB shares on
>  SRV01: a public share for all employees, one for sales employees, and one for >admins.  **Run this as a domain admin from the
>  DC**.
>    - **NOTE:** This script downloads PSExec (and deletes it at the end), so an Internet connection is needed. Otherwise, modify it to use a local instance of PSExec that you copied over.

* [**Disable-Autologon.ps1**](scripts/Disable-Autologon.ps1): This is an optional script that will disable autologon on all machines in the range.**Run this as a domain admin from the DC**.
* [**Fix-Bginfo.ps1**](scripts/Fix-Bginfo.ps1): In my early Ludus days I found that when RDPing (if that can be used as a verb?) into my VMs, bginfo would do lots of funky stuff, and apparently this was a known issue when you run bginfo on a machine using a high display resolution. This doesn't seem to be an issue anymore, but I'm leaving this here just in case. This script will replace the ludus `set-bg.ps1` script with a modified version that will NOT use bginfo if a high resolution is detected. **Run this as a domain admin from the DC** and it will modify `set-bg.ps1` on all machines.
* [**Windows Updates Scripts**](scripts/windows-updates): Out of laziness during one particular lab deployment, these were created as a quick and dirty way to install Windows updates on all the Windows machine sin the Basic AD configuration \([basic-ad.config.yml](basic-ad-config.yml)\). If using it, `Install-PSWindowsUpdates.ps1` should be executed first (to install the PSWindowsUpdate module from NuGet), followed by `Updated-AllMachines.ps1`. `Verify-Updates.ps1` can then be used to verify the updates were installed.
* [**basic_kerberoasting.ps1**](scripts/basic_kerberoasting.ps1): This is what I used to use to set up the [kerberoasting](kerberoasting/README.md) lab when I used to do it manually (after deploying the basic AD lab). 
