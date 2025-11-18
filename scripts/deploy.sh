#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT/vps"

KEY=$(vagrant ssh-config | grep IdentityFile | awk '{print $2}')
HOST="vagrant@localhost"
PORT="2222"
SEEDBOX="$PROJECT_ROOT/seedbox.py"
REQ_TXT="$PROJECT_ROOT/requirements.txt"

vagrant up

scp -P $PORT -i $KEY $REQ_TXT $SEEDBOX $HOST:/home/vagrant/

ssh -p $PORT -i $KEY $HOST << 'EOF'
    python3 -m pip install -r requirements.txt --user
    TERM=xterm python3 seedbox.py
EOF