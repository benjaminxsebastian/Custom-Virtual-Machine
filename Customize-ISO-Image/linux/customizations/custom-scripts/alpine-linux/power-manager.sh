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

xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -n -t int -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-off -n -t int -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-sleep -n -t int -s 0

xfceScreenSaverConfigurationFilePath="/home/<USER NAME>/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-screensaver.xml"

rm -r -f "$xfceScreenSaverConfigurationFilePath"
touch "$xfceScreenSaverConfigurationFilePath"
echo '<?xml version="1.1" encoding="UTF-8"?>' >> "$xfceScreenSaverConfigurationFilePath"
echo '' >> "$xfceScreenSaverConfigurationFilePath"
echo '<channel name="xfce4-screensaver" version="1.0">' >> "$xfceScreenSaverConfigurationFilePath"
echo '  <property name="saver" type="empty">' >> "$xfceScreenSaverConfigurationFilePath"
echo '    <property name="mode" type="int" value="0"/>' >> "$xfceScreenSaverConfigurationFilePath"
echo '    <property name="idle-activation" type="empty">' >> "$xfceScreenSaverConfigurationFilePath"
echo '      <property name="enabled" type="bool" value="false"/>' >> "$xfceScreenSaverConfigurationFilePath"
echo '    </property>' >> "$xfceScreenSaverConfigurationFilePath"
echo '  </property>' >> "$xfceScreenSaverConfigurationFilePath"
echo '</channel>' >> "$xfceScreenSaverConfigurationFilePath"
