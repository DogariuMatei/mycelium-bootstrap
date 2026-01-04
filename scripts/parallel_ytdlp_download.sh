#!/bin/bash

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Configuration (relative to repo root)
#URLS_FILE="$REPO_DIR/YT-API-CC-SCRIPT/cc_urls.txt"
URLS_FILE="$REPO_DIR/YT-API-CC-SCRIPT/cc_urls_test.txt"
OUTPUT_DIR="$REPO_DIR/CreativeCommonsMusic"
NAME_FORMAT="%(id)s_%(title)s.%(ext)s"
CHUNKS=10
TEMP_DIR="/tmp/ytdlp_chunks"

# Validate input file
if [ ! -f "$URLS_FILE" ]; then
    echo "Error: URLs file not found: $URLS_FILE"
    exit 1
fi

TOTAL_URLS=$(wc -l < "$URLS_FILE")
CHUNK_SIZE=$(( (TOTAL_URLS + CHUNKS - 1) / CHUNKS ))

echo "Total URLs: $TOTAL_URLS"
echo "Chunk size: ~$CHUNK_SIZE URLs per thread"
echo "Output directory: $OUTPUT_DIR"

mkdir -p "$OUTPUT_DIR"
mkdir -p "$TEMP_DIR"

# Split URLs file into chunks
split -l "$CHUNK_SIZE" -d --additional-suffix=.txt "$URLS_FILE" "$TEMP_DIR/chunk_"

download_chunk() {
    local chunk_file=$1
    local thread_id=$2
    local chunk_count=$(wc -l < "$chunk_file")

    echo "Thread $thread_id: Downloading $chunk_count URLs from $chunk_file"

    yt-dlp \
        --batch-file "$chunk_file" \
        --output "$OUTPUT_DIR/$NAME_FORMAT" \
        -f ba \
        --extract-audio \
        --audio-format flac \
        --add-metadata \
        --embed-thumbnail \
        --write-info-json \
        --ignore-errors \
        --no-overwrites \
        --concurrent-fragments 2 \
        > "download_log_$thread_id.txt" 2>&1

    echo "Thread $thread_id: Done!"
}

# Launch parallel downloads
thread_id=0
for chunk_file in "$TEMP_DIR"/chunk_*.txt; do
    download_chunk "$chunk_file" "$thread_id" &
    ((thread_id++))
done

wait

# Cleanup temp files
rm -rf "$TEMP_DIR"

echo "All threads finished downloading!"
echo "Downloaded files are in: $OUTPUT_DIR"
