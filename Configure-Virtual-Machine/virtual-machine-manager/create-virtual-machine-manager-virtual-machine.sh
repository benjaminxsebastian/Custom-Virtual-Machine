#!/bin/bash

# Copyright 2023 Benjamin Sebastian
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo ""

if [ -z "$1" ]
then
    echo "Virtual machine name NOT specified!"
elif [ -z "$2" ]
then
    echo "Path to Customized Install ISO NOT specified!"
else
    virtualMachineName="$1"
    lastCharacter="${virtualMachineName: -1}"
    if ! [[ "$lastCharacter" =~ ^[0-9]$ ]]; then
        lastCharacter="0"
    fi
    isoImagePath="$2"
    memorySizeInGb=2
    hardDriveSizeInGb=10
    networkBridgeName="br0"
    macAddress="52:54:00:00:00:0${lastCharacter}"

    if sudo virsh list --all | grep -q "$virtualMachineName"; then
        if sudo virsh list | grep -q "$virtualMachineName"; then
            sudo virsh destroy "$virtualMachineName"
        fi
        snapshots=$(sudo virsh snapshot-list --domain "$virtualMachineName" --name)
        for snapshot in ${snapshots}; do
            echo "Deleting $virtualMachineName snapshot: $snapshot ..."
            sudo virsh snapshot-delete --domain "$virtualMachineName" --snapshotname "$snapshot"
        done
        sudo virsh undefine "$virtualMachineName" --nvram --remove-all-storage
        echo "The virtual machine: $virtualMachineName and its associated storage have been removed."
        echo ""
    fi
    echo "Creating new virtual machine: $virtualMachineName ..."
    sudo virt-install --name "$virtualMachineName" --memory $((memorySizeInGb * 1024)) --vcpus 1 --disk path=/var/lib/libvirt/images/"$virtualMachineName".qcow2,size="$hardDriveSizeInGb" --os-variant alpinelinux3.17 --cdrom "$isoImagePath" --network bridge="$networkBridgeName",mac="$macAddress" --graphics spice --controller type=usb,model=qemu-xhci --input type=keyboard,bus=usb --input type=mouse,bus=usb --boot firmware=efi,firmware.feature0.name=secure-boot,firmware.feature0.enabled=no,cdrom,hd,menu=on --channel unix,target.type=virtio,target.name=org.qemu.guest_agent.0
    exitCode=$?
    if [ $exitCode != 0 ]
    then
        echo ""
        echo "Error creating new virtual machine: $virtualMachineName from: $2. exitCode: $exitCode"
    else
        virtualMachineState=$(sudo virsh list --all --name | grep -w "$virtualMachineName" | xargs -r sudo virsh domstate 2>/dev/null)
        while [[ "$virtualMachineState" != "shut off" && "$virtualMachineState" != "crashed" ]]; do
            echo "The current state of $virtualMachineName is: $virtualMachineState. Sleeping ..."
            sleep 10
            virtualMachineState=$(sudo virsh list --all --name | grep -w "$virtualMachineName" | xargs -r sudo virsh domstate 2>/dev/null)
        done
        echo ""
        sudo virsh start "$virtualMachineName"
        echo ""
        sudo virsh autostart "$virtualMachineName"
        echo ""
        echo "Waiting for QEMU guest agent to become responsive on "$virtualMachineName" ..."
        while true; do
            if sudo virsh qemu-agent-command "$virtualMachineName" "{\"execute\": \"guest-ping\"}" &>/dev/null; then
                echo "QEMU guest agent is connected and responding on "$virtualMachineName""
                break
            fi
            sleep 1
        done
        echo "Waiting for QEMU guest agent to become responsive on "$virtualMachineName" ..."
        while true; do
            if sudo virsh qemu-agent-command "$virtualMachineName" "{\"execute\": \"guest-ping\"}" &>/dev/null; then
                echo "QEMU guest agent is connected and responding on "$virtualMachineName""
                break
            fi
            sleep 1
        done
        echo ""
        echo "Updating host IP address in new virtual machine: "$virtualMachineName" ..."
        ipAddress=$(ip -4 addr show | grep -oP "(?<=inet\s)\d+(\.\d+){3}" | grep -v "127.0.0.1" | head -n 1)
        port="23039"
        if [ -n "$ipAddress" ]; then
            # Set up the server listener
            virtualMachineCommandsListenerScript="$HOME/virtual-machine-commands-listener.sh"
            cat > "$virtualMachineCommandsListenerScript" << EOF
