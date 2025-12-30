# SQLFileWriter System

## Overview
OOP-based system for persisting app-generated data to SQL files, ensuring data survives database rebuilds.

## Architecture

### Class: `SQLFileWriter`
- **Pattern**: Singleton (one instance per application)
- **Thread-Safe**: Uses mutex for concurrent file operations
- **Location**: `backend/src/core/SQLFileWriter.{h,cpp}`

### File Naming Convention
- `NNNu-<entity>.sql`: Development/update environment
- `NNNp-<entity>.sql`: Production environment

Where `NNN` is the 3-digit table number matching schema creation order:
- `019` = users
- `020` = user_emails
- `021` = user_phones
- `022` = external_identities
- `023` = admins
- `024` = clubs
- `025` = club_admins
- `026` = sport_divisions
- `027` = teams
- `028` = team_divisions
- `029` = players
- `030` = team_players (rosters)
- `031` = coaches
- `032` = team_coaches
- `033` = venues
- `034` = matches
- `042` = chats
- `046` = chat_events
- `047` = chat_event_rsvps

## Usage

### 1. Initialization (in main.cpp)
```cpp
#include "core/SQLFileWriter.h"

// Detect environment from ENVIRONMENT variable
const char* env = std::getenv("ENVIRONMENT");
auto sqlEnv = (env && std::string(env) == "production") 
    ? SQLFileWriter::Environment::PRODUCTION 
    : SQLFileWriter::Environment::DEVELOPMENT;

SQLFileWriter::getInstance().initialize(sqlEnv, "/app/database/data");
```

### 2. In Controllers (after INSERT/UPDATE)
```cpp
#include "../core/SQLFileWriter.h"

// After successful INSERT query
std::string sql = "INSERT INTO practices (id, team_id, notes) VALUES (...)";
db_->query(sql);

// Persist to -u or -p file based on environment
SQLFileWriter::getInstance().writeInsert("practices", sql + ";");
```

### 3. Entity Types
Available entity types (automatically mapped to correct file numbers):
- `"users"` → `019u-users.sql` or `019p-users.sql`
- `"user_emails"` → `020u-user-emails.sql` or `020p-user-emails.sql`
- `"user_phones"` → `021u-user-phones.sql` or `021p-user-phones.sql`
- `"external_identities"` → `022u-external-identities.sql` or `022p-external-identities.sql`
- `"admins"` → `023u-admins.sql` or `023p-admins.sql`
- `"clubs"` → `024u-clubs.sql` or `024p-clubs.sql`
- `"club_admins"` → `025u-club-admins.sql` or `025p-club-admins.sql`
- `"sport_divisions"` → `026u-sport-divisions.sql` or `026p-sport-divisions.sql`
- `"teams"` → `027u-teams.sql` or `027p-teams.sql`
- `"team_divisions"` → `028u-team-divisions.sql` or `028p-team-divisions.sql`
- `"players"` → `029u-players.sql` or `029p-players.sql`
- `"team_players"` → `030u-team-players.sql` or `030p-team-players.sql`
- `"coaches"` → `031u-coaches.sql` or `031p-coaches.sql`
- `"team_coaches"` → `032u-team-coaches.sql` or `032p-team-coaches.sql`
- `"venues"` → `033u-venues.sql` or `033p-venues.sql`
- `"matches"` → `034u-matches.sql` or `034p-matches.sql`
- `"chats"` → `042u-chats.sql` or `042p-chats.sql`
- `"chat_events"` → `046u-chat-events.sql` or `046p-chat-events.sql`
- `"chat_event_rsvps"` → `047u-chat-event-rsvps.sql` or `047p-chat-event-rsvps.sql`

## How It Works

1. User creates data via web UI (e.g., create practice)
2. Controller executes INSERT query to database
3. Controller calls `SQLFileWriter::getInstance().writeInsert()`
4. SQL statement gets appended to appropriate `-u` or `-p` file
5. Next rebuild with `./dev.sh` loads all SQL files including app-generated data
6. Data persists across rebuilds!

## Environment Detection

Set `ENVIRONMENT` variable in docker-compose.yml:
```yaml
environment:
  - ENVIRONMENT=production  # Uses -p files
  # OR
  - ENVIRONMENT=development # Uses -u files (default)
```

## Example Flow

**Dev Environment:**
1. Create practice → INSERT executed
2. SQLFileWriter appends to `034u-matches.sql`
3. `git status` shows modified file
4. Commit the change
5. Next `./dev.sh` rebuild loads the practice

**Production Environment:**
1. Create practice → INSERT executed  
2. SQLFileWriter appends to `034p-matches.sql`
3. Data persists independently from dev data

## Thread Safety
- All file operations protected by mutex
- Safe for concurrent requests
- Multiple controllers can write simultaneously

## Logging
- Console output shows which files are written:
  ```
  ✅ Appended SQL to: /app/database/data/72u-practices-app.sql
  ```
- Timestamps added to each entry for audit trail

## Integration Checklist

When adding data persistence to a new controller:

1. ✅ Include header: `#include "../core/SQLFileWriter.h"`
2. ✅ After INSERT query: call `writeInsert()`
3. ✅ Ensure SQL string ends with semicolon
4. ✅ Use correct entity type from map
5. ✅ Test by creating data and checking file
6. ✅ Verify with `git diff` to see appended SQL
7. ✅ Test rebuild loads the data successfully
