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

if [ -z "$1" ]
then
    echo "Login user password NOT specified!"
else
    echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
    sudo apt install cifs-utils -y
    echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
    sudo apt install xrdp -y
    if [[ "$XDG_CURRENT_DESKTOP" == "XFCE" ]]; then
        echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
        polkitAuthorizationFile="45-allow-colord.pkla"
        polkitAuthorizationFilePath="/etc/polkit-1/localauthority/50-local.d/$polkitAuthorizationFile"
        if [ ! -f  "$polkitAuthorizationFilePath" ]
        then
            touch "/home/<USER NAME>/$polkitAuthorizationFile"
            chmod +w "/home/<USER NAME>/$polkitAuthorizationFile"
            echo "[Allow Colord all Users]" >> "/home/<USER NAME>/$polkitAuthorizationFile"
            echo "Identity=unix-user:*" >> "/home/<USER NAME>/$polkitAuthorizationFile"
            echo "Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile" >> "/home/<USER NAME>/$polkitAuthorizationFile"
            echo "ResultAny=no" >> "/home/<USER NAME>/$polkitAuthorizationFile"
            echo "ResultInactive=no" >> "/home/<USER NAME>/$polkitAuthorizationFile"
            echo "ResultActive=yes" >> "/home/<USER NAME>/$polkitAuthorizationFile"
            sudo mv -v -f "/home/<USER NAME>/$polkitAuthorizationFile" "$polkitAuthorizationFilePath"
        fi
    fi
    echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
    if echo "$HOSTNAME" | grep -iq "LinuxMint"; then
        sudo apt install build-essential dpkg-dev autoconf libtool m4 intltool doxygen meson ninja-build libpulse-dev libsndfile-dev libspeexdsp-dev libudev-dev -y
    elif echo "$HOSTNAME" | grep -iq "Ubuntu"; then
        sudo apt install pkg-config autotools-dev libtool make gcc libpipewire-0.3-dev libspa-0.2-dev -y
    fi
fi
