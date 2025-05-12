#!/usr/bin/env bash
source "$(dirname "$0")/liblog.sh"
log blue  "Adding ROS 2 apt repo and GPG key"
apt install -y software-properties-common curl gnupg lsb-release
curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    | tee /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=arm64 signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
      http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" \
    | tee /etc/apt/sources.list.d/ros2.list
apt update
log blue  "Installing ROS 2 Jazzy base"
apt install -y ros-jazzy-ros-base
echo "source /opt/ros/jazzy/setup.bash" >> /etc/profile.d/ros2.sh
log green "ROS 2 Jazzy installed – open a new shell and type: ros2 run demo_nodes_cpp talker"

