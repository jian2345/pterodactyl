#!/bin/bash

CORRECT_PASSWORD=$(echo "SmlhbkNvZGUjMzEy" | base64 -d)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

declare -A SUBDOMAIN_ZONES
declare -A SUBDOMAIN_TOKENS

SUBDOMAIN_ZONES=(
    ["pterodactyl-panel.web.id"]="d69feb7345d9e4dd5cfd7cce29e7d5b0"
    ["storedigital.web.id"]="2ce8a2f880534806e2f463e3eec68d31"
    ["storeid.my.id"]="c651c828a01962eb3c530513c7ad7dcf"
    ["store-panell.my.id"]="0189ecfadb9cf2c4a311c0a3ec8f0d5c"
    ["xyro.web.id"]="46d0cd33a7966f0be5afdab04b63e695"
    ["xyroku.my.id"]="f6d1a73a272e6e770a232c39979d5139"
    ["gacorr.biz.id"]="cff22ce1965394f1992c8dba4c3db539"
    ["cafee.my.id"]="0d7044fc3e0d66189724952fa3b850ce"
    ["pterodaytl.my.id"]="828ef14600aaaa0b1ea881dd0e7972b2"
    ["googlex.my.id"]="dda9e25dac2556c7494470ee6152fc7f"
    ["heavencraft.my.id"]="9e7239dcda7cbd6be79d7615257f56f8"
    ["hilman-store.web.id"]="4e214dfe36faa7c942bc68b5aecdd1e9"
    ["hilmanofficial.tech"]="c8705bfbfdca9c4e8e61eb2663ee87d6"
    ["hilmanzoffc.web.id"]="2627badfda28951bfb936fce0febc5b0"
    ["host-panel.web.id"]="74b3192f7c3b0925cdb8606bb7db95c4"
    ["hostingers-vvip.my.id"]="2341ae01634b852230b7521af26c261f"
)

SUBDOMAIN_TOKENS=(
    ["pterodactyl-panel.web.id"]="32zZwadzwc7qB4mzuDBJkk1xFyoQ2Grr27mAfJcB"
    ["storedigital.web.id"]="v5_unJTqruXV_x-5uj0dT5_Q4QAPThJbXzC2MmOQ"
    ["storeid.my.id"]="N-D6fN6la7jY0AnvbWn9FcU6ZHuDitmFXd-JF04g"
    ["store-panell.my.id"]="eVI-BXIXNEQtBqLpdvuitAR5nXC2bLj6jw365JPZ"
    ["xyro.web.id"]="CygwSHXRSfZnsi1qZmyB8s4qHC12jX_RR4mTpm62"
    ["xyroku.my.id"]="0Mae_Rtx1ixGYenzFcNG9bbPd-rWjoRwqN2tvNzo"
    ["gacorr.biz.id"]="v9kYfj5g2lcacvBaJHA_HRgNqBi9UlsVy0cm_EhT"
    ["cafee.my.id"]="wAOEzAfvb-L3vKYE2Xg8svJpHfNS_u2noWSReSzJ"
    ["pterodaytl.my.id"]="75HrVBzSVObD611RkuNS1ZKsL5A_b8kuiCs26-f9"
    ["googlex.my.id"]="GuT5rNQSr_V2kxb-QZdJ4YbFlEvzE-upzhey9Ezl"
    ["heavencraft.my.id"]="aHvYYKk7YIADVOfpG3i1eaIqTeWCdPS25FAPreDQ"
    ["hilman-store.web.id"]="wpQCANKLRAtWb0XvTRed3vwSkOMMWKO2C75uwnKE"
    ["hilmanofficial.tech"]="hjqWa_eFAfoJNJyBu9WAlg8WO0ICtN5AYpZURgqe"
    ["hilmanzoffc.web.id"]="wZ3QAKn7zDx-tyb04HgCvmogqeM6je8jDNmiPZXq"
    ["host-panel.web.id"]="GuT5rNQSr_V2kxb-QZdJ4YbFlEvzE-upzhey9Ezl"
    ["hostingers-vvip.my.id"]="Ztw1ouD8_lJf-QzRecgmijjsDJODFU4b-y697lPw"
)

