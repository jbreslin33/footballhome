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
echo "   Database may be initializing with data - this can take 1-2 minutes..."

attempts=0

until PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$host" -p "$port" -U "$user" -d "$database" -c '\q' 2>/dev/null; do
  attempts=$((attempts + 1))
  
  # Show progress with elapsed time
  printf "\r⏳ Waiting for database to be ready... %ds elapsed" "$attempts"
  sleep 1
done

echo ""
echo "✅ PostgreSQL is up and accepting connections! (took ${attempts}s)"
echo "🚀 Starting backend server..."

# Execute the actual command (the server binary)
exec "$@"
