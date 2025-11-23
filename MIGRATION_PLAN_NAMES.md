# Migration Plan: User Names Normalization

## Goal
Replace single `name` column with `first_name`, `last_name`, and optional `preferred_name` columns for proper normalization.

---

## Database Changes

### 1. Schema Migration (database/schema/)
**File: Create `database/schema/migrations/001_normalize_user_names.sql`**

```sql
-- Step 1: Add new columns (nullable initially)
ALTER TABLE users 
ADD COLUMN first_name VARCHAR(100),
ADD COLUMN last_name VARCHAR(100),
ADD COLUMN preferred_name VARCHAR(100);

-- Step 2: Parse existing name data
-- Simple parser: assumes "FirstName LastName" format
UPDATE users 
SET 
    first_name = CASE 
        WHEN position(' ' in name) > 0 
        THEN split_part(name, ' ', 1)
        ELSE name
    END,
    last_name = CASE 
        WHEN position(' ' in name) > 0 
        THEN substring(name from position(' ' in name) + 1)
        ELSE ''
    END;

-- Step 3: Make new columns NOT NULL
ALTER TABLE users 
ALTER COLUMN first_name SET NOT NULL,
ALTER COLUMN last_name SET NOT NULL;

-- Step 4: Create index for common queries
CREATE INDEX idx_users_last_first_name ON users(last_name, first_name);

-- Step 5: Drop old name column
ALTER TABLE users DROP COLUMN name;

-- Step 6: Create a view for backward compatibility (temporary)
CREATE VIEW users_legacy AS 
SELECT 
    *,
    (first_name || ' ' || last_name) AS name
FROM users;
```

### 2. Update init.sql
**File: `database/schema/init.sql`**
- Update CREATE TABLE users statement
- Update INSERT statements for test data

---

## Backend Changes

### 1. AuthController.cpp
**Current code** (lines 175-189):
```cpp
std::string firstName = userData.name;
std::string lastName = "";
size_t spacePos = userData.name.find(' ');
if (spacePos != std::string::npos) {
    firstName = userData.name.substr(0, spacePos);
    lastName = userData.name.substr(spacePos + 1);
}
json << "\"name\":\"" << userData.name << "\",";
```

**New code**:
```cpp
// No parsing needed - already have first/last name from DB
json << "\"first_name\":\"" << userData.first_name << "\",";
json << "\"last_name\":\"" << userData.last_name << "\",";
json << "\"name\":\"" << userData.first_name << " " << userData.last_name << "\",";
if (!userData.preferred_name.empty()) {
    json << "\"preferred_name\":\"" << userData.preferred_name << "\",";
}
```

**Lines affected**: 175-181, 189

### 2. EventController.cpp - RSVP Query
**Current code** (line 661):
```cpp
"u.name, u.email "
```

**New code**:
```cpp
"u.first_name, u.last_name, COALESCE(u.preferred_name, '') as preferred_name, u.email "
```

**Then in JSON building** (around line 672):
```cpp
std::string user_name = escapeJSON(result[i]["first_name"].c_str()) + " " + 
                        escapeJSON(result[i]["last_name"].c_str());
```

### 3. TeamController.cpp (Team.cpp model)
**Files affected**:
- `backend/src/models/Team.cpp` lines 83, 98, 126

**Update all queries**:
```cpp
// Change from:
"u.name, "

// To:
"u.first_name, u.last_name, "
```

**Update JSON building to concatenate**:
```cpp
"\"name\": \"" + first_name + " " + last_name + "\", "
```

### 4. Update User struct/class
**If there's a User struct** - update fields:
```cpp
struct UserData {
    std::string id;
    std::string email;
    std::string first_name;
    std::string last_name;
    std::string preferred_name;
    std::string password_hash;
    // ... other fields
};
```

---

## Frontend Changes

### 1. auth.js
**Current**: Returns user with `name` field
**Change**: Backend will return both `first_name`, `last_name`, AND `name` (computed)
**Action**: No change needed - backend provides `name` for display

### 2. role-selection.js
**Current code** (line 8):
```javascript
const userName = user?.name || user?.email || 'User';
```

**Keep as-is**: Backend will provide computed `name` field

### 3. Navigation context header
**File**: `navigation.js` (line 38)
**Current**: Uses `user?.email`
**Consider**: Could display as "First L." or "Preferred Name"
**Action**: Future enhancement, keep as-is for now

### 4. Practice RSVP display
**File**: `practice-list.js`
**Current**: Receives `user_name` from backend
**Action**: No change needed - backend computes full name

---

## Scraping Script Changes

### 1. database/apsl/scrape-apsl.js

