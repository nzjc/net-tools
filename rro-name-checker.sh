#!/bin/bash
## Purpose of this script is to take in a space (or comma, or both) separated line of IPs, such as from a Route Record Object in MPLS - and query them for their names. 
## It could be used as part of a larger tool to help network operators see an MPLS RRO path, for instance. Replace dns_server with your own.
## Usage rro-name-checker.sh "10.1.1.1 10.20.2.2 10.40.4.4"
## This will spit out your DNS names (probably for loopbacks or interface IPs, if they're in your DNS!)

# Check if an argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 'ip1 ip2 ip3 ...'"
  exit 1
fi

# DNS server to use
dns_server="192.168.0.1" ##example only

# Read the input string of IP addresses and remove all commas
ip_addresses=$(echo $1 | tr -d ',')

# Split the string into an array
IFS=' ' read -r -a ip_array <<< "$ip_addresses"

# Loop through each IP address and perform a DNS query
for ip in "${ip_array[@]}"; do
  # Perform the DNS query using the specified DNS server
  name=$(nslookup $ip $dns_server | grep 'name =' | awk '{print $4}' | sed 's/\.mydomain\.net\.$//') ## the final sed is to clean up DNS records to remove trailing TLD etc - edit as you wish 

  # Check if a name was found
  if [ -z "$name" ]; then
    echo "$ip: No DNS name found"
  else
    echo "$ip: $name"
  fi
done
