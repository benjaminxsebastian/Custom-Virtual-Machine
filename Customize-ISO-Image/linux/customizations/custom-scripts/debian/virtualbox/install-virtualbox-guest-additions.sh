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
    sudo mkdir /mnt/cdrom
    sudo mount /dev/sr0 /mnt/cdrom
    sudo /mnt/cdrom/VBoxLinuxAdditions.run
    sudo umount /mnt/cdrom

    launchInstallGuestAdditionsScriptPath="/home/<USER NAME>/.config/autostart/launch-install-virtualbox-guest-additions-script.desktop"
    if [ -f  "$launchInstallGuestAdditionsScriptPath" ]
    then
        sudo rm -rf "$launchInstallGuestAdditionsScriptPath"
    fi

    sudo shutdown now
fi
