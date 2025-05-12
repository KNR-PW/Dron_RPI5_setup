
#!/usr/bin/env bash
source "$(dirname "$0")/liblog.sh"
log blue  "Installing Docker (official convenience script)…"
curl -fsSL https://get.docker.com | sh      # installs engine & CLI
log blue  "Adding \"$USER\" to docker group"
usermod -aG docker "$USER"
log blue  "Building ROS 2 Humble image for Pi 5"
docker build -t inspekcja:humble-pi5-v1 "$(dirname "$0")/docker"
log blue  "Launching container (host networking, privileged, /dev bind)…"
docker run -dit --name ros2_humble --net=host --privileged \
           -v /dev:/dev inspekcja:humble-pi5-v1 bash
log green "Docker ready – reopen your shell to pick up new group"
