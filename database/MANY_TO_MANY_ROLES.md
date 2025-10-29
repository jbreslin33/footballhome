# Many-to-Many Role Normalization - Football Home v2.1

## Overview
Following the initial database normalization, we've implemented a **many-to-many relationship** for user roles, which is the proper normalized approach. This allows users to have multiple roles simultaneously and provides better flexibility for real-world scenarios.

## Architecture Change

### Before: One-to-Many (Suboptimal)
```sql
users table
├── user_role_id → roles.id (single foreign key)

user_roles table (renamed to roles)
├── id, name, display_name, permissions
```
**Limitation**: Each user could have exactly one role.

### After: Many-to-Many (Proper Normalization)
```sql
users table (no direct role reference)
├── id, email, name, phone, etc.

roles table 
├── id, name, display_name, permissions

user_roles table (junction/bridge table)
├── user_id → users.id
├── role_id → roles.id  
├── assigned_at, assigned_by, is_active, expires_at, notes
```
**Flexibility**: Users can have 0, 1, or many roles with full audit trail.

## Database Schema Changes

### 1. Renamed Table
```sql
-- BEFORE
CREATE TABLE user_roles (...)

-- AFTER  
CREATE TABLE roles (...)  -- Clearer naming
```

### 2. Removed Direct Foreign Key
```sql
-- BEFORE
CREATE TABLE users (
    ...
    user_role_id UUID NOT NULL REFERENCES user_roles(id)
);

-- AFTER
CREATE TABLE users (
    ...
    -- No direct role reference
    is_active BOOLEAN DEFAULT true
);
```

### 3. New Junction Table
```sql
CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by UUID REFERENCES users(id),      -- Audit: who granted this role
    is_active BOOLEAN DEFAULT true,             -- Role can be suspended
    expires_at TIMESTAMP,                       -- Optional role expiration
    notes TEXT,                                 -- Assignment notes
    UNIQUE(user_id, role_id)                   -- Prevent duplicate assignments
);
```

### 4. Enhanced Roles Table
```sql
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(20) UNIQUE NOT NULL,
    display_name VARCHAR(50) NOT NULL,
    description TEXT,                          -- Role description
    permissions TEXT[],
    is_system_role BOOLEAN DEFAULT false,      -- Cannot be deleted
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## New Role Types Added

### System Roles (cannot be deleted)
- **admin**: Full system access
- **coach**: Team management capabilities  
- **player**: Basic player access

### Custom Roles (can be deleted/modified)
- **assistant_coach**: Limited coaching capabilities
- **parent**: Parent/guardian access

## Real-World Use Cases Now Supported

### 1. Multi-Role Users
```sql
-- Player who also assists with coaching
INSERT INTO user_roles (user_id, role_id, notes) VALUES 
('user-123', 'player-role-id', 'Team midfielder'),
('user-123', 'assistant_coach-role-id', 'Helps with youth development');
```

### 2. Temporary Roles
```sql
-- Temporary admin access
INSERT INTO user_roles (user_id, role_id, expires_at, notes) VALUES 
('user-456', 'admin-role-id', '2025-12-31 23:59:59', 'Temporary admin during coach absence');
```

### 3. Role Suspension
```sql
-- Suspend role without deleting assignment
UPDATE user_roles SET is_active = false 
WHERE user_id = 'user-789' AND role_id = 'coach-role-id';
```

### 4. Role Audit Trail
```sql
-- Track who assigned roles and when
SELECT 
    u.name as user_name,
    r.display_name as role_name,
    ur.assigned_at,
    assigner.name as assigned_by,
    ur.notes
FROM user_roles ur
JOIN users u ON ur.user_id = u.id
JOIN roles r ON ur.role_id = r.id
LEFT JOIN users assigner ON ur.assigned_by = assigner.id
WHERE ur.is_active = true;
```

## API Changes

### Updated Authentication Response
```javascript
// BEFORE
{
  "user": {
    "role": "coach",
    "role_display": "Coach"
  }
}

// AFTER
{
  "user": {
    "roles": ["player", "assistant_coach"],
    "role_displays": ["Player", "Assistant Coach"],
    "primary_role": "player"
  }
}
```

### New Role Management Endpoints
```javascript
GET    /api/roles                    // List all available roles
GET    /api/users/:userId/roles      // Get user's role assignments
POST   /api/users/:userId/roles      // Assign role to user
DELETE /api/users/:userId/roles/:roleId  // Remove role from user
```

### Enhanced User Queries
```sql
-- Get user with all active roles
SELECT 
  u.*,
  array_agg(r.name) FILTER (WHERE r.name IS NOT NULL AND ur.is_active = true) as roles,
  array_agg(r.display_name) FILTER (WHERE r.display_name IS NOT NULL AND ur.is_active = true) as role_displays
