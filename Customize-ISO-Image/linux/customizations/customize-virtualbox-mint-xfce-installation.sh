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

xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -n -t int -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-off -n -t int -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-sleep -n -t int -s 0

sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt-get update
sudo apt-get -y upgrade -y
sudo apt-get -y autoremove -y
sudo apt install openoffice.org-hyphenation -y
sudo apt install mint-meta-codecs -y

mkdir -p "$HOME/.config/autostart"
sudo cp -v -f /usr/share/applications/firefox.desktop "$HOME/.config/autostart/firefox.desktop"
firefox -preferences

mintupdate

launchCustomizationScriptPath="$HOME/.config/autostart/launch-customize-virtualbox-mint-xfce-installation-script.desktop"
if [ -f  "$launchCustomizationScriptPath" ]
then
    sudo rm -rf "$launchCustomizationScriptPath"
fi

xfce4-session-logout --reboot
