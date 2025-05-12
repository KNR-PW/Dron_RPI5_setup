#!/usr/bin/env bash
source "$(dirname "$0")/liblog.sh"
log blue  "Enabling primary UART on GPIO 14/15 and disabling Bluetooth"
grep -q 'enable_uart=1' /boot/firmware/config.txt || \
  { echo 'enable_uart=1' >> /boot/firmware/config.txt
    echo 'dtoverlay=disable-bt' >> /boot/firmware/config.txt; }
log blue  "Installing MAVROS 2 and serial tools"
apt install -y ros-jazzy-mavros ros-jazzy-mavros-extras screen
log blue  "Creating systemd unit for uXRCE-DDS bridge"
cat <<'EOF' >/etc/systemd/system/px4_bridge.service
[Unit]
Description=PX4 ↔ ROS 2 micro-DDS bridge
After=network-online.target docker.service
Requires=docker.service

[Service]
ExecStart=/usr/bin/docker exec ros2_humble /opt/ros/humble/bin/microdds_agent \
          -t Serial -d /dev/serial0 -b 921600
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable px4_bridge.service
log green "UART and MAVLink bridge enabled – wire TELEM2 ↔ GPIO 14/15 and reboot"

