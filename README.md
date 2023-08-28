# csr-generation-script
Bash &amp; PowerShell scripts to automate generation of certificate signing request on servers.

## Example usage

On the Linux host machine run the script file as below.

```bash
chmod +x generateCsrNixHost.sh
./generateCsrNixHost.sh -s computer1 -d engineer.org -i 192.168.1.1
```