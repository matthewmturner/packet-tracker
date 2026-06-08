#!/usr/bin/env bash

# Target host and tuning
HOST="${1:-8.8.8.8}"
PING_COUNT=20
INTERVAL=5
OUTPUT_FILE="$(dirname "$0")/packet_loss.txt"
LOG_FILE="$(dirname "$0")/packet_loss.log"

while true; do
    # ping -c sends COUNT packets; parse the "X% packet loss" from summary line
    loss=$(ping -c "$PING_COUNT" -q "$HOST" 2>/dev/null \
        | awk '/packet loss/ { gsub(/%/, ""); for(i=1;i<=NF;i++) if($i+0==$i && $(i+1)=="packet") print $i }')

    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    if [[ -z "$loss" ]]; then
        loss="error"
        printf '%s\n' "$loss" > "$OUTPUT_FILE"
        printf '%s host=%s loss=%s\n' "$timestamp" "$HOST" "$loss" >> "$LOG_FILE"
    else
        printf '%s%%\n' "$loss" > "$OUTPUT_FILE"
        printf '%s host=%s loss=%s%%\n' "$timestamp" "$HOST" "$loss" >> "$LOG_FILE"
    fi

    sleep "$INTERVAL"
done
