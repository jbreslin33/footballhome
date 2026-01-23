# Football Home Development Workflow

## 🔄 **Quick Reference**

```bash
# 1️⃣ FULL REBUILD (destroys all data)
./build.sh

# 2️⃣ CHECK DATABASE STATE (anytime)
node database/scripts/audit-database.js

# 3️⃣ UPDATE DATA (run scrapers)
./update.sh
```

## 📊 **When to Use Each Command**

### `./build.sh` - Full Rebuild
**Use when:**
- Starting fresh
- SQL files changed (new teams, divisions, etc.)
- Database is corrupted
- Testing from clean slate

**What it does:**
- ❌ Destroys containers and volumes
- 🏗️ Rebuilds Docker images
- 📁 Loads all SQL files (structure + static data)
- ✅ Database has structure but NO dynamic data

**Time:** ~2-3 minutes

---

### `node database/scripts/audit-database.js` - Check State
**Use when:**
- Before scraping (see what's missing)
- After scraping (verify what changed)
- After rebuild (verify SQL loaded)
- Debugging (understand current state)

**What it shows:**
- ✅ Structure counts (teams, divisions, seasons)
- 📅 Current season data (matches, standings)
- 🔍 What's missing (matches without results)
- 🎯 Scrape target status

**Time:** ~1 second

---

### `./update.sh` - Run Scrapers
**Use when:**
- After rebuild (populate dynamic data)
- Weekly during season (get new matches)
- After games (get results/stats)
- Testing scrapers

**What it does:**
- 🌐 Fetches data from league websites
- 💾 Updates matches, standings, rosters
- ⏭️ Skips already-scraped historical data
- ✅ Only scrapes what's missing

**Time:** ~30 seconds to 2 minutes

---

## 🎯 **Common Workflows**

### First Time Setup
```bash
./build.sh                                    # Build everything
node database/scripts/audit-database.js       # Check structure loaded
./update.sh                                   # Get current season data
node database/scripts/audit-database.js       # Verify data populated
```

### Weekly Updates (During Season)
```bash
node database/scripts/audit-database.js       # See what's missing
./update.sh                                   # Get new matches/results
node database/scripts/audit-database.js       # Verify changes
```

### After SQL File Changes
```bash
# Example: Added new teams to 040-apsl-teams.sql
./build.sh                                    # Reload SQL files
node database/scripts/audit-database.js       # Verify new teams loaded
./update.sh                                   # Re-scrape to link teams to divisions
```

### Debugging Scraper Issues
```bash
node database/scripts/audit-database.js       # Check before state
./update.sh                                   # Run scrapers (watch output)
node database/scripts/audit-database.js       # Check after state (did it work?)
```

### Clean Slate Testing
```bash
./build.sh                                    # Fresh database
node database/scripts/audit-database.js       # Verify clean state
# ... test your changes ...
./update.sh                                   # Populate test data
node database/scripts/audit-database.js       # Verify test results
```

---

## 📁 **Data Architecture**

### FROM SQL FILES (build.sh loads these):
- ✅ Teams (040-041-*.sql) - 261 teams
- ✅ Divisions (034-divisions.sql) - 59 divisions
- ✅ Seasons (032-seasons.sql) - 8 seasons
- ✅ Structure (orgs, leagues, conferences)
- ✅ Users/admins (020-024)

### FROM SCRAPERS (update.sh creates these):
- 🔄 Division-team assignments (which teams play this season)
- 🔄 Standings (current rankings)
- 🔄 Matches (scheduled and completed games)
- 🔄 Match events (goals, cards, subs)
- 🔄 Rosters (players with jersey numbers)
- 🔄 Player stats (from match events)

---

## 🚨 **Important Notes**

### ⚠️ build.sh DESTROYS DATA
Running `./build.sh` will:
- Delete all containers
- Delete all volumes
- Lose all scraped data (matches, standings, rosters)
- Keep only what's in SQL files

**Save scraped data BEFORE rebuild:**
```bash
# Export dynamic data to SQL files (if needed)
node database/scripts/export-standings.js > database/data/050-standings.sql
node database/scripts/export-matches.js > database/data/051-matches.sql
# Then commit to git
git add database/data/*.sql
git commit -m "Export historical data before rebuild"
```

### ✅ update.sh is SAFE
Running `./update.sh` will:
- NOT destroy any data
- Add new records (matches, standings)
- Update existing records (scores, rosters)
- Skip already-scraped historical data

### 📊 audit-database.js is READ-ONLY
- Never modifies database
- Just shows current state
- Safe to run anytime

---

## 🔧 **Troubleshooting**

### "Database container not running"
```bash
./build.sh  # Starts containers
```

### "No divisions found!"
```bash
# Divisions missing from SQL files
# Check: database/data/034-divisions.sql exists
./build.sh  # Reload SQL files
```

### "Matches missing results"
```bash
# Normal - games not scraped yet
./update.sh  # Run scrapers
```

### "Everything is 0 after build.sh"
```bash
# Expected! build.sh only loads SQL files
# Dynamic data comes from scrapers
./update.sh  # Populate dynamic data
```

---

## 🎓 **Learning the System**

### Week 1: Understanding State
```bash
# Run audit to see current state
node database/scripts/audit-database.js

# Read output carefully - what do the numbers mean?
# Organizations: 102 (4 manual + 98 from FIFA scraper)
# Teams: 261 (from SQL files)
# Matches: 250 (from scrapers)
```

### Week 2: Understanding Scrapers
```bash
# Before scraping
node database/scripts/audit-database.js
# Note: "16 matches need results"

# Run scrapers
./update.sh
# Watch output - what does it scrape?

# After scraping
node database/scripts/audit-database.js
# Note: "0 matches need results" (if successful)
```

### Week 3: Understanding Rebuilds
```bash
# Full rebuild
./build.sh

# Check state (should have structure, no dynamic data)
node database/scripts/audit-database.js

# Populate data
./update.sh

# Check state again (now has dynamic data)
node database/scripts/audit-database.js
```

---

## 📚 **More Info**

- [DATA_LOADING_STRATEGY.md](database/DATA_LOADING_STRATEGY.md) - Complete architecture
- [AI_TOOLS.md](AI_TOOLS.md) - Development tool reference
- [README.md](README.md) - Project overview
