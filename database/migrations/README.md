# Database Migrations

## Overview
Production database changes should be applied as **versioned migrations** instead of rebuilding from scratch.

## Directory Structure
```
migrations/
  V001__add_practice_cancellation.sql
  V002__update_user_roles.sql
  V003__apsl_winter_2025.sql
```

## Naming Convention
`V{version}__{description}.sql`
- **Version**: 3-digit number (001, 002, 003...)
- **Description**: Snake_case description
- **Extension**: Always `.sql`

## Migration Template
```sql
-- V001__example_migration.sql
-- Description: Add new feature X
-- Author: Your Name
-- Date: 2025-12-09

DO $$
BEGIN
    -- Check if already applied
    IF EXISTS (SELECT 1 FROM schema_version WHERE version = 1) THEN
        RAISE NOTICE 'Migration V001 already applied, skipping';
        RETURN;
    END IF;

    -- Your changes here
    ALTER TABLE practices ADD COLUMN cancelled_reason TEXT;
    
    -- Record migration
    INSERT INTO schema_version (version, description, type, source_file) 
    VALUES (1, 'Add practice cancellation tracking', 'MIGRATION', 'V001__add_practice_cancellation.sql');
    
    RAISE NOTICE 'Migration V001 applied successfully';
END $$;
```

## Applying Migrations

### Development (automatic)
Migrations run automatically during `./dev.sh` rebuild.

### Production (manual)
```bash
# Copy migration to server
scp migrations/V001__example.sql user@server:/tmp/

# Apply migration
docker exec footballhome_db psql -U footballhome_user -d footballhome -f /tmp/V001__example.sql

# Verify
docker exec footballhome_db psql -U footballhome_user -d footballhome -c "SELECT * FROM schema_version ORDER BY version;"
```

## Guidelines

1. **Idempotent**: Always check if migration already applied
2. **Atomic**: Wrap in transaction or DO block
3. **Reversible**: Consider rollback strategy
4. **Tested**: Test in development first
5. **Documented**: Add comments explaining WHY

## Version Numbering

- **0-99**: Reserved for initial setup
- **100-199**: Schema changes
- **200-299**: Data migrations
- **300-399**: Seed data updates (APSL/CASA scrapes)
- **900+**: Hotfixes/patches
