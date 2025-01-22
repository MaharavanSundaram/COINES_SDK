::@echo off

set RELEASE_DIR=..\..\..\__temp

set RELEASE_TYPE=%1

set COINES_DIR=%RELEASE_DIR%\COINES_SDK

del %RELEASE_DIR%\*.* /s /q

rm -r %RELEASE_DIR%\

set PROJ_DIR=..\..\..
set SWTOOLS_DIR=%PROJ_DIR%\..\Embedded_Tools\pst_tools\PRM_tec_SWtools
set INNO_TOOL_DIR=%SWTOOLS_DIR%\InnoSetup5\v5.6.0

mkdir %RELEASE_DIR%
set MAKE_TOOL=mingw32-make

:: Prerequisites check
set CHECK_RESULT=1
where git
if %ERRORLEVEL%==0 ( 
echo "Git found !"
) else ( 
echo "Git not found.Install Git (or) add Git path to PATH environmental variable"
set CHECK_RESULT=0  
)

where gcc
if %ERRORLEVEL%==0 ( 
echo GCC found !
) else ( 
echo "GCC not found . Install TDM-GCC (or) add GCC path to PATH environmental variable"
set CHECK_RESULT=0
)

where arm-none-eabi-gcc
if %ERRORLEVEL%==0 ( 
echo GCC found !
) else ( 
echo "GCC Arm Embedded tools not found . Install arm-none-eabi-gcc and add to PATH environmental variable"
set CHECK_RESULT=0
)

@REM where pdflatex
if %ERRORLEVEL%==0 ( 
echo Latex found !
) else ( 
echo "PDFLatex not found ! Install Latex from SCCM .."
set CHECK_RESULT=0
)

if %CHECK_RESULT%==0 (
echo "All Prerequisites not found !"
exit /b
)

:: Git clean
:: WARNING - !!!!! Will delete untracked files from COINES_SDK repo !!!!!! 
:: Use git add <filename> to avoid deletion of untracked file

:: set CLEAN_DIR_LIST=(coines-api examples _installer_ tools)
:: for %%c in %CLEAN_DIR_LIST% do (
:: git clean -f -d -x ../../../%%c
:: )

:: coines-api
mkdir %COINES_DIR%\coines-api
xcopy %PROJ_DIR%\coines-api %COINES_DIR%\coines-api /E /EXCLUDE:%cd%\exclusion.txt

:: libraries
mkdir %COINES_DIR%\libraries
xcopy %PROJ_DIR%\libraries %COINES_DIR%\libraries /E 

:: ble dependency handler scripts
mkdir %COINES_DIR%\installer_scripts\Windows
xcopy %PROJ_DIR%\_installer_\Installer_Scripts\Windows\ble_dependency_verifier.bat %COINES_DIR%\installer_scripts\Windows
xcopy %PROJ_DIR%\_installer_\Installer_Scripts\Windows\ble_env_path_setter.bat %COINES_DIR%\installer_scripts\Windows
xcopy %PROJ_DIR%\_installer_\Installer_Scripts\Windows\ble_env_path_remover.bat %COINES_DIR%\installer_scripts\Windows

:: thirdparty
mkdir %COINES_DIR%\thirdparty
robocopy %PROJ_DIR%\thirdparty %COINES_DIR%\thirdparty /XD "nRF5_SDK" /E

:: Delete files with invalid names to avoid .iss script termination
del %COINES_DIR%\thirdparty\openocd\tcl\target\1986*.cfg
del %COINES_DIR%\thirdparty\openocd\tcl\target\*1879x*.cfg


:: thirdparty nRF5_SDK
robocopy %PROJ_DIR%\thirdparty\nRF5_SDK %COINES_DIR%\thirdparty\nRF5_SDK /XD "examples" "external" /E
robocopy %PROJ_DIR%\thirdparty\nRF5_SDK\external %COINES_DIR%\thirdparty\nRF5_SDK\external "licenses_external.txt"
robocopy %PROJ_DIR%\thirdparty\nRF5_SDK\external\fnmatch %COINES_DIR%\thirdparty\nRF5_SDK\external\fnmatch
robocopy %PROJ_DIR%\thirdparty\nRF5_SDK\external\utf_converter %COINES_DIR%\thirdparty\nRF5_SDK\external\utf_converter
robocopy %PROJ_DIR%\thirdparty\nRF5_SDK\external\segger_rtt %COINES_DIR%\thirdparty\nRF5_SDK\external\segger_rtt