FROM users u 
LEFT JOIN user_roles ur ON u.id = ur.user_id AND ur.is_active = true
LEFT JOIN roles r ON ur.role_id = r.id
WHERE u.email = $1 AND u.is_active = true
GROUP BY u.id;
```

## Sample Data Structure

### Users and Their Roles
```
Admin Alice Cooper
├── admin (assigned by: system)

Coach Sarah Martinez  
├── coach (assigned by: Admin Alice Cooper)

Alex Johnson (Team Captain)
├── player (assigned by: Coach Sarah Martinez)
└── assistant_coach (assigned by: Coach Sarah Martinez) -- Multi-role example!

Maria Rodriguez
├── player (assigned by: Coach Sarah Martinez)

...and so on
```

### Role Assignment Examples
```sql
-- Basic player role
('player-id', 'player-role-id', 'Coach Sarah', true, null, 'Team midfielder')

-- Multi-role user  
('alex-id', 'player-role-id', 'Coach Sarah', true, null, 'Team captain and midfielder')
('alex-id', 'assistant_coach-role-id', 'Coach Sarah', true, null, 'Assists with youth development')

-- Temporary admin
('temp-admin-id', 'admin-role-id', 'Admin Alice', true, '2025-12-31', 'Temporary admin during transition')
```

## Migration Benefits

### ✅ Flexibility
- **Multiple roles per user**: Coach who also plays, parent who assists
- **Role combinations**: Any combination of roles possible
- **Granular permissions**: Each role contributes its permissions

### ✅ Auditability  
- **Assignment tracking**: Who assigned roles and when
- **Change history**: Full audit trail of role changes
- **Reason documentation**: Notes field for assignment reasoning

### ✅ Temporal Support
- **Expiring roles**: Temporary access that auto-expires
- **Role suspension**: Deactivate without deleting history
- **Reactivation**: Easily restore suspended roles

### ✅ Administrative Control
- **System vs custom roles**: Protect critical roles from deletion
- **Permission aggregation**: User gets combined permissions from all active roles
- **Flexible management**: Add/remove roles without touching user records

## Frontend Implications

### Role Checking
```javascript
// BEFORE
if (user.role === 'coach') { ... }

// AFTER  
if (user.roles.includes('coach')) { ... }
// OR for primary role
if (user.primary_role === 'coach') { ... }
```

### Permission Checking
```javascript
// Check if user has any role with specific permission
function userCanManageEvents(user) {
  return user.roles.some(role => 
    rolePermissions[role]?.includes('manage_events')
  );
}
```

### Role Display
```javascript
// Show all roles
user.role_displays.join(', ')  // "Player, Assistant Coach"

// Show primary role
user.role_displays[0]  // "Player"
```

## Performance Considerations

### New Indexes
```sql
CREATE INDEX idx_user_roles_user ON user_roles(user_id);
CREATE INDEX idx_user_roles_role ON user_roles(role_id);  
CREATE INDEX idx_user_roles_active ON user_roles(user_id, is_active);
```

### Optimized Queries
- Role checks use indexed joins instead of string comparisons
- Array aggregation reduces multiple queries to single query
- Filtered aggregation only includes active roles

## Security Enhancements

### Role Assignment Control
- Only users with appropriate permissions can assign roles
- System roles cannot be accidentally deleted
- Assignment audit trail for security compliance

### Permission Aggregation
- Users get union of all their active roles' permissions
- Expired roles automatically excluded from permission calculations
- Role suspension immediately revokes access

---

## Migration Summary

✅ **Proper Many-to-Many Normalization**: Users can have multiple roles
✅ **Enhanced Audit Trail**: Track role assignments and changes  
✅ **Temporal Role Support**: Expiring and suspended roles
✅ **Flexible Role Management**: Add/remove roles without data loss
✅ **Real-World Scenarios**: Supports complex organizational structures
✅ **Performance Optimized**: Proper indexing and efficient queries
✅ **Security Enhanced**: Better permission control and auditing

The Football Home platform now supports sophisticated role management that can adapt to complex real-world team structures! 🎉