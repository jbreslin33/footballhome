# Archived Migrations

These migration files have been consolidated into the main `init.sql` schema for cleaner deployments.

## Migration History

- `002_google_places_integration.sql` - Added Google Places fields to venues table
- `003_field_naming_improvements.sql` - Renamed contact fields to match Google standards

## Current Status

All functionality from these migrations is now included in the main `database/init.sql` file. New deployments get the complete schema from the start.

For new features, create new migration files in the `migrations/` directory and use the `migrate.sh` script.