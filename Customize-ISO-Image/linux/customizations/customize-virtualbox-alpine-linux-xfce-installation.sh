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

launchCustomizationScriptPath="$HOME/.config/autostart/launch-customize-virtualbox-alpine-linux-xfce-installation-script.desktop"
if [ -f  "$launchCustomizationScriptPath" ]
then
    rm -rf "$launchCustomizationScriptPath"
fi

launchInstallGuestAdditionsScriptPath="/home/<USER NAME>/custom-scripts/virtualbox/launch-install-virtualbox-guest-additions-script.desktop"
doas mv -v -f "$launchInstallGuestAdditionsScriptPath" "$HOME/.config/autostart"

xfce4-session-logout --halt
