# Database Normalization Decisions

## Overview
This document explains the architectural decisions made during the schema normalization review on 2026-01-01.

---

## ✅ Key Architectural Decision: Keep `players` Table Separate

### **Question:** Do we need a `players` table, or should we merge into `users`?

### **Answer:** KEEP `players` table separate ✅

### **Rationale:**

```
Current Architecture:
teams → team_players → players → users (nullable FK)
```

**Why this design is correct:**

1. **Separation of Concerns:**
   - **`players`** = Soccer entities (scraped from APSL/CASA rosters, historical data)
   - **`users`** = App accounts (authentication, login, chat, RSVP)

2. **Unclaimed Players:**
   - Scrapers create player records from external sources
   - Many players don't have user accounts yet (`players.user_id IS NULL`)
   - Users can "claim" players by setting `players.user_id` (verified by admin)

3. **Different Lifecycles:**
   - A player can exist without a user account (unclaimed stub from scraping)
   - A user can exist without being a player (club admin, parent, referee, fan)
   - Historical players from 10 years ago don't need user accounts

4. **team_players is Source of Truth:**
   - `team_players.player_id` = which soccer player is on the roster
   - `team_players.source_system_id` = where we learned about this roster (APSL=1, CASA=2)
   - Stats, goals, cards linked to `players`, not `users`

**If we merged players into users:**
- ❌ Can't scrape rosters without creating fake user accounts
- ❌ Every historical player needs a user row (bloats users table with inactive accounts)
- ❌ Can't differentiate "soccer identity" from "app user"
- ❌ Forces scrapers to create authentication records (wrong layer)

---

## 🔑 Critical Fix: Unclaimed User Detection Logic

### **Question:** How do we identify unclaimed users?

### **Answer:** NO ENTRY in `user_emails` table (not NULL email)

**Correct Design:**
```sql
-- Claimed user: Has entry in user_emails with email
SELECT u.* FROM users u
INNER JOIN user_emails ue ON u.id = ue.user_id;

-- Unclaimed user: NO ENTRY in user_emails (no row at all)
SELECT u.* FROM users u
LEFT JOIN user_emails ue ON u.id = ue.user_id
WHERE ue.id IS NULL;
```

**Why `user_emails.email` is NOT NULL:**
- If a row exists in `user_emails`, it MUST have an email
- Unclaimed users have NO ROW in `user_emails` (not a row with NULL email)
- This prevents invalid data: "user has email entry but no email value"

**Schema is Correct - No Changes Needed ✅**

---

## 🗑️ Deleted: `player_users` Table (Redundant)

### **Problem:** Violates 3NF - Same Relationship in Two Places

**Old Design:**
```sql
-- REDUNDANT: Two ways to express same 1:1 relationship
CREATE TABLE players (
    user_id INTEGER UNIQUE REFERENCES users(id)  -- 1:1 relationship
);

CREATE TABLE player_users (
    player_id INTEGER REFERENCES players(id),
    user_id INTEGER REFERENCES users(id)  -- SAME relationship as above!
);
```

**Issue:** Which is source of truth?
- If `players.user_id = 123`, do we also need `player_users(player_id, 123)`?
- Updates must happen in TWO places
- Data can become inconsistent

**Fix:** DELETE `player_users` table ✅
- Use `players.user_id` as single source of truth
- 1:1 relationship = single FK column, not junction table

---

## 🔀 Position Assignment Architecture

### **Problem:** Two different concepts confused

**OLD (Confusing):**
```sql
player_positions  -- Positions player CAN play?
team_players.position_id  -- Position on THIS team?
```

**NEW (Clear):**
```sql
player_positions (player_id, position_id)
-- "What positions can this player play across ALL teams?"
-- Example: Player 123 CAN play: GK, CB, CDM

team_player_positions (team_player_id, position_id, is_primary)
-- "What position does this player play for THIS specific roster?"
-- Example: Player 123 plays CB (primary) for Team A, but GK for Team B
```

**Benefits:**
1. Player profile shows all positions they're capable of playing
2. Each roster shows what position they actually play for that team
3. A player might be a defender on one team but goalkeeper on another

---

## 📊 Denormalization Fixes

### **1. `players.full_name` - REDUNDANT**

