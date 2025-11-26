# PostgreSQL 15 with pg_cron extension for scheduled jobs
# Using postgres:15 (Debian) which has easier pg_cron installation
FROM postgres:15

# Install pg_cron from PGDG repository
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-15-cron \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy custom init script with progress indicators
COPY init-with-progress.sh /docker-entrypoint-initdb.d/000-init-with-progress.sh
RUN chmod +x /docker-entrypoint-initdb.d/000-init-with-progress.sh

# pg_cron configuration is handled by docker-compose command
