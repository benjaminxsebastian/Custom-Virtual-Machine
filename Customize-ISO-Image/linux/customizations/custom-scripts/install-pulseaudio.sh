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
    grepStatus=-1
    sourcesList="official-source-repositories.list"
    sourcesListPath="/etc/apt/sources.list.d/$sourcesList"
    sourcesListTempPath="$HOME/$sourcesList"

    echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
    if [ -f  "$sourcesListPath" ]
    then
        sudo cp -v -f "$sourcesListPath" "$sourcesListTempPath"
        sudo grep -i -q "^deb-src http://security.ubuntu.com/ubuntu" "$sourcesListTempPath"
        grepStatus=$?
    fi
    if [ $grepStatus != 0 ]
    then
        sudo echo "deb-src http://security.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse" >> "$sourcesListTempPath"
        sudo mv -v -f "$sourcesListTempPath" "$sourcesListPath"
    fi
    sudo apt-get update
    echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
    sudo apt build-dep pulseaudio -y
    cd "$HOME"
    echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
    sudo git clone https://gitlab.freedesktop.org/pulseaudio/pulseaudio.git
    cd "$HOME/pulseaudio"
    echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
    sudo meson build
    echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
    sudo ninja -C build
    echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
    sudo meson --prefix="$HOME/pulseaudio" build
    echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
    sudo ninja -C build install
    cd "$HOME"
    echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
    sudo git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git
    cd "$HOME/pulseaudio-module-xrdp"
    echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
    sudo ./bootstrap
    echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
    sudo ./configure PULSE_DIR="$HOME/pulseaudio"
    echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
    sudo make
    cd "$HOME/pulseaudio-module-xrdp/src/.libs"
    echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
    sudo install -t "/var/lib/xrdp-pulseaudio-installer" -D -m 644 *.so
    echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
    if [ $grepStatus == -1 ]
    then
        sudo rm -r -f "$sourcesListPath"
    fi
    cd "$HOME"
fi
