#!/bin/sh

# 设置luci语言为中文
uci set luci.main.lang=zh_cn
uci commit luci

# 设置 系统时区
uci set system.@system[0].timezone=CST-8
uci set system.@system[0].zonename=Asia/Shanghai

# 设置日志
uci set system.@system[0].log_size=5120
uci set system.@system[0].log_file=/tmp/log/system.log
uci commit system

# 设置ddns-go为开启状态
uci set ddns-go.config.enabled=1
uci commit ddns-go

# 开启upnp
uci set upnpd.config.enabled=1
uci set upnpd.config.use_stun='1'
uci set upnpd.config.stun_host='stun.qq.com'
uci set upnpd.config.stun_port='3478'
uci commit upnpd


# 设置lan的网关和dns
# uci set network.lan.gateway='10.0.0.1'
# uci add_list network.lan.dns='10.0.0.1'
# uci commit network

# 将2-4加入br-lan 
uci add_list network.@device[0].ports='eth2'
uci add_list network.@device[0].ports='eth3'
uci add_list network.@device[0].ports='eth4'
uci commit network

# 设置wan口的pppoe拨号
uci set network.wan=interface
uci set network.wan.infname='eth1'
uci set network.wan.proto='pppoe'
uci set network.wan.username=''
uci set network.wan.password=''
uci commit network

# 设置zerotier和tailscale的接口
uci set network.zerotier_game=interface
uci set network.zerotier_game.device='zt5u4r3aek'
uci set network.zerotier_game.proto='dhcp'

uci set network.tailscale=interface
uci set network.tailscale.device='tailscale0'
uci set network.tailscale.proto='dhcp'
uci commit network

# 设置防火墙默认参数
uci set firewall.@defaults[0].input=ACCEPT
uci set firewall.@defaults[0].output=ACCEPT
uci set firewall.@defaults[0].forward=ACCEPT
uci set firewall.@defaults[0].flow_offloading=1
uci set firewall.@defaults[0].flow_offloading_hw=1
uci set firewall.@defaults[0].fullcone=1
uci set firewall.@defaults[0].fullcone6=1
uci set firewall.@defaults[0].auto_includes=1
uci commit firewall

# 设置lan口参数
uci set firewall.@zone[0].name=lan
uci set firewall.@zone[0].network='lan utun'
uci set firewall.@zone[0].input=ACCEPT
uci set firewall.@zone[0].output=ACCEPT
uci set firewall.@zone[0].forward=ACCEPT

# 设置wan口参数
uci set firewall.@zone[1].name=wan
uci set firewall.@zone[1].input=ACCEPT
uci set firewall.@zone[1].output=ACCEPT
uci set firewall.@zone[1].forward=ACCEPT
uci set firewall.@zone[1].masq='1'
uci set firewall.@zone[1].mtu_fix='1'

# 设置zerotire和tailscale
uci set firewall.@zone[2].name=vpn
uci set firewall.@zone[2].input=ACCEPT
uci set firewall.@zone[2].output=ACCEPT
uci set firewall.@zone[2].forward=ACCEPT
uci add_list firewall.@zone[2].listen_http='tailscale'
uci add_list firewall.@zone[2].listen_http='zerotier_game'
uci commit firewall

# 设置 lan 的转发
uci set firewall.@forwarding[0].src='lan'
uci set firewall.@forwarding[0].dest='wan'
uci set firewall.@forwarding[1].src='lan'
uci set firewall.@forwarding[1].dest='vpn'

uci set firewall.@forwarding[2].src='wan'
uci set firewall.@forwarding[2].dest='lan'
uci set firewall.@forwarding[3].src='wan'
uci set firewall.@forwarding[3].dest='vpn'

uci set firewall.@forwarding[4].src='vpn'
uci set firewall.@forwarding[4].dest='lan'
uci set firewall.@forwarding[5].src='vpn'
uci set firewall.@forwarding[5].dest='wan'
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
