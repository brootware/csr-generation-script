param(
    [Parameter(Mandatory=$true)]
    [string]$HostName = $(Throw "Error: No hostname argument provided. Usage: Provide a hostname as an argument."),
    [Parameter(Mandatory=$true)]
    [string]$domain = $(Throw "Error: No domain name argument provided. Usage: Provide a domain name as an argument."),
    [Parameter(Mandatory=$true)]
    [string]$Ip = $(Throw "Error: No Ip address argument provided. Usage: Provide an Ip address as an argument.")
)

$HOSTNAME = $Hostname
$DOMAIN = $Domain
$FQDN = "$HOSTNAME.$DOMAIN"
$IP = $Ip

# Create a directory to contain all the artifacts generated
mkdir $HOSTNAME

# Generate a private key for generating CSR
$CreatePrivateKey = "openssl genrsa -out .\$HOSTNAME\$FQDN.key 2048"
Invoke-Expression $CreatePrivateKey

# Create CSR Configuration file
$CsrConf = @"
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = SG
ST = SG
L = SG
O = egg
OU = $HOSTNAME
CN = $FQDN
emalAddress = admin@$DOMAIN

[ req_ext ]
subjectAltNames = @alt_names

[ alt_names ]
DNS.1 = $FQDN
IP.1 = $IP
"@

Set-Content -Path .\$HOSTNAME\csr.conf -Value $CsrConf

# Create CSR using private key
$CreateCsr = "openssl req -new -key .\$HOSTNAME\$FQDN.key -out .\$HOSTNAME\$FQDN.csr -config .\$HOSTNAME\csr.conf"
Invoke-Expression $CreateCsr