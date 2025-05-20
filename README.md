# Drone RPi 5 Setup

## 1  Podstawowa konfiguracja (basic setup)

1. Zainstaluj **Ubuntu 24.04.2 Desktop** za pomocą *Raspberry Pi Imager*.
2. Włóż kartę micro-SD do Raspberry Pi 5, podłącz zasilanie, mysz, klawiaturę i monitor.
3. Przejdź przez kreator pierwszego uruchomienia, ustawiając **hostname**, sieć Wi-Fi oraz hasło użytkownika.
4. **Zaktualizuj system:**

   ```bash
   sudo apt update && sudo apt full-upgrade -y
   ```
5. **Zainstaluj SSH:**

   ```bash
   sudo apt install openssh-server
   ```
6. **Włącz SSH przy starcie:**

   ```bash
   sudo systemctl enable --now ssh
   ```
7. Po chwili możesz się połączyć:

   ```bash
   ssh <hostname>@<IP>
   ```

## 2  Script overview

| Order | File                     | What it does (one sentence)                                                                                      |
| ----- | ------------------------ | ---------------------------------------------------------------------------------------------------------------- |
| 0     | `liblog.sh`              | Colourful, timestamped logger sourced by every script.                                                           |
| 1     | `1_docker.sh`            | Installs Docker Engine, builds the **inspekcja\:humble-pi5-v1** image and starts the `ros2_humble` container.    |
| 2     | `2_remote_connection.sh` | Installs **Raspberry Pi Connect** for browser-based remote desktop and signs in.                                 |
| 3     | `3_AI_hat.sh`            | Adds Hailo APT repo, installs HailoRT 4.x, loads the PCIe overlay for the 13 TOPS AI HAT.                        |
| 4     | `4_gpio.sh`              | Installs **libgpiod** CLI + Python bindings and sets udev rules/groups for non-root GPIO access.                 |
| 5     | `5_camera_imx477.sh`     | Builds **libcamera** & **rpicam-apps** from source, enables the IMX477 overlay and tests with `rpicam-hello`.    |
| 6     | `6_utils.sh`             | Pulls developer niceties: Neovim, Zsh, htop, neofetch and sets Zsh as default shell.                             |
| 7     | `7_ROS2_Jazzy.sh`        | Adds the official ROS 2 repository and installs **ros-jazzy-ros-base** binaries.                                 |
| 8     | `8_uart_fc.sh`           | Frees UART0, installs MAVROS 2, and creates a systemd unit that bridges PX4 ↔ ROS 2 via micro-DDS at 921 600 Bd. |
| •     | `run_all.sh`             | Orchestrator—runs the numbered scripts sequentially, stops on error and prints a green check when done.          |

All scripts are idempotent; you can rerun any of them safely after updates.



## 3  Quick start

```bash
a. git clone https://github.com/<YOUR-ORG>/Dron_RPI5_setup.git
b. cd Dron_RPI5_setup
c. chmod +x run_all.sh  # first time only
d. sudo ./run_all.sh    # grab a coffee ☕️
```

The orchestrator detects missing execute bits and fall

# connectivity

There are guides and scripts for setting up:

1. 4G modem
   1. 4G_modem_setup.md (one way of setting up)
   2. kondrad_setup_modem.txt(second way with connectivity problems after 5mins of connection)
2. tailscale vpn for nat traversal (global connectivity)
