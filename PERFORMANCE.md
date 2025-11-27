# Performance Monitoring & Bottleneck Analysis

This document explains how to identify and fix performance bottlenecks in Football Home.

## 🔍 Verbose Logging

The system now has comprehensive logging to identify bottlenecks during startup and operation.

### What You'll See

When running `./dev.sh`, you'll see real-time output showing:

```
🔨 Step 3: Starting containers...
✓ Startup complete!

Testing connectivity...
Backend: Waiting for health check...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

│ 🔧 CREATE TABLE...
│ ✨ Creating table: users
│ 🔧 ALTER TABLE...
│ ⏱️  125.3ms

│ 📥 COPY 15 columns into: team_players
│    ↳ Reading bulk data...
│ ✅ Loaded 847 rows into team_players

│ ➕ Inserting into: matches
│    ↳ 10 rows inserted...
│    ↳ 20 rows inserted...
│ ⏱️  234.5ms

│ ⏱️  SLOW (1250.5ms): CREATE INDEX idx_events_date ON events(event_date)...

│ ⏳ Still initializing... (45s elapsed)
```

### Understanding the Output

**Operations:**
- `🔧 CREATE TABLE/ALTER/INDEX` - Schema operations
- `✨ Creating table: X` - New table being created
- `📥 COPY X columns into: Y` - Bulk loading data (COPY format)
- `➕ Inserting into: X` - Individual INSERT statements
- `✅ Loaded X rows` - COPY operation completed

**Performance Indicators:**
- `⏱️ XXXms` - Query took 100-500ms (moderate)
- `⏱️ SLOW (XXXms): query...` - Query took >500ms (needs investigation)
- `⏳ Still initializing...` - Heartbeat showing progress

**Row Counters:**
- `↳ X rows inserted...` - Progress during INSERT operations
- Updates every 10 rows so you know it's working

## 🐌 Identifying Bottlenecks

### 1. Slow Queries (>500ms)

When you see:
```
│ ⏱️  SLOW (1250.5ms): CREATE INDEX idx_events_date ON events(event_date)...
```

**This is a bottleneck!** The query text shows what's causing the delay.

**Common slow operations:**
- `CREATE INDEX` - Index creation on large tables
- `ALTER TABLE ADD CONSTRAINT` - Foreign key constraints
- `INSERT INTO large_table` - Individual inserts (should use COPY)

**Fixes:**
- Indexes: Consider deferring non-critical indexes
- Constraints: Add DEFERRABLE option or defer to end
- Inserts: Convert to COPY format for bulk loading

### 2. Long Pauses Between Operations

If you see a long gap with just:
```
│ ⏳ Still initializing... (45s elapsed)
│ ⏳ Still initializing... (50s elapsed)
│ ⏳ Still initializing... (55s elapsed)
```

Check the last operation shown. That's likely where it's stuck.

**Common causes:**
- Large COPY operation in progress (normal, just slow)
- Constraint validation (foreign keys checking millions of rows)
- Index creation on large dataset

### 3. Database Logs

For deeper analysis:
```bash
# Watch live logs
docker logs -f footballhome_db

# Search for slow queries
docker logs footballhome_db 2>&1 | grep -E "duration: [0-9]{4,}"

# Find the slowest query
docker logs footballhome_db 2>&1 | grep "duration:" | sort -t: -k2 -n | tail -20
```

## 🚀 Optimization Strategies

### Strategy 1: COPY vs INSERT

**Problem:** Individual INSERTs are 100x slower than COPY
```sql
-- Slow (1000 rows = ~30 seconds)
INSERT INTO teams (id, name) VALUES ('uuid1', 'Team A');
INSERT INTO teams (id, name) VALUES ('uuid2', 'Team B');
...

-- Fast (1000 rows = ~0.3 seconds)
COPY teams (id, name) FROM stdin;
uuid1	Team A
uuid2	Team B
\.
```

**Fix:** The scraper already generates both formats. Ensure `.copy.sql` files exist:
```bash
ls -lh database/data/*.copy.sql
```

### Strategy 2: Defer Constraints

**Problem:** Foreign key validation during INSERT
```sql
ALTER TABLE team_players 
ADD CONSTRAINT fk_team FOREIGN KEY (team_id) REFERENCES teams(id);
-- This validates ALL existing rows immediately
```

**Fix:** Add constraints after data is loaded
```sql
-- In schema file
CREATE TABLE team_players (
    team_id UUID NOT NULL,
    -- No FK constraint yet
);

-- In separate file (loaded last)
ALTER TABLE team_players 
ADD CONSTRAINT fk_team FOREIGN KEY (team_id) REFERENCES teams(id);
```

### Strategy 3: Defer Index Creation

