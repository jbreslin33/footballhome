#!/bin/bash
# Wrapper to show SQL initialization progress
# This runs our custom init script if it's the first time, then starts postgres normally

set -e

# Check if this is first-time initialization
if [ ! -f /var/lib/postgresql/data/PG_VERSION ]; then
    echo "🔍 First-time database initialization detected"
    echo "   Will show detailed SQL progress..."
    
    # Set flag to run our custom init
    export CUSTOM_INIT=true
fi

# Call the original postgres entrypoint
exec docker-entrypoint.sh "$@"
