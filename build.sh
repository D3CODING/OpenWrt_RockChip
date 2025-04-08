#!/bin/bash

#Set ENV
REPO_URL="https://github.com/immortalwrt/immortalwrt"
REPO_BRANCH="openwrt-24.10"
CONFIG_FILE="immortalwrt/rockchip/defconfig"
DIY_P1_SH="immortalwrt/diy-part1.sh"
DIY_P2_SH="immortalwrt/diy-part2.sh"
TZ="Asia/Shanghai"
OPENWRT_NAME="immortalwrt"
GITHUB_WORKSPACE=$PWD

sudo timedatectl set-timezone "$TZ"
sudo sysctl vm.swappiness=0
ulimit -SHn 65000

#Initialize the compilation environment
sudo apt -y update
sudo apt -y --no-install-recommends install aria2 ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential bzip2 ccache clang cmake cpio curl device-tree-compiler ecj fastjar flex g++ g++-multilib gawk gettext gcc-multilib git libgnutls28-dev gperf haveged help2man intltool jq lib32gcc-s1 libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5 libncursesw5-dev libpython3-dev libreadline-dev libssl-dev libtool lld llvm lrzsz genisoimage nano ninja-build p7zip p7zip-full patch pkgconf pv python2.7 python3 python3-distutils python3-docutils python3-pip python3-ply python3-pyelftools qemu-utils re2c rename rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev

#Initialize Environment and Display System Info
chmod +x $OPENWRT_NAME/*.sh
$GITHUB_WORKSPACE/$OPENWRT_NAME/system-Information.sh

#Download firmware source code
git clone --depth 1 $REPO_URL -b $REPO_BRANCH openwrt
cd openwrt

#Update & install feeds
./scripts/feeds update -a
./scripts/feeds install -a

#Load feeds.conf.default
$GITHUB_WORKSPACE/$DIY_P1_SH

#Load config
cd $GITHUB_WORKSPACE
[ -e "$CONFIG_FILE" ] && cat "$CONFIG_FILE" > openwrt/.config
cd openwrt
$GITHUB_WORKSPACE/$DIY_P2_SH

#Download the installation package
make defconfig
make download -j$(nproc) V=s
find dl -size -1024c -exec ls -l {} \;
find dl -size -1024c -exec rm -f {} \;

#Compile the firmware
echo -e "$(nproc) thread compile"
#make -j$(nproc) || make -j1 || make -j1 V=s
make -j$(nproc) V=s

cd bin/targets/rockchip/armv8
ls -l *.img.gz