**Problem:** Creating indexes on populated tables
```sql
CREATE TABLE events (id UUID PRIMARY KEY, event_date TIMESTAMP);
-- Load 10,000 rows
CREATE INDEX idx_event_date ON events(event_date);  -- SLOW
```

**Fix:** Create indexes before loading data, or after in parallel
```sql
-- Option 1: Create index on empty table (fast)
CREATE INDEX idx_event_date ON events(event_date);
-- Then load data (index updates incrementally)

-- Option 2: Create indexes concurrently (PostgreSQL 11+)
CREATE INDEX CONCURRENTLY idx_event_date ON events(event_date);
```

### Strategy 4: Bulk Operations

**Problem:** Row-by-row operations
```sql
UPDATE team_players SET is_active = true WHERE team_id = 'xxx';  -- 100 times
```

**Fix:** Single bulk update
```sql
UPDATE team_players SET is_active = true WHERE team_id IN (...);
```

## 📊 Performance Benchmarks

**Typical timing for full database initialization:**

| Operation | Rows | INSERT Time | COPY Time | Speedup |
|-----------|------|-------------|-----------|---------|
| users | 1,247 | ~35s | ~0.4s | 87x |
| players | 1,247 | ~35s | ~0.4s | 87x |
| teams | 28 | ~0.8s | ~0.01s | 80x |
| team_players | 847 | ~24s | ~0.3s | 80x |
| events | 189 | ~5s | ~0.06s | 83x |
| matches | 189 | ~5s | ~0.06s | 83x |
| **Total** | **3,747** | **~105s** | **~1.3s** | **81x** |

**Target times:**
- Schema creation: < 5 seconds
- Data loading (COPY): < 5 seconds
- Index creation: < 10 seconds
- Constraint validation: < 5 seconds
- **Total initialization: < 30 seconds**

## 🔧 Troubleshooting Tools

### Find Bottlenecks in Production

```bash
# Enable query logging (already on in dev)
docker exec footballhome_db psql -U footballhome_user -d footballhome -c \
  "ALTER SYSTEM SET log_min_duration_statement = 1000;"  # Log queries >1s

# Find slow queries in logs
docker logs footballhome_db 2>&1 | \
  grep -E "duration: [0-9]{4,}" | \
  sort -t: -k2 -rn | head -20

# Check active queries
docker exec footballhome_db psql -U footballhome_user -d footballhome -c \
  "SELECT pid, now() - query_start as duration, query 
   FROM pg_stat_activity 
   WHERE state = 'active' ORDER BY duration DESC;"

# Check table sizes
docker exec footballhome_db psql -U footballhome_user -d footballhome -c \
  "SELECT tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) 
   FROM pg_tables WHERE schemaname = 'public' ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;"
```

### Analyze Query Performance

```sql
-- Explain a slow query
EXPLAIN ANALYZE 
SELECT * FROM team_players tp 
JOIN teams t ON tp.team_id = t.id 
WHERE t.league_division_id = 'xxx';

-- Check if indexes are being used
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan;

-- Find missing indexes
SELECT schemaname, tablename, attname, n_distinct, correlation
FROM pg_stats
WHERE schemaname = 'public' AND n_distinct > 100
ORDER BY abs(correlation) DESC;
```

## 🎯 Optimization Checklist

Before submitting PR with performance changes:

- [ ] Verified COPY format is used for bulk data
- [ ] Checked all queries complete in <500ms during startup
- [ ] Confirmed total initialization time < 60 seconds
- [ ] Tested with `./dev.sh --quick` (should be <10s)
- [ ] Reviewed logs for SLOW query warnings
- [ ] Verified no long pauses without progress indicators
- [ ] Checked Docker logs show expected operation flow

## 📈 Monitoring in CI/CD

Add performance checks to CI:

```bash
#!/bin/bash
# performance-test.sh

START=$(date +%s)
./dev.sh --no-scrape
END=$(date +%s)
DURATION=$((END - START))

if [ $DURATION -gt 120 ]; then
    echo "❌ Performance regression: initialization took ${DURATION}s (should be <120s)"
    exit 1
fi

echo "✅ Performance OK: initialization took ${DURATION}s"
```

## 🔗 Related Documentation

- [PostgreSQL Performance Tips](https://wiki.postgresql.org/wiki/Performance_Optimization)
- [COPY Command Reference](https://www.postgresql.org/docs/current/sql-copy.html)
- [Index Usage](https://www.postgresql.org/docs/current/indexes.html)
- [Query Planning](https://www.postgresql.org/docs/current/using-explain.html)

---

**Remember:** The verbose logging shows you EXACTLY where time is spent. Use it to identify bottlenecks, then apply these strategies to optimize!