show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔═════════════════════════════════════════════════════╗"
    echo "║                                                     ║"
    echo "║   ███████╗██╗   ██╗██████╗ ██████╗  ██████╗       ║"
    echo "║   ██╔════╝██║   ██║██╔══██╗██╔══██╗██╔═══██╗      ║"
    echo "║   ███████╗██║   ██║██████╔╝██║  ██║██║   ██║      ║"
    echo "║   ╚════██║██║   ██║██╔══██╗██║  ██║██║   ██║      ║"
    echo "║   ███████║╚██████╔╝██████╔╝██████╔╝╚██████╔╝      ║"
    echo "║   ╚══════╝ ╚═════╝ ╚═════╝ ╚═════╝  ╚═════╝       ║"
    echo "║                                                     ║"
    echo "║     PTERODACTYL AUTO INSTALLER V3.0                 ║"
    echo "║          Created By VinnOfficial                    ║"
    echo "║                                                     ║"
    echo "╚═════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

loading_bar() {
    local duration=$1
    local message=$2
    local width=50
    echo -e "${YELLOW}${message}${NC}"
    for ((i=0; i<=width; i++)); do
        printf "\r${CYAN}["
        for ((j=0; j<i; j++)); do printf "█"; done
        for ((j=i; j<width; j++)); do printf " "; done
        printf "] %d%%" $((i*100/width))
        sleep $(awk "BEGIN {print $duration/$width}")
    done
    echo -e "${NC}"
}

check_password() {
    echo -e "${YELLOW}╔═════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║              AUTENTIKASI DIPERLUKAN                 ║${NC}"
    echo -e "${YELLOW}╚═════════════════════════════════════════════════════╝${NC}"
    echo -e -n "${CYAN}Masukkan Password: ${NC}"
    read -s password
    echo ""
    
    if [ "$password" != "$CORRECT_PASSWORD" ]; then
        echo -e "${RED}✗ Password Salah!${NC}\n"
        exit 1
    fi
    echo -e "${GREEN}✓ Autentikasi Berhasil!${NC}\n"
    sleep 1
}

list_domains() {
    echo -e "${CYAN}╔═════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           DAFTAR DOMAIN TERSEDIA                    ║${NC}"
    echo -e "${CYAN}╚═════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    counter=1
    for domain in "${!SUBDOMAIN_ZONES[@]}"; do
        echo -e "${YELLOW}  $counter.${NC} $domain"
        counter=$((counter + 1))
    done
    echo ""
}

create_subdomain() {
    local host=$1
    local ip=$2
    local domain=$3
    local zone=${SUBDOMAIN_ZONES[$domain]}
    local token=${SUBDOMAIN_TOKENS[$domain]}
    
    local clean_host=$(echo "$host" | sed 's/[^a-z0-9.-]//gi')
    local clean_ip=$(echo "$ip" | sed 's/[^0-9.]//g')
    
    local response=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zone/dns_records" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"$clean_host.$domain\",\"content\":\"$clean_ip\",\"ttl\":1,\"proxied\":false}")
    
    local success=$(echo "$response" | grep -o '"success":[^,]*' | cut -d':' -f2)
    
    if [ "$success" == "true" ]; then
        echo "SUCCESS|$clean_host.$domain|$clean_ip"
    else
        local error=$(echo "$response" | grep -o '"message":"[^"]*"' | cut -d'"' -f4 | head -1)
        echo "FAILED|$error"
    fi
}

