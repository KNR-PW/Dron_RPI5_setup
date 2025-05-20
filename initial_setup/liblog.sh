
#!/usr/bin/env bash
# Simple colour logger – source this from the other scripts
log() {
    local colour="$1" ; shift
    local esc=""
    case "$colour" in
        red)   esc="\e[31m" ;;
        green) esc="\e[32m" ;;
        blue)  esc="\e[34m" ;;
        yellow)esc="\e[33m" ;;
        *)     esc="\e[0m"  ;;
    esac
    printf "%b[%(%F %T)T] %s%b\n" "$esc" -1 "$*" "\e[0m"
}
set -euo pipefail
