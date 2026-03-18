# Kerberoasting

## Very Basic Kerberoasting Lab

The script sets up a very basic Kerberoasting lab. It starts by installing IIS on the Windows 2022 member server (`SRV01` by default) and configures the default app pool to run using the `iissvc` service account. It also configures the appropriate HTTP SPNs for the `iissvc` account and configures the default website to use Kerberos authentication. This creates a somewhat realistic scenario with a web app running as a service account and using Kerberos for authentication (e.g., for SSO within a domain).

To set this up, either of the [basic-ad-config](../basic-ad-config.yml) or the [basic-ad-config-with-extras](../basic-ad-config-with-extras.yml) config files can be used. Within the chosen config file, add the `ludus-kerberoasting` role to both `DC01` and `SRV01`. E.g., if using the `basic-ad-config` (no extras), the roles for both `DC01` will look like this:

```
  roles:
    - ludus-ad-content
    - ludus-kerberoasting
```

...and the roles for `SRV01` will look like this:

```
  roles:
    - ludus-kerberoasting
```

Next, you **must** add the `ludus-kerberoasting` role:

```
# Assuming this is executed from the root of this repo:
ludus ansible role add -d ./roles/kerberoasting --force
```

Then just set your config as normal, and deploy. You now have a kerberoastable domain account (`iissvc`) with a weak password, have fun!
