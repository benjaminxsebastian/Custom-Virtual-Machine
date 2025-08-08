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

apk add git
apk add autoconf
apk add automake
apk add libtool
apk add alpine-sdk
apk add abuild-rootbld
apk add meson
apk add ninja
apk add curl
apk add jq
apk add cifs-utils
apk add xrdp
apk add xorgxrdp

rc-service xrdp start 
rc-service xrdp-sesman start
rc-update add xrdp
rc-update add xrdp-sesman