:: examples
if NOT "%RELEASE_TYPE%" == "GITHUB" (
mkdir %COINES_DIR%\examples
xcopy %PROJ_DIR%\examples\* %COINES_DIR%\examples\* /E
) else (
mkdir %COINES_DIR%\examples
xcopy %PROJ_DIR%\examples\c\* %COINES_DIR%\examples\c\* /E
xcopy %PROJ_DIR%\examples\python\* %COINES_DIR%\examples\python\* /E
)

copy %PROJ_DIR%\coines.mk %COINES_DIR%\coines.mk
:: Firmware
mkdir %COINES_DIR%\firmware
xcopy /s %PROJ_DIR%\firmware\* %COINES_DIR%\firmware\* /E

::APP20
@REM mingw32-make SPECIAL_FW=BOOTLOADER -C %PROJ_DIR%\coines-api\mcu_app20\bootloaders\_special_fw_upgrade_packager_
@REM copy %PROJ_DIR%\coines-api\mcu_app20\bootloaders\_special_fw_upgrade_packager_\usb_dfu_bootloader.pkg %COINES_DIR%\firmware\app2.0\coines_bootloader\coines_usb_dfu_bl.pkg

::APP30
del %COINES_DIR%\firmware\app3.0\mtp_fw_update\usb_mtp_WinUSB_RAM.bin

@REM mingw32-make SPECIAL_FW=BOOTLOADER -C %PROJ_DIR%\coines-api\mcu_app30\bootloaders\_special_fw_upgrade_packager_
@REM mingw32-make SPECIAL_FW=USB_MTP -C %PROJ_DIR%\coines-api\mcu_app30\bootloaders\_special_fw_upgrade_packager_

@REM copy %PROJ_DIR%\coines-api\mcu_app30\bootloaders\_special_fw_upgrade_packager_\usb_ble_dfu_bootloader.pkg %COINES_DIR%\firmware\app3.0\bootloader_update
@REM copy %PROJ_DIR%\coines-api\mcu_app30\bootloaders\_special_fw_upgrade_packager_\usb_mtp.pkg %COINES_DIR%\firmware\app3.0\mtp_fw_update

::APP31
del %COINES_DIR%\firmware\app3.1\mtp_fw_update\usb_mtp_WinUSB_RAM.bin

@REM mingw32-make SPECIAL_FW=BOOTLOADER -C %PROJ_DIR%\coines-api\mcu_app31\bootloaders\_special_fw_upgrade_packager_
@REM mingw32-make SPECIAL_FW=USB_MTP -C %PROJ_DIR%\coines-api\mcu_app31\bootloaders\_special_fw_upgrade_packager_

@REM copy %PROJ_DIR%\coines-api\mcu_app31\bootloaders\_special_fw_upgrade_packager_\usb_ble_dfu_bootloader.pkg %COINES_DIR%\firmware\app3.1\bootloader_update
@REM copy %PROJ_DIR%\coines-api\mcu_app31\bootloaders\_special_fw_upgrade_packager_\usb_mtp.pkg %COINES_DIR%\firmware\app3.1\mtp_fw_update

set PREV_DIR=%cd%
if NOT "%RELEASE_TYPE%" == "GITHUB" (
:: Remove '.sh' files from 'firmware' folder since it is Windows
cd %COINES_DIR%\firmware
del *.sh /s
cd %PREV_DIR%
)
:: Docs - Generate PDF
mkdir %COINES_DIR%\doc
@REM echo "Building PDF .."

@REM set PREV_DIR=%cd%
@REM cd %PROJ_DIR%\doc\latex
@REM del /s /q *.pdf
@REM texify -cpq BST-DHW-AN013-00.tex
@REM cd %PREV_DIR%

:: Remove revision number in filename
copy %PROJ_DIR%\doc\latex\BST-DHW-AN013-00.pdf  %COINES_DIR%\doc\BST-DHW-AN013.pdf

:: USB driver
:: Pack driver
set PREV_DIR=%cd%
cd  %PROJ_DIR%\_installer_\Windows_specific\driver
7z a -t7z _drivers.7z -m0=lzma -mx=9 -aoa  .\_driver_files\*
copy /b 7zDP_lzma.sfx + 7zDP_lzma.cfg + _drivers.7z app_board_usb_driver.exe
cd %PREV_DIR%
xcopy "%PROJ_DIR%\_installer_\Windows_specific\driver\app_board_usb_driver.exe" %COINES_DIR%\driver\ /E

