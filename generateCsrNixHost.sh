#!/bin/bash

# Function to prompt the user for additional information
function prompt_for_additional_info() {
    read -p "Enter the Server or Host Name (e.g., computer1): " SERVER_NAME
    read -p "Enter the DNS names (comma-separated, e.g., www.example.com,subdomain.example.com): " DNS_NAMES
    read -p "Enter the IP addresses (comma-separated, e.g., 192.168.0.1,10.0.0.1): " IP_ADDRESSES
    read -p "Enter the Country (2-letter code, e.g., US): " COUNTRY
    read -p "Enter the State: " STATE
    read -p "Enter the City: " CITY
    read -p "Enter the Organization: " ORGANIZATION
    read -p "Enter the Organizational Unit: " ORG_UNIT
    read -p "Enter the Email Address: " EMAIL

    # Set the COMMON_NAME and DIR_NAME based on SERVER_NAME and DOMAIN_NAME
    if [ -z "$SERVER_NAME" ]; then
        COMMON_NAME=$DOMAIN_NAME
        DIR_NAME=$COMMON_NAME
    else
        COMMON_NAME="$SERVER_NAME.$DOMAIN_NAME"
        DIR_NAME=$SERVER_NAME
    fi

    # Make a directory to contain the private key and CSR files
    mkdir $DIR_NAME
}

# Function to generate the private key
function generate_private_key() {
    openssl genpkey -algorithm RSA -out $DIR_NAME/$COMMON_NAME.key -pkeyopt rsa_keygen_bits:4096
}

# Function to generate the CSR with alternate names
function generate_csr() {
    # Process the DNS names
    IFS=',' read -r -a DNS_ARRAY <<<"$DNS_NAMES"
    DNS_ALT_NAMES=""
    for DNS in "${DNS_ARRAY[@]}"; do
        DNS_ALT_NAMES+="DNS:$DNS,"
    done

    # Process the IP addresses
    IFS=',' read -r -a IP_ARRAY <<<"$IP_ADDRESSES"
    IP_ALT_NAMES=""
    for IP in "${IP_ARRAY[@]}"; do
        IP_ALT_NAMES+="IP:$IP,"
    done

    # Generate the CSR with alternate names
    ALT_NAMES="${DNS_ALT_NAMES}${IP_ALT_NAMES}"
    CSR_SUBJECT="/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORGANIZATION/OU=$ORG_UNIT/CN=$COMMON_NAME/emailAddress=$EMAIL"
    if [[ -z "$ALT_NAMES" ]]; then
        openssl req -new -key $DIR_NAME/$COMMON_NAME.key -out $DIR_NAME/$COMMON_NAME.csr -subj "$CSR_SUBJECT"
    else
        openssl req -new -key $DIR_NAME/$COMMON_NAME.key -out $DIR_NAME/$COMMON_NAME.csr -subj "$CSR_SUBJECT" -addext "subjectAltName=${ALT_NAMES::-1}"
    fi
}

# Main script

# Function to prompt the user for input (with validation for DOMAIN_NAME)
while true; do
    read -p "Enter the Domain Name (e.g., example.com): " DOMAIN_NAME
    if [[ -n "$DOMAIN_NAME" ]]; then
        break
    else
        echo "Common Name cannot be empty. Please try again."
    fi
done

# Prompt for additional information
prompt_for_additional_info

# Generate the private key
generate_private_key

# Generate the CSR with alternate names
generate_csr

# Print the CSR
cat $DIR_NAME/$COMMON_NAME.csr
