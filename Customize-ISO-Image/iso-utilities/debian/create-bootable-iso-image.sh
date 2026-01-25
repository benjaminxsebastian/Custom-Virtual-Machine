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
    echo "Path to ISO boot directory NOT specified!"
elif [ -z "$2" ]
then
    echo "Path to ISO image directory NOT specified!"
elif [ -z "$3" ]
then
    echo "Destination ISO image directory path NOT specified!"
else
    createBootableIsoImageScriptStartTime=`date +%s`

    exitCode=0

    isoBaseName="$(eval "basename $2")"
    customIsoName="custom-$isoBaseName.iso"
    destinationCustomIsoImagePath="$3/$customIsoName"

    if [ -f "$destinationCustomIsoImagePath" ]
    then
        backupDestinationCustomIsoImagePath="$3/backup-$customIsoName"
        rm -r -f "$backupDestinationCustomIsoImagePath"
        mv -v "$destinationCustomIsoImagePath" "$backupDestinationCustomIsoImagePath"
    fi

    echo "Creating custom ISO image: $destinationCustomIsoImagePath from: $2 (with boot directory: $1)"
    echo ""

    mkdir -p "$3"
    if [[ "$1" == *"efi.img"* && "$2" == *"aarch64"* ]]; then
        sudo xorrisofs -output "$destinationCustomIsoImagePath" -efi-boot-part --efi-boot-image -e $1 -no-emul-boot -joliet -rational-rock -full-iso9660-filenames -follow-links "$2"
    else
        if [ -f "$2/$1/isolinux.bin" ]; then
            sudo chmod +w "$2/$1/isolinux.bin"
            sudo mkisofs -o "$destinationCustomIsoImagePath" -b  $1/isolinux.bin -c $1/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -J -R -V "Custom Image" -eltorito-alt-boot -eltorito-boot boot/grub/efi.img -no-emul-boot "$2"
        else
            xorriso -as mkisofs -o "$destinationCustomIsoImagePath" --grub2-mbr --interval:local_fs:0s-15s:zero_mbrpt,zero_gpt:"$3/$isoBaseName.iso" --protective-msdos-label -partition_cyl_align off -partition_offset 16 --mbr-force-bootable -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b --interval:local_fs:12383488d-12393647d::"$3/$isoBaseName.iso" -appended_part_as_gpt -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 -b boot/grub/i386-pc/eltorito.img -c boot.catalog -no-emul-boot -boot-load-size 4 -boot-info-table -V "Custom Image" --grub2-boot-info -eltorito-alt-boot -e "--interval:appended_partition_2_start_3095872s_size_10160d:all::" -no-emul-boot -boot-load-size 10160 "$2"
        fi
    fi
    exitCode=$?
    if [ $exitCode != 0 ]
    then
        echo ""
        echo "Error creating custom ISO image: $destinationCustomIsoImagePath from: $2 (with boot directory: $1). exitCode: $exitCode"
    else
        echo ""
        echo "Created custom ISO image: $destinationCustomIsoImagePath from: $2 (with boot directory: $1)"
    fi

    createBootableIsoImageScriptEndTime=`date +%s`
    echo ""
    echo "Runtime [${BASH_SOURCE[0]}]:" $((createBootableIsoImageScriptEndTime-createBootableIsoImageScriptStartTime)) "seconds."
fi

echo ""

if (( ${#BASH_SOURCE[@]} > 1 ))
then
    export exitCode
else
    exit $exitCode
fi
