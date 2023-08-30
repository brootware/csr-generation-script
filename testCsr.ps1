# prompt the user for all needed information
while ($true) {
    $domain_name = Read-Host "enter the domain name (e.g., example.com)"
    if ([string]::IsNullOrEmpty($domain_name)) {
        Write-Host "common name cannot be empty. please try again."
    }
    else {
        break
    }
}
$server_name = Read-Host "enter the server or host name (e.g., computer1)"
$dns_names = Read-Host "enter the dns names (comma-separated, e.g., www.example.com,subdomain.example.com)"
$ip_addresses = Read-Host "enter the ip addresses (comma-separated, e.g., 192.168.0.1,10.0.0.1)"
$country = Read-Host "enter the country (2-letter code, e.g., us)"
$state = Read-Host "enter the state"
$city = Read-Host "enter the city"
$organization = Read-Host "enter the organization"
$org_unit = Read-Host "enter the organizational unit"
$email = Read-Host "enter the email address"

if ([string]::IsNullOrEmpty($server_name)) {
    $common_name = $domain_name
    $dir_name = $common_name
}
else {
    $common_name = "$server_name.$domain_name"
    $dir_name = $server_name
}

# make a directory to contain the private key and csr files
New-Item -ItemType Directory -Path $dir_name | Out-Null


# Generate the private key
openssl genpkey -algorithm rsa -out "$dir_name\$common_name.key" -pkeyopt rsa_keygen_bits:4096


# Generate the csr with alternate names
# process the dns names
$dns_array = $dns_names -split ","
$dns_alt_names = ""
foreach ($dns in $dns_array) {
    $dns_alt_names += "dns:$dns,"
}

# process the ip addresses
$ip_array = $ip_addresses -split ","
$ip_alt_names = ""
foreach ($ip in $ip_array) {
    $ip_alt_names += "ip:$ip,"
}

# generate the csr with alternate names
$alt_names = $dns_alt_names + $ip_alt_names
$csr_subject = "/c=$country/st=$state/l=$city/o=$organization/ou=$org_unit/cn=$common_name/emailaddress=$email"

if ([string]::IsNullOrEmpty($alt_names)) {
    openssl req -new -key "$dir_name\$common_name.key" -out "$dir_name\$common_name.csr" -subj "$csr_subject"
}
else {
    openssl req -new -key "$dir_name\$common_name.key" -out "$dir_name\$common_name.csr" -subj "$csr_subject" -addext "subjectaltname=${alt_names.TrimEnd(',')}"
}

# print the csr
Get-Content "$dir_name\$common_name.csr"
