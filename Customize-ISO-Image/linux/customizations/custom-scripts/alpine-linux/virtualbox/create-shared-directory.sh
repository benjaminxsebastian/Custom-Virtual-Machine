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
    echo "Login user name NOT specified!"
elif [ -z "$2" ]
then
    echo "Share directory name NOT specified!"
else
    exitCode=0

    sharedDirectoryPath="/home/$1/$2"

    mkdir -p "$sharedDirectoryPath"
    umount -l "$sharedDirectoryPath"
    mount -t vboxsf "$2" "$sharedDirectoryPath"
    exitCode=$?
    if [ $exitCode != 0 ]
    then
        echo ""
        echo "Error sharing directory: $sharedDirectoryPath. exitCode: $exitCode"
    else
        echo ""
        echo "Shared directory: $sharedDirectoryPath"
    fi
fi
