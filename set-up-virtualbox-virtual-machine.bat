@ECHO OFF

REM // Copyright 2023 Benjamin Sebastian
REM // 
REM // Licensed under the Apache License, Version 2.0 (the "License");
REM // you may not use this file except in compliance with the License.
REM // You may obtain a copy of the License at
REM // 
REM //     http://www.apache.org/licenses/LICENSE-2.0
REM // 
REM // Unless required by applicable law or agreed to in writing, software
REM // distributed under the License is distributed on an "AS IS" BASIS,
REM // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
REM // See the License for the specific language governing permissions and
REM // limitations under the License.

SET invalidArgument=
IF [%~1] EQU [] SET "invalidArgument=true"
IF [%~2] EQU [] SET "invalidArgument=true"
IF [%~3] EQU [] SET "invalidArgument=true"
IF [%~4] EQU [] SET "invalidArgument=true"
IF [%~5] EQU [] SET "invalidArgument=true"
IF [%~6] EQU [] SET "invalidArgument=true"
IF [%~7] EQU [] SET "invalidArgument=true"
IF [%invalidArgument%] NEQ [] (
    ECHO:
    ECHO Usage: set-up-virtualbox-virtual-machine [Path to ISO Image] [Temporary Directory] [Login User Name] [Login User Password] [Share Name] [Share Path] [Virtual Machine Name]
    SET invalidArgument=
    EXIT /B 10001
)

SETLOCAL ENABLEDELAYEDEXPANSION
    SET "currentDirectoryPath=%~dp0."
    SET "sharePath=%~6"
    VBoxManage sharedfolder add "%~7" -name "%~5" -hostpath "!sharePath!"
    VBoxManage startvm "%~7"
    VBoxManage guestcontrol "%~7" run --exe="/home/%~3/customize-linux-mint-xfce-iso-image-for-virtualbox.sh" --username="%~3" --password="%~4" --wait-stdout --wait-stderr "customize-linux-mint-xfce-iso-image-for-virtualbox.sh/arg0" "%~1" "%~2" "%~3" "%~4" "%~5"

    REM TODO - Create the virtual machine

ENDLOCAL
