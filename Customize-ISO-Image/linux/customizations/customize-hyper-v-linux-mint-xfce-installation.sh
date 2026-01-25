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
        source "/home/<USER NAME>/custom-scripts/power-manager.sh"
        source "/home/<USER NAME>/custom-scripts/update.sh" $1
        source "/home/<USER NAME>/custom-scripts/install-common-packages.sh" $1
        source "/home/<USER NAME>/custom-scripts/install-additional-packages.sh" $1
        source "/home/<USER NAME>/custom-scripts/install-pulseaudio.sh" $1
        source "/home/<USER NAME>/custom-scripts/update.sh" $1
        source "/home/<USER NAME>/custom-scripts/configure-firefox.sh"
        source "/home/<USER NAME>/custom-scripts/hyper-v/setup-remote-desktop.sh" "$1" "$2" "$3" "$4" "$5"

        echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
        sudo apt install openoffice.org-hyphenation -y
        echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
        sudo apt install mint-meta-codecs -y

        killall mintUpdate
        python3 -c 'import gi; from gi.repository import Gio; Gio.Settings(schema_id="com.linuxmint.updates").set_boolean("show-welcome-page", False)'
        python3 -c 'import gi; from gi.repository import Gio; Gio.Settings(schema_id="com.linuxmint.updates").set_boolean("default-repo-is-ok", True)'
        sudo mintupdate-cli upgrade -y

        for SINK in $(pacmd list-sinks | grep 'index:' | cut -b12-)
        do
            pactl -- set-sink-volume $SINK 100%
        done

        mkdir -p "/home/<USER NAME>/.linuxmint/mintwelcome"
        touch "/home/<USER NAME>/.linuxmint/mintwelcome/norun.flag"

        python3 -c 'import gi; from gi.repository import Gio; Gio.Settings(schema_id="com.linuxmint.report").set_strv("ignored-reports", ["timeshift-no-setup"])'
        killall xfce4-panel

        launchCustomizationScriptPath="/home/<USER NAME>/.config/autostart/launch-customize-hyper-v-linux-mint-xfce-installation-script.desktop"
        if [ -f  "$launchCustomizationScriptPath" ]
        then
            sudo rm -rf "$launchCustomizationScriptPath"
        fi

        sudo shutdown now
    fi
fi
