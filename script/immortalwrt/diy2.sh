#!/bin/bash

# 更新luci-app-openclash
# rm -rf feeds/luci/applications/luci-app-openclash
# git clone --depth=1 https://github.com/vernesong/OpenClash.git feeds/luci/applications/luci-app-openclash

# 将192.168.1.1改为10.0.0.1
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# 预置openclash内核
mkdir -p files/etc/openclash/core

# openclash 的 dev内核
CLASH_DEV_URL="https://github.com/vernesong/OpenClash/raw/core/master/dev/clash-linux-amd64.tar.gz"
# openclash 的 TUN内核
CLASH_TUN_VERSION=$(curl -sL https://github.com/vernesong/OpenClash/raw/core/master/core_version | head -n 2 | tail -n 1)
CLASH_TUN_URL="https://github.com/vernesong/OpenClash/raw/core/master/premium/clash-linux-amd64-$CLASH_TUN_VERSION.gz"
# openclash 的 Meta内核版本
# CLASH_META_URL="https://github.com/vernesong/OpenClash/raw/core/master/meta/clash-linux-amd64.tar.gz"

# d大的普核
# CLASH_DEV_URL=$(curl -sL https://api.github.com/repos/Dreamacro/clash/releases/latest | grep /clash-linux-amd64 | awk -F '"' '{print $4}' | head -n 1)
# d大的premium核
# CLASH_TUN_URL=$(curl -sL https://api.github.com/repos/Dreamacro/clash/releases/tags/premium | grep /clash-linux-amd64 | awk -F '"' '{print $4}' | head -n 1)
# meta核
CLASH_META_URL=$(curl -sL https://api.github.com/repos/MetaCubeX/mihomo/releases/tags/Prerelease-Alpha | grep /mihomo-linux-amd64-compatible-alpha | awk -F '"' '{print $4}' | head -n 1)
# 下载clash内核
# openclash 的 内核解压
wget -qO- $CLASH_DEV_URL | tar xOvz > files/etc/openclash/core/clash
wget -qO- $CLASH_TUN_URL | gunzip -c > files/etc/openclash/core/clash_tun
# wget -qO- $CLASH_META_URL | tar xOvz > files/etc/openclash/core/clash_meta

# wget -qO- $CLASH_DEV_URL | gunzip -c > files/etc/openclash/core/clash
# wget -qO- $CLASH_TUN_URL | gunzip -c > files/etc/openclash/core/clash_tun
wget -qO- $CLASH_META_URL | gunzip -c > files/etc/openclash/core/clash_meta
# 给内核权限
chmod +x files/etc/openclash/core/clash*

# Country.mmdb
COUNTRY_LITE_URL=https://raw.githubusercontent.com/alecthw/mmdb_china_ip_list/release/lite/Country.mmdb
# COUNTRY_FULL_URL=https://raw.githubusercontent.com/alecthw/mmdb_china_ip_list/release/Country.mmdb
wget -qO- $COUNTRY_LITE_URL > files/etc/openclash/Country.mmdb
# wget -qO- $COUNTRY_FULL_URL > files/etc/openclash/Country.mmdb

# meta可能要GeoIP.dat 和 GeoSite.dat
GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
wget -qO- $GEOIP_URL > files/etc/openclash/GeoIP.dat
wget -qO- $GEOSITE_URL > files/etc/openclash/GeoSite.dat

# 设置更新upnp的脚本
wget https://github.com/zzcabc/OpenWrt_Action/blob/main/script/update-upnp.sh > files/usr/update-upnp.sh
wget https://github.com/zzcabc/OpenWrt_Action/blob/main/script/99-custom files/etc/hotplug.d/iface/99-custom
chmod +x files/etc/hotplug.d/iface/99-custom
chmod +x files/usr/update-upnp.sh
