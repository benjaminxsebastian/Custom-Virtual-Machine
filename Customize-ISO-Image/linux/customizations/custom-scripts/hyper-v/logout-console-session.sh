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

sessionInformation=$(who)
if ! [ -z "$sessionInformation" ]
then
    grepStatus=0
    inxi -F | grep -i -q XFCE
    grepStatus=$?
    if [ $grepStatus == 0 ]
    then
        xfce4-session-logout --logout
    fi
fi
for SINK in $(pacmd list-sinks | grep 'index:' | cut -b12-)
do
    pactl -- set-sink-volume $SINK 150%
done
