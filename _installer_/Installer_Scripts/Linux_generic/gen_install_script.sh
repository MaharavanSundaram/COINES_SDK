#!/bin/bash

RELEASE_DIR=../../../__temp

PROJ_DIR=../../../

COINES_DIR=$RELEASE_DIR/COINES_SDK

rm -rf $RELEASE_DIR

mkdir $RELEASE_DIR

# Git clean up
# WARNING - !!!!! Will delete untracked files from COINES_SDK repo !!!!!!
# Use git add <filename> to avoid deletion of untracked file

CLEAN_DIR_LIST="coines-api examples _installer_"
for clean_dir in $CLEAN_DIR_LIST; do
	git clean -f -d -x $PROJ_DIR/$clean_dir
done
# coines-api
mkdir -p $COINES_DIR/coines-api
cp -R $PROJ_DIR/coines-api/ $COINES_DIR

# thirdparty
mkdir -p $COINES_DIR/thirdparty
rsync -a --exclude="nRF5_SDK" "$PROJ_DIR/thirdparty/" "$COINES_DIR/thirdparty/"

# nRF5_SDK
rsync -a --exclude={"examples","external"} "$PROJ_DIR/thirdparty/nRF5_SDK/" "$COINES_DIR/thirdparty/nRF5_SDK/"
rsync -a "$PROJ_DIR/thirdparty/nRF5_SDK/external/licenses_external.txt" "$COINES_DIR/thirdparty/nRF5_SDK/external/"
rsync -a "$PROJ_DIR/thirdparty/nRF5_SDK/external/fnmatch" "$COINES_DIR/thirdparty/nRF5_SDK/external/"
rsync -a "$PROJ_DIR/thirdparty/nRF5_SDK/external/utf_converter" "$COINES_DIR/thirdparty/nRF5_SDK/external/"
rsync -a "$PROJ_DIR/thirdparty/nRF5_SDK/external/segger_rtt" "$COINES_DIR/thirdparty/nRF5_SDK/external/"

# libraries
mkdir -p $COINES_DIR/libraries
cp -R $PROJ_DIR/libraries/ $COINES_DIR

# examples
mkdir -p $COINES_DIR/examples
cp -R $PROJ_DIR/examples $COINES_DIR/

cp $PROJ_DIR/coines.mk $COINES_DIR/

# Firmware
mkdir -p $COINES_DIR/firmware
cp -R $PROJ_DIR/firmware/ $COINES_DIR

# APP20
# make SPECIAL_FW=BOOTLOADER -C $PROJ_DIR/coines-api/mcu_app20/bootloaders/_special_fw_upgrade_packager_
# cp $PROJ_DIR/coines-api/mcu_app20/bootloaders/_special_fw_upgrade_packager_/usb_dfu_bootloader.pkg $COINES_DIR/firmware/app2.0/coines_bootloader/coines_usb_dfu_bl.pkg


# APP30
# make SPECIAL_FW=BOOTLOADER -C $PROJ_DIR/coines-api/mcu_app30/bootloaders/_special_fw_upgrade_packager_
# make SPECIAL_FW=USB_MTP -C $PROJ_DIR/coines-api/mcu_app30/bootloaders/_special_fw_upgrade_packager_

# cp $PROJ_DIR/coines-api/mcu_app30/bootloaders/_special_fw_upgrade_packager_/usb_ble_dfu_bootloader.pkg $COINES_DIR/firmware/app3.0/bootloader_update
# cp $PROJ_DIR/coines-api/mcu_app30/bootloaders/_special_fw_upgrade_packager_/usb_mtp.pkg $COINES_DIR/firmware/app3.0/mtp_fw_update

rm $COINES_DIR/firmware/app3.0/mtp_fw_update/usb_mtp_WinUSB_RAM.bin

# APP31
# make SPECIAL_FW=BOOTLOADER -C $PROJ_DIR/coines-api/mcu_app31/bootloaders/_special_fw_upgrade_packager_
# make SPECIAL_FW=USB_MTP -C $PROJ_DIR/coines-api/mcu_app31/bootloaders/_special_fw_upgrade_packager_

