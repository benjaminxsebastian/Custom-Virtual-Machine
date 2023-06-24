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
IF [%invalidArgument%] NEQ [] (
    ECHO:
    ECHO Usage: create-hyper-v-virtual-machine [Virtual Machine Name] [Temporary Directory] [Path to Customized Install ISO]
    SET invalidArgument=
    EXIT /B 11001
)

SETLOCAL ENABLEDELAYEDEXPANSION
    SET "virtualMachineName=%~1"
    SET "virtualMachineDirectory=!USERPROFILE!\Documents\Virtual Machines\!virtualMachineName!"
    SET "dateToday=!DATE%:~4!"
    SET "dateToday=%dateToday:/=%"
    SET "timeNow=!TIME!"
    SET "timeNow=%timeNow::=.%"
    SET "temporaryVirtualMachineName=Temp!virtualMachineName!-!dateToday!-!timeNow!"
    SET "temporaryVirtualMachineDirectory=%~2\!temporaryVirtualMachineName!"

    POWERSHELL -Command "Get-VM -Name !temporaryVirtualMachineName! | Remove-VM -Force"
    POWERSHELL -Command "Get-ChildItem '!temporaryVirtualMachineDirectory!' | Remove-Item -Recurse -Force"
    RMDIR /S /Q "!temporaryVirtualMachineDirectory!"
    POWERSHELL -Command "Move-VMStorage -Name !virtualMachineName! -DestinationStoragePath '!temporaryVirtualMachineDirectory!'"
    POWERSHELL -Command "Get-VM !virtualMachineName! | Rename-VM -NewName !temporaryVirtualMachineName! -PassThru"
    POWERSHELL -Command "New-VM -Name !virtualMachineName! -MemoryStartupBytes 4GB -BootDevice VHD -NewVHDPath '!virtualMachineName!.vhdx' -Path ('{0}\Virtual Machines' -f [Environment]::GetFolderPath('MyDocuments')) -NewVHDSizeBytes 30GB -Generation 2 -Switch 'Default Switch'"
    POWERSHELL -Command "Set-VMMemory !virtualMachineName! -DynamicMemoryEnabled $false"
    POWERSHELL -Command "Set-VMProcessor !virtualMachineName! -Count 4"
    IF [%~3] EQU [] (
        POWERSHELL -Command "Add-VMDvdDrive -VMName !virtualMachineName!"
    ) ELSE (
        POWERSHELL -Command "Add-VMDvdDrive -VMName !virtualMachineName! -Path %3%"
    )
    POWERSHELL -Command "Set-VMFirmware !virtualMachineName! -FirstBootDevice (Get-VMFirmware !virtualMachineName!).bootOrder[2] -EnableSecureBoot Off"
    IF [%~3] NEQ [] (
        POWERSHELL -Command "Start-VM -Name !virtualMachineName!"
    )
ENDLOCAL
