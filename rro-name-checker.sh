#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 'ip1 ip2 ip3 ...'"
  exit 1
fi

# DNS server to use
dns_server="10.128.15.253"

# Read the input string of IP addresses and remove all commas
ip_addresses=$(echo $1 | tr -d ',')

# Split the string into an array
IFS=' ' read -r -a ip_array <<< "$ip_addresses"

# Loop through each IP address and perform a DNS query
for ip in "${ip_array[@]}"; do
  # Perform the DNS query using the specified DNS server
  name=$(nslookup $ip $dns_server | grep 'name =' | awk '{print $4}' | sed 's/\.mydomain\.net\.$//')

  # Check if a name was found
  if [ -z "$name" ]; then
    echo "$ip: No DNS name found"
  else
    echo "$ip: $name"
  fi
done
