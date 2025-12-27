#!/bin/bash

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
    echo -e "${WHITE}  PTERODACTYL AUTO INSTALLER V2.0${NC}"
    echo -e "${YELLOW}  Created By: JianOffc${NC}"
    echo -e "${PURPLE}────────────────────────────────────────${NC}\n"
}

generate_password() {
    tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c 16
}

generate_username() {
    echo "admin$(tr -dc '0-9' < /dev/urandom | head -c 4)"
}

create_subdomain() {
    local host=$1
    local ip=$2
    local domain=$3
    
    local zone=$(echo $CLOUDFLARE_ZONES | jq -r ".\"$domain\".zone")
    local token=$(echo $CLOUDFLARE_ZONES | jq -r ".\"$domain\".token")
    
    if [ "$zone" = "null" ] || [ "$token" = "null" ]; then
        return 1
    fi
    
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zone/dns_records" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"$host\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":false}" > /dev/null 2>&1
    
    return $?
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

install_panel() {
    show_banner
    echo -e "${CYAN}[*] INSTALL PTERODACTYL PANEL${NC}\n"
    
    apt install -y jq > /dev/null 2>&1
    
    VPS_IP=$(curl -s ifconfig.me)
    
    list_domains
    read -p "$(echo -e ${YELLOW}Select domain number: ${NC})" domain_num
    
    SELECTED_DOMAIN=$(echo "$CLOUDFLARE_ZONES" | jq -r 'keys[]' | sed -n "${domain_num}p")
    
    if [ -z "$SELECTED_DOMAIN" ]; then
        echo -e "${RED}[!] Invalid domain selection${NC}"
        return
    fi
    
    read -p "$(echo -e ${YELLOW}Enter hostname for panel: ${NC})" PANEL_HOST
    
    PANEL_DOMAIN="${PANEL_HOST}.${SELECTED_DOMAIN}"
    NODE_DOMAIN="node.${PANEL_DOMAIN}"
    
    ADMIN_USER=$(generate_username)
    ADMIN_PASS=$(generate_password)
    DB_PASS=$(generate_password)
    
    echo -e "\n${YELLOW}[~] Creating subdomains...${NC}"
    create_subdomain "$PANEL_HOST" "$VPS_IP" "$SELECTED_DOMAIN" &
    pid1=$!
    create_subdomain "node.${PANEL_HOST}" "$VPS_IP" "$SELECTED_DOMAIN" &
    pid2=$!
    wait $pid1 $pid2
    echo -e "${GREEN}[✓] Subdomains created${NC}"
    echo -e "${WHITE}    Panel: ${CYAN}${PANEL_DOMAIN}${NC}"
    echo -e "${WHITE}    Node:  ${CYAN}${NODE_DOMAIN}${NC}\n"
    
    echo -e "${GREEN}[✓] Generated credentials:${NC}"
    echo -e "${WHITE}    Username: ${CYAN}${ADMIN_USER}${NC}"
    echo -e "${WHITE}    Password: ${CYAN}${ADMIN_PASS}${NC}\n"
    
    echo -e "${YELLOW}[~] Installing dependencies...${NC}"
    export DEBIAN_FRONTEND=noninteractive
    (
        apt update -y && apt upgrade -y
        apt install -y software-properties-common curl apt-transport-https ca-certificates gnupg
        LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
        apt update -y
        apt install -y php8.2 php8.2-{cli,gd,mysql,pdo,mbstring,tokenizer,bcmath,xml,fpm,curl,zip}
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
        curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash
        apt install -y mariadb-server nginx redis-server certbot python3-certbot-nginx
    ) > /dev/null 2>&1 &
    spinner $!
    echo -e "${GREEN}[✓] Dependencies installed${NC}"
    
    echo -e "${YELLOW}[~] Configuring database...${NC}"
    (
        mysql -e "DROP USER IF EXISTS 'pterodactyl'@'127.0.0.1';" 2>/dev/null
        mysql -e "DROP USER IF EXISTS 'pterodactyl'@'localhost';" 2>/dev/null
        mysql -e "DROP DATABASE IF EXISTS panel;" 2>/dev/null
        mysql -e "CREATE USER 'pterodactyl'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';"
        mysql -e "CREATE DATABASE panel;"
        mysql -e "GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'127.0.0.1';"
        mysql -e "CREATE USER 'pterodactyl'@'localhost' IDENTIFIED BY '${DB_PASS}';"
        mysql -e "GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'localhost';"
        mysql -e "FLUSH PRIVILEGES;"
    ) > /dev/null 2>&1 &
    spinner $!
    echo -e "${GREEN}[✓] Database configured${NC}"
    
    echo -e "${YELLOW}[~] Downloading panel...${NC}"
    (
        mkdir -p /var/www/pterodactyl
        cd /var/www/pterodactyl
        curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
        tar -xzvf panel.tar.gz
        chmod -R 755 storage/* bootstrap/cache/
        cp .env.example .env
        composer install --no-dev --optimize-autoloader --no-interaction
    ) > /dev/null 2>&1 &
    spinner $!
    echo -e "${GREEN}[✓] Panel downloaded${NC}"
    
    echo -e "${YELLOW}[~] Configuring panel...${NC}"
    (
        cd /var/www/pterodactyl
        php artisan key:generate --force
        APPKEY=$(php artisan key:generate --show)
        cat > .env << EOF
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
EOF
        php artisan migrate --seed --force
        php artisan p:user:make --email=admin@${PANEL_DOMAIN} --username=${ADMIN_USER} --name-first=Admin --name-last=Panel --password=${ADMIN_PASS} --admin=1 --no-interaction
        chown -R www-data:www-data /var/www/pterodactyl/*
    ) > /dev/null 2>&1 &
    spinner $!
    echo -e "${GREEN}[✓] Panel configured${NC}"
    
    echo -e "${YELLOW}[~] Configuring nginx...${NC}"
    (
        cat > /etc/nginx/sites-available/pterodactyl.conf << NGINX
server {
listen 80;
server_name ${PANEL_DOMAIN};
root /var/www/pterodactyl/public;
index index.php;
client_max_body_size 100m;
location / { try_files \$uri \$uri/ /index.php?\$query_string; }
location ~ \.php$ {
fastcgi_pass unix:/run/php/php8.2-fpm.sock;
fastcgi_index index.php;
include fastcgi_params;
fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
}
}
NGINX
        rm -f /etc/nginx/sites-enabled/default
        ln -sf /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/
        systemctl restart nginx
    ) > /dev/null 2>&1 &
    spinner $!
    echo -e "${GREEN}[✓] Nginx configured${NC}"
    
    echo -e "${YELLOW}[~] Getting SSL certificate...${NC}"
    sleep 10
    systemctl stop nginx
    certbot certonly --standalone -d ${PANEL_DOMAIN} --non-interactive --agree-tos --email admin@${PANEL_DOMAIN} --force-renewal > /dev/null 2>&1
    
    cat > /etc/nginx/sites-available/pterodactyl.conf << NGINXSSL
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
location / { try_files \$uri \$uri/ /index.php?\$query_string; }
location ~ \.php$ {
fastcgi_pass unix:/run/php/php8.2-fpm.sock;
fastcgi_index index.php;
include fastcgi_params;
fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
}
}
NGINXSSL
    systemctl start nginx
    echo -e "${GREEN}[✓] SSL configured${NC}"
    
    echo -e "${YELLOW}[~] Setting up services...${NC}"
    (
        cat > /etc/systemd/system/pteroq.service << 'SERVICE'
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
SERVICE
        systemctl enable --now pteroq
        (crontab -l 2>/dev/null; echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1") | crontab -
    ) > /dev/null 2>&1 &
    spinner $!
    echo -e "${GREEN}[✓] Services configured${NC}"
    
    echo -e "${YELLOW}[~] Installing Docker & Wings...${NC}"
    (
        curl -sSL https://get.docker.com/ | CHANNEL=stable bash
        systemctl enable --now docker
        mkdir -p /etc/pterodactyl
        curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64"
        chmod u+x /usr/local/bin/wings
    ) > /dev/null 2>&1 &
    spinner $!
    echo -e "${GREEN}[✓] Docker & Wings installed${NC}"
    
    echo -e "${YELLOW}[~] Getting SSL for node...${NC}"
    sleep 10
    systemctl stop nginx
    certbot certonly --standalone -d ${NODE_DOMAIN} --non-interactive --agree-tos --email admin@${PANEL_DOMAIN} --force-renewal > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        mkdir -p /etc/letsencrypt/live/${NODE_DOMAIN}/
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
          -keyout /etc/letsencrypt/live/${NODE_DOMAIN}/privkey.pem \
          -out /etc/letsencrypt/live/${NODE_DOMAIN}/fullchain.pem \
          -subj "/CN=${NODE_DOMAIN}" > /dev/null 2>&1
        chmod 600 /etc/letsencrypt/live/${NODE_DOMAIN}/privkey.pem
        chmod 644 /etc/letsencrypt/live/${NODE_DOMAIN}/fullchain.pem
    fi
    systemctl start nginx
    echo -e "${GREEN}[✓] Node SSL configured${NC}"
    
    cat > /etc/systemd/system/wings.service << 'WINGS'
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
WINGS
    systemctl enable wings
    useradd -r -m -d /var/lib/pterodactyl -s /bin/bash pterodactyl > /dev/null 2>&1
    
    echo -e "\n${PURPLE}────────────────────────────────────────${NC}"
    echo -e "${GREEN}[✓] INSTALLATION COMPLETE!${NC}"
    echo -e "${PURPLE}────────────────────────────────────────${NC}\n"
    echo -e "${WHITE}Panel URL: ${CYAN}https://${PANEL_DOMAIN}${NC}"
    echo -e "${WHITE}Username:  ${CYAN}${ADMIN_USER}${NC}"
    echo -e "${WHITE}Password:  ${CYAN}${ADMIN_PASS}${NC}"
    echo -e "${WHITE}Node FQDN: ${CYAN}${NODE_DOMAIN}${NC}\n"
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "${WHITE}1. Login to panel${NC}"
    echo -e "${WHITE}2. Create location (Admin → Locations)${NC}"
    echo -e "${WHITE}3. Create node with FQDN: ${CYAN}${NODE_DOMAIN}${NC}"
    echo -e "${WHITE}4. Get config and paste to: ${CYAN}/etc/pterodactyl/config.yml${NC}"
    echo -e "${WHITE}5. Run: ${CYAN}systemctl start wings${NC}\n"
    
    cat > /root/pterodactyl_credentials.txt << CRED
Panel URL: https://${PANEL_DOMAIN}
Username: ${ADMIN_USER}
Password: ${ADMIN_PASS}
Node FQDN: ${NODE_DOMAIN}
VPS IP: ${VPS_IP}
CRED
    echo -e "${GREEN}[✓] Credentials saved to: ${CYAN}/root/pterodactyl_credentials.txt${NC}\n"
}

uninstall_panel() {
    show_banner
    echo -e "${RED}[!] UNINSTALL PTERODACTYL${NC}\n"
    read -p "$(echo -e ${YELLOW}Are you sure? [y/N]: ${NC})" confirm
    
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}[✓] Cancelled${NC}"
        return
    fi
    
    echo -e "${YELLOW}[~] Removing services...${NC}"
    (
        systemctl stop wings pteroq
        systemctl disable wings pteroq
        rm -f /etc/systemd/system/wings.service /etc/systemd/system/pteroq.service
        systemctl daemon-reload
    ) > /dev/null 2>&1 &
    spinner $!
    echo -e "${GREEN}[✓] Services removed${NC}"
    
    echo -e "${YELLOW}[~] Removing Docker containers...${NC}"
    (
        docker ps -aq | xargs -r docker stop
        docker ps -aq | xargs -r docker rm
        docker system prune -af
    ) > /dev/null 2>&1 &
    spinner $!
    echo -e "${GREEN}[✓] Docker cleaned${NC}"
    
    echo -e "${YELLOW}[~] Removing files...${NC}"
    (
        rm -rf /var/lib/pterodactyl /etc/pterodactyl /usr/local/bin/wings /var/www/pterodactyl
        rm -f /etc/nginx/sites-enabled/pterodactyl.conf /etc/nginx/sites-available/pterodactyl.conf
        systemctl reload nginx
    ) > /dev/null 2>&1 &
    spinner $!
    echo -e "${GREEN}[✓] Files removed${NC}"
    
    echo -e "${YELLOW}[~] Removing database...${NC}"
    (
        mysql -e "DROP DATABASE IF EXISTS panel;" 2>/dev/null
        mysql -e "DROP USER IF EXISTS 'pterodactyl'@'localhost';" 2>/dev/null
        mysql -e "DROP USER IF EXISTS 'pterodactyl'@'127.0.0.1';" 2>/dev/null
        mysql -e "FLUSH PRIVILEGES;"
    ) > /dev/null 2>&1 &
    spinner $!
    echo -e "${GREEN}[✓] Database removed${NC}"
    
    crontab -l | grep -v "pterodactyl" | crontab - 2>/dev/null
    userdel -r pterodactyl 2>/dev/null
    
    echo -e "\n${GREEN}[✓] Pterodactyl uninstalled!${NC}\n"
}

main_menu() {
    show_banner
    echo -e "${CYAN}[1]${NC} Install Panel + Wings"
    echo -e "${CYAN}[2]${NC} Uninstall Pterodactyl"
    echo -e "${CYAN}[3]${NC} Exit\n"
    read -p "$(echo -e ${YELLOW}Select option: ${NC})" choice
    
    case $choice in
        1) install_panel ;;
        2) uninstall_panel ;;
        3) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid option!${NC}"; sleep 2; main_menu ;;
    esac
}

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root!${NC}"
    exit 1
fi

main_menu
