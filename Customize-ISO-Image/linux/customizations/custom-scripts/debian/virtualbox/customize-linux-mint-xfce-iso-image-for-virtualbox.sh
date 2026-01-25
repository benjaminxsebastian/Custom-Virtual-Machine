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
else
    customizeIsoImageScriptStartTime=`date +%s`

    exitCode=0

    echo "$5" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
    source "/home/$4/custom-scripts/virtualbox/create-shared-directory.sh" "$6"
    if [ $exitCode == 0 ]
    then
        echo "$5" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
        mkdir -p "$3"
        cd "/home/$4"
        git clone https://github.com/benjaminxsebastian/Custom-Virtual-Machine.git
        echo "$5" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null    

        scriptsDirectory="/home/$4/Custom-Virtual-Machine/Customize-ISO-Image/linux"
        cd "$scriptsDirectory"
        isoUtilitiesDirectory="$scriptsDirectory/../iso-utilities/debian"
        customizationsDirectory="customizations"
        destinationDirectory="$(readlink -f $3)"

        echo "Customizing ISO image from: $2 into directory: $destinationDirectory"
        echo ""

        echo "$5" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
        mkdir -p "$destinationDirectory"
        source "$isoUtilitiesDirectory/fetch-iso-image.sh" "$2" "$destinationDirectory"
        if [ $exitCode == 0 ]
        then
            echo "$5" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
            source "$isoUtilitiesDirectory/extract-iso-image.sh" "$destinationIsoImagePath" "$destinationDirectory"
            if [ $exitCode == 0 ]
            then
                echo "$5" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
                sudo cp -r -v -f "$scriptsDirectory/$customizationsDirectory" "$destinationIsoImageDirectory"
                sudo mkdir -p "$destinationIsoImageDirectory/preseed"
                sudo cp -r -v -f "$destinationIsoImageDirectory/$customizationsDirectory/preseed/custom-linuxmint.seed" "$destinationIsoImageDirectory/preseed"
                sudo sed -i "s/<VIRTUAL MACHINE NAME>/$1/g" "$destinationIsoImageDirectory/preseed/custom-linuxmint.seed"
                sudo sed -i "s/<USER NAME>/$4/g" "$destinationIsoImageDirectory/preseed/custom-linuxmint.seed"
                sudo sed -i "s/<USER PASSWORD>/$5/g" "$destinationIsoImageDirectory/preseed/custom-linuxmint.seed"
                sudo sed -i "s/<VIRTUALIZATION PLATFORM>/virtualbox/g" "$destinationIsoImageDirectory/preseed/custom-linuxmint.seed"
                sudo sed -i "s/<USER NAME>/$4/g" "$destinationIsoImageDirectory/$customizationsDirectory/customize-virtualbox-linux-mint-xfce-installation.sh"
                sudo sed -i "s/<USER NAME>/$4/g" "$destinationIsoImageDirectory/$customizationsDirectory/launch-customize-virtualbox-linux-mint-xfce-installation-script.desktop"
                sudo sed -i "s/<USER PASSWORD>/$5/g" "$destinationIsoImageDirectory/$customizationsDirectory/launch-customize-virtualbox-linux-mint-xfce-installation-script.desktop"
                sudo cp -r -v -f "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/debian/." "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts"
                sudo sed -i "s/<USER NAME>/$4/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/configure-firefox.sh"
                sudo sed -i "s/<USER NAME>/$4/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/install-additional-packages.sh"
                sudo sed -i "s/<USER NAME>/$4/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/virtualbox/create-shared-directory.sh"
                sudo sed -i "s/<USER NAME>/$4/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/virtualbox/install-virtualbox-guest-additions.sh"
                sudo sed -i "s/<USER NAME>/$4/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/virtualbox/launch-install-virtualbox-guest-additions-script.desktop"
                sudo sed -i "s/<USER PASSWORD>/$5/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/virtualbox/launch-install-virtualbox-guest-additions-script.desktop"
                sudo cp -v -f "$destinationIsoImageDirectory/boot/grub/grub.cfg" "$destinationIsoImageDirectory/boot/grub/grub.cfg.original"
                sudo sed -i '0,/menuentry "Start Linux Mint/{s,menuentry "Start Linux Mint,set default="0"\nset timeout=3\n\nmenuentry "Automatically Install Linux Mint Xfce" --class linuxmint {\n\tset gfxpayload=keep\n\tlinux	/casper/vmlinuz  file=/cdrom/preseed/custom-linuxmint.seed automatic-ubiquity boot=casper iso-scan/filename=${iso_path} noprompt quiet splash --\n\tinitrd	/casper/initrd.lz\n}\nmenuentry "Start Linux Mint,}' "$destinationIsoImageDirectory/boot/grub/grub.cfg"
                source "$isoUtilitiesDirectory/create-bootable-iso-image.sh" "isolinux" "$destinationIsoImageDirectory" "$destinationDirectory"
                if [ $exitCode == 0 ]
                then
                    echo "$5" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
                    sudo cp -r -v -f "$destinationCustomIsoImagePath" "$sharedDirectoryPath"
                    echo ""
                    echo "Customized ISO image: $destinationCustomIsoImagePath from: $2"
                fi
            fi
        fi
    fi
    customizeIsoImageScriptEndTime=`date +%s`
    echo ""
    echo "Runtime [${BASH_SOURCE[0]}]:" $((customizeIsoImageScriptEndTime-customizeIsoImageScriptStartTime)) "seconds."
fi

echo ""

exit $exitCode
