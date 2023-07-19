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


# 设置lan的网关和dns
uci set network.lan.gateway='10.0.0.1'
uci add_list network.lan.dns='10.0.0.1'
uci commit network

# 将2-4加入br-lan 
# uci add_list network.@device[0].ports='eth2'
# uci add_list network.@device[0].ports='eth3'
# uci add_list network.@device[0].ports='eth4'
# uci commit network

# 设置wan口的pppoe拨号
# uci set network.wan=interface
# uci set network.wan.infname='eth1'
# uci set network.wan.proto='pppoe'
# uci set network.wan.username=''
# uci set network.wan.password=''
# uci commit network

# 设置zerotier和tailscale的接口
uci set network.zerotier_game=interface
uci set network.zerotier_game.device='zt5u4r3aek'
uci set network.zerotier_game.proto='dhcp'

uci set network.zerotier_work=interface
uci set network.zerotier_work.device='ztppisf3lf'
uci set network.zerotier_work.proto='dhcp'

uci set network.tailscale=interface
uci set network.tailscale.device='tailscale0'
uci set network.tailscale.proto='dhcp'
uci commit network


uci set firewall.@defaults[0].input=ACCEPT
uci set firewall.@defaults[0].output=ACCEPT
uci set firewall.@defaults[0].forward=ACCEPT
uci set firewall.@defaults[0].flow_offloading=1
uci set firewall.@defaults[0].flow_offloading_hw=1
uci set firewall.@defaults[0].fullcone=1
uci set firewall.@defaults[0].fullcone6=1
uci set firewall.@defaults[0].auto_includes=1
uci commit firewall



# cat>>/etc/config/firewall<<EOF
# config zone
# 	option name 'VPN'
# 	option input 'ACCEPT'
# 	option output 'ACCEPT'
# 	option forward 'ACCEPT'
# 	list network 'zerotier_game'
# 	list network 'zerotier_work'
# 	list network 'tailscale'

# config forwarding
# 	option src 'VPN'
# 	option dest 'lan'

# config forwarding
# 	option src 'lan'
# 	option dest 'VPN'
# EOF