#!/usr/bin/env bash

# 获取要编译的内核版本号
VERSION=$(grep 'Kernel Configuration' < config | awk '{print $3}')

# 添加 deb-src 到 sources.list
sed -i "/deb-src/s/# //g" /etc/apt/sources.list

# 安装依赖
apt update
apt install -y wget
apt build-dep -y linux

# 下载内核源码
wget http://www.kernel.org/pub/linux/kernel/v5.x/linux-"$VERSION".tar.xz
tar -xf linux-"$VERSION".tar.xz
cd linux-"$VERSION"

# 应用 patch
source ../patch.d/*.sh

# 编译 deb 包
make deb-pkg -j$(($(grep -c processor < /proc/cpuinfo)*2))

# 移动 deb 包到 artifact 目录
cd ..
mkdir artifact
rm ./*dbg*.deb
mv ./*.deb artifact/
