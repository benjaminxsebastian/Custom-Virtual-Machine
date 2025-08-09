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
    SET memorySizeInGb=2
    SET hardDriveSizeInGb=10
    SET isoBaseName=
    FOR /F "usebackq delims==" %%P IN (`WSL eval "basename !%~1! .iso"`) DO (
        SET "isoBaseName=%%P"
    )
    SET "destinationCustomIsoImagePath=%~2\custom-!isoBaseName!.iso"
    IF NOT EXIST "!destinationCustomIsoImagePath!" (
        SET "currentDirectoryPath=%~dp0."
        FOR /F "usebackq delims==" %%P IN (`WSL wslpath "!currentDirectoryPath!"`) DO (
            SET "currentDirectoryPath=%%P"
        )
        SET "temporaryDirectoryPath=%~2"
        FOR /F "usebackq delims==" %%P IN (`WSL wslpath "!temporaryDirectoryPath!"`) DO (
            SET "temporaryDirectoryPath=%%P"
        )
        SET scriptName=
        ECHO "!isoBaseName!" | FINDSTR /I "mint" > NUL
        IF !ERRORLEVEL! EQU 0 (
            SET "scriptName=customize-linux-mint-xfce-iso-image-for-hyper-v.sh"
            SET memorySizeInGb=4
            SET hardDriveSizeInGb=25
        ) ELSE (
            ECHO "!isoBaseName!" | FINDSTR /I "alpine" > NUL
            IF !ERRORLEVEL! EQU 0 (
                SET "scriptName=customize-alpine-linux-xfce-iso-image-for-hyper-v.sh"
            )
        )
        IF [!scriptName!] EQU [] (
            ECHO:
            ECHO Unsupported Linux type!
            EXIT /B 1
        )
        CALL WSL bash -c "sudo apt install -y dos2unix; dos2unix !currentDirectoryPath!Customize-ISO-Image/iso-utilities/alpine-linux/*.sh; dos2unix !currentDirectoryPath!Customize-ISO-Image/iso-utilities/debian/*.sh; dos2unix !currentDirectoryPath!Customize-ISO-Image/linux/*.sh; dos2unix !currentDirectoryPath!Customize-ISO-Image/linux/customizations/*.sh; dos2unix !currentDirectoryPath!Customize-ISO-Image/linux/customizations/custom-scripts/*.sh; dos2unix !currentDirectoryPath!Customize-ISO-Image/linux/customizations/custom-scripts/alpine-linux/*.sh; dos2unix !currentDirectoryPath!Customize-ISO-Image/linux/customizations/custom-scripts/alpine-linux/hyper-v/*.sh; dos2unix !currentDirectoryPath!Customize-ISO-Image/linux/customizations/custom-scripts/alpine-linux/virtualbox/*.sh; dos2unix !currentDirectoryPath!Customize-ISO-Image/linux/customizations/custom-scripts/linux-mint/*.sh; dos2unix !currentDirectoryPath!Customize-ISO-Image/linux/customizations/custom-scripts/linux-mint/hyper-v/*.sh; dos2unix !currentDirectoryPath!Customize-ISO-Image/linux/customizations/custom-scripts/linux-mint/virtualbox/*.sh; dos2unix !currentDirectoryPath!Customize-ISO-Image/linux/customizations/preseed/*; dos2unix !currentDirectoryPath!Customize-ISO-Image/linux/customizations/startup-scripts/*; !currentDirectoryPath!Customize-ISO-Image/linux/!scriptName! \"%~1\" \"!temporaryDirectoryPath!\" \"%~3\" \"%~4\" \"%~5\" \"%~6\" \"%~7\" \"%~8\""
    )
    IF !ERRORLEVEL! NEQ 0 EXIT /B
    CALL %~dp0\Configure-Virtual-Machine\hyper-v\create-hyper-v-virtual-machine.bat "%~9" "%~2" !memorySizeInGb! !hardDriveSizeInGb! "!destinationCustomIsoImagePath!"
ENDLOCAL
