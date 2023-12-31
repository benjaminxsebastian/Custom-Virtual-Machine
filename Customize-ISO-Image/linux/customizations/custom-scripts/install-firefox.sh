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

echo "$1" | sudo -S echo "Refreshing administrator credentials ..." 2>/dev/null
sudo cp -v -f /usr/share/applications/firefox.desktop "$HOME/.config/autostart/firefox.desktop"
firefox &
sleep 5
killall firefox-bin
echo 'user_pref("browser.startup.homepage", "https://www.google.com");' > $HOME/user.js
sudo mv -v -f "$HOME/user.js" $HOME/.mozilla/firefox/*.default-release
firefox &
sleep 5
killall firefox-bin
