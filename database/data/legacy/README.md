# Legacy data files

These SQL files were rolled into `database/data/00-schema.sql` when the
baseline was rebuilt from a live `pg_dump` (see TODO note "schema baseline
rebuilt 2026-06-26"). They are kept here for historical reference only.

They are **not** loaded by `001-load-data.sh` because that script globs
`/app/data/*.sql` (one level), not recursively.

If you need to inspect the original intent for any of these tables (leagues,
seasons, conferences, divisions, player-status normalization), read these
files. Do not move them back into `database/data/` — they will collide with
the data already populated by the new baseline.
