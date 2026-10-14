# Proton Mail Bridge in Docker

Builds Proton Mail Bridge (headless) from source and publishes IMAP/SMTP on the docker host.
The host is assumed to already be on your Tailscale network; Tailscale is not part of this image.

## Setup
1. *(Optional)* To restrict IMAP/SMTP to the tailnet, `cp .env.example .env` and set `BIND_ADDR`
   to the host's Tailscale IP (`tailscale ip -4`). If you skip this, the ports are published on all
   host interfaces (including your LAN) but are still reachable over Tailscale.
2. `docker compose build`
3. Log in once (interactive CLI): `docker compose run --rm -it bridge login`
   - `login` → enter Proton credentials / 2FA
   - `info` → note the **bridge-specific username and password** (not your Proton password)
   - `exit`
4. `docker compose up -d`

## Client settings
Host: the docker host's Tailscale name/IP, IMAP port **143** (STARTTLS), SMTP port **25** (STARTTLS),
with the username/password from `info`. Bridge uses a self-signed certificate, so trust it in your client.

Upgrade Bridge: `docker compose build --build-arg BRIDGE_VERSION=vX.Y.Z` (default v3.27.1).
