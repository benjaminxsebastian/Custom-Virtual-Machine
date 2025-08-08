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
elif [ -z "$2" ]
then
    echo "Share name NOT specified!"
elif [ -z "$3" ]
then
    echo "Share user name NOT specified!"
elif [ -z "$4" ]
then
    echo "Share user password NOT specified!"
elif [ -z "$5" ]
then
    echo "Share user domain NOT specified!"
else
    hyperVCustomScriptsDirectory="/home/<USER NAME>/custom-scripts/hyper-v"
    createSharedDirectoryScriptPath="$hyperVCustomScriptsDirectory/create-shared-directory.sh"
    createRemoteDesktopShortcutScript="create-remote-desktop-shortcut.sh"
    createRemoteDesktopShortcutScriptPath="$hyperVCustomScriptsDirectory/$createRemoteDesktopShortcutScript"
    cronJobsListing="$HOME/cronJobsListing"

    source "$createSharedDirectoryScriptPath" "$2" "$3" "$4" "$5"

    crontab -l > "$cronJobsListing"
    grepStatus=0
    grep -i -q $createRemoteDesktopShortcutScript $cronJobsListing
    grepStatus=$?
    if [ $grepStatus != 0 ]
    then
        echo "* * * * * bash \"$createRemoteDesktopShortcutScriptPath\" \"$2\" \"$3\" \"$4\" \"$5\"" >> $cronJobsListing
        crontab $cronJobsListing
        rm -r -f $cronJobsListing
    fi
    bash "$createRemoteDesktopShortcutScriptPath" "$2" "$3" "$4" "$5"
fi
