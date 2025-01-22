#!/bin/sh

echo "Removing udev rule for BST Boards ..."
sudo rm -rf /etc/udev/rules.d/bst_coines.rules
sudo udevadm control --reload-rules


echo "Remove COINES_SDK Installation folder manually."
