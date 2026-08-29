#!/bin/bash
# Cleaned setup script
# Duplicate install links removed; all unique install links retained.

GitUser="jiwakentantal"
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'

# =========================
# IZIN SCRIPT
# =========================
MYIP=$(curl -sS ipv4.icanhazip.com)

VALIDITY () {
    today=$(date -d "0 days" +"%Y-%m-%d")
    Exp1=$(curl -fsSL "https://raw.githubusercontent.com/jiwakentantal/allow/main/ipvps.conf" | grep "$MYIP" | awk '{print $4}')
    if [[ -n "$Exp1" && "$today" < "$Exp1" ]]; then
        echo -e "\e[32mYOUR SCRIPT ACTIVE..\e[0m"
    else
        echo -e "\e[31mYOUR SCRIPT HAS EXPIRED!\e[0m"
        echo -e "\e[31mPlease renew your ipvps first\e[0m"
        exit 0
    fi
}

IZIN=$(curl -fsSL "https://raw.githubusercontent.com/jiwakentantal/allow/main/ipvps.conf" | awk '{print $5}' | grep "$MYIP")
if [ "$MYIP" = "$IZIN" ]; then
    echo -e "\e[32mPermission Accepted...\e[0m"
    VALIDITY
else
    echo -e "\e[31mPermission Denied!\e[0m"
    echo -e "\e[31mPlease buy script first\e[0m"
    rm -f setup.sh
    exit 0
fi

clear

RED="\033[31m"
export NC='\e[0m'
export DEFBOLD='\e[39;1m'
export RB='\e[31;1m'
export GB='\e[32;1m'
export YB='\e[33;1m'
export BB='\e[34;1m'
export MB='\e[35;1m'
export CB='\e[35;1m'
export WB='\e[37;1m'

if [ "${EUID}" -ne 0 ]; then
    echo "You need to run this script as root"
    exit 1
fi

if [ "$(systemd-detect-virt)" = "openvz" ]; then
    echo "OpenVZ is not supported"
    exit 1
fi

if [ -f "/usr/local/etc/xray/domain" ]; then
    echo "Script Already Installed"
    exit 0
fi

# =========================
# UPDATE & BASIC PACKAGE
# =========================
apt update -y
apt upgrade -y
apt install -y bash
apt install -y sudo wget curl nano

# =========================
# REQUIRED PACKAGE
# =========================
apt install -y zip unzip htop cron socat screen netfilter-persistent vnstat fail2ban
apt-get --reinstall --fix-missing install -y bzip2 gzip coreutils wget rsyslog iftop net-tools sed gnupg gnupg1 bc apt-transport-https build-essential dirmngr libxml-parser-perl neofetch git lsof
apt-get remove --purge ufw firewalld -y
apt-get remove --purge exim4 -y
apt install iptables iptables-persistent -y
apt install curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release -y
apt install socat cron bash-completion ntpdate -y
ntpdate pool.ntp.org
apt -y install chrony
timedatectl set-ntp true
systemctl enable chronyd && systemctl restart chronyd
systemctl enable chrony && systemctl restart chrony
timedatectl set-timezone Asia/Kuala_Lumpur
chronyc sourcestats -v
chronyc tracking -v
date
clear

# =========================
# RESOLVCONF
# =========================
echo -e "\e[0;32mINSTALLING RESOLVCONF...\e[0m"
sleep 1
apt install -y resolvconf
systemctl start resolvconf.service
systemctl enable resolvconf.service
echo 'nameserver 8.8.8.8' > /etc/resolvconf/resolv.conf.d/head
echo 'nameserver 8.8.8.8' > /etc/resolv.conf
systemctl restart resolvconf.service
echo -e "\e[0;32mDONE INSTALLING RESOLVCONF\e[0m"
clear

mkdir -p /var/log/xray
chmod 755 /var/log/xray

mkdir -p /usr/local/etc/xray
touch /usr/local/etc/xray/warp-domain.txt

# =========================
# XRAY CORE
# =========================
curl -fL "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/xraycore/v26.2.6.1/xray.linux.zip" -o /tmp/xray.linux.zip
unzip -o /tmp/xray.linux.zip -d /tmp/xray-core
mv /tmp/xray-core/xray /usr/local/bin/xray
chmod +x /usr/local/bin/xray
rm -rf /tmp/xray.linux.zip /tmp/xray-core

