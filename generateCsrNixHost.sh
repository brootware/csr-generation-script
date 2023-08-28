#!/bin/bash

function create_csr_private_key {
    mkdir $SERVERNAME
    openssl genrsa -out $SERVERNAME/$FQDN.key 4096
    echo "[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = SG
ST = SG
L = Singapore
O = Engineering
OU = $SERVERNAME
CN = $FQDN
emailAddress = admin@$DOMAIN

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $FQDN
IP.1 = $IP" >$SERVERNAME/csr.conf
    openssl req -new -sha256 -key $SERVERNAME/$FQDN.key -out $SERVERNAME/$FQDN.csr -config $SERVERNAME/csr.conf
}

function show_help {
    echo "Usage: ./generateCsrNixHost.sh -s SERVERNAME -d DOMAIN -i IP"
    echo "  -s SERVERNAME   The server or host name of the certificate"
    echo "  -d DOMAIN       The domain name for the certificate"
    echo "  -i IP           The IP address for the certificate"
}

while getopts ":s:d:i:" opt; do
    case $opt in
    s)
        SERVERNAME=$OPTARG
        ;;
    d)
        DOMAIN=$OPTARG
        ;;
    i)
        IP=$OPTARG
        ;;
    esac
done

FQDN="$SERVERNAME.$DOMAIN"

if [[ -z "$SERVERNAME" || -z "$DOMAIN" || -z "$IP" ]]; then
    echo "You must supply all three of the arguments to generate the CSR!"
    show_help
    exit 1
fi

create_csr_private_key
