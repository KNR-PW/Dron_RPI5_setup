#!/usr/bin/env bash
sudo mmcli -L

# 2. zaloguj go do sieci z właściwym APN
sudo mmcli -m 0 --simple-connect="apn=internet"

# 3. podnieś interfejs i pobierz adres
IF=$(ip -brief link | awk '/^wwx/{print $1; exit}')
sudo ip link set "$IF" up
sudo dhclient -v "$IF"

# (opcjonalnie) 4. ustaw modem jako główną bramę
sudo ip route add default dev "$IF" metric 100

