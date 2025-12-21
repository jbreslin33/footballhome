#!/bin/bash
# Load all SQL data files in alphabetical order
# Conditionally loads u/p files based on ENVIRONMENT variable

set -e

echo "Loading data files..."
echo "Environment: ${ENVIRONMENT:-dev}"

# Get all SQL files in alphabetical order
for file in /app/data/*.sql; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        
        # Skip u files if in production
        if [[ $filename =~ u-.*-app\.sql ]] && [[ "${ENVIRONMENT:-dev}" == "production" ]]; then
            echo "  Skipping (dev only): $filename"
            continue
        fi
        
        # Skip p files if in dev
        if [[ $filename =~ p-.*-app\.sql ]] && [[ "${ENVIRONMENT:-dev}" == "dev" ]]; then
            echo "  Skipping (production only): $filename"
            continue
        fi
        
        echo "  Loading: $filename"
        psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f "$file"
    fi
done

echo "Data loading complete!"
