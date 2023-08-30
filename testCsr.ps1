# function to prompt the user for additional information
function prompt_for_additional_info() {
    $server_name = Read-Host "enter the server or host name (e.g., computer1)"
    $dns_names = Read-Host "enter the dns names (comma-separated, e.g., www.example.com,subdomain.example.com)"
    $ip_addresses = Read-Host "enter the ip addresses (comma-separated, e.g., 192.168.0.1,10.0.0.1)"
    $country = Read-Host "enter the country (2-letter code, e.g., us)"
    $state = Read-Host "enter the state"
    $city = Read-Host "enter the city"
    $organization = Read-Host "enter the organization"
    $org_unit = Read-Host "enter the organizational unit"
    $email = Read-Host "enter the email address"

    # set the common_name and dir_name based on server_name and domain_name
    if (-not [string]::IsNullOrEmpty($server_name)) {
        $common_name = "$server_name.$domain_name"
        $dir_name = $server_name
    }
    else {
        $common_name = $domain_name
        $dir_name = $common_name
    }

    # make a directory to contain the private key and csr files
    New-Item -ItemType Directory -Force -Path $dir_name | Out-Null
}

# function to generate the private key
function generate_private_key() {
    $rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider(4096)
    $rsa.PersistKeyInCsp = $true
    $rsa.ExportParameters($true) | Out-File -Encoding ASCII "$dir_name\$common_name.key"
}

# function to generate the csr with alternate names
function generate_csr() {
    # process the dns names
    $dns_array = $dns_names.Split(',')
    $dns_alt_names = $dns_array.ForEach({ "dns:$_" }) -join ','

    # process the ip addresses
    $ip_array = $ip_addresses.Split(',')
    $ip_alt_names = $ip_array.ForEach({ "ip:$_" }) -join ','

    # generate the csr with alternate names
    $alt_names = "$dns_alt_names,$ip_alt_names"
    $csr_subject = "/c=$country/st=$state/l=$city/o=$organization/ou=$org_unit/cn=$common_name/emailaddress=$email"

    if ([string]::IsNullOrEmpty($alt_names)) {
        $params = @{
            KeyFile = "$dir_name\$common_name.key"
            OutFile = "$dir_name\$common_name.csr"
            Subject = $csr_subject
        }
    }
    else {
        $params = @{
            KeyFile = "$dir_name\$common_name.key"
            OutFile = "$dir_name\$common_name.csr"
            Subject = $csr_subject
            Extensions = @("2.5.29.17={text}""$alt_names""")
        }
    }

    & certreq.exe -new $params
}

# main script
# function to prompt the user for input (with validation for domain_name)
do {
    $domain_name = Read-Host "enter the domain name (e.g., example.com)"
    if ([string]::IsNullOrEmpty($domain_name)) {
        Write-Host "common name cannot be empty. please try again."
    }
} until (![string]::IsNullOrEmpty($domain_name))

# prompt for additional information
prompt_for_additional_info

# generate the private key
generate_private_key

# generate the csr with alternate names
generate_csr

# print the csr
Get-Content "$dir_name\$common_name.csr"
