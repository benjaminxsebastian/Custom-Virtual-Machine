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
    echo "Share directory name NOT specified!"
elif [ -z "$2" ]
then
    echo "Share user name NOT specified!"
elif [ -z "$3" ]
then
    echo "Share password NOT specified!"
elif [ -z "$4" ]
then
    echo "Share user domain NOT specified!"
else
    createSharedDirectoryScriptPath="/home/<USER NAME>/custom-scripts/hyper-v/create-shared-directory.sh"

    releaseInformation=$(cat /etc/issue)
    read -a releaseInformationArray <<< $releaseInformation
    virtualMachineType="Other"
    if echo "$HOSTNAME" | grep -iq "Browser"; then
        virtualMachineType="Browser"
    elif echo "$HOSTNAME" | grep -iq "Developer"; then
        virtualMachineType="Developer"
    fi
    if echo "$HOSTNAME" | grep -iq "LinuxMint"; then
        rdpFileName="${releaseInformationArray[0]}-${releaseInformationArray[1]}-${releaseInformationArray[2]}-${releaseInformationArray[3]}-$virtualMachineType ($(hostname -I | awk '{print $1}')).rdp"
    else
        rdpFileName="${releaseInformationArray[0]}-${releaseInformationArray[1]}-${releaseInformationArray[2]}-$virtualMachineType ($(hostname -I | awk '{print $1}')).rdp"
    fi
    rdpFilePath="/home/<USER NAME>/$rdpFileName"

    rm -r -f "$rdpFilePath"
    touch "$rdpFilePath"
    echo "screen mode id:i:2" >> "$rdpFilePath"
    echo "use multimon:i:0" >> "$rdpFilePath"
    echo "desktopwidth:i:1920" >> "$rdpFilePath"
    echo "desktopheight:i:1080" >> "$rdpFilePath"
    echo "session bpp:i:32" >> "$rdpFilePath"
    echo "winposstr:s:0,3,0,0,800,600" >> "$rdpFilePath"
    echo "compression:i:1" >> "$rdpFilePath"
    echo "keyboardhook:i:2" >> "$rdpFilePath"
    echo "audiocapturemode:i:0" >> "$rdpFilePath"
    echo "videoplaybackmode:i:1" >> "$rdpFilePath"
    echo "connection type:i:7" >> "$rdpFilePath"
    echo "networkautodetect:i:1" >> "$rdpFilePath"
    echo "bandwidthautodetect:i:1" >> "$rdpFilePath"
    echo "displayconnectionbar:i:1" >> "$rdpFilePath"
    echo "enableworkspacereconnect:i:0" >> "$rdpFilePath"
    echo "disable wallpaper:i:0" >> "$rdpFilePath"
    echo "allow font smoothing:i:0" >> "$rdpFilePath"
    echo "allow desktop composition:i:0" >> "$rdpFilePath"
    echo "disable full window drag:i:1" >> "$rdpFilePath"
    echo "disable menu anims:i:1" >> "$rdpFilePath"
    echo "disable themes:i:0" >> "$rdpFilePath"
    echo "disable cursor setting:i:0" >> "$rdpFilePath"
    echo "bitmapcachepersistenable:i:1" >> "$rdpFilePath"
    echo "full address:s:$(hostname -I)" >> "$rdpFilePath"
    echo "audiomode:i:0" >> "$rdpFilePath"
    echo "redirectprinters:i:1" >> "$rdpFilePath"
    echo "redirectlocation:i:0" >> "$rdpFilePath"
    echo "redirectcomports:i:0" >> "$rdpFilePath"
    echo "redirectsmartcards:i:1" >> "$rdpFilePath"
    echo "redirectclipboard:i:1" >> "$rdpFilePath"
    echo "redirectposdevices:i:0" >> "$rdpFilePath"
    echo "drivestoredirect:s:DynamicDrives" >> "$rdpFilePath"
    echo "autoreconnection enabled:i:1" >> "$rdpFilePath"
    echo "authentication level:i:2" >> "$rdpFilePath"
    echo "prompt for credentials:i:0" >> "$rdpFilePath"
    echo "negotiate security layer:i:1" >> "$rdpFilePath"
    echo "remoteapplicationmode:i:0" >> "$rdpFilePath"
    echo "alternate shell:s:" >> "$rdpFilePath"
    echo "shell working directory:s:" >> "$rdpFilePath"
    echo "gatewayhostname:s:" >> "$rdpFilePath"
    echo "gatewayusagemethod:i:4" >> "$rdpFilePath"
    echo "gatewaycredentialssource:i:4" >> "$rdpFilePath"
    echo "gatewayprofileusagemethod:i:0" >> "$rdpFilePath"
    echo "promptcredentialonce:i:0" >> "$rdpFilePath"
    echo "gatewaybrokeringtype:i:0" >> "$rdpFilePath"
    echo "use redirection server name:i:0" >> "$rdpFilePath"
    echo "rdgiskdcproxy:i:0" >> "$rdpFilePath"
    echo "kdcproxyname:s:" >> "$rdpFilePath"
    echo "username:s:<USER NAME>" >> "$rdpFilePath"
    echo "redirectwebauthn:i:1" >> "$rdpFilePath"
    echo "enablerdsaadauth:i:0" >> "$rdpFilePath"

    source "$createSharedDirectoryScriptPath" "$1" "$2" "$3" "$4"

    sudo rm -r -f "$sharedDirectoryPath/$rdpFileName"
    sudo mv -v -f "$rdpFilePath" "$sharedDirectoryPath/$rdpFileName"
fi
