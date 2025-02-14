# Kerberoasting

## Very Basic Kerberoasting Lab

To set up a very basic Kerberoasting lab, deploy a range using the [basic AD
config](../basic-ad-config.yml). Then log into DC (`"{{ range_id }}-DC01-2022"`)
as `domainadmin` (if using default ludus creds, it should be
`domainadmin`/`password`), then just run the [basic kerberoasting PowerShell
script](./basic_kerberoasting.ps1).

The script sets up IIS on the Windows 2019 server and configures the default app
pool to run using the `iissvc` service account. It also configures the
appropriate HTTP SPNs for the `iissvc` account and configures the default
website to use Kerberos authentication. This creates a somewhat realistic
scenario with a web app running as a service account and using Kerberos for
authentication (e.g., for SSO within a domain).

You now have a kerberoastable domain account (`iissvc`) with a weak password, have fun!
