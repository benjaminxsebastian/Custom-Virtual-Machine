#!/bin/sh

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

while ! pgrep "firefox" > /dev/null; do
  echo 'Waiting for firefox to initialize ...'
  sleep 1
done
firefoxFolder=`grep -i "default-release" .mozilla/firefox/installs.ini | cut -d '=' -f 2`
firefoxFiles=`find "/home/sbenjamin/.mozilla/firefox/$firefoxFolder" -maxdepth 1 -type f | wc -l`
while [ "$firefoxFiles" -le "30" ]; do
  echo "Waiting for firefox to finish initializing ..."
  sleep 1
  firefoxFolder=`grep -i "default-release" .mozilla/firefox/installs.ini | cut -d '=' -f 2`
  firefoxFiles=`find "/home/sbenjamin/.mozilla/firefox/$firefoxFolder" -maxdepth 1 -type f | wc -l`
done
sleep 3
killall firefox
echo 'user_pref("browser.startup.homepage", "https://www.google.com");' > "/home/<USER NAME>/user.js"
mv -v -f "/home/<USER NAME>/user.js" /home/<USER NAME>/.mozilla/firefox/*.default-release
firefox &
sleep 10
killall firefox