# cp $PROJ_DIR/coines-api/mcu_app31/bootloaders/_special_fw_upgrade_packager_/usb_ble_dfu_bootloader.pkg $COINES_DIR/firmware/app3.1/bootloader_update
# cp $PROJ_DIR/coines-api/mcu_app31/bootloaders/_special_fw_upgrade_packager_/usb_mtp.pkg $COINES_DIR/firmware/app3.1/mtp_fw_update
# Remove '.bat' files from 'firmware' folder since it is not Windows

rm $COINES_DIR/firmware/app3.1/mtp_fw_update/usb_mtp_WinUSB_RAM.bin

find $COINES_DIR/firmware -type f -name "*.bat" -delete

# Docs
mkdir -p $COINES_DIR/doc
# git clean -f -d -x $PROJ_DIR/doc/*.pdf
# # PDF Generation from TeX files
# prev_dir=$PWD
# cd $PROJ_DIR/doc/latex
# for ((i = 1; i <= 3; i++)); do
# 	pdflatex -synctex=1 -interaction=nonstopmode BST-DHW-AN013-00.tex >/dev/null
# done
# cd $prev_dir
cp $PROJ_DIR/doc/latex/BST-DHW-AN013-00.pdf $COINES_DIR/doc/BST-DHW-AN013.pdf


# C++
#mkdir -p $COINES_DIR/examples/cpp

# uninstall.sh
cp -r ./uninstall.sh $COINES_DIR

# Delete all folders with name _*_
find $RELEASE_DIR -type d -name '_*_' -exec rm -r {} +

# USB driver
cp -R $PROJ_DIR/_installer_/Linux_specific/driver $COINES_DIR

# tools
mkdir -p $COINES_DIR/tools
UTIL_LIST="app20-flash app_switch"
for util in $UTIL_LIST; do
	rm $PROJ_DIR/tools/$util/$util.exe
	make -C $PROJ_DIR/tools/$util
	strip $PROJ_DIR/tools/$util/$util
	rm -rf $PROJ_DIR/tools/$util/build
	cp -R $PROJ_DIR/tools/$util $COINES_DIR/tools/$util
done
cp -R $PROJ_DIR/tools/app30-ble-dfu $COINES_DIR/tools/
cp -R $PROJ_DIR/tools/ble-nus-term $COINES_DIR/tools/
cp -R $PROJ_DIR/tools/openocd $COINES_DIR/tools/

# Delete all .cproject, .project files
# The above files are for internal development purpose
files_to_delete=".cproject .project"
for file in $files_to_delete; do
	find $COINES_DIR/examples -type f -name "$file" -delete
	find $COINES_DIR/coines-api -type f -name "$file" -delete
	find $COINES_DIR/tools -type f -name "$file" -delete
done

# Examples.tar.gz
tar -czf $COINES_DIR/examples.tar.gz -C $COINES_DIR/examples .

# ReleaseNotes,LICENSES,etc.,
cp $PROJ_DIR/ReleaseNotes.txt $COINES_DIR/ReleaseNotes.txt
# cp $PROJ_DIR/doc/ReleaseNotes_public.txt $COINES_DIR/ReleaseNotes.txt
cp $PROJ_DIR/COINES_SDK_SoftwareLicenseAgreement.txt $COINES_DIR
cp $PROJ_DIR/README.md $COINES_DIR/README.md

# make .sh
cp -r ./coines-inst.sh $RELEASE_DIR
tar zcf __data.tar.gz $RELEASE_DIR
cat ./License_Parsing_Script __data.tar.gz >coines_sdk_installer.sh
rm __data.tar.gz
chmod +x coines_sdk_installer.sh

# Rename installer with version information
TAG_DESC=$(git describe --tags)
mv coines_sdk_installer.sh $TAG_DESC.sh

tar -czvf ${TAG_DESC}_installer_linux.tar.gz $TAG_DESC.sh

tar -czf  $TAG_DESC.tar.gz -C $COINES_DIR/ .
