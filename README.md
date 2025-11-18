# Local VPS Seedbox

A BitTorrent seedbox running in a local Vagrant VM using libtorrent.

## Quick Start

```bash
# First-time setup (creates VM and installs dependencies)
# Can also use as a 'fresh start' button
./scripts/first_spinup.sh
```

```bash
# 2. Sync music files to VM
./scripts/sync_music.sh
```
```bash
# 3. Start the seedbox
./scripts/deploy.sh
```

## Requirements
- VirtualBox
- Vagrant


## Project Structure

```
├── CreativeCommonsMusic/    # Music files to seed
├── scripts/
│   ├── first_spinup.sh     # Initial VM setup
│   ├── sync_music.sh       # Sync music to VM
│   └── deploy.sh           # Deploy and run seedbox
├── vps/Vagrantfile         # VM configuration
└── seedbox.py              # Main seedbox script
```

## Cleanup VM

```bash
./scripts/cleanup.sh
```