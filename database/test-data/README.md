# Test Data

This folder contains test/development data files that are **not** loaded by default.

## Files

- `99-test-matches.sql` - Projected Spring 2026 schedule for Lighthouse 1893 SC
  - Reversed home/away from Fall 2025
  - 1 Werner Fricker Cup match (Feb 14)
  - 11 league matches (March 1 - May 10)
  - Mix of Sunday games with a few Saturday games

## Usage

To include test data in your development environment:

```bash
./dev.sh --apsl --test-data
```

This copies the SQL files from `test-data/` to `data/` before rebuilding, so they get loaded by PostgreSQL.

## Why Separate?

- Keeps test data out of production builds
- Easy to toggle on/off without git changes
- Can add more test scenarios (practices, additional matches) later
- Files are cleaned up from `data/` on each run (with or without flag)
