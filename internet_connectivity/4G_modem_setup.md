# LTE Modem E3276 on Raspberry Pi 5

*Ubuntu 24.04 LTS (64‑bit)*

---

## 0 . Prerequisites

* Raspberry Pi 5 Model B with official 5 V 5 A PSU **or** `usb_max_current_enable=1` in `/boot/firmware/config.txt` to let the modem draw 500 mA.
* Huawei E3276 4 G USB stick.
* SIM with data plan ‑ this guide uses Play (PL) whose APN is **internet**.
* Working internet on the Pi (Wi‑Fi/LAN) just for package installation.

---

## 1 . Install required packages

```bash
sudo apt update && sudo apt install -y \
  modemmanager network-manager usb-modeswitch usb-modeswitch-data \
  isc-dhcp-client net-tools
```

These provide the kernel driver, automatic mode‑switching and the `mmcli`, `dhclient`, `ip` tools that we used in the session.

---

## 2 . Verify that the stick is in **modem** mode

```bash
lsusb | grep 12d1
```

* `12d1:1506`  → already in modem/NCM mode — **skip** to §3.
* `12d1:14fe`  → still a virtual CD‑ROM. Force switch once:

```bash
sudo usb_modeswitch -v 0x12d1 -p 0x14fe -R
```

The bundled udev rule will do this automatically next time.

---

## 3 . Confirm kernel driver & network interface

```bash
sudo dmesg | grep -E "huawei_cdc_ncm|wwan"
```

You should see `huawei_cdc_ncm … wwan0 renamed to wwx<MAC>`.

---

## 4 . Attach to the LTE network

1. List modems

   ```bash
   sudo mmcli -L
   ```
2. Connect with your APN (Play → **internet**)

   ```bash
   sudo mmcli -m 0 --simple-connect="apn=internet"
   ```

   *If you get `Incorrect parameters`, double‑check the APN or SIM PIN.*

---

## 5 . Bring up the interface & obtain an IP

```bash
IF=$(ip -brief link | awk '/^wwx/{print $1}')   # auto‑detect
sudo ip link set "$IF" up
sudo dhclient -v "$IF"                          # leases IPv4 from carrier
```

`dhclient` was missing during our first attempt; installing `isc-dhcp-client` fixed it.

---

## 6 . Make LTE the preferred default route

```bash
sudo ip route add default dev "$IF" metric 100
```

Lower metric → higher priority than Wi‑Fi (which usually has 20600).

---

## 7 . (Option) Disable Wi‑Fi until reboot

```bash
sudo nmcli radio wifi off     # or: sudo rfkill block wifi
```

Useful for testing pure LTE throughput; survives until the next reboot or `nmcli radio wifi on`.

---

## 8 . Sanity tests

```bash
ping -I "$IF" 8.8.8.8 -c 4       # raw reachability
curl -4 ifconfig.co               # public IP (will differ from 10.* lease)
```

If pings work but DNS fails, add Google DNS manually:

```bash
sudo nmcli con mod gsm ipv4.dns "8.8.8.8 1.1.1.1"
```

---

## 9 . Persist across boots (recommended)

Create an NM profile that autoconnects:

```bash
sudo nmcli connection add type gsm ifname "*" con-name play4g \
     apn internet ipv4.method auto autoconnect yes \
     ipv4.route-metric 100
```

`tailscaled` and any other services will now come up over LTE even if Wi‑Fi is down.

---

## 10 . Troubleshooting quick table

| Symptom                                         | Fix                                            |
| ----------------------------------------------- | ---------------------------------------------- |
| `mmcli --simple-connect` → Incorrect parameters | Wrong APN / SIM locked                         |
| Interface DOWN after connect                    | `ip link set $IF up` then `dhclient`           |
| `dhclient` *No DHCPOFFERS*                      | Wait 10 s and retry; some Polish EPCs are slow |
| Random USB resets                               | Use powered hub or bigger PSU                  |

---

*Last tested: **2025‑05‑20** on Ubuntu 24.04.2 / kernel 6.8, Raspberry Pi 5 Rev 1.1.*

