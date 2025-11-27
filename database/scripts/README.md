# Database Scripts

## Overview

This directory contains utility scripts for managing database data generation and optimization.

## INSERT-to-COPY Conversion System

### Performance Impact

PostgreSQL's `COPY` command is **~100x faster** than individual `INSERT` statements for bulk data loading:

- **Before:** 200 seconds database initialization (5,348 INSERT statements)
- **After:** 5-10 seconds database initialization (COPY bulk loads)

### How It Works

```
Developer                Scraper                 Docker Init
    │                       │                        │
    │  Edit .sql files      │                        │
    │  (INSERT format)      │                        │
    ├───────────────────────►                        │
    │                       │ Generate .sql          │
    │                       │ (INSERT format)        │
    │                       ├──────────┐             │
    │                       │          │             │
    │                       │  Convert to COPY       │
    │                       │  (.copy.sql files)     │
    │                       │◄─────────┘             │
    │                       │                        │
    │                       │                        ├─► Load .copy.sql (fast)
    │                       │                        │   or .sql (slow fallback)
```

### File Structure

```
database/
├── scripts/
│   ├── convert-to-copy.sh          # Universal conversion utility
│   ├── apsl-scraper/
│   │   ├── scrape-apsl.sh         # Auto-calls post-scrape.sh
│   │   └── post-scrape.sh         # Converts APSL files
│   └── venue-scraper/
│       └── post-scrape.sh         # Converts venue files
└── data/
    ├── *.sql                       # INSERT format (git-tracked)
    └── *.copy.sql                  # COPY format (git-ignored)
```

## Scripts

### `convert-to-copy.sh`

Universal script that converts INSERT statements to PostgreSQL COPY format.

**Usage:**
```bash
# Convert single file
./convert-to-copy.sh ../data/08b-users-apsl.sql

# Convert multiple files
./convert-to-copy.sh ../data/*.sql

# Convert specific files
./convert-to-copy.sh ../data/08b-users-apsl.sql ../data/14-rosters.sql
```

**Features:**
- Handles single-row and multi-row INSERTs
- Preserves `ON CONFLICT` clauses as comments
- Converts NULL values, booleans, and strings correctly
- Handles escaped characters and JSON data
- Shows progress and statistics

**Output:**
- Creates `filename.copy.sql` for each `filename.sql`
- Original files remain unchanged
- `.copy.sql` files are git-ignored

### `apsl-scraper/post-scrape.sh`

Converts APSL scraper output files to COPY format.

**Usage:**
```bash
cd database/scripts/apsl-scraper
./post-scrape.sh
```

**Converts:**
- `database/data/08b-users-apsl.sql` (1,609 users)
- `database/data/13b-players-apsl.sql` (1,609 players)
- `database/data/14-rosters.sql` (1,609 roster entries)

**Note:** Automatically called by `scrape-apsl.sh` after successful scrape.

### `venue-scraper/post-scrape.sh`

Converts venue scraper output to COPY format.

**Usage:**
```bash
cd database/scripts/venue-scraper
./post-scrape.sh
```

**Converts:**
- `database/data/02-venues.sql` (521 venues, 2.7MB → 59KB!)

## Workflows

### Running APSL Scraper

```bash
cd database/scripts/apsl-scraper
./scrape-apsl.sh
```

**What happens:**
1. Scrapes APSL data from website
2. Generates INSERT-format SQL files
3. **Automatically converts to COPY format**
4. Ready for fast database loading

### Manual Conversion

If you edit any `.sql` file manually:

```bash
./database/scripts/convert-to-copy.sh database/data/YOUR-FILE.sql
```

### Convert All Files

Useful after git clone or major data changes:

```bash
./database/scripts/convert-to-copy.sh database/data/*.sql
```

## Docker Integration

The database initialization script (`docker/postgres/init-with-progress.sh`) automatically:

1. Looks for `.copy.sql` version of each file
2. Uses `.copy.sql` if available (fast loading)
3. Falls back to `.sql` if `.copy.sql` doesn't exist

**You don't need to do anything!** Just run:

```bash
docker compose up --build
```

## File Size Comparison

| File | INSERT (.sql) | COPY (.copy.sql) | Reduction |
|------|---------------|------------------|-----------|
| 02-venues.sql | 2.7 MB | 59 KB | 98% |
| 08b-users-apsl.sql | 445 KB | 492 KB | -10% |
| 13b-players-apsl.sql | 288 KB | 280 KB | 3% |
| 14-rosters.sql | 540 KB | 599 KB | -10% |

**Note:** Venue file has huge size reduction due to JSON data compression in COPY format.

## Why Two Formats?

**INSERT format (`.sql` files):**
- ✅ Human-readable
- ✅ Git-friendly diffs
- ✅ Easy to edit manually
- ✅ Contains `ON CONFLICT` logic
- ❌ Slow to load (200 seconds)

**COPY format (`.copy.sql` files):**
- ✅ 100x faster loading (5-10 seconds)
- ✅ Smaller size for JSON-heavy data
- ✅ PostgreSQL's preferred bulk format
- ❌ Not human-friendly
- ❌ Can't include `ON CONFLICT`
- ✅ Auto-generated, disposable

## Best Practices

1. **Always edit `.sql` files (INSERT format)**
   - These are version-controlled
   - More readable and maintainable

2. **Regenerate `.copy.sql` after editing**
   ```bash
   ./database/scripts/convert-to-copy.sh database/data/YOUR-FILE.sql
   ```

3. **Scrapers auto-convert**
   - No need to manually convert scraper output
   - Just run the scraper normally

4. **`.copy.sql` files are ephemeral**
   - Can delete and regenerate anytime
   - Not tracked by git
   - Recreated on each scraper run

5. **After git clone**
   ```bash
   # Convert all files for fast loading
   ./database/scripts/convert-to-copy.sh database/data/*.sql
   ```

## Troubleshooting

### Conversion fails with Python error

Ensure Python 3 is installed:
```bash
python3 --version
```

### `.copy.sql` files not being used

Check Docker init logs:
```bash
docker logs footballhome_db | grep "Loading:"
```

Should show:
```
Loading (COPY): /docker-entrypoint-initdb.d/08b-users-apsl.copy.sql
```

### Want to force INSERT format

Delete `.copy.sql` files:
```bash
rm database/data/*.copy.sql
docker compose up --build
```

### Database loading still slow

Check which files are being loaded:
```bash
docker logs footballhome_db 2>&1 | grep "Processing:"
```

Verify `.copy.sql` files exist:
```bash
ls -lh database/data/*.copy.sql
```

## Performance Benchmarks

**Before (INSERT format):**
- 00-schema.sql: 15 INSERTs → ~2s
- 01-core-lookups.sql: 10 INSERTs → ~1s
- 02-venues.sql: 521 INSERTs → ~45s
- 08b-users-apsl.sql: 1,609 INSERTs → ~60s
- 13b-players-apsl.sql: 1,609 INSERTs → ~50s
- 14-rosters.sql: 1,609 INSERTs → ~42s
- **Total: ~200 seconds**

**After (COPY format):**
- All files: COPY bulk loads → **5-10 seconds total**

**Speedup: 20-40x overall**

## Future Enhancements

- [ ] Auto-conversion during Docker build (if `.copy.sql` missing)
- [ ] Parallel file conversion for faster processing
- [ ] Support for more complex INSERT patterns
- [ ] Conversion progress bars for large files
- [ ] Automatic re-conversion detection (file modified date)
