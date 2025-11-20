#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT/vps"

KEY=$(vagrant ssh-config | grep IdentityFile | awk '{print $2}')
HOST="vagrant@localhost"
PORT="2222"
#######################################################
# DELETE THE /TestMusic part if you want all your locally stored songs - replace with /CreativeCommonsMusic
MUSIC_DIR="$PROJECT_ROOT/TestMusic"
#######################################################




ssh -p $PORT -i $KEY $HOST "mkdir -p /home/vagrant/music"

rsync -avz --progress -e "ssh -p $PORT -i $KEY" "$MUSIC_DIR/" "$HOST:/home/vagrant/music/"

echo ""
echo "Sync complete!"
