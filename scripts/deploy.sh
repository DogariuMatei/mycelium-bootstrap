#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT/vps"

KEY=$(vagrant ssh-config | grep IdentityFile | awk '{print $2}')
HOST="vagrant@localhost"
PORT="2222"

echo "========================================"
echo "  Deploying Orchestrator"
echo "========================================"
echo ""

echo "[1/4] Ensuring VM is running..."
vagrant up
echo ""

echo "[2/4] Pulling latest code..."
ssh -p $PORT -i $KEY $HOST << 'EOF'
    cd /home/vagrant/mycelium
    git pull origin main
EOF
echo ""

echo "[3/4] Setting up wrapper script..."
ssh -p $PORT -i $KEY $HOST "chmod +x /home/vagrant/mycelium/code/scripts/orchestrator_wrapper.sh"
echo ""

echo "[4/4] Starting orchestrator..."
ssh -p $PORT -i $KEY $HOST << 'EOF'
    # Kill existing orchestrator if running
    pkill -f "python3.*main.py" || true

    # Start orchestrator with wrapper
    nohup /home/vagrant/mycelium/code/scripts/orchestrator_wrapper.sh > /home/vagrant/logs/wrapper.log 2>&1 &

    echo "Orchestrator started (PID: $!)"
EOF
echo ""

echo "========================================"
echo "  Deployment Complete!"
echo "========================================"
echo ""
echo "Monitor logs with:"
echo "  ssh -p $PORT -i $KEY $HOST 'tail -f /home/vagrant/logs/orchestrator.log'"
echo ""
echo "Or SSH into VM -> vagrant ssh"
echo " tail -f /home/vagrant/logs/orchestrator.log "
echo " tail -f /home/vagrant/logs/wrapper.log "
echo ""