#!/usr/bin/env bash
source "$(dirname "$0")/liblog.sh"
log blue  "Installing libgpiod tools & Python bindings"
apt install -y gpiod python3-lgpio
log blue  "Adding udev rule for /dev/gpiochip ownership"
cat <<'EOF' >/etc/udev/rules.d/88-gpio.rules
SUBSYSTEM=="gpio", KERNEL=="gpiochip[0-9]*", GROUP="gpio", MODE="0660"
EOF
groupadd -f gpio
usermod -aG gpio "$USER"
udevadm control --reload-rules && udevadm trigger
log green "GPIO ready – try: gpioset --mode=time 0 18=1"
