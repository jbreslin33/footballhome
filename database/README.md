# Database Directory

This directory contains all database-related files for the Football Home application.

## Directory Structure

### `/schema/`
Core database schema and table definitions:
- `init.sql` - Main database initialization script with table structures

### `/apsl/` 
APSL (American Premier Soccer League) data and scraping tools:
- `apsl-data.sql` - Complete APSL player and team data (1,572 players)
- `scrape-apsl.js` - Node.js scraping script for APSL data
- `scrape-apsl.sh` - Shell script wrapper for scraping
- `test-scrape.js` - Testing utilities for scraping
- `APSL_SCRAPING.md` - Documentation for APSL scraping process

### `/venues/`
Google Places venue data for football fields:
- `venues-google-*.sql` - Venue data organized by city/region
- `VENUES_README.md` - Documentation for venue data structure

### `/scripts/`
Database utility scripts and tools:
- `run-sql.sh` - Helper script for running SQL commands against the database

## Usage

The database is automatically initialized via Docker Compose using files from:
1. `schema/init.sql` - Creates tables and basic structure
2. `apsl/apsl-data.sql` - Loads player and team data

## Database Scripts

### run-sql.sh

Execute SQL commands directly against the footballhome database.

**Usage:**
```bash
./scripts/run-sql.sh "SQL_QUERY" [-f]
```

**Examples:**
```bash
# Simple query
./scripts/run-sql.sh "SELECT COUNT(*) FROM teams;"

# With formatted output
./scripts/run-sql.sh "SELECT name, email FROM users;" -f
```

See `/scripts/` directory for detailed documentation.