#!/bin/bash

if [ -z "$GIT_TOKEN" ]; then
  exit 0
fi

cd /repo 2>/dev/null || exit 0

# Copy latest playlist
cp app/output/playlist.m3u . 2>/dev/null || true

# Configure git
git config --global user.email "bot@docker.local" 2>/dev/null
git config --global user.name "Docker Updater" 2>/dev/null

# Add and check for changes
git add playlist.m3u 2>/dev/null || true

if git diff --cached --quiet 2>/dev/null; then
  echo "[$(date '+%H:%M:%S')] No changes to push"
  exit 0
fi

# Commit
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
git commit -m "Auto-update: $TIMESTAMP" 2>/dev/null || exit 0

# Push with token
echo "[$(date '+%H:%M:%S')] Attempting push to GitHub..."
git push -u "https://${GIT_TOKEN}@github.com/kadirsener1/vavoos.git" HEAD:main 2>&1 | tee -a /app/output/cron.log

if [ ${PIPESTATUS[0]} -eq 0 ]; then
  echo "[$(date '+%H:%M:%S')] Push successful!"
else
  echo "[$(date '+%H:%M:%S')] Push failed - check token and permissions"
fi
