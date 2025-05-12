#!/usr/bin/env bash
# run_all.sh ─ Kick-off launcher for Drone RPi5 setup
# ---------------------------------------------------
# Prerequisites:  the numbered scripts (1_…8_) and liblog.sh
#                 sit in the SAME directory as this file.
# Usage: sudo ./run_all.sh

set -euo pipefail

##### 1. make sure we have root privileges ##############################
if [[ $EUID -ne 0 ]]; then
  echo -e "\e[31m[ERROR] Please run as root (e.g. sudo ./run_all.sh)\e[0m" >&2
  exit 1
fi

##### 2. find the folder this script lives in ##########################
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

##### 3. source the colour-logger ######################################
# falls back to plain echo if liblog.sh is missing
if [[ -f "${SCRIPT_DIR}/liblog.sh" ]]; then
  # shellcheck source=/dev/null
  source "${SCRIPT_DIR}/liblog.sh"
else
  log() { printf "[%s] %s\n" "$(date '+%F %T')" "$*"; }
fi

##### 4.  list the stage scripts in the order you want #################
STAGES=(
  "1_docker.sh"
  "2_remote_connection.sh"
  "3_AI_hat.sh"
  "4_gpio.sh"
  "5_camera_imx477.sh"
  "6_utils.sh"
  "7_ROS2_Jazzy.sh"
  "8_uart_fc.sh"
)

##### 5.  run them one by one ##########################################
for stage in "${STAGES[@]}"; do
  FILE="${SCRIPT_DIR}/${stage}"
  if [[ ! -f "$FILE" ]]; then
    log red  "[SKIP] $stage not found – skipping"
    continue
  fi
  log blue ">>> running $stage"
  if [[ -x "$FILE" ]]; then
    "$FILE"
  else
    bash "$FILE"
  fi
  log green "<<< finished $stage"
done

##### 6.  done ##########################################################
log green "🎉  All setup stages completed successfully"

