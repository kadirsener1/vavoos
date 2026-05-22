#!/bin/bash
set -e

# Git configuration from environment variables
GIT_USER_NAME="${GIT_USER_NAME:-Docker Bot}"
GIT_USER_EMAIL="${GIT_USER_EMAIL:-bot@docker.com}"
GIT_TOKEN="${GIT_TOKEN}"
GIT_REPO="${GIT_REPO:-https://github.com/kadirsener1/vavoos.git}"

# Configure git
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"

# Clone or setup repo if needed
if [ ! -d "/repo/.git" ]; then
    mkdir -p /repo
    cd /repo
    if [ -n "$GIT_TOKEN" ]; then
        git clone "https://${GIT_TOKEN}@github.com/kadirsener1/vavoos.git" .
    else
        git clone "$GIT_REPO" .
    fi
fi

# Function to run the updater and push
run_update_and_push() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting playlist update..."
    /usr/local/bin/python3 /app/playlist_updater.py
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Update completed."
    
    # Push to GitHub if token is set
    if [ -n "$GIT_TOKEN" ]; then
        cd /repo
        cp /app/output/playlist.m3u . 2>/dev/null || true
        git add playlist.m3u 2>/dev/null || true
        
        if git diff --cached --quiet; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] No changes to commit."
        else
            git commit -m "Auto-update: $(date '+%Y-%m-%d %H:%M:%S')" 2>/dev/null || true
            
            if [ -n "$GIT_TOKEN" ]; then
                git push "https://${GIT_TOKEN}@github.com/kadirsener1/vavoos.git" main 2>/dev/null || echo "Push failed"
            else
                git push 2>/dev/null || echo "Push failed - no token"
            fi
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Playlist pushed to GitHub."
        fi
    fi
}

# Run immediately on startup
run_update_and_push

# Start cron daemon in foreground with enhanced logging
echo "Cron scheduler started (updates every 10 minutes with auto-push to GitHub)..."
exec /usr/sbin/cron -f -l 2