**Current code** (lines 271, 295):
```javascript
const playerName = nameDiv?.textContent.trim();

// Store user
users.set(userId, {
  id: userId,
  email: email,
  name: playerName,
  password: password
});
```

**New code** - Parse names:
```javascript
const playerName = nameDiv?.textContent.trim();

// Parse name into first/last
// Handle formats: "First Last", "First Middle Last", "First"
let firstName = playerName;
let lastName = '';

const nameParts = playerName.trim().split(/\s+/);
if (nameParts.length >= 2) {
  firstName = nameParts[0];
  lastName = nameParts.slice(1).join(' '); // Everything after first name
}

// Store user
users.set(userId, {
  id: userId,
  email: email,
  first_name: firstName,
  last_name: lastName,
  password: password
});
```

**Current INSERT statement** (lines 407-417):
```javascript
console.log(`INSERT INTO users (id, email, name, password_hash, is_active)`);
console.log(`VALUES (`);
console.log(`  ${sqlEscape(user.id)},`);
console.log(`  ${sqlEscape(user.email)},`);
console.log(`  ${sqlEscape(user.name)},`);
console.log(`  crypt(${sqlEscape(user.password)}, gen_salt('bf')),`);
console.log(`  true`);
console.log(`)`);
console.log(`ON CONFLICT (email) DO UPDATE SET`);
console.log(`  name = EXCLUDED.name,`);
```

**New INSERT statement**:
```javascript
console.log(`INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)`);
console.log(`VALUES (`);
console.log(`  ${sqlEscape(user.id)},`);
console.log(`  ${sqlEscape(user.email)},`);
console.log(`  ${sqlEscape(user.first_name)},`);
console.log(`  ${sqlEscape(user.last_name)},`);
console.log(`  crypt(${sqlEscape(user.password)}, gen_salt('bf')),`);
console.log(`  true`);
console.log(`)`);
console.log(`ON CONFLICT (email) DO UPDATE SET`);
console.log(`  first_name = EXCLUDED.first_name,`);
console.log(`  last_name = EXCLUDED.last_name,`);
```

---

## Summary of Files to Modify

### Database (2 files)
1. ✅ Create `database/schema/migrations/001_normalize_user_names.sql`
2. ✅ Update `database/schema/init.sql` - users table definition and seed data

### Backend (4 files)
1. ✅ `backend/src/controllers/AuthController.cpp` - Login response JSON
2. ✅ `backend/src/controllers/EventController.cpp` - RSVP queries
3. ✅ `backend/src/models/Team.cpp` - Team roster queries  
4. ✅ `backend/src/main_old.cpp` - If still used (can skip if deprecated)

### Scraping Scripts (1 file)
1. ✅ `database/apsl/scrape-apsl.js` - Parse player names into first/last

### Frontend (0 files)
- **No changes needed** - Backend provides backward-compatible `name` field

**Total: 7 files to modify**

---

## Migration Steps

### Step 1: Database Migration
```bash
# Run migration
./database/scripts/run-sql.sh < database/schema/migrations/001_normalize_user_names.sql

# Verify
./database/scripts/run-sql.sh "SELECT first_name, last_name, preferred_name FROM users LIMIT 5;"
```

### Step 2: Update Schema Definition
- Update init.sql for future deployments

### Step 3: Update Backend
- Modify 4 backend files
- Update queries to use first_name, last_name
- Compute full name in JSON responses

### Step 4: Rebuild & Test
```bash
docker compose build backend
docker compose up -d backend

# Test:
# 1. Login - verify user data returned
# 2. View practices - verify RSVP names display
# 3. Team rosters - verify names display
```

### Step 5: Future Enhancements
- Add preferred_name input to user profile forms
- Add "display as" options (First Last, Last First, Preferred)
- Update scraping scripts to parse names during import

---

## Rollback Plan

If issues arise:
```sql
-- Restore name column
ALTER TABLE users ADD COLUMN name VARCHAR(100);
UPDATE users SET name = first_name || ' ' || last_name;
ALTER TABLE users ALTER COLUMN name SET NOT NULL;

-- Remove new columns
ALTER TABLE users DROP COLUMN first_name;
ALTER TABLE users DROP COLUMN last_name;
ALTER TABLE users DROP COLUMN preferred_name;
```

---

## Risk Assessment

**LOW RISK** because:
- ✅ Backend will continue providing `name` field (computed) for compatibility
- ✅ No frontend changes required
- ✅ Existing APIs remain compatible
- ✅ Can test thoroughly before pushing to production
- ✅ Simple rollback available

**Testing checklist**:
- [ ] Login returns user with name
- [ ] RSVP list shows correct names
- [ ] Team rosters display properly
- [ ] Name parsing handles edge cases (single names, etc.)
