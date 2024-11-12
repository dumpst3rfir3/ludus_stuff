# Kerberoasting

## Very Basic Kerberoasting Lab

To set up a very basic Kerberoasting lab, deploy a range using the [basic AD config](../basic-ad-config.yml). Then log into **the Windows 2019 server (NOT the DC)** as `domainadmin` (if using default ludus creds, it should be `domainadmin`/`password`), then just run the [basic kerberoasting PowerShell script](./basic_kerberoasting.ps1).

The script sets up FTP and IIS on the Windows 2019 server, and then sets FTP and HTTP SPNs on the FTP and IIS service accounts, respectively. This is to at least make it appear somewhat realistic, or at least less unrealistic.

You now have 2 kerberoastable accounts, have fun!