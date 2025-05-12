#!/usr/bin/env bash
source "$(dirname "$0")/liblog.sh"
log blue  "Adding Hailo repository & key…"
wget -qO - https://hailo.ai/developer-zone/apt/public.key | apt-key add -
echo "deb [arch=arm64] https://hailo.ai/developer-zone/apt/ stable main" \
  | tee /etc/apt/sources.list.d/hailo.list
apt update
log blue  "Installing HailoRT 4.x and example pipelines…"
apt install -y hailort hailort-examples
log blue  "Loading PCIe overlay for the AI HAT"
grep -q '^dtoverlay=pci' /boot/firmware/config.txt || \
  echo 'dtoverlay=pci' >> /boot/firmware/config.txt
log green "Reboot now and run: hailortcli run --model yolov8n.hef"
