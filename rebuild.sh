#!/bin/bash
CONFIG_FILE="immortalwrt/rockchip/defconfig"

sudo sysctl vm.swappiness=0
ulimit -SHn 65000

#Load config
[ -e "$CONFIG_FILE" ] && cat "$CONFIG_FILE" > openwrt/.config

#Download the installation package
cd openwrt
make defconfig
#make download -j$(nproc) V=s
#find dl -size -1024c -exec ls -l {} \;
#find dl -size -1024c -exec rm -f {} \;

#Compile the firmware
echo -e "$(nproc) thread compile"
#make -j$(nproc) || make -j1 || make -j1 V=s
make -j$(nproc) V=s

#Organize and Rename Files
cd bin/targets/rockchip/armv8
ls -l *.img.gz