#!/bin/bash
set -e

# Function to run the updater
run_update() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting playlist update..."
    python /app/playlist_updater.py
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Update completed."
}

# Run immediately on startup
run_update

# Setup cron job for every 10 minutes
echo "*/10 * * * * cd /app && python /app/playlist_updater.py >> /app/output/cron.log 2>&1" | crontab -

# Start cron daemon in foreground
echo "Starting cron scheduler..."
exec cron -f