if "%RELEASE_TYPE%" == "GITHUB" (
xcopy %PROJ_DIR%\_installer_\Linux_specific\driver\* %COINES_DIR%\driver\linux\* /E
)

:: util
mkdir %COINES_DIR%\tools
mkdir %COINES_DIR%\tools\usb-dfu
mkdir %COINES_DIR%\tools\app30-ble-dfu
mkdir %COINES_DIR%\tools\app20-flash
mkdir %COINES_DIR%\tools\app_switch
mkdir %COINES_DIR%\tools\ble-nus-term
mkdir %COINES_DIR%\tools\openocd

copy %PROJ_DIR%\tools\usb-dfu\*  %COINES_DIR%\tools\usb-dfu\*
copy %PROJ_DIR%\tools\app30-ble-dfu\* %COINES_DIR%\tools\app30-ble-dfu\*
copy %PROJ_DIR%\tools\app_switch\* %COINES_DIR%\tools\app_switch\*
copy %PROJ_DIR%\tools\app20-flash\* %COINES_DIR%\tools\app20-flash\*
copy %PROJ_DIR%\tools\ble-nus-term\* %COINES_DIR%\tools\ble-nus-term\*
xcopy %PROJ_DIR%\tools\openocd\* %COINES_DIR%\tools\openocd\* /E

:: Delete files with invalid names to avoid .iss script termination
del %COINES_DIR%\tools\openocd\xpack-openocd-0.11.0-4\scripts\target\1986*.cfg
del %COINES_DIR%\tools\openocd\xpack-openocd-0.11.0-4\scripts\target\*1879x*.cfg

mingw32-make -C %PROJ_DIR%\tools\app_switch
mingw32-make -C %PROJ_DIR%\tools\app20-flash
strip %PROJ_DIR%\tools\app_switch\app_switch.exe
strip %PROJ_DIR%\tools\app20-flash\app20-flash.exe
mingw32-make -C %PROJ_DIR%\tools\app_switch clean
mingw32-make -C %PROJ_DIR%\tools\app20-flash clean
mingw32-make clean-all

:: Delete all  .cproject, .project files
:: The above files are for internal development purpose
set PREV_DIR=%cd%
cd %RELEASE_DIR%
set FILES_TO_DELETE=(.cproject .project)
for %%f in %FILES_TO_DELETE% do (
del %%f /s
)

:: Delete all folders with name _*_ 
for /f %%i in ('dir /a:d /s /b _*_') do (
rd /s /q %%i
)
cd %PREV_DIR%

@REM :: Examples.zip
@REM if NOT "%RELEASE_TYPE%" == "GITHUB" (
@REM 7z a -tzip %COINES_DIR%\examples.zip %COINES_DIR%\examples
@REM )

:: Release Notes,COINES_SDK_SoftwareLicenseAgreement ,etc.,
copy %PROJ_DIR%\ReleaseNotes.txt %COINES_DIR%\ReleaseNotes.txt
:: copy %PROJ_DIR%\doc\ReleaseNotes_public.txt %COINES_DIR%\ReleaseNotes.txt
copy %PROJ_DIR%\COINES_SDK_SoftwareLicenseAgreement.txt %COINES_DIR%\COINES_SDK_SoftwareLicenseAgreement.txt
copy %PROJ_DIR%\README.md %COINES_DIR%\README.md


::Create Installer
%INNO_TOOL_DIR%\ISCC.exe COINES_SDK_PRM.iss

:: Get Git Tag Description
for /F "tokens=* USEBACKQ" %%F in (`git describe  --tags`) do (
set TAG_DESC=%%F
)
if NOT "%RELEASE_TYPE%" == "GITHUB" (
set INSTALLER_NAME=%TAG_DESC%
) else (
set INSTALLER_NAME=%TAG_DESC%_GH
)

ren COINES_SDK.exe %INSTALLER_NAME%.exe
:: Zip the Installer
7z a -tzip %INSTALLER_NAME%_installer_windows.zip %INSTALLER_NAME%.exe

7z a -tzip %INSTALLER_NAME%_source.zip %COINES_DIR%
