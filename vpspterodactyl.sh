RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

CLOUDFLARE_ZONES='{"pterodactyl-panel.web.id":{"zone":"d69feb7345d9e4dd5cfd7cce29e7d5b0","token":"32zZwadzwc7qB4mzuDBJkk1xFyoQ2Grr27mAfJcB"},"storedigital.web.id":{"zone":"2ce8a2f880534806e2f463e3eec68d31","token":"v5_unJTqruXV_x-5uj0dT5_Q4QAPThJbXzC2MmOQ"},"storeid.my.id":{"zone":"c651c828a01962eb3c530513c7ad7dcf","token":"N-D6fN6la7jY0AnvbWn9FcU6ZHuDitmFXd-JF04g"},"xyro.web.id":{"zone":"46d0cd33a7966f0be5afdab04b63e695","token":"CygwSHXRSfZnsi1qZmyB8s4qHC12jX_RR4mTpm62"},"xyroku.my.id":{"zone":"f6d1a73a272e6e770a232c39979d5139","token":"0Mae_Rtx1ixGYenzFcNG9bbPd-rWjoRwqN2tvNzo"},"gacorr.biz.id":{"zone":"cff22ce1965394f1992c8dba4c3db539","token":"v9kYfj5g2lcacvBaJHA_HRgNqBi9UlsVy0cm_EhT"},"cafee.my.id":{"zone":"0d7044fc3e0d66189724952fa3b850ce","token":"wAOEzAfvb-L3vKYE2Xg8svJpHfNS_u2noWSReSzJ"},"pterodaytl.my.id":{"zone":"828ef14600aaaa0b1ea881dd0e7972b2","token":"75HrVBzSVObD611RkuNS1ZKsL5A_b8kuiCs26-f9"},"googlex.my.id":{"zone":"dda9e25dac2556c7494470ee6152fc7f","token":"GuT5rNQSr_V2kxb-QZdJ4YbFlEvzE-upzhey9Ezl"},"heavencraft.my.id":{"zone":"9e7239dcda7cbd6be79d7615257f56f8","token":"aHvYYKk7YIADVOfpG3i1eaIqTeWCdPS25FAPreDQ"},"hilman-store.web.id":{"zone":"4e214dfe36faa7c942bc68b5aecdd1e9","token":"wpQCANKLRAtWb0XvTRed3vwSkOMMWKO2C75uwnKE"},"hilmanofficial.tech":{"zone":"c8705bfbfdca9c4e8e61eb2663ee87d6","token":"hjqWa_eFAfoJNJyBu9WAlg8WO0ICtN5AYpZURgqe"},"hilmanzoffc.web.id":{"zone":"2627badfda28951bfb936fce0febc5b0","token":"wZ3QAKn7zDx-tyb04HgCvmogqeM6je8jDNmiPZXq"},"host-panel.web.id":{"zone":"74b3192f7c3b0925cdb8606bb7db95c4","token":"GuT5rNQSr_V2kxb-QZdJ4YbFlEvzE-upzhey9Ezl"},"hostingers-vvip.my.id":{"zone":"2341ae01634b852230b7521af26c261f","token":"Ztw1ouD8_lJf-QzRecgmijjsDJODFU4b-y697lPw"}}'

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while ps -p $pid > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

show_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╦  ╦╔═╗╔═╗  ╔═╗╔╗╔╦  ╦ ╦
╚╗╔╝╠═╝╚═╗  ║ ║║║║║  ╚╦╝
 ╚╝ ╩  ╚═╝  ╚═╝╝╚╝╩═╝ ╩ 
EOF
    echo -e "${PURPLE}────────────────────────────────────────${NC}"
    echo -e "${WHITE}  PTERODACTYL AUTO INSTALLER V3.1${NC}"
    echo -e "${YELLOW}  Created By: JianOffc${NC}"
    echo -e "${PURPLE}────────────────────────────────────────${NC}\n"
}

generate_password() {
    tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c 16
}

generate_username() {
    echo "admin$(tr -dc '0-9' < /dev/urandom | head -c 4)"
}

test_ssh_connection() {
    local ip=$1
    local pass=$2
    sshpass -p "$pass" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 root@$ip "exit" 2>/dev/null
    return $?
}

