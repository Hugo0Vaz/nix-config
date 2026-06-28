# Nixarr Music Stack — Testing Guide

This guide walks through setting up and testing the nixarr music library
management stack on **nixos-notebook**: Lidarr + Prowlarr + qBittorrent.

## 1. Get your Proton VPN WireGuard config

1. Go to https://account.protonvpn.com/downloads#wireguard-configuration
2. Download a WireGuard config for any server
3. Save it to `~/Documents/proton-wg.conf` (or wherever `services.nixarrMusic.vpn.wgConf` points)

> **⚠️ Important:** This file must NOT be committed to git.

## 2. Activate the configuration

```bash
# From the repo root:
sudo nixos-rebuild switch --flake .#nixos-notebook
```

## 3. Verify services are running

```bash
systemctl status lidarr
systemctl status prowlarr
systemctl status qbittorrent
```

If VPN is enabled, qBittorrent runs inside a VPN namespace. Check:

```bash
# Should show qbittorrent in the wg namespace
sudo ip netns list
```

## 4. First-time web UI setup

All services are internal-only — access via `localhost` (or Tailscale IP):

| Service | URL | Purpose |
|---|---|---|
| **Lidarr** | http://localhost:8686 | Music collection manager |
| **Prowlarr** | http://localhost:9696 | Indexer management |
| **qBittorrent (qui)** | http://localhost:5252 | Download client |

### Lidarr

1. Open http://localhost:8686
2. Create your admin account
3. Go to **Settings → Media Management**:
   - Click **Show Advanced**
   - Enable **Use Hardlinks instead of Copy**
   - Under Permissions, set **chmod Folder** to `775`
4. Go to **Settings → Root Folders** → add `/data/media/library/music`
5. Go to **Settings → Download Clients** → add qBittorrent:
   - Host: `127.0.0.1`
   - Port: `5252`
   - Category: `lidarr`
   - Click Test, then Save

### qBittorrent (qui)

1. Open http://localhost:5252
2. qui will ask for the qBittorrent backend URL:
   - **If using VPN:** enter `http://192.168.15.1:8085`
   - **If NOT using VPN:** enter `http://127.0.0.1:8085`

### Prowlarr

1. Open http://localhost:9696
2. Create your admin account
3. Lidarr should already be auto-configured as an app (declarative settings-sync)
4. Go to **Indexers** → add music indexers (e.g., Headphones)
5. Go to **Settings → Apps** → verify Lidarr is connected (should show a green check)

## 5. Adding music

1. In Lidarr, go to **Library → Add New** → search for an artist
2. Set the root folder to `/data/media/library/music`
3. Set quality profile and monitoring options
4. Lidarr will search Prowlarr indexers → send downloads to qBittorrent → import
   to your music library automatically

## 6. Directory structure

Created automatically by nixarr on first activation:

```
/data/
├── media/                      # services.nixarrMusic.mediaDir
│   ├── library/
│   │   └── music/              # Lidarr library root
│   └── qbittorrent/
│       └── lidarr/             # qBittorrent downloads for Lidarr
└── .state/nixarr/              # service state
    ├── lidarr/
    ├── prowlarr/
    ├── qbittorrent/
    └── secrets/                # auto-generated API keys
```

## 7. Listing available API keys

```bash
sudo nixarr list-api-keys
```

## 8. Adding indexers declaratively (later)

Edit `modules/hosts/nixos-notebook/default.nix`, find the `settings-sync` block
inside the `nixarrMusicModule`, and add:

```nix
indexers = [
  {
    sort_name = "headphones";
    tags = [ "music" ];
  }
];
```

To discover available music indexer schemas:

```bash
sudo nixarr show-prowlarr-schemas indexer | jq '.[].sort_name'
```

## 9. Toggling VPN / changing media path

Edit `modules/hosts/nixos-notebook/configuration.nix`:

```nix
services.nixarrMusic = {
  enable = true;
  mediaDir = "/mnt/storage/media";   # change media path
  vpn = {
    enable = false;                   # disable VPN
    wgConf = null;
  };
};
```

Then:

```bash
sudo nixos-rebuild switch --flake .#nixos-notebook
```

## 10. Troubleshooting

### Service won't start

```bash
journalctl -u lidarr -n 50 --no-pager
journalctl -u prowlarr -n 50 --no-pager
journalctl -u qbittorrent -n 50 --no-pager
```

### VPN not working

- Verify the WireGuard config file exists at the configured path
- Check if Proton's WireGuard server is reachable
- Look for VPN namespace errors: `journalctl -u qbittorrent | grep -i vpn`

### Prowlarr settings-sync failed

The sync runs as a oneshot service after boot:

```bash
systemctl status prowlarr-sync-config
journalctl -u prowlarr-sync-config --no-pager
```

### Can't access web UIs

- All services bind to `127.0.0.1` (localhost only)
- Use Tailscale IP if accessing remotely: `tailscale status` to find the notebook's IP
- Check firewall isn't blocking: `sudo nft list ruleset | grep -E "8686|9696|5252"`
