# Kerberoasting

## Very Basic Kerberoasting Lab

To set up a very basic Kerberoasting lab, deploy a range using the [basic AD config](../basic-ad-config.yml). Then log into **the Windows 2019 server (NOT the DC)** as `domainadmin` (if using default ludus creds, it should be `domainadmin`/`password`), then just run the [basic kerberoasting PowerShell script](./basic_kerberoasting.ps1).

The script sets up an IIS server on the Windows 2019 server, and then sets an HTTP SPN on one of the IT users to make it look somewhat realistic, or at least less unrealistic. It also sets an MSSQLSvc SPN on another IT user for the MSSQL service that is set up on that same server (from the basic AD configuration).