delete_dns_record() {
    local host=$1
    local domain=$2
    
    local zone=$(echo $CLOUDFLARE_ZONES | jq -r ".\"$domain\".zone")
    local token=$(echo $CLOUDFLARE_ZONES | jq -r ".\"$domain\".token")
    
    if [ "$zone" = "null" ] || [ "$token" = "null" ]; then
        return 1
    fi
    
    local record_id=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone/dns_records?name=${host}.${domain}" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" | jq -r '.result[0].id')
    
    if [ "$record_id" != "null" ] && [ -n "$record_id" ]; then
        curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$zone/dns_records/$record_id" \
            -H "Authorization: Bearer $token" \
            -H "Content-Type: application/json" > /dev/null 2>&1
    fi
}

create_subdomain() {
    local host=$1
    local ip=$2
    local domain=$3
    
    local zone=$(echo $CLOUDFLARE_ZONES | jq -r ".\"$domain\".zone")
    local token=$(echo $CLOUDFLARE_ZONES | jq -r ".\"$domain\".token")
    
    if [ "$zone" = "null" ] || [ "$token" = "null" ]; then
        echo -e "${RED}[!] Invalid zone or token${NC}"
        return 1
    fi
    
    delete_dns_record "$host" "$domain"
    
    sleep 2
    
    local response=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zone/dns_records" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"$host\",\"content\":\"$ip\",\"ttl\":120,\"proxied\":false}")
    
    local success=$(echo $response | jq -r '.success')
    
    if [ "$success" = "true" ]; then
        return 0
    else
        echo -e "${RED}[!] Cloudflare API Error: $(echo $response | jq -r '.errors[0].message')${NC}"
        return 1
    fi
}

verify_dns() {
    local domain=$1
    local expected_ip=$2
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        local resolved_ip=$(dig +short $domain @1.1.1.1 | head -n1)
        
        if [ "$resolved_ip" = "$expected_ip" ]; then
            return 0
        fi
        
        attempt=$((attempt + 1))
        sleep 2
    done
    
    return 1
}

list_domains() {
    echo -e "${CYAN}Available Domains:${NC}\n"
    local i=1
    echo "$CLOUDFLARE_ZONES" | jq -r 'keys[]' | while read domain; do
        echo -e "${YELLOW}[$i]${NC} $domain"
        ((i++))
    done
    echo ""
}

create_subdomain_menu() {
    show_banner
    echo -e "${CYAN}[*] CREATE SUBDOMAIN${NC}\n"
    
    apt install -y jq dnsutils > /dev/null 2>&1
    
    read -p "$(echo -e ${YELLOW}Enter VPS IP Address: ${NC})" VPS_IP
    
    if [[ ! $VPS_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}[!] Invalid IP address format${NC}"
        sleep 2
        return
    fi
    
    list_domains
    read -p "$(echo -e ${YELLOW}Select domain number: ${NC})" domain_num
    
    SELECTED_DOMAIN=$(echo "$CLOUDFLARE_ZONES" | jq -r 'keys[]' | sed -n "${domain_num}p")
    
    if [ -z "$SELECTED_DOMAIN" ]; then
        echo -e "${RED}[!] Invalid domain selection${NC}"
        sleep 2
        return
    fi
    
    read -p "$(echo -e ${YELLOW}Enter hostname: ${NC})" HOSTNAME
    
    FULL_DOMAIN="${HOSTNAME}.${SELECTED_DOMAIN}"
    
    echo -e "\n${YELLOW}[~] Creating subdomain...${NC}"
    create_subdomain "$HOSTNAME" "$VPS_IP" "$SELECTED_DOMAIN"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✓] Subdomain created in Cloudflare${NC}"
        
        echo -e "${YELLOW}[~] Verifying DNS propagation...${NC}"
        verify_dns "$FULL_DOMAIN" "$VPS_IP"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[✓] DNS verified successfully${NC}"
            echo -e "${WHITE}Domain: ${CYAN}${FULL_DOMAIN}${NC}"
            echo -e "${WHITE}IP: ${CYAN}${VPS_IP}${NC}"
            echo -e "${WHITE}Status: ${GREEN}Active${NC}\n"
        else
            echo -e "${YELLOW}[!] DNS propagation in progress (may take a few minutes)${NC}"
            echo -e "${WHITE}Domain: ${CYAN}${FULL_DOMAIN}${NC}"
            echo -e "${WHITE}IP: ${CYAN}${VPS_IP}${NC}"
            echo -e "${WHITE}Status: ${YELLOW}Propagating${NC}\n"
        fi
        
        cat > /root/subdomain_${HOSTNAME}.txt << SUBINFO
Domain: ${FULL_DOMAIN}
IP: ${VPS_IP}
Created: $(date)
Status: Active
SUBINFO
        echo -e "${GREEN}[✓] Info saved to: ${CYAN}/root/subdomain_${HOSTNAME}.txt${NC}\n"
    else
        echo -e "${RED}[!] Failed to create subdomain${NC}\n"
    fi
    
    read -p "Press Enter to continue..."
}

