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
    echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
    polkitAuthorizationFile="45-allow-colord.pkla"
    polkitAuthorizationFilePath="/etc/polkit-1/localauthority/50-local.d/$polkitAuthorizationFile"
    if [ ! -f  "$polkitAuthorizationFilePath" ]
    then
        touch "$HOME/$polkitAuthorizationFile"
        chmod +w "$HOME/$polkitAuthorizationFile"
        echo "[Allow Colord all Users]" >> "$HOME/$polkitAuthorizationFile"
        echo "Identity=unix-user:*" >> "$HOME/$polkitAuthorizationFile"
        echo "Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile" >> "$HOME/$polkitAuthorizationFile"
        echo "ResultAny=no" >> "$HOME/$polkitAuthorizationFile"
        echo "ResultInactive=no" >> "$HOME/$polkitAuthorizationFile"
        echo "ResultActive=yes" >> "$HOME/$polkitAuthorizationFile"
        sudo mv -v -f "$HOME/$polkitAuthorizationFile" "$polkitAuthorizationFilePath"
    fi
    sudo apt install libpulse-dev autoconf m4 intltool build-essential dpkg-dev libtool libsndfile-dev libspeexdsp-dev libudev-dev doxygen meson ninja-build -y
fi
