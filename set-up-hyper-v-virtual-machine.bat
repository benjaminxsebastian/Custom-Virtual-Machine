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
IF [%~8] EQU [] SET "invalidArgument=true"
IF [%~9] EQU [] SET "invalidArgument=true"
IF [%invalidArgument%] NEQ [] (
    ECHO:
    ECHO Usage: set-up-hyper-v-virtual-machine [Path to ISO Image] [Temporary Directory] [Login User Name] [Login User Password] [Share Name] [Share User Name] [Share User Password] [Share User Domain] [Virtual Machine Name]
    SET invalidArgument=
    EXIT /B 10001
)

SETLOCAL ENABLEDELAYEDEXPANSION
    SET "currentDirectoryPath=%~dp0."
    FOR /F "usebackq delims==" %%P IN (`WSL wslpath "!currentDirectoryPath!"`) DO (
        SET "currentDirectoryPath=%%P"
    )
    SET "temporaryDirectoryPath=%~2"
    FOR /F "usebackq delims==" %%P IN (`WSL wslpath "!temporaryDirectoryPath!"`) DO (
        SET "temporaryDirectoryPath=%%P"
    )
    CALL WSL bash -c "sudo apt install -y dos2unix; dos2unix !currentDirectoryPath!Customize-ISO-Image/iso-utilities/*.sh; dos2unix !currentDirectoryPath!Customize-ISO-Image/linux/*.sh; dos2unix !currentDirectoryPath!Customize-ISO-Image/linux/customizations/*.sh; dos2unix !currentDirectoryPath!Customize-ISO-Image/linux/customizations/custom-scripts/*.sh; dos2unix !currentDirectoryPath!Customize-ISO-Image/linux/customizations/custom-scripts/hyper-v/*.sh; dos2unix !currentDirectoryPath!Customize-ISO-Image/linux/customizations/custom-scripts/virtualbox/*.sh; dos2unix !currentDirectoryPath!Customize-ISO-Image/linux/customizations/preseed/*; !currentDirectoryPath!Customize-ISO-Image/linux/customize-linux-mint-xfce-iso-image-for-hyper-v.sh \"%~1\" \"!temporaryDirectoryPath!\" \"%~3\" \"%~4\" \"%~5\" \"%~6\" \"%~7\" \"%~8\""
    SET isoBaseName=
    FOR /F "usebackq delims==" %%P IN (`WSL eval "basename !%~1! .iso"`) DO (
        SET "isoBaseName=%%P"
    )
    SET "destinationCustomIsoImagePath=%~2\custom-!isoBaseName!.iso"
    CALL %~dp0\Configure-Virtual-Machine\hyper-v\create-hyper-v-virtual-machine.bat "%~9" "%~2" "!destinationCustomIsoImagePath!"
ENDLOCAL