# =========================
# SERVER INFO
# =========================
# Ambil IP awam server
curl -4 -fsS --max-time 5 https://ipinfo.io/ip > /usr/local/etc/xray/IPVPS

# Ambil Bandar
curl -fsS --max-time 5 https://ipinfo.io/city > /usr/local/etc/xray/city

# Ambil Pembekal Rangkaian
curl -fsS --max-time 5 https://ipinfo.io/org | cut -d " " -f 2- > /usr/local/etc/xray/org

# Ambil Zon Masa
curl -fsS --max-time 5 https://ipinfo.io/timezone > /usr/local/etc/xray/timezone

# =========================
# SPEEDTEST
# =========================
curl -fsSL "https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh" | bash
apt-get install -y speedtest

# =========================
# TIMEZONE
# =========================
ln -fs /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime

# =========================
# SSH BANNER
# =========================
wget -q -O /etc/issue.net "https://raw.githubusercontent.com/vinstechmy/VlessWebsocket/main/OTHERS/issues.net"
chmod +x /etc/issue.net
grep -q '^Banner /etc/issue.net$' /etc/ssh/sshd_config || echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config

# =========================
# NGINX
# =========================
apt install -y nginx
rm -f /var/www/html/*.html
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-available/default
systemctl restart nginx

mkdir -p /var/lib/premium-script

echo -e "\e[1;32m════════════════════════════════════════════════════════════\e[0m"
echo ""
echo -e "   \e[1;32mPlease enter the name of Provider for Script.\e[0m"
read -p "   Name : " nm
echo "$nm" > /root/provided
echo ""

touch /usr/local/etc/xray/domain
echo -e "\e[1;32m════════════════════════════════════════════════════════════\e[0m"
echo ""
echo -e "   .----------------------------------."
echo -e "   |\e[1;32mPlease select a domain type below \e[0m|"
echo -e "   '----------------------------------'"
echo ""
read -rp "Insert Domain : " -e dns

if [ -z "$dns" ]; then
    echo -e "\e[31mPlease Insert Domain!\e[0m"
    exit 1
else
    echo "$dns" > /usr/local/etc/xray/domain
    echo "DNS=$dns" > /var/lib/premium-script/ipvps.conf
fi

clear

# =========================
# XRAY CERTIFICATE
# =========================
systemctl stop nginx
domain=$(cat /usr/local/etc/xray/domain)

mkdir -p /root/.acme.sh
curl -fsSL "https://acme-install.netlify.app/acme.sh" -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d "$domain" --standalone -k ec-256
/root/.acme.sh/acme.sh --installcert -d "$domain" \
    --fullchainpath /usr/local/etc/xray/xray.crt \
    --keypath /usr/local/etc/xray/xray.key \
    --ecc

mkdir -p /home/vps/public_html
chown -R www-data:www-data /home/vps/public_html

uuid=$(cat /proc/sys/kernel/random/uuid)

# =========================
# VLESS WS TLS
# =========================
cat > /usr/local/etc/xray/config.json << END
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "level": 0,
            "email": ""
#xray-vless-tls
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vlessws-tls"
        },
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/usr/local/etc/xray/xray.crt",
              "keyFile": "/usr/local/etc/xray/xray.key"
            }
          ]
        }
      }
     }
  ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
		]
}
END

# =========================
# VLESS WS NONE-TLS / HTTPUPGRADE / XHTTP
# =========================
cat > /usr/local/etc/xray/none.json << END
  {
  "log": {
    "loglevel": "warning",
    "error": "/var/log/xray/error.log",
    "access": "/var/log/xray/access.log"
      },
      "inbounds": [
      {
      "listen": "127.0.0.1",
      "port": 10000,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
      },
      {
      "port": "80,8880",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "level": 0,
            "email": "user"
          }
        ],
        "decryption": "none",
        "fallbacks": [
          {
            "path": "/ssh",
            "dest": 10015,
            "xver": 2
          },
          {
            "path": "/vmess",
            "dest": "@vmess-ws",
            "xver": 2
          },
          {
            "path": "/vless",
            "dest": "@vless-ws",
            "xver": 2
          },
          {
            "dest": "1212"
          },
          {
            "path": "/trojan-ws",
            "dest": "@trojan-ws",
            "xver": 2
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
          "security": "none"
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls", "quic"]
      }
    },
    {
      "tag": "vmess-ws",
      "listen": "@vmess-ws",
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "level": 0,
            "email": ""
#vmess
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/vmess"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls",
          "quic"
        ]
      }
    },
    {
      "tag": "vless-ws",
      "listen": "@vless-ws",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "level": 0,
            "email": ""
#xray-vless-nontls
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/vless"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls",
          "quic"
        ]
      }
    },
    {
      "tag": "trojan-ws",
      "listen": "@trojan-ws",
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "9f8806d8-27e4-42bb-83b2-b01ac48e9839",
            "email": ""
#trojanws
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/trojan-ws"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls",
          "quic"
        ]
      }
    },
    {
      "protocol": "vless",
      "port": 1212,
      "settings": {
        "clients": [
          {
             "id": "${uuid}",
             "level": 0
#xray-vless-xhttp
          }
       ],
       "decryption": "none"
    },
    "streamSettings": {
    "network": "xhttp",
    "security": "none",
    "xhttpSettings": {
     "mode": "auto",
     "path": "/xhttp"
        }
    },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls",
          "quic"
        ]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct"
    },
    {
      "protocol": "blackhole",
      "tag": "blocked"
    }
  ],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "inboundTag": [
          "api"
        ],
        "outboundTag": "api",
        "type": "field"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
## default
        "domain": ["bittorrent","playstation.com","playstation.net"]
      },
     {
     "type": "field",
      "outboundTag": "blocked",
      "protocol": [
             "vmess",
             "vless",
             "trojan"
         ]
      },
      {
        "type": "field",
        "outboundTag": "direct",
        "network": "tcp,udp"
      }
    ]
  },
  "stats": {},
  "api": {
    "services": [
      "StatsService"
    ],
    "tag": "api"
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink" : true,
      "statsOutboundDownlink" : true
      }
   }
}
END

# =========================
# XRAY SYSTEMD SERVICES
# =========================
rm -rf /etc/systemd/system/xray.service.d
rm -rf /etc/systemd/system/xray@.service.d

cat> /etc/systemd/system/xray.service << END
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /usr/local/etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target

END

# starting xray vmess ws tls core on sytem startup
cat> /etc/systemd/system/xray@.service << END
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /usr/local/etc/xray/%i.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target

END

iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8880 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 80 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8080 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8880 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

# =========================
# NGINX CONFIG
# =========================
cat > /etc/nginx/nginx.conf << EOF
user www-data;
worker_processes auto;
worker_rlimit_nofile 65536;  # Meningkatkan batas file deskriptor
pid /var/run/nginx.pid;

events {
    multi_accept on;
    worker_connections 2048;  # Meningkatkan jumlah koneksi worker
}
http {
	gzip on;
	gzip_vary on;
	gzip_comp_level 5;
	gzip_types text/plain application/x-javascript text/xml text/css;
	autoindex on;
	tcp_nopush on;
	tcp_nodelay on;
	keepalive_timeout 65;
	types_hash_max_size 2048;
	server_tokens off;
	include /etc/nginx/mime.types;
	default_type application/octet-stream;
	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;
	client_max_body_size 32M;
	client_header_buffer_size 8m;
	large_client_header_buffers 8 8m;
	fastcgi_buffer_size 8m;
	fastcgi_buffers 8 8m;
	fastcgi_read_timeout 600;
	#CloudFlare IPv4
	set_real_ip_from 199.27.128.0/21;
	set_real_ip_from 173.245.48.0/20;
	set_real_ip_from 103.21.244.0/22;
	set_real_ip_from 103.22.200.0/22;
	set_real_ip_from 103.31.4.0/22;
	set_real_ip_from 141.101.64.0/18;
	set_real_ip_from 108.162.192.0/18;
	set_real_ip_from 190.93.240.0/20;
	set_real_ip_from 188.114.96.0/20;
	set_real_ip_from 197.234.240.0/22;
	set_real_ip_from 198.41.128.0/17;
	set_real_ip_from 162.158.0.0/15;
	set_real_ip_from 104.16.0.0/12;
	#Incapsula
	set_real_ip_from 199.83.128.0/21;
	set_real_ip_from 198.143.32.0/19;
	set_real_ip_from 149.126.72.0/21;
	set_real_ip_from 103.28.248.0/22;
	set_real_ip_from 45.64.64.0/22;
	set_real_ip_from 185.11.124.0/22;
	set_real_ip_from 192.230.64.0/18;
	real_ip_header CF-Connecting-IP;
	include /etc/nginx/conf.d/*.conf;
}
EOF

# =========================
# XRAY CONFIG
# =========================
cat > /etc/nginx/conf.d/vps.conf << 'EOF'
server {
    listen 81 ssl http2 reuseport;
    listen [::]:81 ssl http2 reuseport;

    ssl_certificate /usr/local/etc/xray/xray.crt;
    ssl_certificate_key /usr/local/etc/xray/xray.key;
    ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
    ssl_protocols TLSv1.2 TLSv1.3;
    root /var/www/html;
}

server {
    listen 8080;
    listen [::]:8080;

    listen 8443 ssl http2 reuseport;
    listen [::]:8443 ssl http2 reuseport;

    server_name $domain;

    ssl_certificate /usr/local/etc/xray/xray.crt;
    ssl_certificate_key /usr/local/etc/xray/xray.key;
    ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
    ssl_protocols TLSv1.2 TLSv1.3;

    access_log /dev/null;
    error_log /dev/null;

    location / {
        if ($http_upgrade != "Upgrade") {
            rewrite /(.*) /ssh break;
        }
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10015;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

# =========================
# START SERVICES
# =========================
systemctl daemon-reload
systemctl enable xray.service
systemctl start xray.service
systemctl restart xray.service

systemctl enable xray@none.service
systemctl start xray@none.service
systemctl restart xray@none.service

systemctl restart nginx

# =========================
# LIGHT CPU/RAM NETWORK TUNING
# =========================
cat >> /etc/sysctl.conf <<'EOF'
vm.swappiness=10
net.core.somaxconn=4096
net.core.netdev_max_backlog=4096
net.ipv4.tcp_max_syn_backlog=4096
net.ipv4.tcp_fin_timeout=30
net.ipv4.tcp_tw_reuse=1
EOF
sysctl -p

# =========================
# BBR
# =========================
cat >> /etc/sysctl.conf <<'EOF'
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768
net.ipv4.ip_forward = 1
EOF
sysctl -p

# =========================
# GEOIP / GEOSITE
# =========================
cd /usr/local/bin
rm -f geoip.dat geosite.dat
wget -q "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/202602030418/geoip.dat"
wget -q "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/202602030418/geosite.dat"
chmod 755 geoip.dat geosite.dat
cd

# =========================
# RC.LOCAL + DISABLE IPV6
# =========================
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

# nano /etc/rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
END

# Ubah izin akses
chmod +x /etc/rc.local

# enable rc local
systemctl enable rc-local
systemctl start rc-local.service

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# =========================
# XRAY MENU / TOOLS
# =========================
cd /usr/bin

wget -O autobackup "https://raw.githubusercontent.com/huaweipadu/script-lite/main/system/backupBot.sh"
wget -O port-xray "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/change-port/port-xray.sh"
wget -O certv2ray "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/cert.sh"
wget -O xraay "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/menu/xraay.sh"
wget -O add-xray "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/add-user/add-xray.sh"
wget -O del-xray "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/delete-user/del-xray.sh"
wget -O renew-xray "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/renew-user/renew-xray.sh"
wget -O cek-xray "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/cek-user/cek-xray.sh"
wget -O add-vless "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/add-user/add-vless.sh"
wget -O trial-vless "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/add-user/trial-vless.sh"
wget -O del-vless "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/delete-user/del-vless.sh"
wget -O renew-vless "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/renew-user/renew-vless.sh"
wget -O show-vless "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/add-user/show-vless.sh"
wget -O cek-vless "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/cek-user/cek-vless.sh"
wget -O add-host "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/system/add-host.sh"
wget -O menu "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/menu.sh"
wget -O restart "https://raw.githubusercontent.com/huaweipadu/vlessonly/main/restart.sh"
wget -O info "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/system/info.sh"
wget -O ram "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/system/ram.sh"
wget -O renew-ssh "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/renew-user/renew-ssh.sh"
wget -O clear-log "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/clear-log.sh"
wget -O change-port "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/change.sh"
wget -O xp "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/xp.sh"
wget -O swap "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/swapkvm.sh"
wget -O check-sc "https://raw.githubusercontent.com/basikal123/moto/main/running.sh"
wget -O autoreboot "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/system/autoreboot.sh"
wget -O bbr "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/system/bbr.sh"
wget -O panel-domain "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/menu/panel-domain.sh"
wget -O system "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/menu/system.sh"
wget -O limit-speed "https://raw.githubusercontent.com/jiwakentantal/caliburn/main/limit-speed.sh"

chmod +x /usr/bin/autobackup /usr/bin/port-xray /usr/bin/certv2ray /usr/bin/xraay
chmod +x /usr/bin/add-xray /usr/bin/del-xray /usr/bin/renew-xray /usr/bin/cek-xray
chmod +x /usr/bin/add-vless /usr/bin/trial-vless /usr/bin/del-vless /usr/bin/renew-vless
chmod +x /usr/bin/show-vless /usr/bin/cek-vless /usr/bin/add-host /usr/bin/menu
chmod +x /usr/bin/restart /usr/bin/info /usr/bin/ram /usr/bin/renew-ssh /usr/bin/clear-log
chmod +x /usr/bin/change-port /usr/bin/xp /usr/bin/swap /usr/bin/check-sc
chmod +x /usr/bin/autoreboot /usr/bin/bbr /usr/bin/panel-domain /usr/bin/system /usr/bin/limit-speed

# =========================
# GOTOP
# =========================
curl -fsSL "https://raw.githubusercontent.com/xxxserxxx/gotop/master/scripts/download.sh" | bash
if [ -f gotop ]; then
    chmod +x gotop
    mv gotop /usr/local/bin/gotop
fi

echo -e "[ ${GB}INFO${NC} ] Autoscript Files Successfully Download !"
sleep 2
# =========================
# AUTO MENU ON SSH LOGIN
# =========================
if ! grep -q 'AUTO MENU WHEN LOGIN' /root/.bashrc 2>/dev/null; then
cat >> /root/.bashrc <<'EOF'

# AUTO MENU WHEN LOGIN
if [[ $- == *i* ]] && command -v menu >/dev/null 2>&1; then
    clear
    menu
fi
EOF
fi

# =========================
# CRON
# =========================
grep -qF 'root /usr/bin/clear-log' /etc/crontab || echo "*/2 * * * * root /usr/bin/clear-log" >> /etc/crontab
grep -qF 'root reboot' /etc/crontab || echo "0 5 * * * root reboot" >> /etc/crontab
grep -qF 'root /usr/bin/xp' /etc/crontab || echo "0 0 * * * root /usr/bin/xp" >> /etc/crontab

