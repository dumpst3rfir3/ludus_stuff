# Ludus Stuff

This is just a personal repo I am using to store configurations, scripts, etc. that I am using for my homelab [Ludus](https://ludus.cloud/) setup. I am a fan of using Ludus for deploying Active Directory ranges in my homelab, it's worth checking out if you haven't yet.

## Configs

* **basic-ad-config.yml:** This is my config for a very basic Active Directory setup. It sets up:
    - A domain: dumpster.fire 
    - A DC running Windows Server 2022
    - A basic Windows 2019 server 
    - 2 workstations, one running Windows 10 and the other running Windows 11
        * The workstations include the Ludus additional tools (Office, Chrome, etc.)
    - 2 OUs, US and CA
    - 3 groups: Sales US, Sales CA, and IT
    - 5 users in addition to the Ludus defaults (1 in Sales US, 1 in Sales CA, 3 in IT - one of whom is a DA)