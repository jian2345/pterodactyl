#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

CLOUDFLARE_ZONES='{"pterodactyl-panel.web.id":{"zone":"d69feb7345d9e4dd5cfd7cce29e7d5b0","token":"32zZwadzwc7qB4mzuDBJkk1xFyoQ2Grr27mAfJcB"},"storedigital.web.id":{"zone":"2ce8a2f880534806e2f463e3eec68d31","token":"v5_unJTqruXV_x-5uj0dT5_Q4QAPThJbXzC2MmOQ"},"storeid.my.id":{"zone":"c651c828a01962eb3c530513c7ad7dcf","token":"N-D6fN6la7jY0AnvbWn9FcU6ZHuDitmFXd-JF04g"},"xyro.web.id":{"zone":"46d0cd33a7966f0be5afdab04b63e695","token":"CygwSHXRSfZnsi1qZmyB8s4qHC12jX_RR4mTpm62"},"xyroku.my.id":{"zone":"f6d1a73a272e6e770a232c39979d5139","token":"0Mae_Rtx1ixGYenzFcNG9bbPd-rWjoRwqN2tvNzo"},"gacorr.biz.id":{"zone":"cff22ce1965394f1992c8dba4c3db539","token":"v9kYfj5g2lcacvBaJHA_HRgNqBi9UlsVy0cm_EhT"},"cafee.my.id":{"zone":"0d7044fc3e0d66189724952fa3b850ce","token":"wAOEzAfvb-L3vKYE2Xg8svJpHfNS_u2noWSReSzJ"},"pterodaytl.my.id":{"zone":"828ef14600aaaa0b1ea881dd0e7972b2","token":"75HrVBzSVObD611RkuNS1ZKsL5A_b8kuiCs26-f9"},"googlex.my.id":{"zone":"dda9e25dac2556c7494470ee6152fc7f","token":"GuT5rNQSr_V2kxb-QZdJ4YbFlEvzE-upzhey9Ezl"},"heavencraft.my.id":{"zone":"9e7239dcda7cbd6be79d7615257f56f8","token":"aHvYYKk7YIADVOfpG3i1eaIqTeWCdPS25FAPreDQ"},"hilman-store.web.id":{"zone":"4e214dfe36faa7c942bc68b5aecdd1e9","token":"wpQCANKLRAtWb0XvTRed3vwSkOMMWKO2C75uwnKE"},"hilmanofficial.tech":{"zone":"c8705bfbfdca9c4e8e61eb2663ee87d6","token":"hjqWa_eFAfoJNJyBu9WAlg8WO0ICtN5AYpZURgqe"},"hilmanzoffc.web.id":{"zone":"2627badfda28951bfb936fce0febc5b0","token":"wZ3QAKn7zDx-tyb04HgCvmogqeM6je8jDNmiPZXq"},"host-panel.web.id":{"zone":"74b3192f7c3b0925cdb8606bb7db95c4","token":"GuT5rNQSr_V2kxb-QZdJ4YbFlEvzE-upzhey9Ezl"},"hostingers-vvip.my.id":{"zone":"2341ae01634b852230b7521af26c261f","token":"Ztw1ouD8_lJf-QzRecgmijjsDJODFU4b-y697lPw"}}'

show_ascii() {
    clear
    echo -e "${RED}"
    cat << "EOF"
    ╔══════════════════════════════════════════════════╗
    ║                                                  ║
    ║   ██╗   ██╗██████╗ ███████╗     ██████╗ ███╗   ██╗██╗  ██╗   ██╗  ║
    ║   ██║   ██║██╔══██╗██╔════╝    ██╔═══██╗████╗  ██║██║  ╚██╗ ██╔╝  ║
    ║   ██║   ██║██████╔╝███████╗    ██║   ██║██╔██╗ ██║██║   ╚████╔╝   ║
    ║   ╚██╗ ██╔╝██╔═══╝ ╚════██║    ██║   ██║██║╚██╗██║██║    ╚██╔╝    ║
    ║    ╚████╔╝ ██║     ███████║    ╚██████╔╝██║ ╚████║███████╗██║     ║
    ║     ╚═══╝  ╚═╝     ╚══════╝     ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝     ║
    ║                                                  ║
    ║              PTERODACTYL INSTALLER               ║
    ║                   By JianCode                    ║
    ║                                                  ║
    ╚══════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

loading_bar() {
    local duration=${1}
    local message=${2}
    echo -ne "${CYAN}${message}${NC} "
    for i in $(seq 1 20); do
        echo -ne "${GREEN}▓${NC}"
        sleep $(echo "$duration / 20" | bc -l)
    done
    echo -e " ${GREEN}✓${NC}"
}

spinner() {
    local pid=$1
    local message=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %10 ))
        printf "\r${CYAN}${message}${NC} ${YELLOW}${spin:$i:1}${NC}"
        sleep 0.1
    done
    printf "\r${CYAN}${message}${NC} ${GREEN}✓${NC}\n"
}

