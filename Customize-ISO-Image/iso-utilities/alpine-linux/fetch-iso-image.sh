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

exitCode=2

if [ -z "$1" ]
then
    echo "Path to ISO image NOT specified!"
elif [ -z "$2" ]
then
    echo "Destination ISO image directory path NOT specified!"
else
    fetchIsoImageScriptStartTime=`date +%s`

    exitCode=0

    isoBaseName="$(eval "basename $1 .iso")"
    isoName="$isoBaseName.iso"
    destinationIsoImagePath="$2/$isoName"
    downloadIsoImage=true

    if [ -f "$destinationIsoImagePath" ]
    then
        isoImageSize=$(wget --spider --server-response "$1" -O - 2>&1 | sed -ne '/Content-Length/{s/.*: //;p}')
        destinationIsoImageSize=$(stat -c%s "$destinationIsoImagePath")
        if [ "$isoImageSize" -eq "$destinationIsoImageSize" ]
        then
            downloadIsoImage=false
        else
            backupDestinationIsoImagePath="$2/backup-$isoName"
            rm -r -f "$backupDestinationIsoImagePath"
            mv -v "$destinationIsoImagePath" "$backupDestinationIsoImagePath"
        fi
    fi
    if [ "$downloadIsoImage" = true ]
    then
        echo "Fetching ISO image from: $1 to: $destinationIsoImagePath"
        echo ""

        mkdir -p "$2"
        wget -O "$destinationIsoImagePath" "$1"
        exitCode=$?
        if [ $exitCode != 0 ]
        then
            echo ""
            echo "Error fetching ISO image from: $1 to: $destinationIsoImagePath. exitCode: $exitCode"
        else
            echo ""
            echo "Fetched ISO image from: $1 to: $destinationIsoImagePath"
        fi
    else
        echo "Using existing ISO image at: $destinationIsoImagePath"
    fi

    fetchIsoImageScriptEndTime=`date +%s`
    echo ""
    echo "Runtime [${BASH_SOURCE[0]}]:" $((fetchIsoImageScriptEndTime-fetchIsoImageScriptStartTime)) "seconds."
fi

echo ""

if (( ${#BASH_SOURCE[@]} > 1 ))
then
    export exitCode
else
    exit $exitCode
fi
