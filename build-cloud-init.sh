#!/bin/bash

# Check if all required arguments are provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <hostname> <username> <sshPublicKey> <devOpsUrl> <token>"
    exit 1
fi

# Assign arguments to variables
hostname=$1
username=$2
sshPubKey=$3
devOpsUrl=$4
token=$5

# Read the template file
template_file="cloud-init-template.yaml"
if [ ! -f "$template_file" ]; then
    echo "Template file $template_file not found!"
    exit 1
fi

# Create a new file for the output
output_file="cloud-init.yaml"

# Replace the placeholders with the provided values
sed -e "s/{hostname}/$hostname/g" \
    -e "s/{username}/$username/g" \
    -e "s/{sshPubKey}/$sshPubKey/g" \
    -e "s|{devOpsUrl}|$devOpsUrl|g" \
    -e "s/{token}/$token/g" \
    "$template_file" > "$output_file"

echo "Cloud-init configuration has been generated in $output_file"