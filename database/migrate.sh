#!/bin/bash

# Football Home Database Migration Runner
# Ensures all migrations are applied in correct order for clean rebuilds

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

# Configuration
DB_CONTAINER="footballhome_db"
DB_USER="footballhome_user"
DB_NAME="footballhome"
MIGRATIONS_DIR="./migrations"

# Check if we're in the right directory
if [[ ! -d "$MIGRATIONS_DIR" ]]; then
    print_error "Migrations directory not found. Please run from database/ directory"
    exit 1
fi

# Check if database container is running
if ! docker ps | grep -q "$DB_CONTAINER"; then
    print_error "Database container '$DB_CONTAINER' is not running"
    print_info "Start it with: docker compose up -d db"
    exit 1
fi

# Wait for database to be ready
print_info "Waiting for database to be ready..."
timeout=30
while ! docker exec "$DB_CONTAINER" pg_isready -U "$DB_USER" > /dev/null 2>&1; do
    timeout=$((timeout - 1))
    if [ $timeout -eq 0 ]; then
        print_error "Database not ready after 30 seconds"
        exit 1
    fi
    sleep 1
done
print_status "Database is ready"

# Create migrations table if it doesn't exist
print_info "Creating migrations tracking table..."
docker exec "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "
CREATE TABLE IF NOT EXISTS schema_migrations (
    id SERIAL PRIMARY KEY,
    filename VARCHAR(255) UNIQUE NOT NULL,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    checksum VARCHAR(64)
);
" > /dev/null

# Function to get file checksum
get_checksum() {
    sha256sum "$1" | cut -d' ' -f1
}

# Function to check if migration is already applied
is_migration_applied() {
    local filename="$1"
    result=$(docker exec "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -t -c "
        SELECT COUNT(*) FROM schema_migrations WHERE filename = '$filename';
    " 2>/dev/null | tr -d ' \n')
    [ "$result" = "1" ]
}

# Function to apply a migration
apply_migration() {
    local file="$1"
    local filename=$(basename "$file")
    local checksum=$(get_checksum "$file")
    
    print_info "Applying migration: $filename"
    
    # Apply the migration
    if docker exec -i "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" < "$file"; then
        # Record successful migration
        docker exec "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "
            INSERT INTO schema_migrations (filename, checksum) 
            VALUES ('$filename', '$checksum')
            ON CONFLICT (filename) DO UPDATE SET 
                applied_at = CURRENT_TIMESTAMP,
                checksum = '$checksum';
        " > /dev/null
        print_status "Migration applied: $filename"
    else
        print_error "Failed to apply migration: $filename"
        exit 1
    fi
}

# Get list of migration files (sorted)
migration_files=($(find "$MIGRATIONS_DIR" -name "*.sql" | sort))

if [ ${#migration_files[@]} -eq 0 ]; then
    print_warning "No migration files found in $MIGRATIONS_DIR"
    exit 0
fi

print_info "Found ${#migration_files[@]} migration files"

# Apply migrations
applied_count=0
skipped_count=0

for file in "${migration_files[@]}"; do
    filename=$(basename "$file")
    
    if is_migration_applied "$filename"; then
        print_warning "Skipping already applied migration: $filename"
        skipped_count=$((skipped_count + 1))
    else
        apply_migration "$file"
        applied_count=$((applied_count + 1))
    fi
done

# Summary
echo
print_status "Migration completed!"
print_info "Applied: $applied_count migrations"
print_info "Skipped: $skipped_count migrations (already applied)"

# Show current migration status
print_info "Current migration status:"
docker exec "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "
    SELECT filename, applied_at 
    FROM schema_migrations 
    ORDER BY applied_at;
"