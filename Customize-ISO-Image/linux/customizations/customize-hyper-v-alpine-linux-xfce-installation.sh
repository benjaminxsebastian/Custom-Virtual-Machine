#!/bin/sh

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

source "/home/<USER NAME>/custom-scripts/power-manager.sh"
source "/home/<USER NAME>/custom-scripts/configure-firefox.sh"

for SINK in $(pacmd list-sinks | grep 'index:' | cut -b12-)
do
    pactl -- set-sink-volume $SINK 100%
done

launchCustomizationScriptPath="/home/<USER NAME>/.config/autostart/launch-customize-hyper-v-alpine-linux-xfce-installation-script.desktop"
if [ -f  "$launchCustomizationScriptPath" ]
then
    rm -rf "$launchCustomizationScriptPath"
fi

doas sed -i 's/autologin-user=/#autologin-user=/g' "/etc/lightdm/lightdm.conf"
doas sed -i 's/permit nopass <USER NAME> as root//g' "/etc/doas.d/doas.conf" &
sleep 3

xfce4-session-logout --halt
