# csr-generation-script

Bash &amp; PowerShell scripts to automate the generation of certificate signing request on servers.

## Example usage

On the Linux host machine run the script file as below.

```bash
chmod +x generateCsrNixHost.sh
./generateCsrNixHost.sh
Enter the Domain Name (e.g., example.com): egg.com
Enter the Server or Host Name (e.g., computer1): ca1
Enter the DNS names (comma-separated, e.g., www.example.com,subdomain.example.com): ca2.egg.com
Enter the IP addresses (comma-separated, e.g., 192.168.0.1,10.0.0.1): 10.1.1.1
Enter the Country (2-letter code, e.g., US): SG
Enter the State: SG
Enter the City: SIN
Enter the Organization: egg corp
Enter the Organizational Unit: cyber egg
Enter the Email Address: admin@egg.com
```

On the windows machine you will need to install a few tools before running the script.

Install sudo via scoop

```powershell
scoop install sudo
```

Install chocolatey - https://chocolatey.org/install

Install openssl

```powershell
sudo choco install openssl
```

```powershell
.\generateCsrWinHost.ps1
```