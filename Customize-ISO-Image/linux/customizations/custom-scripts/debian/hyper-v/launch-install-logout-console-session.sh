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
    echo "Share directory name NOT specified!"
elif [ -z "$2" ]
then
    echo "Share user name NOT specified!"
elif [ -z "$3" ]
then
    echo "Share password NOT specified!"
elif [ -z "$4" ]
then
    echo "Share user domain NOT specified!"
else
    hyperVCustomScriptsDirectory="/home/<USER NAME>/custom-scripts/hyper-v"
    createSharedDirectoryScriptPath="$hyperVCustomScriptsDirectory/create-shared-directory.sh"
    installLogoutConsoleSessionScript="install-logout-console-session.sh"
    installLogoutConsoleSessionScriptPath="$hyperVCustomScriptsDirectory/$installLogoutConsoleSessionScript"

    source "$createSharedDirectoryScriptPath" "$1" "$2" "$3" "$4"

    "$sharedDirectoryPath/$installLogoutConsoleSessionScript"
fi