#!/bin/bash

# Copyright 2023 Benjamin Sebastian
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

while read -r virtualMachineComand; do
    # Skip empty lines
    [[ -z "\$virtualMachineComand" ]] && continue

    if [[ "\$virtualMachineComand" == *":"* ]]; then
        action=\$(echo "\${virtualMachineComand%%:*}" | xargs)
        virtualMachineName=\$(echo "\${virtualMachineComand#*:}" | xargs)

        if [[ "\$action" == "Reimage" ]]; then
            echo "\$(date): Received REIMAGE command for: \$virtualMachineName. Reimaging ..."
            "$HOME/reimage-virtual-machine-manager-virtual-machine.sh" "\$virtualMachineName"
        fi
    fi
done

echo ""

EOF
            sudo chmod +x "$virtualMachineCommandsListenerScript"
            virtualMachineCommandsListenerServiceName="virtual-machine-commands-listener"
            virtualMachineCommandsListenerService="/etc/systemd/system/"$virtualMachineCommandsListenerServiceName".service"
            tempVirtualMachineCommandsListenerService="$HOME/"$virtualMachineCommandsListenerServiceName".service"
            sudo cat > "$tempVirtualMachineCommandsListenerService" << EOF
[Unit]
Description=Virtual Machine Commands Listener
After=libvirtd.service

[Service]
ExecStart=/usr/bin/socat TCP-LISTEN:"$port",bind="$ipAddress",reuseaddr,fork EXEC:"$virtualMachineCommandsListenerScript"
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
            sudo systemctl stop "$virtualMachineCommandsListenerServiceName"
            sudo cp -f "$tempVirtualMachineCommandsListenerService" "$virtualMachineCommandsListenerService"
            sudo systemctl daemon-reload
            sudo systemctl enable "$virtualMachineCommandsListenerServiceName"
            sudo systemctl start "$virtualMachineCommandsListenerServiceName"
            # Set up the client
            ipAddressAndPortInBase64=$(echo -n "$ipAddress:$port" | base64 | tr -d '\n')
            filePathOnGuestVirtualMachine="/etc/host_ip_address_port"
            fileOpenResult=$(sudo virsh qemu-agent-command "$virtualMachineName" "{\"execute\": \"guest-file-open\", \"arguments\": {\"path\": \""$filePathOnGuestVirtualMachine"\", \"mode\": \"w+\"}}")
            fileHandle=$(echo "$fileOpenResult" | jq -r '.return')
            if [ -n "$fileHandle" ]; then
                echo "Opened file $filePathOnGuestVirtualMachine on $virtualMachineName with handle $fileHandle"
                fileWriteResult=$(sudo virsh qemu-agent-command "$virtualMachineName" "{\"execute\": \"guest-file-write\", \"arguments\": {\"handle\": "$fileHandle", \"buf-b64\": \""$ipAddressAndPortInBase64"\"}}")
                echo "Wrote \""$ipAddressAndPortInBase64"\" into file $filePathOnGuestVirtualMachine on $virtualMachineName with handle $fileHandle: $fileWriteResult"
                fileCloseResult=$(sudo virsh qemu-agent-command "$virtualMachineName" "{\"execute\": \"guest-file-close\", \"arguments\": {\"handle\": "$fileHandle"}}")
                echo "Closed file $filePathOnGuestVirtualMachine on $virtualMachineName with handle $fileHandle: $fileCloseResult"
            else
                echo "Error opening file $filePathOnGuestVirtualMachine on $virtualMachineName: $fileOpenResult"
            fi
            echo ""
            sudo virsh shutdown "$virtualMachineName"
            virtualMachineState=$(sudo virsh list --all --name | grep -w "$virtualMachineName" | xargs -r sudo virsh domstate 2>/dev/null)
            while [[ "$virtualMachineState" != "shut off" && "$virtualMachineState" != "crashed" ]]; do
                echo "The current state of $virtualMachineName is: $virtualMachineState. Sleeping ..."
                sleep 10
                virtualMachineState=$(sudo virsh list --all --name | grep -w "$virtualMachineName" | xargs -r sudo virsh domstate 2>/dev/null)
            done
            echo ""
            sudo virsh snapshot-create-as --domain "$virtualMachineName" --name "BaseSnapshot" --atomic
            echo ""
            sudo virsh start "$virtualMachineName"
            echo ""
            echo "Created new virtual machine: $virtualMachineName from: $2."
        else
            echo "Error: Unable to find host IP address!"
        fi
    fi
fi

echo ""
