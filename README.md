# dnsmasq-china-list-openwrt

一键配置 Openwrt 设备上的 China List

测试环境
====

Server: Ubuntu 14.04 64bit

Router:

1. 360 Router C301 Openwrt 15.05
2. Mirouter R2D 2.11.39 开发版

How to
====

##＃ 获得一个可信的上游 DNS 服务器

```
$ curl -k https://raw.githubusercontent.com/ITJesse/dnsmasq-china-list-openwrt/master/dns-server-one-key.sh|sh
```

你将获得一个开放了 53 及 5353 端口的可信上游 DNS 服务器

##＃ 获得一个可信的本地 DNS 服务器

Openwet
```
$ curl -k https://raw.githubusercontent.com/ITJesse/dnsmasq-china-list-openwrt/master/dnsmasq-conf-one-key.sh|sh
```

小米路由器
```
$ curl -k https://raw.githubusercontent.com/ITJesse/dnsmasq-china-list-openwrt/master/dnsmasq-conf-one-key-mirouter.sh|sh
```

将路由器的 DNS 转发设置为可信的 DNS 服务器。
