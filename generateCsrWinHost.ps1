# Define the variables for the CSR
$CommonName = "example.com"
$Country = "US"
$State = "California"
$City = "Los Angeles"
$Organization = "Example Organization"
$Department = "IT"

# Generate a new private key
$PrivateKey = New-SelfSignedCertificate -CertStoreLocation cert:\LocalMachine\My -DnsName $CommonName -KeyExportPolicy Exportable -KeyUsage DigitalSignature -Type DocumentEncryptionCert -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider"

# Create a certificate request using the private key
$CSR = New-CertificateRequest -CertReq -Subject "CN=$CommonName, C=$Country, S=$State, L=$City, O=$Organization, OU=$Department" -KeySpec KeyExchange -HashAlgorithm SHA256 -KeyExportPolicy Exportable -KeyAlgorithm RSA -KeyLength 2048 -PrivateKey $PrivateKey

# Save the CSR to a file
$CSR | Set-Content -Path "C:\path\to\csr.csr" -Encoding ASCII

Write-Host "Certificate Signing Request (CSR) generated successfully."