install_panel() {
    show_banner
    echo -e "${CYAN}[*] INSTALL PTERODACTYL PANEL${NC}\n"
    
    apt install -y jq sshpass dnsutils > /dev/null 2>&1
    
    read -p "$(echo -e ${YELLOW}Enter VPS IP Address: ${NC})" VPS_IP
    
    if [[ ! $VPS_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}[!] Invalid IP address format${NC}"
        sleep 2
        return
    fi
    
    read -sp "$(echo -e ${YELLOW}Enter VPS Root Password: ${NC})" VPS_PASS
    echo ""
    
    echo -e "\n${YELLOW}[~] Testing SSH connection...${NC}"
    test_ssh_connection "$VPS_IP" "$VPS_PASS"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}[!] Failed to connect to VPS. Check IP and password${NC}\n"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${GREEN}[✓] SSH connection successful${NC}\n"
    
    list_domains
    read -p "$(echo -e ${YELLOW}Select domain number: ${NC})" domain_num
    
    SELECTED_DOMAIN=$(echo "$CLOUDFLARE_ZONES" | jq -r 'keys[]' | sed -n "${domain_num}p")
    
    if [ -z "$SELECTED_DOMAIN" ]; then
        echo -e "${RED}[!] Invalid domain selection${NC}"
        sleep 2
        return
    fi
    
    read -p "$(echo -e ${YELLOW}Enter hostname for panel: ${NC})" PANEL_HOST
    
    PANEL_DOMAIN="${PANEL_HOST}.${SELECTED_DOMAIN}"
    NODE_DOMAIN="node.${PANEL_DOMAIN}"
    
    ADMIN_USER=$(generate_username)
    ADMIN_PASS=$(generate_password)
    DB_PASS=$(generate_password)
    
    echo -e "\n${YELLOW}[~] Creating panel subdomain...${NC}"
    create_subdomain "$PANEL_HOST" "$VPS_IP" "$SELECTED_DOMAIN"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✓] Panel subdomain created${NC}"
        echo -e "${YELLOW}[~] Verifying DNS for panel...${NC}"
        verify_dns "$PANEL_DOMAIN" "$VPS_IP"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[✓] Panel DNS verified${NC}"
        else
            echo -e "${YELLOW}[!] Panel DNS propagating...${NC}"
        fi
    else
        echo -e "${RED}[!] Failed to create panel subdomain${NC}\n"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${YELLOW}[~] Creating node subdomain...${NC}"
    create_subdomain "node.${PANEL_HOST}" "$VPS_IP" "$SELECTED_DOMAIN"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✓] Node subdomain created${NC}"
        echo -e "${YELLOW}[~] Verifying DNS for node...${NC}"
        verify_dns "$NODE_DOMAIN" "$VPS_IP"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[✓] Node DNS verified${NC}"
        else
            echo -e "${YELLOW}[!] Node DNS propagating...${NC}"
        fi
    else
        echo -e "${RED}[!] Failed to create node subdomain${NC}\n"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "\n${WHITE}Panel: ${CYAN}${PANEL_DOMAIN}${NC} -> ${GREEN}${VPS_IP}${NC}"
    echo -e "${WHITE}Node:  ${CYAN}${NODE_DOMAIN}${NC} -> ${GREEN}${VPS_IP}${NC}\n"
    
    echo -e "${GREEN}[✓] Generated credentials:${NC}"
    echo -e "${WHITE}    Username: ${CYAN}${ADMIN_USER}${NC}"
    echo -e "${WHITE}    Password: ${CYAN}${ADMIN_PASS}${NC}\n"
    
    echo -e "${YELLOW}[~] Installing on remote VPS (this may take 10-15 minutes)...${NC}\n"
    
    sshpass -p "$VPS_PASS" ssh -o StrictHostKeyChecking=no root@$VPS_IP bash << ENDSSH
