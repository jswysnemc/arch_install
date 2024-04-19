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

echo -e "\n$CNT starting settings timedate ....................."

timedatectl set-ntp true
timedatectl set-timezone Asia/Shanghai
timedatectl set-ntp true
hwclock --systohc --utc


echo -e "\n$CAC timedate done ...................."
sleep 1


echo -e "$CWR please create 2 blocks before!!! "


read -p "Has the partition been created? Continue? (Enter 'y' to continue, any other character to exit):" choice

if [[ $choice != "y" ]]; then
    exit 1
fi
sleep 2

lsblk
echo -e "choose your block to efi (default is /dev/sda1) \n\n NOTICE:This operation will erase all the date in your U disk!!!\n\n"
read -p "Enter you block(in 20s ):" -t 20 EFI_BLOCK
BLOCK_STATE=$?
if [[ $BLOCK_STATE -eq 142 ]]
then
    EFI_BLOCK='/dev/sda1'
fi
echo "your block is $EFI_BLOCK"


echo -e "choose your block to root,home,swap for btrfs (default is /dev/sda2) \n\n NOTICE:This operation will erase all the date in your U disk!!!\n\n"
read -p "Enter you block(in 20s ):" -t 20 ROOT_BLOCK
BLOCK_STATE=$?
if [[ $BLOCK_STATE -eq 142 ]]
then
    ROOT_BLOCK='/dev/sda2'
fi
echo "your block is $ROOT_BLOCK"

sleep 3



# mkfs
echo -e "\n$CNT starting mkfs ....................."
sleep 1
mkfs.fat -F32  $EFI_BLOCK  # efi 分区
echo -e "\n$CAC $EFI_BLOCK done ...................."
sleep 1
# 如果是多磁盘还需要加上磁盘阵列 例如： -d raid0 -m raid1
mkfs.btrfs -f -L "MyArch" --checksum xxhash $ROOT_BLOCK
echo -e "\n$CAC  $ROOT_BLOCK done ...................."
sleep 1

# mount
echo -e "\n$CNT starting create subvolume ...................."
sleep 1
mount $ROOT_BLOCK /mnt

sleep 1
btrfs sub create /mnt/@
sleep 1
btrfs sub create /mnt/@home
sleep 1

btrfs sub create /mnt/@swap
sleep 1


sleep 1
umount /mnt
echo -e "\n$CAC created subvolume done ...................."

echo -e "\n$CNT starting mount ........................."
sleep 1
mount -o noatime,ssd,compress-force=zstd,nodiscard,subvol=@  $ROOT_BLOCK  /mnt   # 根分区
echo -e "\n$CAC root mounted done ...................."

sleep 1
mount $EFI_BLOCK /mnt/efi --mkdir    # efi 分区
echo -e "\n$CAC efi mounted done ...................."
sleep 1
mount -o noatime,ssd,compress-force=zstd,nodiscard,subvol=@home  $ROOT_BLOCK  /mnt/home --mkdir  # home 分区
echo -e "\n$CAC home mounted done ...................."
sleep 1

mount -o defaults,subvol=@swap $ROOT_BLOCK  /mnt/swap --mkdir  #swap 分区
echo -e "\n$CAC swap mounted done ...................."
sleep 1

lsblk

sleep 5


# disable reflector
echo -e "\n$CNT uninstall reflector ........................"
pacman -Rsnu reflector --noconfirm
echo -e "\n$CAC uninstall reflector done ...................."
sleep 1

echo -e "\n$CNT fix mirrorlist ........................."
cat > /etc/pacman.d/mirrorlist << EOF
Server=https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch
Server=https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch
EOF

echo -e "\n$CAC created subvolume done ...................."
sleep 1

# install system
echo -e "\n$CNT startings install system .........................."
sleep 1
pacstrap /mnt base base-devel linux linux-firmware btrfs-progs neovim networkmanager git pacman-contrib
echo -e "\n$CAC install system done ...................."
sleep 1

# gen fstab
echo -e "\n$CNT generator fstab  ......................"
genfstab -U /mnt > /mnt/etc/fstab
echo -e "\n$CAC gen fstab done ...................."
sleep 1

# mv script
mv arch-scripts /mnt/root/

# chroot /mnt
echo -e "\n$COK Has been completed. Please >>>>>>>>>>>>>>>> arch-chroot /mnt \n"
