FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    cron \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY playlist_updater.py .
COPY entrypoint.sh .
RUN chmod +x /app/entrypoint.sh

# Create output directory
RUN mkdir -p /app/output

# Create crontab file directly in /etc/cron.d (cron reads this automatically)
RUN echo "*/10 * * * * root cd /app && /usr/local/bin/python3 /app/playlist_updater.py >> /app/output/cron.log 2>&1" > /etc/cron.d/playlist-updater && \
    chmod 0644 /etc/cron.d/playlist-updater

# Set environment
ENV PYTHONUNBUFFERED=1

ENTRYPOINT ["/app/entrypoint.sh"]
