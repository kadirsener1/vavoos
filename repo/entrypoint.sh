#!/bin/bash
set -e

# Function to run the updater
run_update() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting playlist update..."
    /usr/local/bin/python3 /app/playlist_updater.py
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Update completed."
}

# Run immediately on startup
run_update

# Start cron daemon in foreground
echo "Cron scheduler started (updates every 10 minutes)..."
exec /usr/sbin/cron -f -l 2