export DEBIAN_FRONTEND=noninteractive

echo "[1/15] Updating system..."
apt update -y > /dev/null 2>&1
apt upgrade -y > /dev/null 2>&1

echo "[2/15] Installing dependencies..."
apt install -y software-properties-common curl apt-transport-https ca-certificates gnupg > /dev/null 2>&1

echo "[3/15] Adding PHP repository..."
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php > /dev/null 2>&1
apt update -y > /dev/null 2>&1

echo "[4/15] Installing PHP and extensions..."
apt install -y php8.2 php8.2-{cli,gd,mysql,pdo,mbstring,tokenizer,bcmath,xml,fpm,curl,zip} > /dev/null 2>&1

echo "[5/15] Installing Composer..."
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer > /dev/null 2>&1

echo "[6/15] Installing MariaDB..."
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash > /dev/null 2>&1
apt install -y mariadb-server > /dev/null 2>&1

echo "[7/15] Installing Nginx, Redis, Certbot..."
apt install -y nginx redis-server certbot python3-certbot-nginx > /dev/null 2>&1

echo "[8/15] Configuring database..."
mysql -e "DROP USER IF EXISTS 'pterodactyl'@'127.0.0.1';" 2>/dev/null
mysql -e "DROP USER IF EXISTS 'pterodactyl'@'localhost';" 2>/dev/null
mysql -e "DROP DATABASE IF EXISTS panel;" 2>/dev/null
mysql -e "CREATE USER 'pterodactyl'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';"
mysql -e "CREATE DATABASE panel;"
mysql -e "GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'127.0.0.1';"
mysql -e "CREATE USER 'pterodactyl'@'localhost' IDENTIFIED BY '${DB_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

