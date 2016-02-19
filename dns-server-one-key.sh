#/bin/sh

if [ "$(whoami)" != "root" ]; then
	echo "Please run this script with root."
	exit 1
fi

# Specify DNS server
echo "nameserver 114.114.114.114" >/etc/resolv.conf

# Specify source mirror
cat >/etc/apt/sources.list <<EOF
deb http://mirrors.ustc.edu.cn/ubuntu/ trusty main restricted universe multiverse
deb http://mirrors.ustc.edu.cn/ubuntu/ trusty-security main restricted universe multiverse
deb http://mirrors.ustc.edu.cn/ubuntu/ trusty-updates main restricted universe multiverse
deb http://mirrors.ustc.edu.cn/ubuntu/ trusty-proposed main restricted universe multiverse
deb http://mirrors.ustc.edu.cn/ubuntu/ trusty-backports main restricted universe multiverse
deb-src http://mirrors.ustc.edu.cn/ubuntu/ trusty main restricted universe multiverse
deb-src http://mirrors.ustc.edu.cn/ubuntu/ trusty-security main restricted universe multiverse
deb-src http://mirrors.ustc.edu.cn/ubuntu/ trusty-updates main restricted universe multiverse
deb-src http://mirrors.ustc.edu.cn/ubuntu/ trusty-proposed main restricted universe multiverse
deb-src http://mirrors.ustc.edu.cn/ubuntu/ trusty-backports main restricted universe multiverse
EOF

# Remove old packages and configs
apt-get -y remove dnscrypt-proxy dnsmasq pdnsd --purge

# Install necessary packages
apt-get update
apt-get -y upgrade
apt-get install -y software-properties-common
add-apt-repository -y ppa:xuzhen666/dnscrypt
apt-get update
apt-get -y install dnscrypt-proxy dnsmasq pdnsd wget curl
service dnscrypt-proxy stop
service dnsmasq stop
service pdnsd stop

# Configure
sed -i "s/127.0.2.1:53/127.0.0.1:5301/" /etc/default/dnscrypt-proxy
sed -i "s/no/yes/" /etc/default/pdnsd

cat >/etc/dnsmasq.conf <<EOF
listen-address=0.0.0.0
bind-interfaces
no-resolv
no-poll
server=127.0.0.1#5301
no-dhcp-interface=eth0
no-dhcp-interface=eth1
cache-size=81920
conf-dir=/etc/dnsmasq.d
EOF

cat >/etc/pdnsd.conf <<EOF
global {
	perm_cache=2048;
	cache_dir="/var/cache/pdnsd";
	run_as="pdnsd";
	server_port = 5353;
	server_ip = 0.0.0.0;
	status_ctl = on;
  	paranoid=on;
	query_method=udp_tcp;
	min_ttl=15m;
	max_ttl=1w;
	timeout=10;
}
server {
        label= "myisp";
        ip =    127.0.0.1;
        root_server = on;
}
rr {
	name=localhost;
	reverse=on;
	a=127.0.0.1;
	owner=localhost;
	soa=localhost,root.localhost,42,86400,900,86400,86400;
}
EOF

# Create folder if not exist
if [ ! -d "/etc/dnsmasq.d" ]; then
    echo "Create dnsmasq.d folder"
    mkdir -p /etc/dnsmasq.d
fi

# Do some clean
if [ -f "/etc/dnsmasq.d/accelerated-domains.china.conf" ]; then
    echo "Clean accelerated-domains.china.conf"
    rm /etc/dnsmasq.d/accelerated-domains.china.conf
fi
if [ -f "/etc/dnsmasq.d/bogus-nxdomain.china.conf" ]; then
    echo "Clean bogus-nxdomain.china.conf"
    rm /etc/dnsmasq.d/bogus-nxdomain.china.conf
fi
if [ -f "/etc/dnsmasq.d/google.china.conf" ]; then
    echo "Clean google.china.conf"
    rm /etc/dnsmasq.d/google.china.conf
fi

# Download the list files
echo "Downloading accelerated-domains.china.conf"
wget -q -P /etc/dnsmasq.d http://dns.xu1s.com/dnsmasq-china-list/accelerated-domains.china.conf
echo "Downloading bogus-nxdomain.china.conf"
wget -q -P /etc/dnsmasq.d http://dns.xu1s.com/dnsmasq-china-list/bogus-nxdomain.china.conf
echo "Downloading google.china.conf"
wget -q -P /etc/dnsmasq.d http://dns.xu1s.com/dnsmasq-china-list/google.china.conf

# Edit crontab
echo "Creating auto update script"
cat > /root/dnsmasq-update.sh <<SAD
#/bin/sh
if [ ! -d "/etc/dnsmasq.d" ]; then
    mkdir /etc/dnsmasq.d
fi
if [ -f "/etc/dnsmasq.d/accelerated-domains.china.conf" ]; then
    rm /etc/dnsmasq.d/accelerated-domains.china.conf
fi
if [ -f "/etc/dnsmasq.d/bogus-nxdomain.china.conf" ]; then
    rm /etc/dnsmasq.d/bogus-nxdomain.china.conf
fi
if [ -f "/etc/dnsmasq.d/google.china.conf" ]; then
    rm /etc/dnsmasq.d/google.china.conf
fi

wget -q -P /etc/dnsmasq.d http://dns.xu1s.com/dnsmasq-china-list/accelerated-domains.china.conf
wget -q -P /etc/dnsmasq.d http://dns.xu1s.com/dnsmasq-china-list/bogus-nxdomain.china.conf
wget -q -P /etc/dnsmasq.d http://dns.xu1s.com/dnsmasq-china-list/google.china.conf

/etc/init.d/dnsmasq restart
SAD

chmod +x /root/dnsmasq-update.sh

echo "Add script into crontab"
crontab -l > tmpcron
echo "30 * * * * /root/dnsmasq-update.sh & >/dev/null" >> tmpcron
crontab tmpcron
rm tmpcron

# Start service
/etc/init.d/dnscrypt-proxy start
/etc/init.d/dnsmasq start
/etc/init.d/pdnsd start

echo "Done!"
