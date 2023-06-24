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
    echo "Path to ISO image NOT specified!"
elif [ -z "$2" ]
then
    echo "Destination ISO image directory path NOT specified!"
elif [ -z "$3" ]
then
    echo "Login user name NOT specified!"
elif [ -z "$4" ]
then
    echo "Login user password NOT specified!"
else
    customizeIsoImageScriptStartTime=`date +%s`

    exitCode=0

    scriptsDirectory="$(dirname "`realpath "${BASH_SOURCE[0]}"`")"
    isoUtilitiesDirectory="$scriptsDirectory/../iso-utilities"
    customizationsDirectory="customizations"
    destinationDirectory="$(readlink -f $2)"

    echo "Customizing ISO image from: $1 into directory: $destinationDirectory"
    echo ""

    mkdir -p "$destinationDirectory"
    source "$isoUtilitiesDirectory/fetch-iso-image.sh" "$1" "$destinationDirectory"
    if [ $exitCode == 0 ]
    then
        source "$isoUtilitiesDirectory/extract-iso-image.sh" "$destinationIsoImagePath" "$destinationDirectory"

    #---
    # If you wish to debug this script without wanting to download and extract the distribution ISO,
    # then please comment out the 2 calls above to the fetch-iso-image.sh and extract-iso-image.sh scripts
    # and uncomment the lines below where the used variables are set.
    #---
    #isoBaseName="$(eval "basename $1 .iso")"
    #isoName="$isoBaseName.iso"
    #destinationIsoImageDirectory="$2/$isoBaseName"
    #destinationIsoImagePath="$2/$isoName"
    #---

        if [ $exitCode == 0 ]
        then
            sudo cp -r -v -f "$scriptsDirectory/$customizationsDirectory" "$destinationIsoImageDirectory"
            sudo cp -v -f "$destinationIsoImageDirectory/customizations/preseed/custom-linuxmint.seed" "$destinationIsoImageDirectory/preseed/custom-linuxmint.seed"
            sudo sed -i "s/<USER NAME>/$3/g" "$destinationIsoImageDirectory/preseed/custom-linuxmint.seed"
            sudo sed -i "s/<USER PASSWORD>/$4/g" "$destinationIsoImageDirectory/preseed/custom-linuxmint.seed"
            sudo sed -i "s/<VIRTUALIZATION PLATFORM>/virtualbox/g" "$destinationIsoImageDirectory/preseed/custom-linuxmint.seed"
            sudo sed -i "s/<USER NAME>/$3/g" "$destinationIsoImageDirectory/customizations/custom-scripts/hyper-v/create-remote-desktop-shortcut.sh"
            sudo sed -i "s/<USER NAME>/$3/g" "$destinationIsoImageDirectory/customizations/custom-scripts/hyper-v/logout-console-session.desktop"
            #sudo cp -v -f "$destinationIsoImageDirectory/isolinux/isolinux.cfg" "$destinationIsoImageDirectory/isolinux/isolinux.cfg.original"
            #sudo sed -i "s/timeout 100/timeout 30/g" "$destinationIsoImageDirectory/isolinux/isolinux.cfg"
            #sudo sed -i 's,menu default,label automatic-install\n  menu label Automatically Install Linux Mint\n  kernel /casper/vmlinuz\n  append  file=/cdrom/preseed/custom-linuxmint.seed automatic-ubiquity boot=casper initrd=/casper/initrd.lz noprompt quiet splash --\nmenu default,' "$destinationIsoImageDirectory/isolinux/isolinux.cfg"
            sudo cp -v -f "$destinationIsoImageDirectory/boot/grub/grub.cfg" "$destinationIsoImageDirectory/boot/grub/grub.cfg.original"
            sudo sed -i '0,/menuentry "Start Linux Mint/{s,menuentry "Start Linux Mint,set default="0"\nset timeout=3\n\nmenuentry "Automatically Install Linux Mint Xfce" --class linuxmint {\n\tset gfxpayload=keep\n\tlinux	/casper/vmlinuz  file=/cdrom/preseed/custom-linuxmint.seed automatic-ubiquity boot=casper iso-scan/filename=${iso_path} noprompt quiet splash --\n\tinitrd	/casper/initrd.lz\n}\nmenuentry "Start Linux Mint,}' "$destinationIsoImageDirectory/boot/grub/grub.cfg"
            source "$isoUtilitiesDirectory/create-bootable-iso-image.sh" "$destinationIsoImageDirectory" "$destinationDirectory"
            if [ $exitCode == 0 ]
            then
                echo ""
                echo "Customized ISO image: $destinationCustomIsoImagePath from: $1"
            fi
        fi
    fi
    customizeIsoImageScriptEndTime=`date +%s`
    echo ""
    echo "Runtime [${BASH_SOURCE[0]}]:" $((customizeIsoImageScriptEndTime-customizeIsoImageScriptStartTime)) "seconds."
fi

echo ""

exit $exitCode
