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
elif [ -z "$5" ]
then
    echo "Share name NOT specified!"
elif [ -z "$6" ]
then
    echo "Share user name NOT specified!"
elif [ -z "$7" ]
then
    echo "Share user password NOT specified!"
elif [ -z "$8" ]
then
    echo "Share user domain NOT specified!"
else
    customizeIsoImageScriptStartTime=`date +%s`

    exitCode=0

    scriptsDirectory="$(dirname "`realpath "${BASH_SOURCE[0]}"`")"
    isoUtilitiesDirectory="$scriptsDirectory/../iso-utilities/debian"
    customizationsDirectory="customizations"
    destinationDirectory="$(readlink -f $2)"

    echo "Customizing ISO image from: $1 into directory: $destinationDirectory"
    echo ""

    mkdir -p "$destinationDirectory"
    source "$isoUtilitiesDirectory/fetch-iso-image.sh" "$1" "$destinationDirectory"
    if [ $exitCode == 0 ]
    then
        source "$isoUtilitiesDirectory/extract-iso-image.sh" "$destinationIsoImagePath" "$destinationDirectory"
        if [ $exitCode == 0 ]
        then
            sudo cp -r -v -f "$scriptsDirectory/$customizationsDirectory" "$destinationIsoImageDirectory"
            cd "$destinationIsoImageDirectory/$customizationsDirectory"
            sudo cp -v -f "$destinationIsoImageDirectory/boot/initramfs-virt" "$destinationIsoImageDirectory/boot/initramfs-virt.original"
            zcat "$destinationIsoImageDirectory/boot/initramfs-virt" | cpio -idm
            sudo sed -i "s/<USER NAME>/$3/g" "$destinationIsoImageDirectory/$customizationsDirectory/customize-hyper-v-alpine-linux-xfce-installation.sh"
            sudo sed -i "s/<USER NAME>/$3/g" "$destinationIsoImageDirectory/$customizationsDirectory/customize-virtualbox-alpine-linux-xfce-installation.sh"
            sudo cp -r -v -f "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/alpine-linux/." "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts"
            sudo sed -i "s/<USER NAME>/$3/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/power-manager.sh"
            sudo sed -i "s/<USER NAME>/$3/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/configure-firefox.sh"
            sudo sed -i "s/<USER NAME>/$3/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/install-pulseaudio.sh"
            sudo sed -i "s/<USER NAME>/$3/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/hyper-v/setup-remote-desktop.sh"
            sudo sed -i "s/<USER NAME>/$3/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/hyper-v/create-shared-directory.sh"
            sudo sed -i "s/<USER NAME>/$3/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/hyper-v/create-remote-desktop-shortcut.sh"
            sudo sed -i "s/<USER NAME>/$3/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/hyper-v/custom-alpinelinux-first-time.start.disabled"
            sudo sed -i "s/<USER PASSWORD>/$4/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/hyper-v/custom-alpinelinux-first-time.start.disabled"
            sudo sed -i "s/<SHARE NAME>/$5/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/hyper-v/custom-alpinelinux-first-time.start.disabled"
            sudo sed -i "s/<SHARE USER NAME>/$6/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/hyper-v/custom-alpinelinux-first-time.start.disabled"
            sudo sed -i "s/<SHARE USER PASSWORD>/$7/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/hyper-v/custom-alpinelinux-first-time.start.disabled"
            sudo sed -i "s/<SHARE USER DOMAIN>/$8/g" "$destinationIsoImageDirectory/$customizationsDirectory/custom-scripts/hyper-v/custom-alpinelinux-first-time.start.disabled"
            sudo sed -i "s/<USER NAME>/$3/g" "$destinationIsoImageDirectory/$customizationsDirectory/launch-customize-hyper-v-alpine-linux-xfce-installation-script.desktop"
            sudo cp -v -f "$destinationIsoImageDirectory/$customizationsDirectory/init" "$destinationIsoImageDirectory/$customizationsDirectory/init.original"
            sudo sed -z -i 's|exec switch_root $switch_root_opts $sysroot $chart_init "$KOPT_init" $KOPT_init_args|cp -v -f ./startup-scripts/* $sysroot/etc/local.d\ncp -v -f ./custom-scripts/hyper-v/custom-alpinelinux-first-time.start.disabled $sysroot/etc/local.d\nchmod a+x $sysroot/etc/local.d/*.start*\nmkdir -p $sysroot/home/customizations\nmkdir -p $sysroot/home/customizations/custom-scripts\ncp -r -v -f ./custom-scripts/* $sysroot/home/customizations/custom-scripts\ncp -v -f ./*customize-*-installation.* $sysroot/home/customizations\ncp -v -f ./launch-customize-hyper-v-alpine-linux-xfce-installation-script.desktop $sysroot/home/customizations\nchmod a+x $sysroot/home/customizations/*\nln -s /etc/init.d/local $sysroot/etc/runlevels/default\nexec switch_root $switch_root_opts $sysroot $chart_init "$KOPT_init" $KOPT_init_args|2' "$destinationIsoImageDirectory/$customizationsDirectory/init"
            sudo rm -r -f "$destinationIsoImageDirectory/boot/initramfs-virt"
            find . | cpio -o -H newc | gzip -1 > "$destinationIsoImageDirectory/boot/initramfs-virt"
            cd "$scriptsDirectory/.."
            source "$isoUtilitiesDirectory/create-bootable-iso-image.sh" "boot/syslinux" "$destinationIsoImageDirectory" "$destinationDirectory"
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
