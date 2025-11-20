# Local VPS Seedbox

A BitTorrent seedbox running in a local Vagrant VM using libtorrent.

## Quick Start
Please run these in this exact order!
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

## Check VM Logs:
First, go to `/vps` and SSH into the VM with `vagrant ssh`
```bash
cd vps
vagrant ssh
```
Then inside:
```bash
tail -f /home/vagrant/logs/orchestrator.log 
```
Or to view the wrapper logs
```bash
tail -f /home/vagrant/logs/wrapper.log 
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