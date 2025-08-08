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
    echo "PulseAudio directory NOT specified!"
else
    pulseaudioXrdpModuleVersion=`curl -s https://api.github.com/repos/neutrinolabs/pulseaudio-module-xrdp/releases/latest | jq -r '.name' | cut -c 2-`

    cd /home/<USER NAME>/
    wget https://github.com/neutrinolabs/pulseaudio-module-xrdp/archive/v$pulseaudioXrdpModuleVersion.tar.gz -O pulseaudio-module-xrdp-$pulseaudioXrdpModuleVersion.tar.gz
    tar -zxf pulseaudio-module-xrdp-$pulseaudioXrdpModuleVersion.tar.gz
    cd /home/<USER NAME>/pulseaudio-module-xrdp-$pulseaudioXrdpModuleVersion
    ./bootstrap
    ./configure PULSE_DIR=$1
    make
    make install

    apk add pulseaudio
    apk add pulseaudio-alsa
    apk add alsa-plugins-pulse
    apk add pulseaudio-utils
    apk add pavucontrol

    rc-update add pulseaudio
    rc-service pulseaudio start

    pulseaudio start
fi
