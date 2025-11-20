#!/bin/bash

# First-time VM setup script
# Use this script to:
# - Initial VM creation
# - Rebuild VM after vagrant destroy
# - Reset VM to clean state

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "========================================"
echo "  Seedbox VM First-Time Setup"
echo "========================================"
echo ""

# Check prerequisites
echo "[1/6] Checking prerequisites..."
if ! command -v vagrant &> /dev/null; then
    echo "ERROR: Vagrant is not installed!"
    echo "Please install from: https://www.vagrantup.com/"
    exit 1
fi

if ! command -v VBoxManage &> /dev/null; then
    echo "ERROR: VirtualBox is not installed!"
    echo "Please install from: https://www.virtualbox.org/"
    exit 1
fi
echo "Vagrant and VirtualBox found"
echo ""


cd "$PROJECT_ROOT/vps"

# Destroy existing VM if user wants
echo "[2/6] Checking for existing VM..."
if vagrant status | grep -q "running\|poweroff\|saved"; then
    read -p "Existing VM found. Destroy and recreate? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Destroying existing VM..."
        vagrant destroy -f
    fi
fi
echo ""

# Start VM
echo "[3/6] Starting VM (this may take a few minutes)..."
vagrant up
echo "VM is up"
echo ""

# Clean SSH known_hosts
echo "[4/6] Cleaning SSH known hosts..."
ssh-keygen -f "$HOME/.ssh/known_hosts" -R '[localhost]:2222' 2>/dev/null || true
echo "SSH known hosts cleaned"
echo ""

# Install dependencies
echo "[5/6] Installing dependencies on VM..."
KEY=$(vagrant ssh-config | grep IdentityFile | awk '{print $2}')
HOST="vagrant@localhost"
PORT="2222"

ssh -o StrictHostKeyChecking=no -p $PORT -i $KEY $HOST << 'EOF'
    sudo apt-get update -qq
    sudo apt-get install -y python3 python3-pip git > /dev/null
    python3 -m pip install libtorrent --user --quiet
    mkdir -p /home/vagrant/music /home/vagrant/logs /home/vagrant/data

    if [ ! -d "/home/vagrant/mycelium" ]; then
        git clone https://github.com/DogariuMatei/mycelium.git /home/vagrant/mycelium
    fi
EOF
echo "All Dependencies Installed on VM!"
echo ""

# Install requirements
echo "[6/6] Installing Python dependencies..."
ssh -p $PORT -i $KEY $HOST << 'EOF'
    cd /home/vagrant/mycelium
    python3 -m pip install -r code/requirements.txt --user --quiet
EOF
echo "Dependencies installed"
echo ""

echo "========================================"
echo "  Setup Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. Run ./sync_music.sh to copy music files (optional)"
echo "  2. Run ./deploy.sh to start the orchestrator"
echo ""
echo "Useful commands:"
echo "  vagrant ssh       - SSH into the VM"
echo "  vagrant halt      - Stop the VM"
echo "  vagrant destroy   - Delete the VM"
echo ""
