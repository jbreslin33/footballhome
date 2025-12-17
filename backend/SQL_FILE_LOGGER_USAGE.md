# SQL File Logger Usage Guide

## Overview

The `SqlFileLogger` automatically logs all database INSERT/UPDATE/DELETE operations to `##u` (dev) or `##p` (production) files. These files are version-controlled and loaded on database rebuild.

## Initialization

The logger is automatically initialized in `main.cpp` on server startup:

```cpp
// In HttpServer::initialize()
SqlFileLogger::initialize();  // Reads ENVIRONMENT from env var
```

## Usage in Controllers

### Example: Create User

```cpp
#include "database/SqlFileLogger.h"
#include "database/SqlBuilder.h"

Response AuthController::handleRegister(const Request& request) {
    // Extract data from request
    std::string email = extractField(request.getBody(), "email");
    std::string name = extractField(request.getBody(), "name");
    std::string phone = extractField(request.getBody(), "phone");
    
    // Generate UUID for new user
    std::string user_id = generateUUID();
    
    // Insert into database
    try {
        auto txn = db_->beginTransaction();
        
        std::string sql = "INSERT INTO users (id, email, first_name, phone, is_active) "
                         "VALUES ('" + user_id + "', '" + email + "', '" + name + "', '" + phone + "', true)";
        
        txn->exec(sql);
        db_->commit(txn);
        
        // Log to ##u or ##p file
        std::map<std::string, std::string> columns = {
            {"email", email},
            {"first_name", name},
            {"phone", phone},
            {"is_active", "true"}
        };
        
        std::string upsert_sql = SqlBuilder::buildUpsert("users", user_id, columns);
        SqlFileLogger::log("users", upsert_sql);
        
        return Response(HttpStatus::OK, createJSONResponse(true, "User created"));
        
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       createJSONResponse(false, "Database error"));
    }
}
```

### Example: Update User

```cpp
Response UserController::updateProfile(const Request& request) {
    std::string user_id = extractField(request.getBody(), "id");
    std::string email = extractField(request.getBody(), "email");
    std::string phone = extractField(request.getBody(), "phone");
    
    try {
        // Update database
        auto txn = db_->beginTransaction();
        txn->exec("UPDATE users SET email = '" + email + "', phone = '" + phone + "' "
                 "WHERE id = '" + user_id + "'");
        db_->commit(txn);
        
        // Log as upsert (handles both insert and update)
        std::map<std::string, std::string> columns = {
            {"email", email},
            {"phone", phone}
        };
        
        std::string upsert_sql = SqlBuilder::buildUpsert("users", user_id, columns);
        SqlFileLogger::log("users", upsert_sql);
        
        return Response(HttpStatus::OK, createJSONResponse(true, "Profile updated"));
        
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                       createJSONResponse(false, "Update failed"));
    }
}
```

### Example: Add Player to Team

```cpp
Response TeamController::addPlayer(const Request& request) {
    std::string team_id = extractField(request.getBody(), "team_id");
    std::string player_id = extractField(request.getBody(), "player_id");
    std::string jersey_number = extractField(request.getBody(), "jersey_number");
    
    try {
        auto txn = db_->beginTransaction();
        txn->exec("INSERT INTO team_players (team_id, player_id, jersey_number, is_active) "
                 "VALUES ('" + team_id + "', '" + player_id + "', " + jersey_number + ", true)");
        db_->commit(txn);
        
        // Log to 23u-team-players-app.sql or 23p-team-players-app.sql
        std::map<std::string, std::string> columns = {
            {"player_id", player_id},
            {"jersey_number", jersey_number},
            {"is_active", "true"}
        };
        
        // For junction tables, use composite key
        std::string upsert_sql = SqlBuilder::buildUpsert("team_players", team_id, columns, "team_id");
        SqlFileLogger::log("team_players", upsert_sql);
        
        return Response(HttpStatus::OK, createJSONResponse(true, "Player added"));
        
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                       createJSONResponse(false, "Failed to add player"));
    }
}
```

## Table → File Mapping

The logger automatically maps tables to the correct numbered files:

| Table          | File Number | Dev File                      | Prod File                      |
|----------------|-------------|-------------------------------|--------------------------------|
| users          | 08          | 08u-users-app.sql             | 08p-users-app.sql              |
| teams          | 21          | 21u-teams-app.sql             | 21p-teams-app.sql              |
| players        | 22          | 22u-players-app.sql           | 22p-players-app.sql            |
| team_players   | 23          | 23u-team-players-app.sql      | 23p-team-players-app.sql       |
| coaches        | 24          | 24u-coaches-app.sql           | 24p-coaches-app.sql            |
| team_coaches   | 25          | 25u-team-coaches-app.sql      | 25p-team-coaches-app.sql       |
| matches/events | 30          | 30u-schedule-app.sql          | 30p-schedule-app.sql           |

## Environment Detection

The logger checks the `ENVIRONMENT` variable:
- `dev` → writes to ##u files
- `production` → writes to ##p files
- Empty/other → logging disabled (during init)

## Output Format

Generated SQL files contain upsert statements with timestamps:

```sql
-- Logged at: 2025-12-17 14:30:45
INSERT INTO users (id, email, first_name, phone, is_active) 
VALUES ('550e8400-e29b-41d4-a716-446655440000', 'user@example.com', 'John Doe', '555-1234', true)
ON CONFLICT (id) DO UPDATE SET 
  email = EXCLUDED.email, 
  first_name = EXCLUDED.first_name, 
  phone = EXCLUDED.phone, 
  is_active = EXCLUDED.is_active;

-- Logged at: 2025-12-17 14:35:22
INSERT INTO users (id, email, first_name, phone, is_active)
VALUES ('550e8400-e29b-41d4-a716-446655440000', 'newemail@example.com', 'John Doe', '555-5678', true)
ON CONFLICT (id) DO UPDATE SET 
  email = EXCLUDED.email,
  first_name = EXCLUDED.first_name,
  phone = EXCLUDED.phone,
  is_active = EXCLUDED.is_active;
```

## Best Practices

1. **Always log after successful commit**: Only log if transaction succeeds
2. **Use upserts**: Makes SQL idempotent (can replay multiple times)
3. **Include all columns**: Full state capture, not just changed fields
4. **Wrap in try-catch**: Don't let logging failures crash the app
5. **Test both environments**: Verify ##u and ##p files generate correctly

## Testing

```bash
# Dev mode (generates ##u files)
./dev.sh

# Production mode (generates ##p files)
./dev.sh --production

# Wipe dev data
./dev.sh --wipe-u

# Wipe production data
./dev.sh --wipe-p
```

## Troubleshooting

**Files not being created:**
- Check ENVIRONMENT variable is set correctly
- Verify `/app/database/data` is mounted in docker-compose
- Check file permissions on host `database/data/` directory

**SQL errors on rebuild:**
- Ensure upserts use `ON CONFLICT` clause
- Verify all columns exist in schema
- Check for SQL syntax errors in generated files

**Large file sizes:**
- Normal! Files grow with every operation
- Use `--wipe-u` or `--wipe-p` to reset
- Manually edit files to remove unwanted data
