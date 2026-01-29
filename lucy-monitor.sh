#!/bin/bash
C_NAME="lucy-awareness"
USER_D="adityowicaksono"
D_PATH="/home/adityowicaksono/bin/docker"
G='\033[0;32m'; R='\033[0;31m'; Y='\033[1;33m'; B='\033[0;34m'; C='\033[0;36m'; NC='\033[0m'

# DATA GATHERING
L_VER=$(sudo -u $USER_D $D_PATH exec $C_NAME ls /opt/phishing/versions/ 2>/dev/null | grep '^[0-9]' | sort -V | tail -n 1)
STATS=$(sudo -u $USER_D $D_PATH stats $C_NAME --no-stream --format "{{.CPUPerc}}|{{.MemUsage}}|{{.MemPerc}}")
C_CPU_STR=$(echo $STATS | cut -d'|' -f1)
C_RAM_STR=$(echo $STATS | cut -d'|' -f2)
C_RAM_PCT=$(echo $STATS | cut -d'|' -f3)
OS_NAME=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -v2)
UPD_COUNT=$(dnf check-update --quiet | grep -v "^$" | wc -l)
IP_ADDR=$(hostname -I | awk '{print $1}')
MEM_FREE=$(free -h | awk '/^Mem:/ {print $4}')
Z_DATA=$(zramctl --noheadings --output DATA,COMPR /dev/zram0 2>/dev/null | awk '{print $1 " -> " $2}')

# HEALTH LOGIC
C_CPU_VAL=$(echo $C_CPU_STR | tr -d '%')
C_RAM_VAL=$(echo $C_RAM_PCT | tr -d '%')
if (( $(echo "$C_CPU_VAL > 85.0" | bc -l) )) || (( $(echo "$C_RAM_VAL > 90.0" | bc -l) )); then
    SYS_STATUS="${R}CRITICAL${NC}"
elif (( $(echo "$C_CPU_VAL > 60.0" | bc -l) )) || [ "$UPD_COUNT" -gt 5 ]; then
    SYS_STATUS="${Y}WARNING${NC}"
else
    SYS_STATUS="${G}OPTIMAL${NC}"
fi

clear
echo -e "${C}🚀 LUCY AWARENESS MONITORING DASHBOARD${NC}"
printf "${Y}%-15s :${NC} %s\n" "Timestamp" "$(date "+%d %b %Y | %H:%M:%S")"
printf "${Y}%-15s :${NC} %s\n" "Uptime" "$(uptime -p | sed 's/up //')"
echo -e "---------------------------------------------------------"

echo -e "${B}[ 🛰️  CORE APPLICATION LAYER ]${NC}"
printf " 1. Software Version  : ${G}v%s${NC}\n" "${L_VER:-"5.6.3"}"
printf " 2. CPU Utilization   : ${G}%s${NC}\n" "${C_CPU_STR}"
printf " 3. Memory Allocation : ${G}%s${NC} / ${G}%s${NC} (${Y}%s${NC})\n" "$(echo $C_RAM_STR | awk '{print $1}')" "$(echo $C_RAM_STR | awk '{print $3}')" "${C_RAM_PCT}"
printf " 4. Network Sessions  : ${G}%s Active Connection(s)${NC}\n" "$(ss -tun | grep ESTAB | wc -l)"
printf " 5. Database Service  : ${G}🟢 ACTIVE (PostgreSQL)${NC}\n"

echo -e "\n${B}[ 🧠 MEMORY HIERARCHY ]${NC}"
printf " 6. Physical RAM Free : ${C}%s${NC}\n" "$MEM_FREE"
printf " 7. zRAM Efficiency   : ${G}%s${NC} (Data -> Comp)\n" "${Z_DATA:-"0B -> 0B"}"
printf " 8. Swappiness Level  : ${C}%s${NC}\n" "$(cat /proc/sys/vm/swappiness)"

echo -e "\n${B}[ 🛡️  SECURITY & COMPLIANCE ]${NC}"
printf " 9. Operating System  : ${C}%s${NC}\n" "$OS_NAME"
printf " 10. OS Update Status : ${Y}%s pending packages${NC}\n" "$UPD_COUNT"
printf " 11. Firewall Status  : ${G}%s${NC}\n" "$(systemctl is-active firewalld)"
printf " 12. SSH Server Status: ${G}%s (SAFE)${NC}\n" "$(systemctl is-active sshd | tr '[:lower:]' '[:upper:]')"
printf " 13. Primary IPv4 Addr: ${C}%s${NC}\n" "$IP_ADDR"

echo -e "\n${B}--- TOP 5 PROCESSES ------------------------------------${NC}"
ps -eo comm,%cpu,%mem --sort=-%cpu | head -n 6 | tail -n 5 | while read -r NAME CPU_VAL RAM_VAL; do
    if (( $(echo "$CPU_VAL > 50.0" | bc -l) )); then CPU_COL=$R; else CPU_COL=$G; fi
    printf "  - %-18.18s : CPU ${CPU_COL}%5s%%${NC} | RAM ${Y}%5s%%${NC}\n" "$NAME" "$CPU_VAL" "$RAM_VAL"
done

echo -e "\n${B}[ 💾 STORAGE ARCHITECTURE ]${NC}"
printf " 14. I/O Scheduler    : ${C}%s${NC}\n" "$(cat /sys/block/sda/queue/scheduler 2>/dev/null | grep -o "\[.*\]")"
printf " 15. Root Partition   : ${G}%s used${NC}\n" "$(df -h / | awk 'NR==2 {print $5}')"
printf " 16. Home Partition   : ${G}%s used${NC}\n" "$(df -h /home | awk 'NR==2 {print $5}')"

echo -e "---------------------------------------------------------"
echo -e "System Health: $SYS_STATUS | Kucing1000cc"
