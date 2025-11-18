#!/bin/bash

# Cleanup script - stops and optionally destroys the VM

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT/vps"

echo "========================================"
echo "  VM Cleanup"
echo "========================================"
echo ""

# Check if VM exists
if ! vagrant status | grep -q "running\|poweroff\|saved"; then
    echo "No VM found. Nothing to clean up."
    exit 0
fi

# Ask what to do
echo "What would you like to do?"
echo "  1) Halt (stop VM, keep data)"
echo "  2) Destroy (delete VM completely)"
echo "  3) Cancel"
echo ""
read -p "Enter choice [1-3]: " -n 1 -r
echo ""
echo ""

case $REPLY in
    1)
        echo "Halting VM..."
        vagrant halt
        echo ""
        echo "VM halted successfully!"
        echo "Run ./first_spinup.sh or 'vagrant up' to restart"
        ;;
    2)
        echo "This will permanently delete the VM and all data inside it."
        read -p "Are you sure? (y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Destroying VM..."
            vagrant destroy -f
            echo ""
            echo "VM destroyed successfully!"
            echo "Run ./first_spinup.sh to create a new VM"
        else
            echo "Cancelled."
        fi
        ;;
    3)
        echo "Cancelled."
        ;;
    *)
        echo "Invalid choice. Cancelled."
        ;;
esac