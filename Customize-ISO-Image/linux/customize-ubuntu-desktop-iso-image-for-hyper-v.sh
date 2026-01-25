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

exitCode=2

if [ -z "$1" ]
then
    echo "Virtual machine name NOT specified!"
elif [ -z "$2" ]
then
    echo "Path to ISO image NOT specified!"
elif [ -z "$3" ]
then
    echo "Destination ISO image directory path NOT specified!"
elif [ -z "$4" ]
then
    echo "Login user name NOT specified!"
elif [ -z "$5" ]
then
    echo "Login user password NOT specified!"
elif [ -z "$6" ]
then
    echo "Share name NOT specified!"
elif [ -z "$7" ]
then
    echo "Share user name NOT specified!"
elif [ -z "$8" ]
then
    echo "Share user password NOT specified!"
elif [ -z "$9" ]
then
    echo "Share user domain NOT specified!"
else
    customizeIsoImageScriptStartTime=`date +%s`

    exitCode=0

    scriptsDirectory="$(dirname "`realpath "${BASH_SOURCE[0]}"`")"
    isoUtilitiesDirectory="$scriptsDirectory/../iso-utilities/debian"
    customizationsDirectory="customizations"
    destinationDirectory="$(readlink -f $3)"

    echo "Customizing ISO image from: $2 into directory: $destinationDirectory"
    echo ""

    mkdir -p "$destinationDirectory"
    source "$isoUtilitiesDirectory/fetch-iso-image.sh" "$2" "$destinationDirectory"
    if [ $exitCode == 0 ]
    then
        source "$isoUtilitiesDirectory/extract-iso-image.sh" "$destinationIsoImagePath" "$destinationDirectory"
        if [ $exitCode == 0 ]
        then
            sudo cp -r -v -f "$scriptsDirectory/$customizationsDirectory" "$destinationIsoImageDirectory"
            sudo mkdir -p "$destinationIsoImageDirectory/nocloud"
            sudo cp -r -v -f "$destinationIsoImageDirectory/$customizationsDirectory/nocloud/user-data" "$destinationIsoImageDirectory/nocloud"
            sudo sed -i "s/<VIRTUAL MACHINE NAME>/$1/g" "$destinationIsoImageDirectory/nocloud/user-data"
            sudo sed -i "s/<USER NAME>/$4/g" "$destinationIsoImageDirectory/nocloud/user-data"
            encryptedPassword=$(mkpasswd -m sha-512 "$5")
            sudo sed -i "s,<ENCRYPTED USER PASSWORD>,$encryptedPassword,g" "$destinationIsoImageDirectory/nocloud/user-data"
            sudo sed -i "s/<VIRTUALIZATION PLATFORM>/hyper-v/g" "$destinationIsoImageDirectory/nocloud/user-data"
            sudo sed -i "s/<USER PASSWORD>/$5/g" "$destinationIsoImageDirectory/nocloud/user-data"
            sudo sed -i "s/<SHARE NAME>/$6/g" "$destinationIsoImageDirectory/nocloud/user-data"
            sudo sed -i "s/<SHARE USER NAME>/$7/g" "$destinationIsoImageDirectory/nocloud/user-data"
            sudo sed -i "s/<SHARE USER PASSWORD>/$8/g" "$destinationIsoImageDirectory/nocloud/user-data"
            sudo sed -i "s/<SHARE USER DOMAIN>/$9/g" "$destinationIsoImageDirectory/nocloud/user-data"
            sudo touch "$destinationIsoImageDirectory/nocloud/meta-data"
            sudo sed -i "s/<USER NAME>/$4/g" "$destinationIsoImageDirectory/$customizationsDirectory/customize-hyper-v-ubuntu-desktop-installation.sh"
            sudo sed -i "s/<USER NAME>/$4/g" "$destinationIsoImageDirectory/$customizationsDirectory/launch-customize-hyper-v-ubuntu-desktop-installation-script.desktop"
            sudo sed -i "s/<USER PASSWORD>/$5/g" "$destinationIsoImageDirectory/$customizationsDirectory/launch-customize-hyper-v-ubuntu-desktop-installation-script.desktop"
            sudo sed -i "s/<SHARE NAME>/$6/g" "$destinationIsoImageDirectory/$customizationsDirectory/launch-customize-hyper-v-ubuntu-desktop-installation-script.desktop"
            sudo sed -i "s/<SHARE USER NAME>/$7/g" "$destinationIsoImageDirectory/$customizationsDirectory/launch-customize-hyper-v-ubuntu-desktop-installation-script.desktop"
            sudo sed -i "s/<SHARE USER PASSWORD>/$8/g" "$destinationIsoImageDirectory/$customizationsDirectory/launch-customize-hyper-v-ubuntu-desktop-installation-script.desktop"
            sudo sed -i "s/<SHARE USER DOMAIN>/$9/g" "$destinationIsoImageDirectory/$customizationsDirectory/launch-customize-hyper-v-ubuntu-desktop-installation-script.desktop"
            sudo cp -r -v -f "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/debian/." "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts"
            sudo sed -i "s/<USER NAME>/$4/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/configure-firefox.sh"
            sudo sed -i "s/<USER NAME>/$4/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/install-additional-packages.sh"
            sudo sed -i "s/<USER NAME>/$4/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/install-pipewire.sh"
            sudo sed -i "s/<USER NAME>/$4/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/hyper-v/setup-remote-desktop.sh"
            sudo sed -i "s/<USER NAME>/$4/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/hyper-v/create-shared-directory.sh"
            sudo sed -i "s/<USER NAME>/$4/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/hyper-v/create-remote-desktop-shortcut.sh"
            sudo mkdir -p "$destinationIsoImageDirectory/$customizationsDirectory/$4"
            sudo mv -v -f "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts" "$destinationIsoImageDirectory/$customizationsDirectory/$4"
            sudo cp -v -f "$destinationIsoImageDirectory/boot/grub/grub.cfg" "$destinationIsoImageDirectory/boot/grub/grub.cfg.original"
            sudo sed -i '0,/set timeout=30/{s,set timeout=30,set default="0"\nset timeout=3,}' "$destinationIsoImageDirectory/boot/grub/grub.cfg"
            sudo sed -i 's,menuentry "Try or Install Ubuntu",menuentry "Automatically Install Ubuntu" {\n\tset gfxpayload=keep\n\tlinux\t/casper/vmlinuz quiet autoinstall ds=nocloud\\;s=/cdrom/nocloud/ ---\n\tinitrd\t/casper/initrd\n}\nmenuentry "Try or Install Ubuntu",' "$destinationIsoImageDirectory/boot/grub/grub.cfg"
            source "$isoUtilitiesDirectory/create-bootable-iso-image.sh" "grub" "$destinationIsoImageDirectory" "$destinationDirectory"
            if [ $exitCode == 0 ]
            then
                echo ""
                echo "Customized ISO image: $destinationCustomIsoImagePath from: $2"
            fi
        fi
    fi
    customizeIsoImageScriptEndTime=`date +%s`
    echo ""
    echo "Runtime [${BASH_SOURCE[0]}]:" $((customizeIsoImageScriptEndTime-customizeIsoImageScriptStartTime)) "seconds."
fi

echo ""

exit $exitCode