create_subdomain() {
    local subdomain=$1
    local domain=$2
    local ip=$3
    
    local zone_id=$(echo $CLOUDFLARE_ZONES | jq -r --arg domain "$domain" '.[$domain].zone')
    local api_token=$(echo $CLOUDFLARE_ZONES | jq -r --arg domain "$domain" '.[$domain].token')
    
    if [ "$zone_id" == "null" ] || [ "$api_token" == "null" ]; then
        echo -e "${RED}Domain tidak ditemukan dalam konfigurasi!${NC}"
        return 1
    fi
    
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records" \
        -H "Authorization: Bearer ${api_token}" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"${subdomain}\",\"content\":\"${ip}\",\"ttl\":120,\"proxied\":false}" > /dev/null
    
    echo -e "${GREEN}Subdomain ${subdomain}.${domain} berhasil dibuat!${NC}"
}

random_pass() {
    tr -dc A-Za-z0-9 </dev/urandom | head -c 16
}

install_panel() {
    show_ascii
    echo -e "${YELLOW}┌─────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│${NC}  ${CYAN}INSTALL PANEL PTERODACTYL${NC}         ${YELLOW}│${NC}"
    echo -e "${YELLOW}└─────────────────────────────────────────┘${NC}"
    echo ""
    
    read -p "$(echo -e ${CYAN}Masukkan IP VPS: ${NC})" IPVPS
    read -p "$(echo -e ${CYAN}Pilih domain \(1-15\): ${NC})" DOMAIN_CHOICE
    
    DOMAINS=("pterodactyl-panel.web.id" "storedigital.web.id" "storeid.my.id" "xyro.web.id" "xyroku.my.id" "gacorr.biz.id" "cafee.my.id" "pterodaytl.my.id" "googlex.my.id" "heavencraft.my.id" "hilman-store.web.id" "hilmanofficial.tech" "hilmanzoffc.web.id" "host-panel.web.id" "hostingers-vvip.my.id")
    
    MAIN_DOMAIN=${DOMAINS[$((DOMAIN_CHOICE-1))]}
    
    read -p "$(echo -e ${CYAN}Masukkan subdomain panel: ${NC})" SUBDOMAIN_PANEL
    read -p "$(echo -e ${CYAN}Masukkan subdomain node: ${NC})" SUBDOMAIN_NODE
    
    DOMAIN_PANEL="${SUBDOMAIN_PANEL}.${MAIN_DOMAIN}"
    DOMAIN_NODE="${SUBDOMAIN_NODE}.${MAIN_DOMAIN}"
    
    PASSWORD_ADMIN=$(random_pass)
    
    echo ""
    loading_bar 2 "Membuat subdomain panel"
    create_subdomain "$SUBDOMAIN_PANEL" "$MAIN_DOMAIN" "$IPVPS"
    
    loading_bar 2 "Membuat subdomain node"
    create_subdomain "$SUBDOMAIN_NODE" "$MAIN_DOMAIN" "$IPVPS"
    
    echo ""
    echo -e "${GREEN}┌─────────────────────────────────────────┐${NC}"
    echo -e "${GREEN}│${NC}  ${CYAN}MEMULAI INSTALASI PANEL${NC}            ${GREEN}│${NC}"
    echo -e "${GREEN}└─────────────────────────────────────────┘${NC}"
    echo ""
    
    loading_bar 3 "Mengunduh script installer"
    
    (
        bash <(curl -s https://pterodactyl-installer.se) <<EOF
0
y

admin
admin
Asia/Jakarta
admin@gmail.com
admin@gmail.com
admin
admin
admin
${PASSWORD_ADMIN}
${DOMAIN_PANEL}
y
y
1
y
y
y
A
EOF
    ) &
    spinner $! "Menginstall Panel Pterodactyl"
    
    sleep 5
    
    echo ""
    echo -e "${GREEN}┌─────────────────────────────────────────┐${NC}"
    echo -e "${GREEN}│${NC}  ${CYAN}MEMULAI INSTALASI WINGS${NC}            ${GREEN}│${NC}"
    echo -e "${GREEN}└─────────────────────────────────────────┘${NC}"
    echo ""
    
    (
        bash <(curl -s https://pterodactyl-installer.se) <<EOF
1
y
${DOMAIN_PANEL}
admin
admin
${DOMAIN_NODE}
admin@gmail.com
EOF
    ) &
    spinner $! "Menginstall Wings Pterodactyl"
    
    sleep 5
    
    echo ""
    echo -e "${GREEN}┌─────────────────────────────────────────┐${NC}"
    echo -e "${GREEN}│${NC}  ${CYAN}MEMBUAT NODE PTERODACTYL${NC}           ${GREEN}│${NC}"
    echo -e "${GREEN}└─────────────────────────────────────────┘${NC}"
    echo ""
    
    read -p "$(echo -e ${CYAN}Masukkan RAM Server \(MB\): ${NC})" RAM_SERVER
    
    (
        bash <(curl -s https://raw.githubusercontent.com/SkyzoOffc/Pterodactyl-Theme-Autoinstaller/main/createnode.sh) <<EOF
Singapore
Node By JianCode
${DOMAIN_NODE}
JianNode
${RAM_SERVER}
${RAM_SERVER}
1
EOF
    ) &
    spinner $! "Membuat Node Pterodactyl"
    
    sleep 3
    
    clear
    show_ascii
    echo -e "${GREEN}┌──────────────────────────────────────────────────┐${NC}"
    echo -e "${GREEN}│${NC}  ${CYAN}INSTALASI SELESAI!${NC}                          ${GREEN}│${NC}"
    echo -e "${GREEN}├──────────────────────────────────────────────────┤${NC}"
    echo -e "${GREEN}│${NC}  ${YELLOW}Detail Panel:${NC}                               ${GREEN}│${NC}"
    echo -e "${GREEN}│${NC}  ${CYAN}URL:${NC} https://${DOMAIN_PANEL}              ${GREEN}│${NC}"
    echo -e "${GREEN}│${NC}  ${CYAN}Username:${NC} admin                           ${GREEN}│${NC}"
    echo -e "${GREEN}│${NC}  ${CYAN}Password:${NC} ${PASSWORD_ADMIN}               ${GREEN}│${NC}"
    echo -e "${GREEN}├──────────────────────────────────────────────────┤${NC}"
    echo -e "${GREEN}│${NC}  ${YELLOW}Detail Node:${NC}                                ${GREEN}│${NC}"
    echo -e "${GREEN}│${NC}  ${CYAN}Domain:${NC} ${DOMAIN_NODE}                     ${GREEN}│${NC}"
    echo -e "${GREEN}│${NC}  ${CYAN}RAM:${NC} ${RAM_SERVER} MB                      ${GREEN}│${NC}"
    echo -e "${GREEN}└──────────────────────────────────────────────────┘${NC}"
    echo ""
}

uninstall_panel() {
    show_ascii
    echo -e "${RED}┌─────────────────────────────────────────┐${NC}"
    echo -e "${RED}│${NC}  ${CYAN}UNINSTALL PANEL PTERODACTYL${NC}       ${RED}│${NC}"
    echo -e "${RED}└─────────────────────────────────────────┘${NC}"
    echo ""
    
    read -p "$(echo -e ${YELLOW}Yakin ingin uninstall? \(y/n\): ${NC})" CONFIRM
    
    if [ "$CONFIRM" != "y" ]; then
        echo -e "${CYAN}Batal uninstall${NC}"
        return
    fi
    
    echo ""
    loading_bar 2 "Memulai proses uninstall"
    
    (
        bash <(curl -s https://pterodactyl-installer.se) <<EOF
6
y

EOF
    ) &
    spinner $! "Menghapus Panel Pterodactyl"
    
    sleep 3
    
    clear
    show_ascii
    echo -e "${GREEN}┌─────────────────────────────────────────┐${NC}"
    echo -e "${GREEN}│${NC}  ${CYAN}UNINSTALL BERHASIL!${NC}                ${GREEN}│${NC}"
    echo -e "${GREEN}└─────────────────────────────────────────┘${NC}"
    echo ""
}

main_menu() {
    while true; do
        show_ascii
        echo -e "${CYAN}┌──────────────────────────────────────────┐${NC}"
        echo -e "${CYAN}│${NC}  ${YELLOW}MENU UTAMA${NC}                           ${CYAN}│${NC}"
        echo -e "${CYAN}├──────────────────────────────────────────┤${NC}"
        echo -e "${CYAN}│${NC}  ${GREEN}1.${NC} Install Panel + Wings + Node      ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC}  ${GREEN}2.${NC} Uninstall Panel                   ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC}  ${GREEN}3.${NC} Keluar                            ${CYAN}│${NC}"
        echo -e "${CYAN}└──────────────────────────────────────────┘${NC}"
        echo ""
        read -p "$(echo -e ${YELLOW}Pilih menu: ${NC})" MENU_CHOICE
        
        case $MENU_CHOICE in
            1)
                install_panel
                read -p "$(echo -e ${CYAN}Tekan enter untuk kembali...${NC})"
                ;;
            2)
                uninstall_panel
                read -p "$(echo -e ${CYAN}Tekan enter untuk kembali...${NC})"
                ;;
            3)
                echo -e "${GREEN}Terima kasih!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Pilihan tidak valid!${NC}"
                sleep 2
                ;;
        esac
    done
}

if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}Installing jq...${NC}"
    apt-get update -y && apt-get install -y jq
fi

main_menu
