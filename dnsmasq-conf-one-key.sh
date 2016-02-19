#/bin/sh

# Create folder if not exist.
if [ ! -d "/etc/dnsmasq.d" ]; then
    echo "Create dnsmasq.d folder"
    mkdir /etc/dnsmasq.d
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
wget --no-check-certificate -q -P /etc/dnsmasq.d https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf
echo "Downloading bogus-nxdomain.china.conf"
wget --no-check-certificate -q -P /etc/dnsmasq.d https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/bogus-nxdomain.china.conf
echo "Downloading google.china.conf"
wget --no-check-certificate -q -P /etc/dnsmasq.d https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/google.china.conf

# Restart service
echo "Restarting dnsmasq"
/etc/init.d/dnsmasq restart

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

wget --no-check-certificate -q -P /etc/dnsmasq.d https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf
wget --no-check-certificate -q -P /etc/dnsmasq.d https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/bogus-nxdomain.china.conf
wget --no-check-certificate -q -P /etc/dnsmasq.d https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/google.china.conf
SAD

chmod +x /root/dnsmasq-update.sh

echo "Add script into crontab"
cat >> /etc/crontabs/root <<EOF
0 4 * * * /root/dnsmasq-update.sh >/dev/null 2>&1
EOF

echo "Done!"
