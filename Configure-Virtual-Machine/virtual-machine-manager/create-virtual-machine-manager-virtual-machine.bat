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
    sudo virt-install --name "$virtualMachineName" --memory $((memorySizeInGb * 1024)) --vcpus 1 --disk path=/var/lib/libvirt/images/"$virtualMachineName".qcow2,size="$hardDriveSizeInGb" --os-variant alpinelinux3.17 --cdrom "$isoImagePath" --network bridge="$networkBridgeName",mac="$macAddress" --graphics spice --controller type=usb,model=qemu-xhci --input type=keyboard,bus=usb --input type=mouse,bus=usb --boot firmware=efi,firmware.feature0.name=secure-boot,firmware.feature0.enabled=no,cdrom,hd,menu=on
    exitCode=$?
    if [ $exitCode != 0 ]
    then
        echo ""
        echo "Error creating new virtual machine: $virtualMachineName from: $2. exitCode: $exitCode"
    else
        echo ""
        virtualMachineState=$(sudo virsh list --all --name | grep -w "$virtualMachineName" | xargs -r sudo virsh domstate 2>/dev/null)
        while [[ "$virtualMachineState" != "shut off" && "$virtualMachineState" != "crashed" ]]; do
            echo "The current state of $virtualMachineName is: $virtualMachineState. Sleeping ..."
            sleep 30
            virtualMachineState=$(sudo virsh list --all --name | grep -w "$virtualMachineName" | xargs -r sudo virsh domstate 2>/dev/null)
        done
        sudo virsh snapshot-create-as --domain "$virtualMachineName" --name "BaseSnapshot" --atomic
        echo ""
        sudo virsh start "$virtualMachineName"
        echo ""
        echo "Created new virtual machine: $virtualMachineName from: $2."
    fi
fi

echo ""
