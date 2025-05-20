# VPN / Tailscale Setup on Raspberry Pi 5

*Works over Wi‑Fi **or** the LTE link from `modem_setup_guide.md`*

---

## 1 . Install Tailscale

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

The script adds the apt repo that matches your release (Ubuntu 24.04 = *noble*) and installs `tailscale` + `tailscaled` service.

### Verify the service

```bash
sudo systemctl status tailscaled
```

Expect *active (running)*. If not:

```bash
sudo systemctl enable --now tailscaled
```

---

## 2 . Log in & enable built‑in SSH

```bash
sudo tailscale up --ssh
```

A URL appears in the console; open it in a browser, choose your identity provider and approve the device.

> **Tip – Reusable auth key**
> For headless re‑images you can skip the browser by generating a *Reusable Auth Key* in the admin console and running:
> `sudo tailscale up --ssh --authkey tskey-abc123…`

---

## 3 . Test connectivity

```bash
# On the Pi
tailscale ip       # shows 100.x.x.x and fd7a:… addresses

# From your laptop
ping 100.x.x.x      # low‑latency NAT‑traversed ping
ssh pi@100.x.x.x    # if you enabled --ssh above
```

If you see `Permission denied (tailscale login)`, add your user in *Access Controls → tailscale-ssh* section of admin console.

---

## 4 . Coupling with LTE‑only mode

During field tests you may want the modem to be the **sole** uplink. Disable Wi‑Fi until next reboot:

```bash
sudo nmcli radio wifi off    # restore with:  nmcli radio wifi on
```

Tailscale automatically re‑heads over whichever interface has Internet, so your tunnel persists.

### Quick end‑to‑end checklist

1. LTE interface `wwx…` has an IP (see `ip a`).
2. `tailscale status` shows *direct* or *derp* connection, not *offline*.
3. Laptop can `ssh pi@<Tailnet‑IP>` even though Wi‑Fi is off on the Pi.

---

## 5 . Useful commands cheat‑sheet

| Command                      | What it does                            |
| ---------------------------- | --------------------------------------- |
| `tailscale status`           | list all machines & connection quality  |
| `tailscale ip -4`            | print just the IPv4 Tailnet address     |
| `tailscale netcheck`         | diagnose NAT/latency problems           |
| `tailscale logout`           | invalidate machine key                  |
| `tailscale funnel enable 80` | expose local web service (requires ACL) |

---

## 6 . Unattended upgrades

Tailscale auto‑updates via apt. For on‑device upgrades:

```bash
sudo tailscale update stable  # or: tailscale update unstable
```

---

*Last validated: **2025‑05‑20**, tailscale 1.82.5.*

