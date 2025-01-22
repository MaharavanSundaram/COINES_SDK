#!/bin/bash

VERSION="v2.9.1"
MAC_LIBUSB_DEV=libusb
MAC_DFU_UTIL=dfu-util
MAC_GCC_ARM_TOOLCHAIN=gcc-arm-embedded
MAC_GCC=gcc
MAC_MAKE=make

dependencies_mac="$MAC_LIBUSB_DEV $MAC_DFU_UTIL $MAC_GCC_ARM_TOOLCHAIN"

APP_SHORTCUTS_DIR=/Applications

if [ "$(uname -s)" == "Darwin" ]; then
	OS="MAC"
	dependencies=$dependencies_mac
	PKG_MGMT_SYSTEM=brew
	PKG_MGMT_UPDATE="$PKG_MGMT_SYSTEM update"
	PKG_MGMT_INSTALL="$PKG_MGMT_SYSTEM install"
else
	OS="UNKNOWN"
	dependencies="gcc make libusb-dev libudev-dev"
fi

check_if_installed() {
	if [ "$OS" = "MAC" ]; then
		brew list | grep $1 >/dev/null
	elif [ "$OS" = "UNKNOWN" ]; then
		echo "Unknown Operating System"
	fi

	if [ $? -eq 0 ]; then
		echo "installed"
	else
		echo "not_installed"
	fi
}

## Get list of dependencies/packages not installed
get_list_not_installed() {
	for pkg in $1; do
		if [ $(check_if_installed $pkg) == "not_installed" ]; then
			unavailable_pkgs+=" $pkg"
		fi
	done
	echo "$unavailable_pkgs"
}

## Prompt user to install dependencies
prompt_to_install_dependencies() {
	if [ "$1" != "" ]; then
		unavailable_pkgs_temp=$(echo $1 | sed "s/ /,/g")
		echo -n "Do you want to install $unavailable_pkgs_temp? [y or n]"
		read ans
		if [ "$ans" = "Y" ] || [ "$ans" = "y" ] && [ "$DISTRO" != "UNKNOWN" ]; then
			echo -n "Do you want to run $PKG_MGMT_UPDATE before installing the packages? [y/n]"
			read ans
			if [ "$ans" = "Y" ] || [ "$ans" = "y" ]; then
				$PKG_MGMT_UPDATE
			fi
			if [ "$1" = "gcc-arm-embedded" ]; then
				$PKG_MGMT_INSTALL --cask $1
			else
				$PKG_MGMT_INSTALL $1
			fi
		else
			echo "Please  install the dependencies $unavailable_pkgs_temp manually !"
		fi
	fi
}
## Ask for installation path
printf "Please select install path:[$HOME/COINES_SDK/$VERSION]"
read INPUT

if [ ! -z $INPUT ]; then
	eval INST_PATH=$INPUT
else
	INST_PATH=$HOME/COINES_SDK/$VERSION
fi

## Ask for deleting legacy COINES
if [ -d "$HOME/COINES" ]; then
	responded=
	while [ x$responded = x ]
	do
		printf "Do you want to delete the legacy COINES in the path:[$HOME/COINES]? [yes or no]"
		read reply leftover
		case $reply in
			[yY] | [yY]es)
			responded=1
			echo "Deleting legacy COINES...";
			rm -rf "$HOME/COINES"
			echo "Done !";
			exit 1
			;;
			[nN] | [nN]o)
			responded=1
			;;
			*)
			echo "Please input yes/y or no/n"
			;;
		esac
	done
fi

not_installed=$(get_list_not_installed "$dependencies")
if [ "$not_installed" != "" ]; then
	echo "Dependencies which are required to build COINES_SDK examples are missing !"
fi

prompt_to_install_dependencies "$not_installed"
## Copy files to installation path
mkdir -p $INST_PATH
if [ $? -ne 0 ]; then
	echo "Create installation directory failed."
	exit 1	
fi
cp -rpf __temp/COINES_SDK/* $INST_PATH/

UTIL_LIST="app20-flash app_switch"
for util in $UTIL_LIST; do
	make -C $INST_PATH/tools/$util
done

mkdir -p $INST_PATH/examples
tar xf $INST_PATH/examples.tar.gz -C $INST_PATH/examples