**Problem:**
```sql
CREATE TABLE players (
    full_name VARCHAR(255),  -- "John Smith"
    first_name VARCHAR(100), -- "John"
    last_name VARCHAR(100)   -- "Smith"
);
```

**Issue:** Full name can be derived from parts
- Violates 1NF (redundant data)
- What if `full_name = "Johnny Smith"` but `first_name = "John"`? Which is correct?

**Fix:** Remove `full_name` column, use VIEW:
```sql
CREATE VIEW players_with_full_name AS
SELECT 
    p.*,
    CONCAT(first_name, ' ', COALESCE(middle_name || ' ', ''), last_name) AS derived_full_name
FROM players p;
```

---

### **2. `coaches.name` - REDUNDANT**

**Problem:**
```sql
CREATE TABLE coaches (
    user_id INTEGER REFERENCES users(id),
    name VARCHAR(255)  -- DUPLICATE of users.first_name + last_name!
);
```

**Issue:** Name stored in TWO tables
- Violates 3NF (transitive dependency)
- If user changes name in `users` table, `coaches.name` becomes stale

**Fix:** Remove `coaches.name`, use VIEW:
```sql
CREATE VIEW coaches_with_name AS
SELECT 
    c.*,
    CONCAT(u.first_name, ' ', u.last_name) AS derived_name
FROM coaches c
LEFT JOIN users u ON c.user_id = u.id;
```

---

## 📋 Lookup Table Standardization

**Principle:** ALL text enums must be lookup tables

### **Added Lookup Tables:**
1. **`countries`** - Replace `governing_bodies.country_code` VARCHAR
2. **`states`** - Replace `governing_bodies.state_code` VARCHAR
3. **`division_types`** - Replace `divisions.division_type` CHECK constraint
4. **`email_types`** - Replace `user_emails.email_type` CHECK constraint
5. **`phone_types`** - Replace `user_phones.phone_type` CHECK constraint

### **Populated Lookup Tables:**
6. **`alias_types`** - Was defined but empty (abbreviation, historical_name, nickname, etc.)
7. **`match_event_types`** - Expanded from 6 to 17 event types (added saves, corners, fouls, etc.)

**Benefits:**
- Consistent pattern across schema
- Sortable, extensible
- Can add descriptions and metadata
- No typos (FK constraint enforces validity)

---

## 🎯 Normalization Level Achieved

**Target:** 3NF (Third Normal Form)

**Violations Fixed:**
- ❌ 1NF Violation: `players.full_name` redundant with parsed fields → **FIXED**
- ❌ 3NF Violation: `coaches.name` transitive dependency on `users` → **FIXED**
- ❌ 3NF Violation: `player_users` duplicate relationship → **FIXED**
- ❌ Consistency: VARCHAR enums instead of lookup tables → **FIXED**

**Current Status:** ✅ **Fully Normalized to 3NF**

---

## 🚀 Next Steps

### **Before Running Migration:**
1. Review migration script: `database/migrations/001-normalize-schema-fixes.sql`
2. Test on development database first
3. Backup production database
4. Run verification queries (included in migration)

### **Application Changes Required:**
1. Update scrapers to set `players.user_id = NULL` for unclaimed players
2. Update queries using `players.full_name` → use VIEW `players_with_full_name`
3. Update queries using `coaches.name` → use VIEW `coaches_with_name`
4. Update position assignment logic to use `team_player_positions` junction
5. Remove any code referencing deleted `player_users` table

### **Scraper Updates:**
- `CasaScraper.js` - Create user+player pairs with `user_id` nullable
- `ApslScraper.js` - Same pattern as CASA
- Set `players.user_id = NULL` initially, let users claim accounts later

---

## 📝 Summary

**Critical Decisions:**
1. ✅ Keep `players` table separate from `users` (different concerns)
2. ✅ Allow `players.user_id = NULL` (unclaimed scraped players)
3. ✅ Delete `player_users` table (redundant with `players.user_id`)
4. ✅ Split position logic: `player_positions` (can play) vs `team_player_positions` (does play)
5. ✅ Remove denormalized columns: `players.full_name`, `coaches.name`
6. ✅ Standardize all enums as lookup tables

**Result:** Fully normalized 3NF schema with clear separation of concerns!
