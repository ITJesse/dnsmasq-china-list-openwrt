#/bin/sh

# Create folder if not exist
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
wget -q -P /etc/dnsmasq.d http://dns.xu1s.com/dnsmasq-china-list/accelerated-domains.china.conf
echo "Downloading bogus-nxdomain.china.conf"
wget -q -P /etc/dnsmasq.d http://dns.xu1s.com/dnsmasq-china-list/bogus-nxdomain.china.conf
echo "Downloading google.china.conf"
wget -q -P /etc/dnsmasq.d http://dns.xu1s.com/dnsmasq-china-list/google.china.conf

echo "Fucking mirouter"
echo "#Fuck Mirouter" >/etc/dnsmasq.d/rr_404.conf
echo "#Fuck Mirouter" >/etc/dnsmasq.d/rr_tb.conf
echo "#Fuck Mirouter" >/etc/dnsmasq.d/rr_gfw.conf

# Restart service
echo "Restarting dnsmasq"
/etc/init.d/dnsmasq restart

# Edit crontab
echo "Creating auto update script"
cat > /data/userdisk/dnsmasq-update.sh <<SAD
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
echo "#Fuck Mirouter" >/etc/dnsmasq.d/rr_404.conf
echo "#Fuck Mirouter" >/etc/dnsmasq.d/rr_tb.conf
echo "#Fuck Mirouter" >/etc/dnsmasq.d/rr_gfw.conf

/etc/init.d/dnsmasq restart
SAD

chmod +x /data/userdisk/dnsmasq-update.sh

echo "Add script into crontab"
cat >> /etc/crontabs/root <<EOF
30 * * * * /data/userdisk/dnsmasq-update.sh & >/dev/null
EOF

echo "Done!"
