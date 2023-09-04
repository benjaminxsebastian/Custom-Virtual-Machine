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
    ECHO Usage: create-virtualbox-virtual-machine [Virtual Machine Name] [Temporary Directory] [Path to Customized Install ISO]
    SET invalidArgument=
    EXIT /B 11001
)

SETLOCAL ENABLEDELAYEDEXPANSION
    SET "virtualMachineName=%~1"
    SET "virtualMachineDirectory=!USERPROFILE!\VirtualBox VMs"
    SET "dateToday=!DATE%:~4!"
    SET "dateToday=%dateToday: =%"
    SET "dateToday=%dateToday:/=%"
    SET "timeNow=!TIME!"
    SET "timeNow=%timeNow: =%"
    SET "timeNow=%timeNow::=.%"
    SET "temporaryVirtualMachineName=Temp!virtualMachineName!-!dateToday!-!timeNow!"
    SET "temporaryVirtualMachineDirectory=%~2\!temporaryVirtualMachineName!"

    VBoxManage controlvm !virtualMachineName! shutdown --force

:CheckForRunningVirtualMachineAfterFirstShutdown
    FOR /F "usebackq delims==" %%R IN (`VBoxManage list runningvms`) DO (
        FOR /F "tokens=1 delims= " %%T IN ("%%R") DO (
            SET "running=%%T"
            SET "running=!running:%~1=!"
            IF [!running!] EQU [""] (
                TIMEOUT /T 10
                GOTO CheckForRunningVirtualMachineAfterFirstShutdown
            )
        )
    )

    VBoxManage modifyvm !virtualMachineName! --name !temporaryVirtualMachineName!
    VBoxManage movevm !temporaryVirtualMachineName! --folder "%~2" --type basic
    VBoxManage createvm --name "!virtualMachineName!" --basefolder "!virtualMachineDirectory!" --ostype Ubuntu_64 --register
    VBoxManage createmedium disk --filename "!virtualMachineDirectory!/!virtualMachineName!/!virtualMachineName!.vdi" --size 25600 --format VDI --variant Fixed
    VBoxManage storagectl "!virtualMachineName!" --name "IDE" --add ide --controller PIIX4 --hostiocache on
    IF [%~3] EQU [] (
        VBoxManage storageattach "!virtualMachineName!" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium emptydrive
    ) ELSE (
        VBoxManage storageattach "!virtualMachineName!" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "%~3"
    )
    VBoxManage storagectl "!virtualMachineName!" --name "SATA" --add sata --controller IntelAhci
    VBoxManage storageattach "!virtualMachineName!" --storagectl "SATA" --port 1 --device 0 --type hdd --medium "!virtualMachineDirectory!/!virtualMachineName!/!virtualMachineName!.vdi"
    VBoxManage modifyvm "!virtualMachineName!" --clipboard-mode  bidirectional --memory 2048 --rtc-use-utc on --cpus 1 --pae off --vram 16 --graphicscontroller vmsvga --audio-out on --nic1 nat  --usb-ehci on
    TIMEOUT /T 5
    VBoxManage startvm "!virtualMachineName!"

    SET attempt=0
:CheckForRunningVirtualMachineAfterSecondShutdown
    FOR /F "usebackq delims==" %%R IN (`VBoxManage list runningvms`) DO (
        FOR /F "tokens=1 delims= " %%T IN ("%%R") DO (
            SET "running=%%T"
            SET "running=!running:%~1=!"
            IF [!running!] EQU [""] (
                SET attempt=0
                TIMEOUT /T 120
                GOTO CheckForRunningVirtualMachineAfterSecondShutdown
            )
        )
    )
    IF !attempt! LSS 2 (
        SET /A attempt=!attempt!+1
        TIMEOUT /T 10
        GOTO CheckForRunningVirtualMachineAfterSecondShutdown
    )

    VBoxManage storageattach "!virtualMachineName!" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium additions
    TIMEOUT /T 5
    VBoxManage startvm "!virtualMachineName!"

:CheckForRunningVirtualMachineAfterThirdShutdown
    FOR /F "usebackq delims==" %%R IN (`VBoxManage list runningvms`) DO (
        FOR /F "tokens=1 delims= " %%T IN ("%%R") DO (
            SET "running=%%T"
            SET "running=!running:%~1=!"
            IF [!running!] EQU [""] (
                TIMEOUT /T 30
                GOTO CheckForRunningVirtualMachineAfterThirdShutdown
            )
        )
    )

    TIMEOUT /T 5
    VBoxManage startvm "!virtualMachineName!"
    TIMEOUT /T 180
    VBoxManage controlvm !virtualMachineName! shutdown --force

:CheckForRunningVirtualMachineAfterFourthShutdown
    FOR /F "usebackq delims==" %%R IN (`VBoxManage list runningvms`) DO (
        FOR /F "tokens=1 delims= " %%T IN ("%%R") DO (
            SET "running=%%T"
            SET "running=!running:%~1=!"
            IF [!running!] EQU [""] (
                TIMEOUT /T 30
                GOTO CheckForRunningVirtualMachineAfterFourthShutdown
            )
        )
    )

    VBoxManage snapshot "!virtualMachineName!" take "Base Snapshot"
ENDLOCAL
