#!/bin/bash
## Script will take in an RRO/ERO style list of IPs and reverse look em up, then print a little graph 
# Check if an argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 'ip1(flag=...) ip2(flag=...) ...'"
  exit 1
fi

# DNS server to use
dns_server="192.168.12.1"

# Extract only the dotted decimal IP addresses from the input
ip_addresses=$(echo "$1" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b')

# Split the string into an array
IFS=$'\n' read -r -d '' -a ip_array <<< "$ip_addresses"

# Declare an array to store unique hostnames
unique_hostnames=()

# Loop through each IP address and perform a DNS query
for ip in "${ip_array[@]}"; do
  # Perform the DNS query using the specified DNS server
  name=$(nslookup "$ip" "$dns_server" | grep 'name =' | awk '{print $4}' | sed 's/\.packetfabric\.net\.$//')

  # Extract the important part of the DNS name
  important_part=$(echo "$name" | grep -oE '[a-z]{3}[0-9]\.[a-z]{3}[0-9]')

  # Check if the important part was found
  if [ -z "$important_part" ]; then
    echo "$ip: No DNS name found"
  else
    echo "$ip: $important_part"

    # Check if the hostname is already in the list
    if [[ ! " ${unique_hostnames[@]} " =~ " ${important_part} " ]]; then
      unique_hostnames+=("$important_part")
    fi
  fi
done

# Draw the graph of unique hosts
echo -e "\nGraph of Unique Hosts:"
for ((i = 0; i < ${#unique_hostnames[@]}; i++)); do
  hostname="${unique_hostnames[$i]}"

  # Calculate the number of spaces needed to align the hostname
  if [ ${#hostname} -eq 7 ]; then
    padding="    "
  else
    padding="   "
  fi

  echo "+-------------+"
  echo "| ${hostname}${padding}|"
  echo "+-------------+"

  # Check if there is a next hostname to connect
  if [ $i -lt $((${#unique_hostnames[@]} - 1)) ]; then
    echo "       |"
    echo "       v"
  fi
done
