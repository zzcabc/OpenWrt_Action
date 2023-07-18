#!/bin/sh

# 设置luci语言为中文
uci set luci.main.lang=zh_cn
uci commit luci

# 设置 系统时区
uci set system.@system[0].timezone=CST-8
uci set system.@system[0].zonename=Asia/Shanghai

# 设置日志
uci set system.@system[0].log_size=5120
uci set system.@system[0].log_file=/var/log/system.log
uci commit system

# 设置ddns-go为开启状态
uci set ddns-go.config.enabled=1
uci commit ddns-go

# 开启upnp
uci set upnpd.config.enabled=1
uci commit upnpd

# 将2-4加入br-lan 
uci add_list network.@device[0].ports=eth2
uci add_list network.@device[0].ports=eth3
uci add_list network.@device[0].ports=eth4
uci commit network

# 设置wan口的pppoe拨号
uci set network.wan=interface
uci set network.wan.infname=eth1
uci set network.wan.proto=pppoe
uci set network.wan.username=''
uci set network.wan.password=''
uci commit network