#!/bin/bash
# Wait for PostgreSQL to be ready before starting the backend server

set -e

host="$1"
shift
port="$1"
shift
user="$1"
shift
database="$1"
shift

echo "⏳ Waiting for PostgreSQL at $host:$port..."

# Install psql if not available (usually available in postgres images)
attempts=0
max_attempts=60

until PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$host" -p "$port" -U "$user" -d "$database" -c '\q' 2>/dev/null; do
  attempts=$((attempts + 1))
  percent=$((attempts * 100 / max_attempts))
  
  if [ $attempts -ge $max_attempts ]; then
    echo "❌ PostgreSQL did not become ready after ${max_attempts} attempts"
    exit 1
  fi
  
  # Show progress with elapsed time and percentage
  printf "\r⏳ Waiting for database... %ds elapsed [%d%%]" "$attempts" "$percent"
  sleep 1
done

echo ""
echo "✅ PostgreSQL is up and accepting connections! (took ${attempts}s)"
echo "🚀 Starting backend server..."

# Execute the actual command (the server binary)
exec "$@"
