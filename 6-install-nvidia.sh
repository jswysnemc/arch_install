#!/bin/bash

# set some colors
CNT="[\e[1;36mNOTE\e[0m]"
COK="[\e[1;32mOK\e[0m]"
CER="[\e[1;31mERROR\e[0m]"
CAT="[\e[1;37mATTENTION\e[0m]"
CWR="[\e[1;35mWARNING\e[0m]"
CAC="[\e[1;33mACTION\e[0m]"


sudo pacman -S linux-headers nvidia-dkms nvidia-utils nvidia-settings


sudo sed -i 's/GRUB_CMDLINE_LINUX=""/#GRUB_CMDLINE_LINUX=""\nGRUB_CMDLINE_LINUX="nvidia_drm.modeset=1"/g'  /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg


sed -i '/^HOOKS=(base kms udev autodetect microcode modconf keyboard keymap consolefont numlock block encrypt filesystems fsck)$/{
h
s/kms //
x
s/^/# /
G
}' /etc/mkinitcpio.conf

sudo sed -i 's/MODULES=()/# MODULES=()\nMODULES=(nvidia nvidia_modeset nvidia_drm)/g' /etc/mkinitcpio.conf




sudo mkinitcpio -P






