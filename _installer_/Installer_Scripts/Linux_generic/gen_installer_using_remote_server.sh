#!/bin/bash

# Run this script on Windows Machine using Git Bash
# Requires openssh-server ,git to be installed on the remote Linux server
# One can run and connect with VM installed locally

COINES_REPO_ROOT="../../.."

temp_repo_folder="__coines"

if [ $# -eq 3 ]; then
	remote_ip=$1
	ssh_port=$2
	user=$3
else
	echo "Usage: $0 <Remote_IP> <SSH Port> <User>"
	echo "Example 1: $0 10.30.22.6 22 winston"
	echo "Example 2: $0 localhost 2222 winston"
	echo "Example 3: $0 cob1033442 2222 coines"
	exit
fi

# SSH Port Configuration
ssh_non_std="ssh -p $ssh_port"
REMOTE_EXEC="$ssh_non_std -t $user@$remote_ip"

rm -rf $COINES_REPO_ROOT/__temp
tar czf $COINES_REPO_ROOT/../$temp_repo_folder.tar.gz $COINES_REPO_ROOT

echo "Copying compressed repo to VM/Remote Linux Machine ..."
scp -P $ssh_port $COINES_REPO_ROOT/../$temp_repo_folder.tar.gz $user@$remote_ip:/home/$user/

echo "Extracting repo on VM/Remote Linux Machine ..."
$REMOTE_EXEC "rm -rf $temp_repo_folder && mkdir $temp_repo_folder && tar xf $temp_repo_folder.tar.gz -C $temp_repo_folder"

echo "Performing a git checkout.."
$REMOTE_EXEC "cd $temp_repo_folder && git checkout -f"

echo "Generating the installer .."
$REMOTE_EXEC "cd ~/$temp_repo_folder/_installer_/Installer_Scripts/Linux_generic && ./gen_install_script.sh"

TAG_DESC=$(git describe --tags)
echo "Get the generated installer on our Windows machine"
scp -P $ssh_port $user@$remote_ip:~/$temp_repo_folder/_installer_/Installer_Scripts/Linux_generic/coines_$TAG_DESC.sh coines_$TAG_DESC.sh
