# PostgreSQL 15 with pg_cron extension for scheduled jobs
# Using postgres:15 (Debian) which has easier pg_cron installation
FROM docker.io/library/postgres:15

# Install pg_cron from PGDG repository  
RUN apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false --allow-insecure-repositories update \
    && apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false --allow-unauthenticated install -y --no-install-recommends \
        postgresql-15-cron \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy init script with proper permissions
COPY database/data/001-load-data.sh /docker-entrypoint-initdb.d/001-load-data.sh
RUN chmod +x /docker-entrypoint-initdb.d/001-load-data.sh

# pg_cron configuration is handled by docker-compose command


