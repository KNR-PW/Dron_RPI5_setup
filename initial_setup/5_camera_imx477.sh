#!/usr/bin/env bash
source "$(dirname "$0")/liblog.sh"
log blue  "Installing build prerequisites for rpicam-apps & libcamera"
apt install -y clang meson ninja-build pkg-config libyaml-dev \
               libdw-dev libunwind-dev libudev-dev libgstreamer1.0-dev \
               libgstreamer-plugins-base1.0-dev libpython3-dev pybind11-dev \
               libevent-dev libtiff-dev qt6-base-dev qt6-tools-dev-tools
log blue  "Building libcamera"
git clone --depth=1 https://github.com/raspberrypi/libcamera.git
meson setup libcamera/build --buildtype=release -Dv4l2=true -Dgstreamer=enabled
ninja -C libcamera/build install
log blue  "Building rpicam-apps"
git clone --depth=1 https://github.com/raspberrypi/rpicam-apps.git
meson setup rpicam-apps/build -Denable_libav=enabled -Denable_egl=enabled
meson compile -C rpicam-apps/build && meson install -C rpicam-apps/build
log blue  "Enabling IMX477 overlays"
grep -q 'dtoverlay=imx477' /boot/firmware/config.txt || \
  { echo 'camera_auto_detect=0' >> /boot/firmware/config.txt
    echo 'dtoverlay=imx477,cam0' >> /boot/firmware/config.txt; }
log green "Camera installed – reboot and run: rpicam-hello --camera 0"

