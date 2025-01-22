#!/bin/bash

VERSION="v2.9.1"

DEB_LIBUSB_DEV=libusb-1.0-0-dev
DEB_LIBUDEV_DEV=libudev-dev
DEB_GCC=gcc
DEB_MAKE=make
DEB_DFU=dfu-util

dependencies_debian="$DEB_LIBUSB_DEV  $DEB_GCC $DEB_MAKE $DEB_DFU $DEB_LIBUDEV_DEV"
dependencies_debian_gui="libqt5core5a libqt5gui5 libqt5network5 libqt5widgets5 python3-tk python3-pil.imagetk"

RH_LIBUSB_DEV=libusbx-devel
RH_GCC=gcc
RH_MAKE=make
RH_DFU=dfu-util

dependencies_redhat="$RH_LIBUSB_DEV $RH_GCC $RH_MAKE"
dependencies_redhat_gui="qt5-qtbase-gui python3-tkinter python3-pillow-tk"

APP_SHORTCUTS_DIR="$HOME/.local/share/applications"

if [ "$(which dpkg 2>/dev/null)" != "" ]; then
	DISTRO="DEBIAN"
	dependencies=$dependencies_debian
	dependencies_gui=$dependencies_debian_gui
	PKG_MGMT_SYSTEM=apt-get
	PKG_MGMT_UPDATE="$PKG_MGMT_SYSTEM update"
	PKG_MGMT_INSTALL="$PKG_MGMT_SYSTEM -y install"
elif [ "$(which rpm 2>/dev/null) " != "" ]; then
	DISTRO="REDHAT"
	dependencies=$dependencies_redhat
	dependencies_gui=$dependencies_redhat_gui
	PKG_MGMT_SYSTEM=yum
	PKG_MGMT_UPDATE="$PKG_MGMT_SYSTEM check-update"
	PKG_MGMT_INSTALL="$PKG_MGMT_SYSTEM -y install"
else
	DISTRO="UNKNOWN"
	dependencies="gcc make libusb-dev libudev-dev dfu-util"
fi

check_if_installed() {
	if [ "$DISTRO" = "DEBIAN" ]; then
		dpkg -s $1 2>/dev/null >/dev/null
	elif [ "$DISTRO" = "REDHAT" ]; then
		rpm -q $1 >/dev/null
	elif [ "$DISTRO" = "UNKNOWN" ]; then
		which $1 >/dev/null
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
		if [ $(check_if_installed $pkg) = "not_installed" ]; then
			unavailable_pkgs+=" $pkg"
		fi
	done
	echo "$unavailable_pkgs"
}

## Prompt user to install dependencies
prompt_to_install_dependencies() {
	if [ "$1" != "" ]; then
		unavailable_pkgs_temp=$(echo $1 | sed "s/ /,/g")
		echo -n "Do you want to install $unavailable_pkgs_temp? [y/n]"
		read ans
		if [ "$ans" = "Y" ] || [ "$ans" = "y" ] && [ "$DISTRO" != "UNKNOWN" ]; then
			echo -n "Do you want to run $PKG_MGMT_UPDATE before installing the packages? [y/n]"
			read ans
			if [ "$ans" = "Y" ] || [ "$ans" = "y" ]; then
				sudo $PKG_MGMT_UPDATE
			fi
			sudo $PKG_MGMT_INSTALL $1
		else
			echo "Please  install the dependencies $unavailable_pkgs_temp manually !"
		fi
	fi
}
## Ask for installation path
printf "Please select install path:[/home/$USER/COINES_SDK/$VERSION]"
read INPUT
INST_PATH="/home/$USER/COINES_SDK/$VERSION"
if [ ! -z $INPUT ]; then
	eval INST_PATH=$INPUT
fi

## Ask for deleting legacy COINES
if [ -d "/home/$USER/COINES" ]; then
	responded=
	while [ x$responded = x ]
	do
		printf "Do you want to delete the legacy COINES in the path:[/home/$USER/COINES]? [yes or no]"
		read reply leftover
		case $reply in
			[yY] | [yY]es)
			responded=1
			echo "Deleting legacy COINES...";
			rm -rf "/home/$USER/COINES"
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

mkdir -p $INST_PATH/examples
tar xf $INST_PATH/examples.tar.gz -C $INST_PATH/examples

if [ "$not_installed" == "" ]; then
	UTIL_LIST="app20-flash app_switch"
	for util in $UTIL_LIST; do
		make -C $INST_PATH/tools/$util
	done
fi

## UDEV Configuration
echo "Configuring udev rules...."
PREV_DIR=$PWD
cd $INST_PATH/driver/
bash install_driver.sh
cd $PREV_DIR

## To access serial port devices without being root
sudo adduser $USER dialout
