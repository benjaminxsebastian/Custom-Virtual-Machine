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
    hyperVCustomScriptsDirectory="$(dirname "`realpath "${BASH_SOURCE[0]}"`")"
    createSharedDirectoryScriptPath="$hyperVCustomScriptsDirectory/create-shared-directory.sh"
    installLogoutConsoleSessionScript="install-logout-console-session.sh"
    installLogoutConsoleSessionScriptPath="$hyperVCustomScriptsDirectory/$installLogoutConsoleSessionScript"
    launchInstallLogoutConsoleSessionScript="launch-install-logout-console-session.sh"
    launchInstallLogoutConsoleSessionScriptPath="$hyperVCustomScriptsDirectory/$launchInstallLogoutConsoleSessionScript"
    createRemoteDesktopShortcutScript="create-remote-desktop-shortcut.sh"
    createRemoteDesktopShortcutScriptPath="$hyperVCustomScriptsDirectory/$createRemoteDesktopShortcutScript"
    cronJobsListing="$HOME/cronJobsListing"

    echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
    source "$createSharedDirectoryScriptPath" "$2" "$3" "$4" "$5"

    sudo crontab -l > "$cronJobsListing"
    grepStatus=0
    grep -i -q $createRemoteDesktopShortcutScript $cronJobsListing
    grepStatus=$?
    if [ $grepStatus != 0 ]
    then
        echo "* * * * * \"$launchInstallLogoutConsoleSessionScriptPath\" \"$2\" \"$3\" \"$4\" \"$5\"" >> $cronJobsListing
        echo "* * * * * \"$createRemoteDesktopShortcutScriptPath\" \"$2\" \"$3\" \"$4\" \"$5\"" >> $cronJobsListing
        sudo crontab $cronJobsListing
        rm -r -f $cronJobsListing
    fi
    "$createRemoteDesktopShortcutScriptPath" "$2" "$3" "$4" "$5"

    sudo rm -r -f "$sharedDirectoryPath/$installLogoutConsoleSessionScript"
    sudo cp -v -f "$installLogoutConsoleSessionScriptPath" "$sharedDirectoryPath/$installLogoutConsoleSessionScript"
    "$sharedDirectoryPath/$installLogoutConsoleSessionScript"
fi
