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
IF [%invalidArgument%] NEQ [] (
    ECHO:
    ECHO Usage: set-up-virtualbox-virtual-machine [Path to ISO Image] [VM Temporary Directory] [Login User Name] [Login User Password] [Share Name] [Share Path] [Virtual Machine Name] [Host Temporary Directory]
    SET invalidArgument=
    EXIT /B 10001
)

SETLOCAL ENABLEDELAYEDEXPANSION
    SET memorySizeInGb=2
    SET hardDriveSizeInGb=10
    SET "isoBaseName=%~1"
    FOR %%P IN ("%~1") DO (
        SET "isoBaseName=%%~NXP"
    )
    SET "destinationCustomIsoImagePath=%~6\custom-!isoBaseName!"
    IF NOT EXIST "!destinationCustomIsoImagePath!" (
        VBoxManage sharedfolder remove "%~7" -name "%~5" --transient
        VBoxManage sharedfolder add "%~7" -name "%~5" -hostpath "%~6" --transient
        IF !ERRORLEVEL! NEQ 0 EXIT /B
        SET scriptName=
        ECHO "!isoBaseName!" | FINDSTR /I "mint" > NUL
        IF !ERRORLEVEL! EQU 0 (
            SET memorySizeInGb=4
            SET hardDriveSizeInGb=25
            SET "scriptName=customize-linux-mint-xfce-iso-image-for-virtualbox.sh"
        ) ELSE (
            ECHO "!isoBaseName!" | FINDSTR /I "alpine" > NUL
            IF !ERRORLEVEL! EQU 0 (
                SET "scriptName=customize-alpine-linux-xfce-iso-image-for-virtualbox-v.sh"
            )
        )
        IF [!scriptName!] EQU [] (
            ECHO:
            ECHO Unsupported Linux type!
            EXIT /B 1
        )
        VBoxManage guestcontrol "%~7" run --exe "/home/%~3/custom-scripts/virtualbox/!scriptName!" --username="%~3" --password="%~4" --wait-stdout --wait-stderr -- "%~1" "%~2" "%~3" "%~4" "%~5"
    )
    IF !ERRORLEVEL! NEQ 0 EXIT /B
    CALL %~dp0\Configure-Virtual-Machine\virtualbox\create-virtualbox-virtual-machine.bat "%~7" "%~8" !memorySizeInGb! !hardDriveSizeInGb! "!destinationCustomIsoImagePath!"
ENDLOCAL
