#!/bin/sh

# Copyright 2026 Benjamin Sebastian
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     https://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

filePath="/etc/host_ip_address_port"
IFS= read -r hostIPAddressAndPort < $filePath || [[ -n "$hostIPAddressAndPort" ]]

hostIPAddress="${hostIPAddressAndPort%:*}"
port="${hostIPAddressAndPort##*:}"

echo "Connecting to host at ${hostIPAddress}:${port} ..."

if ! nc -z -w3 "$hostIPAddress" "$port" 2>/dev/null; then
    echo "Error connecting to host at ${hostIPAddress}:${port}."
    read -p "Press [Enter] to continue ..."
    exit 1
fi

echo "WARNING: This will wipe this virtual machine immediately."
printf "Are you sure? (Y/N): "
read -r answer

if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
    echo "Initiating host-side rebuild..."
    
    # Force system sync to finish writing log dumps
    sync
    
    echo "Reimage: $(hostname)" | socat - TCP4:${hostIPAddress}:${port}
else
    echo "Reimage aborted."
fi
