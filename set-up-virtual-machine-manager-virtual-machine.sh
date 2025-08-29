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

echo ""

if [ -z "$1" ]
then
    echo "Virtual machine name NOT specified!"
elif [ -z "$2" ]
then
    echo "Path to ISO image NOT specified!"
elif [ -z "$3" ]
then
    echo "Destination ISO image directory path NOT specified!"
elif [ -z "$4" ]
then
    echo "Login user name NOT specified!"
elif [ -z "$5" ]
then
    echo "Login user password NOT specified!"
else
    rootDirectory="$(dirname "`realpath "${BASH_SOURCE[0]}"`")"
    scriptsDirectory="$rootDirectory/Customize-ISO-Image/linux"
    isoBaseName=`(basename "$2" .iso)`
    destinationDirectory="$(readlink -f $3)"

    source "$scriptsDirectory/customize-alpine-linux-xfce-iso-image-for-virtual-machine-manager.sh" "$2" "$destinationDirectory" "$4" "$5"

    if [ $exitCode != 0 ]
    then
        echo "Error customizing ISO image: $2. exitCode: $exitCode"
    else
        source "$rootDirectory/Configure-Virtual-Machine/virtual-machine-manager/create-virtual-machine-manager-virtual-machine.bat" "$1" "$destinationCustomIsoImagePath"
    fi
fi

echo ""
