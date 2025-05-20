#!/usr/bin/env bash
# modem_setup.sh – one‑shot configuration for Huawei E3276 on Ubuntu 24.04 (Raspberry Pi 5)
#
# Usage: sudo ./modem_setup.sh <APN> [interface]
#   APN        – required (e.g. internet, plus)
#   interface  – optional; defaults to first wwx… device found.
#
# Idempotent: you can run it again after reboot; it will skip steps that are already done.
set -euo pipefail

APN=${1:-}
if [[ -z "$APN" ]]; then
  echo "Usage: $0 <APN> [interface]" >&2
  exit 1
fi

# Step 1 . Install packages (skip if already present)
export DEBIAN_FRONTEND=noninteractive
apt update -qq
apt install -y modemmanager network-manager usb-modeswitch usb-modeswitch-data \
               isc-dhcp-client net-tools > /dev/null

# Step 2 . Optionally bump USB current limit (Pi 5)
CFG=/boot/firmware/config.txt
if ! grep -q '^usb_max_current_enable=1' "$CFG"; then
  echo 'usb_max_current_enable=1' >> "$CFG"
fi

# Step 3 . Wait for modem and make sure it is in 12d1:1506 mode
if lsusb | grep -q '12d1:14fe'; then
  usb_modeswitch -v 0x12d1 -p 0x14fe -R || true
  echo "☛ Switching modem from storage to NCM mode…"
  sleep 5
fi

# Step 4 . Connect via ModemManager (simple‑connect caches credentials)
mmcli -L | grep -q Modem || { echo "❌ No modem found" >&2; exit 1; }
modem=$(mmcli -L | awk -F '/' '{print $NF}')
state=$(mmcli -m "$modem" | awk '/state:/ {print $3}')
if [[ "$state" != "connected" ]]; then
  echo "☛ Attaching to network using APN $APN…"
  mmcli -m "$modem" --simple-connect="apn=$APN" || true
fi

# Step 5 . Bring interface UP and get DHCP lease
IFACE=${2:-$(ip -brief link | awk '/^wwx/{print $1; exit}')}
if [[ -z "$IFACE" ]]; then
  echo "❌ Could not detect network interface" >&2
  exit 1
fi
ip link set "$IFACE" up
if ! ip -4 addr show "$IFACE" | grep -q inet; then
  dhclient -v "$IFACE"
fi

# Step 6 . Prefer LTE route
ip route | grep -q "default dev $IFACE" || ip route add default dev "$IFACE" metric 100

# Step 7 . Disable Wi‑Fi until reboot (optional; comment to keep Wi‑Fi)
rfkill block wifi || true

echo "✅ Modem $IFACE is up. Public IP: $(curl -4 -s ifconfig.co)"

