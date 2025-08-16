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

doas mkdir /mnt/cdrom
doas mount -t iso9660 /dev/sr0 /mnt/cdrom
doas /mnt/cdrom/VBoxLinuxAdditions.run
doas umount /mnt/cdrom
doas apk add virtualbox-guest-additions
doas apk add virtualbox-guest-additions-x11

doas rc-service virtualbox-guest-additions start
doas rc-update add virtualbox-guest-additions boot
doas rc-service virtualbox-drm-client start
doas rc-update add virtualbox-drm-client default

#launchInstallGuestAdditionsScriptPath="$HOME/.config/autostart/launch-install-virtualbox-guest-additions-script.desktop"
#if [ -f  "$launchInstallGuestAdditionsScriptPath" ]
#then
#    doas rm -rf "$launchInstallGuestAdditionsScriptPath"
#fi