systemctl restart cron
systemctl restart sshd

# =========================
# CLEANUP
# =========================
cd
apt autoclean -y
apt -y remove --purge unscd
apt-get -y --purge remove 'samba*'
apt-get -y --purge remove 'apache2*'
apt-get -y --purge remove 'bind9*'
apt-get -y remove 'sendmail*'
apt autoremove -y

echo "1.0" > /home/ver

# =========================
# INSTALLATION COMPLETE
# =========================
clear
echo ""
echo "=============================================="
echo "      SUCCESSFULLY INSTALLED THE SCRIPT"
echo "=============================================="
echo ""
echo "Xray VLESS WS TLS       : 443"
echo "Xray VLESS WS None TLS  : 80"
echo "IPv6                    : OFF"
echo "Timezone                : Asia/Kuala_Lumpur"
echo ""
echo "Installation log        : /root/log-install.txt"
echo ""

cat > /root/log-install.txt <<EOF
=========================[SCRIPT PREMIUM]========================
Service & Port
Xray Vless Ws Tls       : 443
Xray Vless Ws None Tls  : 80
Timezone                : Asia/Kuala_Lumpur (GMT +8)
IPv6                    : OFF
Autoreboot               : 05:00 GMT +8
===============================================================
EOF

rm -f setup.sh
sleep 5
reboot
