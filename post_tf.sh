#!/bin/bash
# This script will use terraform outputs to create an ansible inventory file
tf_refresh=$(tofu refresh)
tf_output=$(tofu output -json)

#Check if environment variables are set if not exit
if [ -z "$SERVER_USER" ] || [ -z "$SERVER_PASSWORD" ]; then
  echo "Please set the SERVER_USER and SERVER_PASSWORD environment variables"
  exit 1
fi

# Set the variables from environment variables
server_user=${SERVER_USER}
server_password=${SERVER_PASSWORD}

echo "Creating Master and Worker inventory file"
echo "[master]" > inventory
master=$(echo $tf_output | jq -r '.ips.value[0][0]' | tr '\n' ' ')
echo master ansible_host=${master} ansible_ssh_user=${server_user} >> inventory

# Parse the json output for first element of the tuple
count=0
ips=$(echo $tf_output | jq -r '.ips.value[1:][][0]' | tr '\n' ' ')
echo "[workers]" >> inventory
for ip in $ips; do
  echo k8s-${count} ansible_host=${ip} ansible_ssh_user=${server_user} >> inventory
  count=$((count+1))
done
echo "Inventory file created"
