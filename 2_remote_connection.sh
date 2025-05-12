
#!/usr/bin/env bash
source "$(dirname "$0")/liblog.sh"
log blue  "Installing Raspberry Pi Connect service…"
echo "deb http://archive.raspberrypi.com/debian/ bookworm main" \
  | tee /etc/apt/sources.list.d/raspi-connect.list
curl -fsSL https://archive.raspberrypi.com/debian/pubkey.gpg | tee /usr/share/keyrings/raspi.gpg
apt update
apt install -y rpi-connect
log blue  "Linking device with your Raspberry Pi ID (opens URL)…"
rpi-connect signin
log green "Pi Connect is now running – open https://connect.raspberrypi.com"
