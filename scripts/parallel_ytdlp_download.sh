#!/bin/bash

# consts
PLAYLIST_URL="https://www.youtube.com/playlist?list=PLzCxunOM5WFI6sgbAppnSgLQxxNg_d10L"
OUTPUT_DIR="/home/doga/Desktop/thesis/CreativeCommonsMusic"
NAME_FORMAT="%(title)s.%(ext)s"
PLAYLIST_START=1
PLAYLIST_END=1149
CHUNKS=10

TOTAL_ITEMS=$((PLAYLIST_END - PLAYLIST_START + 1))
CHUNK_SIZE=$((TOTAL_ITEMS / CHUNKS))

mkdir -p "$OUTPUT_DIR"

download_range() {
    local start=$1
    local end=$2
    local thread_id=$3

    echo "Thread $thread_id: Downloading items $start to $end"

    yt-dlp \
        --playlist-start "$start" \
        --playlist-end "$end" \
        --output "$OUTPUT_DIR/$NAME_FORMAT" \
        -f ba \
        --extract-audio \
        --audio-format flac \
        --add-metadata \
        --embed-thumbnail \
        --concurrent-fragments 2 \
        "$PLAYLIST_URL" \
        > "download_log_$thread_id.txt" 2>&1

    echo "Thread $thread_id: Done!"
}

# parallel downloads
for i in $(seq 0 $((CHUNKS - 1))); do
    start=$((PLAYLIST_START + i * CHUNK_SIZE))
    end=$((start + CHUNK_SIZE - 1))

    # last chunk does remainder
    if [ $i -eq $((CHUNKS - 1)) ]; then
        end=$PLAYLIST_END
    fi

    download_range "$start" "$end" "$i" &
done

wait

echo "All threads finished downloading!"