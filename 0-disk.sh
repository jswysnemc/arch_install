#!/bin/bash

# set some colors
CNT="[\e[1;36mNOTE\e[0m]"
COK="[\e[1;32mOK\e[0m]"
CER="[\e[1;31mERROR\e[0m]"
CAT="[\e[1;37mATTENTION\e[0m]"
CWR="[\e[1;35mWARNING\e[0m]"
CAC="[\e[1;33mACTION\e[0m]"




# cfdisk -> /efi 100M,

# setting timedate

echo -e "\n$CNT starting  disk  ....................."



echo -e "$CWR This operation will cause irreversible loss, please confirm to continue (Enter 'y' to continue, any other character to exit): \c" 
read choice

if [[ $choice != "y" ]]; then
    exit 1
fi
sleep 2


read -p "Please enter the disk you want to delete the partition table (e.g. /dev/sda): " disk


# 删除磁盘上的分区表 
parted -s $disk mklabel gpt

echo "partition table has been deleted  !! "


parted -s $disk mklabel gpt mkpart primary fat32 1MiB 100MiB set 1 esp on

# 创建 Linux 系统分区（使用剩余空间）
parted -s $disk mkpart primary btrfs 100MiB 100%



# chroot /mnt
echo -e "\n$COK Has been completed. Please >>>>>>>>>>>>>>>> next \n"
