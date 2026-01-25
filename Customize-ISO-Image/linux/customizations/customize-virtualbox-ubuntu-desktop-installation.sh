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

exitCode=2

if [[ "$XDG_CURRENT_DESKTOP" == "XFCE" ]]; then
    echo "Running on XFCE ..."
elif [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
    echo "Running on GNOME ..."
else
    echo "Running on UNRECOGNIZED $XDG_CURRENT_DESKTOP desktop environment!"

    exit $exitCode
fi

if [ "$EUID" == 0 ]
then
    echo "Please run this script from a regular user login, and DO NOT use sudo!"
else
    if [ -z "$1" ]
    then
        echo "Login user password NOT specified!"
    else
        source "/home/<USER NAME>/custom-scripts/power-manager.sh"
        source "/home/<USER NAME>/custom-scripts/update.sh" $1
        source "/home/<USER NAME>/custom-scripts/install-common-packages.sh" $1
        source "/home/<USER NAME>/custom-scripts/configure-firefox.sh"
        source "/home/<USER NAME>/custom-scripts/update.sh" $1

        echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
        sudo apt install gnome-shell-extension-manager -y
        gnome-extensions enable ubuntu-dock@ubuntu.com
        gsettings set org.gnome.mutter dynamic-workspaces false
        gsettings set org.gnome.desktop.wm.preferences num-workspaces 1

        launchCustomizationScriptPath="/home/<USER NAME>/.config/autostart/launch-customize-virtualbox-ubuntu-desktop-installation-script.desktop"
        if [ -f  "$launchCustomizationScriptPath" ]
        then
            sudo rm -rf "$launchCustomizationScriptPath"
        fi

        launchInstallGuestAdditionsScriptPath="/home/<USER NAME>/custom-scripts/virtualbox/launch-install-virtualbox-guest-additions-script.desktop"
        sudo mv -v -f "$launchInstallGuestAdditionsScriptPath" "/home/<USER NAME>/.config/autostart"

        sudo sed -i 's/AutomaticLoginEnable=True/# AutomaticLoginEnable=True/' "/etc/gdm3/custom.conf"
        sudo sed -i 's/AutomaticLogin=<USER NAME>/# AutomaticLogin=<USER NAME>/' "/etc/gdm3/custom.conf"
        sudo sed -i 's/NOPASSWD: //g' "/etc/sudoers"

        shutdown now
    fi
fi
