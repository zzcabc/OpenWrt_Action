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
    if command -v jq > /dev/null; then
        LATEST_VERSION=$(curl -sS "https://api.github.com/repos/tailscale/tailscale/releases/latest" | jq -r '.tag_name')
    else
        LATEST_VERSION=$(curl -sS "https://api.github.com/repos/tailscale/tailscale/releases/latest" | awk -F '"' '/tag_name/{print $4;exit}')
    fi
fi

# 检查是否成功获取版本号
if [ -z "$LATEST_VERSION" ]; then
    echo "Failed to fetch the latest version number."
    exit 1
fi

# 构建下载URL
TGZ_URL="https://pkgs.tailscale.com/stable/tailscale_${LATEST_VERSION#v}_${ARCH}.tgz"
TGZ_FILE="$TMP_DIR/tailscale_${LATEST_VERSION#v}_${ARCH}.tgz"

# 下载到 /tmp 文件夹
wget -O "$TGZ_FILE" "$TGZ_URL"
if [ $? -ne 0 ]; then
    echo "Error: Failed to download Tailscale archive."
    exit 1
fi

# 停止 Tailscale 服务
if [ -x "$INIT_SCRIPT" ]; then
    "$INIT_SCRIPT" stop
fi

# 解压文件
tar -xzf "$TGZ_FILE" -C "$TMP_DIR"
BIN_DIR="$TMP_DIR/tailscale_${LATEST_VERSION#v}_${ARCH}"

# 检查二进制文件是否存在
if [ ! -f "$BIN_DIR/tailscale" ]; then
    echo "Error: Tailscale binary not found in $BIN_DIR."
    exit 1
fi

# 复制文件到 /usr/sbin 并设置权限
cp "$BIN_DIR/tailscale"* "$INSTALL_DIR"
chmod +x "$INSTALL_DIR/tailscale"*

# 启动或下载 Tailscale 服务脚本
if [ -x "$INIT_SCRIPT" ]; then
    # 如果脚本存在且可执行，直接启动服务
    echo "Starting Tailscale service..."
    "$INIT_SCRIPT" start
else
    # 如果脚本不存在，下载并设置
    echo "Tailscale service script not found. Downloading..."
    wget -O "$INIT_SCRIPT" "https://raw.githubusercontent.com/zzcabc/OpenWrt_Action/main/script/tailscale"
    
    # 检查下载是否成功
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download Tailscale service script."
        exit 1
    fi
    
    # 设置执行权限
    chmod +x "$INIT_SCRIPT"
    echo "Tailscale service script downloaded and permissions set."

    # 将服务脚本设置为开机自启动
    echo "Enabling Tailscale service..."
    "$INIT_SCRIPT" enable

    # 启动 Tailscale 服务
    echo "Starting Tailscale service..."
    "$INIT_SCRIPT" start
fi


# 清理临时文件
if [[ "$BIN_DIR" == /tmp/tailscale* ]]; then
    rm -rf "$BIN_DIR"
fi
rm -f "$TGZ_FILE"

echo "Tailscale ${LATEST_VERSION} installed successfully."
