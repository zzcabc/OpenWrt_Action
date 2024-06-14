# /bin/bash
wget https://raw.githubusercontent.com/zzcabc/OpenWrt_Action/main/files/etc/config/dhcp
cp dhcp /etc/config/dhcp

wget https://raw.githubusercontent.com/zzcabc/OpenWrt_Action/main/files/etc/config/smartdns
cp smartdns /etc/config/smartdns

wget https://raw.githubusercontent.com/zzcabc/OpenWrt_Action/main/files/etc/config/system
cp system /etc/config/system

wget https://raw.githubusercontent.com/zzcabc/OpenWrt_Action/main/files/etc/config/zerotier
cp zerotier /etc/config/zerotier

wget https://raw.githubusercontent.com/zzcabc/OpenWrt_Action/main/files/etc/hotplug.d/iface/99-update-upnp
chmod +x 99-update-upnp
cp 99-update-upnp /etc/hotplug.d/iface/99-update-upnp

wget https://raw.githubusercontent.com/zzcabc/OpenWrt_Action/main/files/etc/smartdns/custom.conf
cp custom.conf /etc/smartdns/custom.conf

wget https://raw.githubusercontent.com/zzcabc/OpenWrt_Action/main/files/usr/update-upnp.sh
chmod +x update-upnp.sh
cp update-upnp.sh /usr/update-upnp.sh

wget https://raw.githubusercontent.com/zzcabc/OpenWrt_Action/main/script/tailscale
chmod +x tailscale
cp tailscale /etc/init.d/tailscale

wget https://raw.githubusercontent.com/zzcabc/OpenWrt_Action/main/script/update_tailscale.sh
chmod +x update_tailscale.sh
./update_tailscale.sh

tailscale up --accept-dns=false --accept-routes=true --advertise-routes=10.0.0.0/24 --advertise-exit-node=true
