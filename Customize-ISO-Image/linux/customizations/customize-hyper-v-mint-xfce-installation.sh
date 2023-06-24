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

if [ "$EUID" == 0 ]
then
    echo "Please run this script from a regular user login, and DO NOT use sudo!"
else
    if [ -z "$1" ]
    then
        echo "Login user password NOT specified!"
    elif [ -z "$2" ]
    then
        echo "Share name NOT specified!"
    elif [ -z "$3" ]
    then
        echo "Share user name NOT specified!"
    elif [ -z "$4" ]
    then
        echo "Share user password NOT specified!"
    elif [ -z "$5" ]
    then
        echo "Share user domain NOT specified!"
    else
        source "$HOME/custom-scripts/power-manager.sh"
        source "$HOME/custom-scripts/update.sh" $1
        source "$HOME/custom-scripts/install-additional-packages.sh" $1
        source "$HOME/custom-scripts/install-pulseaudio.sh" $1
        source "$HOME/custom-scripts/update.sh" $1
        source "$HOME/custom-scripts/install-firefox.sh"
        source "$HOME/custom-scripts/hyper-v/setup-remote-desktop.sh" "$1" "$2" "$3" "$4" "$5"

        mintupdate

        pavucontrol

        launchCustomizationScriptPath="$HOME/.config/autostart/launch-customize-hyper-v-mint-xfce-installation-script.desktop"
        if [ -f  "$launchCustomizationScriptPath" ]
        then
            sudo rm -rf "$launchCustomizationScriptPath"
        fi

        xfce4-session-logout --reboot --fast
    fi
fi
