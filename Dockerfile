FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    cron \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY playlist_updater.py .
COPY entrypoint.sh .
RUN chmod +x /app/entrypoint.sh

# Create output directory
RUN mkdir -p /app/output /repo

# Create git push script
RUN echo '#!/bin/bash\nif [ -n "$GIT_TOKEN" ]; then\n  cd /repo\n  cp /app/output/playlist.m3u . 2>/dev/null || true\n  git config user.email "bot@docker.local"\n  git config user.name "Docker Updater"\n  git add playlist.m3u 2>/dev/null || true\n  if ! git diff --cached --quiet 2>/dev/null; then\n    git commit -m "Auto-update: $(date '+%Y-%m-%d %H:%M:%S')"\n    git push https://$GIT_TOKEN@github.com/kadirsener1/vavoos.git main 2>/dev/null && echo "Push OK" || echo "Push failed"\n  fi\nfi' > /app/git_push.sh && chmod +x /app/git_push.sh

# Create crontab - runs every 10 minutes
RUN echo '*/10 * * * * root cd /app && /usr/local/bin/python3 /app/playlist_updater.py >> /app/output/cron.log 2>&1 && /app/git_push.sh >> /app/output/cron.log 2>&1' > /etc/cron.d/playlist-updater && \
    chmod 0644 /etc/cron.d/playlist-updater

# Set environment
ENV PYTHONUNBUFFERED=1
ENV GIT_USER_NAME="Docker Updater"
ENV GIT_USER_EMAIL="updater@docker.local"

ENTRYPOINT ["/app/entrypoint.sh"]
