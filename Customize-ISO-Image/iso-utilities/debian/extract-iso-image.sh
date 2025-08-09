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
    extractIsoImageScriptStartTime=`date +%s`

    exitCode=0

    isoUtilitiesDirectory="$(dirname "`realpath "${BASH_SOURCE[0]}"`")"
    isoBaseName="$(eval "basename $1 .iso")"
    mountBaseDirectory="$2/mount"
    mountDirectory="$mountBaseDirectory/$isoBaseName"
    destinationIsoImageDirectory="$2/$isoBaseName"

    if [ -d "$destinationIsoImageDirectory" ]
    then
        backupDestinationIsoImageDirectory="$2/backup-$isoBaseName"
        rm -r -f "$backupDestinationIsoImageDirectory"
        mv -v "$destinationIsoImageDirectory" "$backupDestinationIsoImageDirectory"
    fi

    echo "Extracting ISO image from: $1 into: $destinationIsoImageDirectory"
    echo ""

    mkdir -p "$mountDirectory"
    sudo mount -o loop=/dev/loop0 "$1" "$mountDirectory"
    exitCode=$?
    if [ $exitCode != 0 ]
    then
        echo ""
        echo "Error mounting ISO image from: $1 into: $mountDirectory. exitCode: $exitCode"
    else
        echo ""
        echo "Mounted ISO image from: $1 into: $mountDirectory"

        cd "$mountBaseDirectory"
        sudo tar -cvf - "$isoBaseName" | (cd .. && tar -xf - )
        exitCode=$?
        if [ $exitCode != 0 ]
        then
            echo ""
            echo "Error extracting ISO image from: $1 into: $destinationIsoImageDirectory. exitCode: $exitCode"
        else
            echo ""
            echo "Extracted ISO image from: $1 into: $destinationIsoImageDirectory"
        fi
        cd "$2"
        cd ..    

        sudo umount /dev/loop0
        tempExitCode=$?
        if [ $tempExitCode != 0 ]
        then
            echo ""
            echo "Error unmounting ISO image: $1 from: $mountDirectory. tempExitCode: $tempExitCode"
            exitCode=$tempExitCode
        else
            echo ""
            echo "Unmounted ISO image: $1 from: $mountDirectory"
        fi
    fi

    rm -r -f "$mountBaseDirectory"

    extractIsoImageScriptEndTime=`date +%s`
    echo ""
    echo "Runtime [${BASH_SOURCE[0]}]:" $((extractIsoImageScriptEndTime-extractIsoImageScriptStartTime)) "seconds."
fi

cd "$isoUtilitiesDirectory"
cd ..

echo ""

if (( ${#BASH_SOURCE[@]} > 1 ))
then
    export exitCode
else
    exit $exitCode
fi