echo "[9/15] Downloading Pterodactyl Panel..."
mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz 2>/dev/null
tar -xzvf panel.tar.gz > /dev/null 2>&1
chmod -R 755 storage/* bootstrap/cache/ 2>/dev/null
cp .env.example .env
composer install --no-dev --optimize-autoloader --no-interaction > /dev/null 2>&1

echo "[10/15] Configuring Panel..."
php artisan key:generate --force > /dev/null 2>&1
APPKEY=\$(php artisan key:generate --show)

cat > .env << 'ENVFILE'
APP_ENV=production
APP_DEBUG=false
APP_KEY=${APPKEY}
APP_TIMEZONE=UTC
APP_URL=https://${PANEL_DOMAIN}
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=panel
DB_USERNAME=pterodactyl
DB_PASSWORD=${DB_PASS}
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=
REDIS_PORT=6379
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis
RECAPTCHA_ENABLED=false
RECAPTCHA_SECRET_KEY=
RECAPTCHA_WEBSITE_KEY=
ENVFILE

sed -i "s/\\\${APPKEY}/\${APPKEY}/g" .env
sed -i "s/\\\${PANEL_DOMAIN}/${PANEL_DOMAIN}/g" .env
sed -i "s/\\\${DB_PASS}/${DB_PASS}/g" .env

php artisan migrate --seed --force > /dev/null 2>&1
php artisan p:user:make --email=admin@${PANEL_DOMAIN} --username=${ADMIN_USER} --name-first=Admin --name-last=Panel --password=${ADMIN_PASS} --admin=1 --no-interaction > /dev/null 2>&1
chown -R www-data:www-data /var/www/pterodactyl/*

echo "[11/15] Configuring Nginx..."
cat > /etc/nginx/sites-available/pterodactyl.conf << 'NGINXCONF'
server {
    listen 80;
    server_name ${PANEL_DOMAIN};
    root /var/www/pterodactyl/public;
    index index.php;
    client_max_body_size 100m;
    
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
NGINXCONF

sed -i "s/\\\${PANEL_DOMAIN}/${PANEL_DOMAIN}/g" /etc/nginx/sites-available/pterodactyl.conf

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/
nginx -t > /dev/null 2>&1
systemctl restart nginx

echo "[12/15] Getting SSL certificate for panel..."
sleep 5
systemctl stop nginx
certbot certonly --standalone -d ${PANEL_DOMAIN} --non-interactive --agree-tos --email admin@${PANEL_DOMAIN} --force-renewal > /dev/null 2>&1

if [ -f /etc/letsencrypt/live/${PANEL_DOMAIN}/fullchain.pem ]; then
    cat > /etc/nginx/sites-available/pterodactyl.conf << 'NGINXSSL'
server {
    listen 80;
    server_name ${PANEL_DOMAIN};
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ${PANEL_DOMAIN};
    root /var/www/pterodactyl/public;
    index index.php;
    client_max_body_size 100m;
    
    ssl_certificate /etc/letsencrypt/live/${PANEL_DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${PANEL_DOMAIN}/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
NGINXSSL
    sed -i "s/\\\${PANEL_DOMAIN}/${PANEL_DOMAIN}/g" /etc/nginx/sites-available/pterodactyl.conf
fi

systemctl start nginx

echo "[13/15] Setting up services..."
cat > /etc/systemd/system/pteroq.service << 'SERVICECONF'
[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3

[Install]
WantedBy=multi-user.target
SERVICECONF

systemctl enable --now pteroq > /dev/null 2>&1
(crontab -l 2>/dev/null; echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1") | crontab -

echo "[14/15] Installing Docker & Wings..."
curl -sSL https://get.docker.com/ | CHANNEL=stable bash > /dev/null 2>&1
systemctl enable --now docker > /dev/null 2>&1
mkdir -p /etc/pterodactyl
curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64" 2>/dev/null
chmod u+x /usr/local/bin/wings

echo "[15/15] Getting SSL certificate for node..."
sleep 5
systemctl stop nginx
certbot certonly --standalone -d ${NODE_DOMAIN} --non-interactive --agree-tos --email admin@${PANEL_DOMAIN} --force-renewal > /dev/null 2>&1

if [ ! -f /etc/letsencrypt/live/${NODE_DOMAIN}/fullchain.pem ]; then
    mkdir -p /etc/letsencrypt/live/${NODE_DOMAIN}/
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/letsencrypt/live/${NODE_DOMAIN}/privkey.pem \
      -out /etc/letsencrypt/live/${NODE_DOMAIN}/fullchain.pem \
      -subj "/CN=${NODE_DOMAIN}" > /dev/null 2>&1
    chmod 600 /etc/letsencrypt/live/${NODE_DOMAIN}/privkey.pem
    chmod 644 /etc/letsencrypt/live/${NODE_DOMAIN}/fullchain.pem
fi

systemctl start nginx

cat > /etc/systemd/system/wings.service << 'WINGSCONF'
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
WINGSCONF

systemctl enable wings > /dev/null 2>&1
useradd -r -m -d /var/lib/pterodactyl -s /bin/bash pterodactyl > /dev/null 2>&1

cat > /root/pterodactyl_credentials.txt << CREDFILE
========================================
PTERODACTYL INSTALLATION CREDENTIALS
========================================
VPS IP: ${VPS_IP}
Panel URL: https://${PANEL_DOMAIN}
Username: ${ADMIN_USER}
Password: ${ADMIN_PASS}
Node FQDN: ${NODE_DOMAIN}
Database Password: ${DB_PASS}
Installation Date: \$(date)
========================================
CREDFILE

echo ""
echo "========================================="
echo "INSTALLATION COMPLETED SUCCESSFULLY!"
echo "========================================="
echo "Panel URL: https://${PANEL_DOMAIN}"
echo "Username: ${ADMIN_USER}"
echo "Password: ${ADMIN_PASS}"
echo "========================================="

ENDSSH
    
    if [ $? -eq 0 ]; then
        echo -e "\n${PURPLE}════════════════════════════════════════${NC}"
        echo -e "${GREEN}[✓] INSTALLATION COMPLETE!${NC}"
        echo -e "${PURPLE}════════════════════════════════════════${NC}\n"
        echo -e "${WHITE}VPS IP:    ${CYAN}${VPS_IP}${NC}"
        echo -e "${WHITE}Panel URL: ${CYAN}https://${PANEL_DOMAIN}${NC}"
        echo -e "${WHITE}Username:  ${CYAN}${ADMIN_USER}${NC}"
        echo -e "${WHITE}Password:  ${CYAN}${ADMIN_PASS}${NC}"
        echo -e "${WHITE}Node FQDN: ${CYAN}${NODE_DOMAIN}${NC}\n"
        echo -e "${YELLOW}Next Steps:${NC}"
        echo -e "${WHITE}1. Open browser and go to: ${CYAN}https://${PANEL_DOMAIN}${NC}"
        echo -e "${WHITE}2. Login with credentials above${NC}"
        echo -e "${WHITE}3. Go to: ${CYAN}Admin → Locations${NC} and create a location${NC}"
        echo -e "${WHITE}4. Go to: ${CYAN}Admin → Nodes${NC} and create a node:${NC}"
        echo -e "${WHITE}   - FQDN: ${CYAN}${NODE_DOMAIN}${NC}"
        echo -e "${WHITE}   - Communicate Over SSL: ${GREEN}Yes${NC}"
        echo -e "${WHITE}   - Behind Proxy: ${RED}No${NC}"
        echo -e "${WHITE}5. Copy the configuration from the panel${NC}"
        echo -e "${WHITE}6. SSH to VPS and run: ${CYAN}nano /etc/pterodactyl/config.yml${NC}"
        echo -e "${WHITE}7. Paste the configuration and save (Ctrl+X, Y, Enter)${NC}"
        echo -e "${WHITE}8. Start Wings: ${CYAN}systemctl start wings${NC}"
        echo -e "${WHITE}9. Check Wings status: ${CYAN}systemctl status wings${NC}\n"
        
        cat > /root/local_pterodactyl_${PANEL_HOST}.txt << LOCALCRED
========================================
PTERODACTYL INSTALLATION CREDENTIALS
========================================
VPS IP: ${VPS_IP}
VPS Root Password: ${VPS_PASS}
Panel URL: https://${PANEL_DOMAIN}
Username: ${ADMIN_USER}
Password: ${ADMIN_PASS}
Node FQDN: ${NODE_DOMAIN}
Database Password: ${DB_PASS}
Installation Date: $(date)
========================================

DNS Records Created:
- ${PANEL_DOMAIN} -> ${VPS_IP}
- ${NODE_DOMAIN} -> ${VPS_IP}

Next Steps:
1. Open: https://${PANEL_DOMAIN}
2. Login with credentials above
3. Create Location (Admin → Locations)
4. Create Node with FQDN: ${NODE_DOMAIN}
5. Copy config to /etc/pterodactyl/config.yml on VPS
6. Run: systemctl start wings
7. Check: systemctl status wings

SSH Command:
ssh root@${VPS_IP}

Troubleshooting:
- Check Nginx: systemctl status nginx
- Check Panel: systemctl status pteroq
- Check Wings: systemctl status wings
- Check Logs: tail -f /var/www/pterodactyl/storage/logs/laravel-*.log
========================================
LOCALCRED
        
        echo -e "${GREEN}[✓] Credentials saved on VPS: ${CYAN}/root/pterodactyl_credentials.txt${NC}"
        echo -e "${GREEN}[✓] Credentials saved locally: ${CYAN}/root/local_pterodactyl_${PANEL_HOST}.txt${NC}\n"
    else
        echo -e "${RED}[!] Installation failed or incomplete${NC}\n"
    fi
    
    read -p "Press Enter to continue..."
}

uninstall_panel() {
    show_banner
    echo -e "${RED}[!] UNINSTALL PTERODACTYL${NC}\n"
    
    apt install -y sshpass > /dev/null 2>&1
    
    read -p "$(echo -e ${YELLOW}Enter VPS IP Address: ${NC})" VPS_IP
    
    if [[ ! $VPS_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}[!] Invalid IP address format${NC}"
        sleep 2
        return
    fi
    
    read -sp "$(echo -e ${YELLOW}Enter VPS Root Password: ${NC})" VPS_PASS
    echo ""
    
    echo -e "\n${YELLOW}[~] Testing SSH connection...${NC}"
    test_ssh_connection "$VPS_IP" "$VPS_PASS"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}[!] Failed to connect to VPS. Check IP and password${NC}\n"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${GREEN}[✓] SSH connection successful${NC}\n"
    
    read -p "$(echo -e ${RED}Are you sure? This will delete EVERYTHING! [y/N]: ${NC})" confirm
    
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}[✓] Cancelled${NC}"
        sleep 2
        return
    fi
    
    echo -e "\n${YELLOW}[~] Uninstalling from remote VPS...${NC}\n"
    
    sshpass -p "$VPS_PASS" ssh -o StrictHostKeyChecking=no root@$VPS_IP bash << 'ENDSSH'

echo "[1/8] Stopping services..."
systemctl stop wings pteroq nginx > /dev/null 2>&1
systemctl disable wings pteroq > /dev/null 2>&1

echo "[2/8] Removing service files..."
rm -f /etc/systemd/system/wings.service /etc/systemd/system/pteroq.service
systemctl daemon-reload

echo "[3/8] Stopping Docker containers..."
docker ps -aq | xargs -r docker stop > /dev/null 2>&1

echo "[4/8] Removing Docker containers..."
docker ps -aq | xargs -r docker rm > /dev/null 2>&1
docker system prune -af --volumes > /dev/null 2>&1

echo "[5/8] Removing Pterodactyl files..."
rm -rf /var/lib/pterodactyl
rm -rf /etc/pterodactyl
rm -rf /usr/local/bin/wings
rm -rf /var/www/pterodactyl
rm -f /etc/nginx/sites-enabled/pterodactyl.conf
rm -f /etc/nginx/sites-available/pterodactyl.conf

echo "[6/8] Removing SSL certificates..."
rm -rf /etc/letsencrypt/live/*/
rm -rf /etc/letsencrypt/archive/*/
rm -rf /etc/letsencrypt/renewal/*.conf

echo "[7/8] Removing database..."
mysql -e "DROP DATABASE IF EXISTS panel;" 2>/dev/null
mysql -e "DROP USER IF EXISTS 'pterodactyl'@'localhost';" 2>/dev/null
mysql -e "DROP USER IF EXISTS 'pterodactyl'@'127.0.0.1';" 2>/dev/null
mysql -e "FLUSH PRIVILEGES;" 2>/dev/null

echo "[8/8] Final cleanup..."
crontab -l 2>/dev/null | grep -v "pterodactyl" | crontab - 2>/dev/null
userdel -r pterodactyl 2>/dev/null
rm -f /root/pterodactyl_credentials.txt

systemctl start nginx > /dev/null 2>&1

echo ""
echo "========================================="
echo "UNINSTALLATION COMPLETED SUCCESSFULLY!"
echo "========================================="

ENDSSH
    
    if [ $? -eq 0 ]; then
        echo -e "\n${PURPLE}════════════════════════════════════════${NC}"
        echo -e "${GREEN}[✓] UNINSTALLATION COMPLETE!${NC}"
        echo -e "${PURPLE}════════════════════════════════════════${NC}\n"
        echo -e "${WHITE}VPS IP: ${CYAN}${VPS_IP}${NC}"
        echo -e "${WHITE}Status: ${GREEN}All Pterodactyl components removed${NC}\n"
        echo -e "${YELLOW}Note:${NC} Subdomain DNS records still exist in Cloudflare"
        echo -e "${YELLOW}You can delete them manually if needed${NC}\n"
    else
        echo -e "${RED}[!] Uninstallation failed or incomplete${NC}\n"
    fi
    
    read -p "Press Enter to continue..."
}

fix_installation() {
    show_banner
    echo -e "${CYAN}[*] FIX PTERODACTYL INSTALLATION${NC}\n"
    
    apt install -y sshpass > /dev/null 2>&1
    
    read -p "$(echo -e ${YELLOW}Enter VPS IP Address: ${NC})" VPS_IP
    
    if [[ ! $VPS_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}[!] Invalid IP address format${NC}"
        sleep 2
        return
    fi
    
    read -sp "$(echo -e ${YELLOW}Enter VPS Root Password: ${NC})" VPS_PASS
    echo ""
    
    echo -e "\n${YELLOW}[~] Testing SSH connection...${NC}"
    test_ssh_connection "$VPS_IP" "$VPS_PASS"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}[!] Failed to connect to VPS. Check IP and password${NC}\n"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${GREEN}[✓] SSH connection successful${NC}\n"
    
    read -p "$(echo -e ${YELLOW}Enter Panel Domain (e.g., anossir.storeid.my.id): ${NC})" PANEL_DOMAIN
    read -p "$(echo -e ${YELLOW}Enter Node Domain (e.g., node.anossir.storeid.my.id): ${NC})" NODE_DOMAIN
    
    echo -e "\n${YELLOW}[~] Fixing installation on VPS...${NC}\n"
    
    sshpass -p "$VPS_PASS" ssh -o StrictHostKeyChecking=no root@$VPS_IP bash << ENDSSH

echo "[1/4] Reconfiguring Nginx..."
cat > /etc/nginx/sites-available/pterodactyl.conf << 'NGINXFIX'
server {
    listen 80;
    server_name ${PANEL_DOMAIN};
    return 301 https://\\\$server_name\\\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ${PANEL_DOMAIN};
    root /var/www/pterodactyl/public;
    index index.php;
    client_max_body_size 100m;
    
    ssl_certificate /etc/letsencrypt/live/${PANEL_DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${PANEL_DOMAIN}/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    
    location / {
        try_files \\\$uri \\\$uri/ /index.php?\\\$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \\\$document_root\\\$fastcgi_script_name;
    }
}
NGINXFIX

sed -i "s/\\\${PANEL_DOMAIN}/${PANEL_DOMAIN}/g" /etc/nginx/sites-available/pterodactyl.conf

echo "[2/4] Getting SSL certificates..."
systemctl stop nginx
certbot certonly --standalone -d ${PANEL_DOMAIN} --non-interactive --agree-tos --email admin@${PANEL_DOMAIN} --force-renewal > /dev/null 2>&1
certbot certonly --standalone -d ${NODE_DOMAIN} --non-interactive --agree-tos --email admin@${PANEL_DOMAIN} --force-renewal > /dev/null 2>&1

if [ ! -f /etc/letsencrypt/live/${NODE_DOMAIN}/fullchain.pem ]; then
    mkdir -p /etc/letsencrypt/live/${NODE_DOMAIN}/
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/letsencrypt/live/${NODE_DOMAIN}/privkey.pem \
      -out /etc/letsencrypt/live/${NODE_DOMAIN}/fullchain.pem \
      -subj "/CN=${NODE_DOMAIN}" > /dev/null 2>&1
    chmod 600 /etc/letsencrypt/live/${NODE_DOMAIN}/privkey.pem
    chmod 644 /etc/letsencrypt/live/${NODE_DOMAIN}/fullchain.pem
fi

echo "[3/4] Restarting services..."
systemctl start nginx
systemctl restart pteroq
systemctl restart php8.2-fpm

echo "[4/4] Setting permissions..."
chown -R www-data:www-data /var/www/pterodactyl/*
chmod -R 755 /var/www/pterodactyl/storage
chmod -R 755 /var/www/pterodactyl/bootstrap/cache

echo ""
echo "========================================="
echo "FIX COMPLETED SUCCESSFULLY!"
echo "========================================="
echo "Panel URL: https://${PANEL_DOMAIN}"
echo "Node FQDN: ${NODE_DOMAIN}"
echo "========================================="
echo ""
echo "Try accessing the panel now!"

ENDSSH
    
    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}[✓] Installation fixed successfully!${NC}"
        echo -e "${WHITE}Panel URL: ${CYAN}https://${PANEL_DOMAIN}${NC}"
        echo -e "${WHITE}Node FQDN: ${CYAN}${NODE_DOMAIN}${NC}\n"
        echo -e "${YELLOW}Try accessing the panel in your browser now${NC}\n"
    else
        echo -e "${RED}[!] Fix failed${NC}\n"
    fi
    
    read -p "Press Enter to continue..."
}

main_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}[1]${NC} Create Subdomain Only"
        echo -e "${CYAN}[2]${NC} Install Panel + Wings"
        echo -e "${CYAN}[3]${NC} Uninstall Pterodactyl"
        echo -e "${CYAN}[4]${NC} Fix Installation (if panel not accessible)"
        echo -e "${CYAN}[5]${NC} Exit\n"
        read -p "$(echo -e ${YELLOW}Select option: ${NC})" choice
        
        case $choice in
            1) create_subdomain_menu ;;
            2) install_panel ;;
            3) uninstall_panel ;;
            4) fix_installation ;;
            5) echo -e "\n${GREEN}Goodbye!${NC}\n"; exit 0 ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 2 ;;
        esac
    done
}

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root!${NC}"
    exit 1
fi

main_menu
