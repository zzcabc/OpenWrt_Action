#!/bin/bash

# 设置基本变量
ARCH=$(uname -m)
TMP_DIR="/tmp"
INSTALL_DIR="/usr/sbin"
INIT_SCRIPT="/etc/init.d/tailscale"

# 根据系统架构设置下载URL中的架构名称
if [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
    ARCH="arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# 提示用户手动填写版本号
read -p "Enter the Tailscale version (press Enter to fetch the latest version from GitHub): " LATEST_VERSION

# 如果用户没有输入版本号，则从 GitHub 获取最新版本号
if [ -z "$LATEST_VERSION" ]; then
    echo "Fetching the latest version from GitHub..."
    LATEST_VERSION=$(curl -sX GET "https://api.github.com/repos/tailscale/tailscale/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]')
fi

# 检查是否成功获取版本号
if [ -z "$LATEST_VERSION" ]; then
    echo "Failed to fetch the latest version number."
    exit 1
fi

# 构建下载URL
TGZ_URL="https://pkgs.tailscale.com/stable/tailscale_${LATEST_VERSION#v}_${ARCH}.tgz"

# 下载到 /tmp 文件夹
TGZ_FILE="$TMP_DIR/tailscale_${LATEST_VERSION#v}_${ARCH}.tgz"
wget -O "$TGZ_FILE" "$TGZ_URL"

# 停止 Tailscale 服务
if [ -x "$INIT_SCRIPT" ]; then
    "$INIT_SCRIPT" stop
fi

# 解压文件
cd "$TMP_DIR"
gzip -d "$TGZ_FILE"
TAR_FILE="${TGZ_FILE%.tgz}.tar"
tar xvf "$TAR_FILE"

# 复制文件到 /usr/sbin 并设置权限
BIN_DIR="$TMP_DIR/tailscale_${LATEST_VERSION#v}_${ARCH}"
cp "$BIN_DIR/tailscale"* "$INSTALL_DIR"
chmod +x "$INSTALL_DIR/tailscale"*

# 启动 Tailscale 服务
if [ -x "$INIT_SCRIPT" ]; then
    "$INIT_SCRIPT" start
fi

# 清理临时文件
rm -rf "$BIN_DIR"
rm "$TAR_FILE"

echo "Tailscale ${LATEST_VERSION} installed successfully."
