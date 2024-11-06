# Kerberoasting

## Very Basic Kerberoasting Lab

To set up a very basic Kerberoasting lab, deploy a range using the [basic AD config](../basic-ad-config.yml), then just run the [basic kerberoasting PowerShell script](./basic_kerberoasting.ps1) **on the Windows 2019 server, NOT the DC.**

The script sets up an IIS server on the Windows 2019 server, and then sets HTTP SPNs on two of the IT users to make it look somewhat realistic, or at least less unrealistic.