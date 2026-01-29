# 🚀 LUCY Awareness Hardened Monitoring Stack
**Infrastructure Standard for PT Seraphim Digital Technology**

Panduan instalasi dan optimasi Lucy Awareness pada Oracle Linux 10 menggunakan Docker Rootless.

---

## 🛠️ I. SYSTEM TUNING
Langkah optimasi kernel dan memory tiering:

1. I/O Scheduler:
echo "mq-deadline" | sudo tee /sys/block/sda/queue/scheduler

2. Memory (zRAM):
sudo dnf install zram-generator -y
sudo bash -c 'cat <<EOF > /etc/systemd/zram-generator.conf
[zram0]
zram-size = min(ram / 1, 8192)
compression-algorithm = zstd
swap-priority = 100
EOF'

3. Swappiness:
echo "vm.swappiness=100" | sudo tee -a /etc/sysctl.d/99-zram.conf
sudo sysctl --system

---

## 📦 II. DOCKER ROOTLESS & DEPLOYMENT
1. Install Docker Rootless:
sudo dnf install -y dbus-user-session fuse-overlayfs slirp4netns
curl -fsSL https://get.docker.com/rootless | sh

2. Set Environment (~/.bashrc):
export PATH=/home/<username_lu>/bin:$PATH
export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock

3. Linger & Deploy Lucy:
sudo loginctl enable-linger <username_lu>

docker run -d \
  --name lucy-awareness \
  --restart always \
  -p 8080:80 \
  -p 8443:443 \
  -v /home/<username_lu>/lucy/data:/opt/phishing/files \
  -v /home/<username_lu>/lucy/logs:/opt/phishing/logs \
  lucysecurity/lucy:latest

---

## 🛰️ III. MONITORING SETUP
Gunakan script lucy-monitor.sh untuk memantau kesehatan sistem.

1. Move script:
sudo cp lucy-monitor.sh /usr/local/lib/.lucy-monitor-internal.sh
sudo chown root:root /usr/local/lib/.lucy-monitor-internal.sh
sudo chmod 700 /usr/local/lib/.lucy-monitor-internal.sh

2. Create Command:
sudo bash -c 'cat <<EOF > /usr/local/bin/lucy-monitor
#!/bin/bash
sudo /usr/local/lib/.lucy-monitor-internal.sh
EOF'
sudo chmod +x /usr/local/bin/lucy-monitor

3. Passwordless Sudo (via visudo):
<username_lu> ALL=(ALL) NOPASSWD: /usr/local/lib/.lucy-monitor-internal.sh

---

## 🔧 IV. MAINTENANCE & PERMISSION FIX
Jika muncul error "Exception Error writing to file", jalankan:

sudo -u <username_lu> /home/<username_lu>/bin/docker exec -u root lucy-awareness chown -R www-data:www-data /opt/phishing/files/assets/
sudo -u <username_lu> /home/<username_lu>/bin/docker exec -u root lucy-awareness chmod -R 775 /opt/phishing/files/assets/

---
**Maintainer: Kucing1000cc**
