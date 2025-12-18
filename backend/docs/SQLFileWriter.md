# SQLFileWriter System

## Overview
OOP-based system for persisting app-generated data to SQL files, ensuring data survives database rebuilds.

## Architecture

### Class: `SQLFileWriter`
- **Pattern**: Singleton (one instance per application)
- **Thread-Safe**: Uses mutex for concurrent file operations
- **Location**: `backend/src/core/SQLFileWriter.{h,cpp}`

### File Naming Convention
- `##u-<entity>-app.sql`: Development/update environment
- `##p-<entity>-app.sql`: Production environment

Where `##` is:
- `08` = users
- `21` = teams
- `22` = players
- `23` = team_players (rosters)
- `24` = coaches
- `25` = team_coaches
- `30` = schedule (matches)
- `72` = practices

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
Available entity types:
- `"users"` → `08u-users-app.sql` or `08p-users-app.sql`
- `"teams"` → `21u-teams-app.sql` or `21p-teams-app.sql`  
- `"players"` → `22u-players-app.sql` or `22p-players-app.sql`
- `"team_players"` → `23u-team-players-app.sql` or `23p-team-players-app.sql`
- `"coaches"` → `24u-coaches-app.sql` or `24p-coaches-app.sql`
- `"team_coaches"` → `25u-team-coaches-app.sql` or `25p-team-coaches-app.sql`
- `"schedule"` → `30u-schedule-app.sql` or `30p-schedule-app.sql`
- `"practices"` → `72u-practices-app.sql` or `72p-practices-app.sql`

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
2. SQLFileWriter appends to `72u-practices-app.sql`
3. `git status` shows modified file
4. Commit the change
5. Next `./dev.sh` rebuild loads the practice

**Production Environment:**
1. Create practice → INSERT executed  
2. SQLFileWriter appends to `72p-practices-app.sql`
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