install_panel() {
    echo ""
    echo -e -n "${CYAN}Format: ipvps|pwvps|panel.com|node.com|ramserver\n${NC}"
    echo -e -n "${CYAN}Masukkan data: ${NC}"
    read input
    
    if [[ ! "$input" =~ "|" ]]; then
        echo -e "${RED}\n✗ Format salah!\n${NC}"
        sleep 2
        main_menu
        return
    fi
    
    IFS='|' read -r ipvps pwvps paneldomain nodedomain ramserver <<< "$input"
    ipvps=$(echo "$ipvps" | xargs)
    pwvps=$(echo "$pwvps" | xargs)
    paneldomain=$(echo "$paneldomain" | xargs)
    nodedomain=$(echo "$nodedomain" | xargs)
    ramserver=$(echo "$ramserver" | xargs)
    
    list_domains
    
    echo -e -n "${CYAN}Pilih nomor domain: ${NC}"
    read domain_choice
    
    counter=1
    selected_domain=""
    for domain in "${!SUBDOMAIN_ZONES[@]}"; do
        if [ "$counter" == "$domain_choice" ]; then
            selected_domain=$domain
            break
        fi
        counter=$((counter + 1))
    done
    
    if [ -z "$selected_domain" ]; then
        echo -e "${RED}\n✗ Domain tidak ditemukan!\n${NC}"
        sleep 2
        main_menu
        return
    fi
    
    panel_host=$(echo "$paneldomain" | cut -d'.' -f1)
    node_host=$(echo "$nodedomain" | cut -d'.' -f1)
    
    echo ""
    loading_bar 2 "⏳ Membuat subdomain node..."
    result_node=$(create_subdomain "$node_host" "$ipvps" "$selected_domain")
    
    loading_bar 2 "⏳ Membuat subdomain panel..."
    result_panel=$(create_subdomain "$panel_host" "$ipvps" "$selected_domain")
    
    echo ""
    
    if [[ "$result_node" == SUCCESS* ]]; then
        IFS='|' read -r status node_subdomain node_ip <<< "$result_node"
        echo -e "${GREEN}✅ Sukses membuat Subdomain!${NC}"
        echo ""
        echo -e "🌐 sᴜʙᴅᴏᴍᴀɪɴ: ${YELLOW}$node_subdomain${NC}"
        echo -e "📌 ɪᴘ ᴠᴘs: ${YELLOW}$node_ip${NC}"
        echo ""
    fi
    
    if [[ "$result_panel" == SUCCESS* ]]; then
        IFS='|' read -r status panel_subdomain panel_ip <<< "$result_panel"
        echo -e "${GREEN}✅ Sukses membuat Subdomain!${NC}"
        echo ""
        echo -e "🌐 sᴜʙᴅᴏᴍᴀɪɴ: ${YELLOW}$panel_subdomain${NC}"
        echo -e "📌 ɪᴘ ᴠᴘs: ${YELLOW}$panel_ip${NC}"
        echo ""
    fi
    
    echo -e "${BLUE}╔═════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║         MEMULAI INSTALASI PTERODACTYL               ║${NC}"
    echo -e "${BLUE}╚═════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [[ "$result_panel" == SUCCESS* ]] && [[ "$result_node" == SUCCESS* ]]; then
        IFS='|' read -r status panel_subdomain panel_ip <<< "$result_panel"
        IFS='|' read -r status node_subdomain node_ip <<< "$result_node"
        
        loading_bar 3 "⏳ Menghubungkan ke VPS..."
        
        echo -e "${CYAN}📦 Menginstall Panel Pterodactyl...${NC}"
        echo -e "${YELLOW}⏳ Proses ini memakan waktu 10-20 menit${NC}\n"
        
        sshpass -p "$pwvps" ssh -o StrictHostKeyChecking=no root@$ipvps << EOF
bash <(curl -s https://pterodactyl-installer.se) <<INSTALLER
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
admin001
$panel_subdomain
y
y
1
y
y
y
y
A
INSTALLER

sleep 5

bash <(curl -s https://pterodactyl-installer.se) <<WINGS
1
y
$panel_subdomain
admin
admin
$node_subdomain
admin@gmail.com
WINGS

sleep 5

bash <(curl -s https://raw.githubusercontent.com/SkyzoOffc/Pterodactyl-Theme-Autoinstaller/main/createnode.sh) <<NODESETUP
Singapore
Node By Skyzo
$node_subdomain
Skyzopedia
$ramserver
$ramserver
1
NODESETUP

EOF
        
        if [ $? -eq 0 ]; then
            echo ""
            echo -e "${GREEN}╔═════════════════════════════════════════════════════╗${NC}"
            echo -e "${GREEN}║       INSTALASI PANEL BERHASIL DISELESAIKAN         ║${NC}"
            echo -e "${GREEN}╚═════════════════════════════════════════════════════╝${NC}"
            echo ""
            echo -e "${CYAN}📦 DETAIL AKUN PANEL PTERODACTYL${NC}"
            echo ""
            echo -e "👤 Username  : ${YELLOW}admin${NC}"
            echo -e "🔐 Password  : ${YELLOW}admin001${NC}"
            echo -e "🌐 URL Panel : ${YELLOW}https://$panel_subdomain${NC}"
            echo -e "🖥️  URL Node  : ${YELLOW}https://$node_subdomain${NC}"
            echo ""
            echo -e "${MAGENTA}⚠️  PENTING:${NC}"
            echo -e "• Login ke panel untuk mengatur allocation"
            echo -e "• Ambil token node dari panel"
            echo -e "• Jalankan: ${CYAN}./script.sh${NC} > Menu 4 untuk start wings"
            echo ""
            echo -e "${GREEN}╚═════════════════════════════════════════════════════╝${NC}"
        else
            echo -e "${RED}✗ Instalasi gagal! Periksa koneksi SSH${NC}"
        fi
    else
        echo -e "${RED}✗ Gagal membuat subdomain, instalasi dibatalkan${NC}"
    fi
    
    echo ""
    echo -e -n "${YELLOW}Tekan Enter untuk kembali...${NC}"
    read
    main_menu
}

start_wings() {
    echo ""
    echo -e -n "${CYAN}Format: ipvps|pwvps|token_node\n${NC}"
    echo -e -n "${CYAN}Masukkan data: ${NC}"
    read input
    
    if [[ ! "$input" =~ "|" ]]; then
        echo -e "${RED}\n✗ Format salah!\n${NC}"
        sleep 2
        main_menu
        return
    fi
    
    IFS='|' read -r ipvps pwvps token <<< "$input"
    ipvps=$(echo "$ipvps" | xargs)
    pwvps=$(echo "$pwvps" | xargs)
    token=$(echo "$token" | xargs)
    
    echo ""
    loading_bar 2 "⏳ Menghubungkan ke VPS..."
    
    sshpass -p "$pwvps" ssh -o StrictHostKeyChecking=no root@$ipvps << EOF
$token
systemctl start wings
EOF
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}╔═════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║         WINGS BERHASIL DIJALANKAN                   ║${NC}"
        echo -e "${GREEN}╚═════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN}✓ Wings node panel pterodactyl telah aktif${NC}"
        echo ""
    else
        echo -e "${RED}✗ Gagal menjalankan wings${NC}"
    fi
    
    echo ""
    echo -e -n "${YELLOW}Tekan Enter untuk kembali...${NC}"
    read
    main_menu
}

uninstall_panel() {
    echo ""
    echo -e -n "${CYAN}Format: ipvps|pwvps\n${NC}"
    echo -e -n "${CYAN}Masukkan data: ${NC}"
    read input
    
    if [[ ! "$input" =~ "|" ]]; then
        echo -e "${RED}\n✗ Format salah!\n${NC}"
        sleep 2
        main_menu
        return
    fi
    
    IFS='|' read -r ipvps pwvps <<< "$input"
    ipvps=$(echo "$ipvps" | xargs)
    pwvps=$(echo "$pwvps" | xargs)
    
    echo ""
    loading_bar 2 "⏳ Menghapus Pterodactyl Panel..."
    
    sshpass -p "$pwvps" ssh -o StrictHostKeyChecking=no root@$ipvps << EOF
bash <(curl -s https://pterodactyl-installer.se) <<UNINSTALL
6
y

UNINSTALL
EOF
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}╔═════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║      PTERODACTYL PANEL BERHASIL DIHAPUS             ║${NC}"
        echo -e "${GREEN}╚═════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN}📍 VPS: ${YELLOW}$ipvps${NC}"
        echo ""
    else
        echo -e "${RED}✗ Gagal menghapus panel${NC}"
    fi
    
    echo ""
    echo -e -n "${YELLOW}Tekan Enter untuk kembali...${NC}"
    read
    main_menu
}

create_subdomain_only() {
    echo ""
    echo -e -n "${CYAN}Format: hostname|ip\n${NC}"
    echo -e -n "${CYAN}Masukkan data: ${NC}"
    read input
    
    if [[ ! "$input" =~ "|" ]]; then
        echo -e "${RED}\n✗ Format salah!\n${NC}"
        sleep 2
        main_menu
        return
    fi
    
    IFS='|' read -r host ip <<< "$input"
    host=$(echo "$host" | xargs)
    ip=$(echo "$ip" | xargs)
    
    list_domains
    
    echo -e -n "${CYAN}Pilih nomor domain: ${NC}"
    read domain_choice
    
    counter=1
    selected_domain=""
    for domain in "${!SUBDOMAIN_ZONES[@]}"; do
        if [ "$counter" == "$domain_choice" ]; then
            selected_domain=$domain
            break
        fi
        counter=$((counter + 1))
    done
    
    if [ -z "$selected_domain" ]; then
        echo -e "${RED}\n✗ Domain tidak ditemukan!\n${NC}"
        sleep 2
        main_menu
        return
    fi
    
    echo ""
    loading_bar 2 "⏳ Membuat subdomain node..."
    result_node=$(create_subdomain "node" "$ip" "$selected_domain")
    
    loading_bar 2 "⏳ Membuat subdomain utama..."
    result_main=$(create_subdomain "$host" "$ip" "$selected_domain")
    
    echo ""
    echo -e "${GREEN}╔═════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       SUBDOMAIN BERHASIL DIBUAT                     ║${NC}"
    echo -e "${GREEN}╚═════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [[ "$result_node" == SUCCESS* ]]; then
        IFS='|' read -r status subdomain vps_ip <<< "$result_node"
        echo -e "${GREEN}✅ Sukses membuat Subdomain!${NC}"
        echo ""
        echo -e "🌐 sᴜʙᴅᴏᴍᴀɪɴ: ${YELLOW}$subdomain${NC}"
        echo -e "📌 ɪᴘ ᴠᴘs: ${YELLOW}$vps_ip${NC}"
        echo ""
    fi
    
    if [[ "$result_main" == SUCCESS* ]]; then
        IFS='|' read -r status subdomain vps_ip <<< "$result_main"
        echo -e "${GREEN}✅ Sukses membuat Subdomain!${NC}"
        echo ""
        echo -e "🌐 sᴜʙᴅᴏᴍᴀɪɴ: ${YELLOW}$subdomain${NC}"
        echo -e "📌 ɪᴘ ᴠᴘs: ${YELLOW}$vps_ip${NC}"
        echo ""
    fi
    
    echo -e "${GREEN}╚═════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e -n "${YELLOW}Tekan Enter untuk kembali...${NC}"
    read
    main_menu
}

main_menu() {
    show_banner
    
    echo -e "${MAGENTA}╔═════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║                   MENU UTAMA                        ║${NC}"
    echo -e "${MAGENTA}╠═════════════════════════════════════════════════════╣${NC}"
    echo -e "║  ${YELLOW}1.${NC} Install Panel Pterodactyl (Auto Domain)        ║"
    echo -e "║  ${YELLOW}2.${NC} Buat Subdomain + Node Saja                     ║"
    echo -e "║  ${YELLOW}3.${NC} Lihat Daftar Domain                            ║"
    echo -e "║  ${YELLOW}4.${NC} Start Wings Node                               ║"
    echo -e "║  ${YELLOW}5.${NC} Uninstall Panel Pterodactyl                    ║"
    echo -e "║  ${YELLOW}6.${NC} Keluar                                         ║"
    echo -e "${MAGENTA}╚═════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e -n "${CYAN}Pilih menu (1-6): ${NC}"
    read choice
    
    case $choice in
        1)
            install_panel
            ;;
        2)
            create_subdomain_only
            ;;
        3)
            list_domains
            echo -e -n "${YELLOW}Tekan Enter untuk kembali...${NC}"
            read
            main_menu
            ;;
        4)
            start_wings
            ;;
        5)
            uninstall_panel
            ;;
        6)
            echo -e "${CYAN}\n👋 Terima kasih!\n${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}\n✗ Pilihan tidak valid!\n${NC}"
            sleep 1
            main_menu
            ;;
    esac
}

if ! command -v sshpass &> /dev/null; then
    echo -e "${YELLOW}⏳ Installing sshpass...${NC}"
    apt-get update > /dev/null 2>&1
    apt-get install -y sshpass > /dev/null 2>&1
    echo -e "${GREEN}✓ sshpass installed${NC}\n"
fi

check_password
main_menu
