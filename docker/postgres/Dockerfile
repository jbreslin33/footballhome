# PostgreSQL 15 with pg_cron extension for scheduled jobs
# Using postgres:15 (Debian) which has easier pg_cron installation
FROM postgres:15

# Install pg_cron from PGDG repository
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-15-cron \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# pg_cron configuration is handled by docker-compose command
