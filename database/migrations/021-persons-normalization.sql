-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 021: Normalize user data into persons/person_emails/person_phones
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Moves first_name, last_name, date_of_birth out of users into a persons
-- table. Moves email into person_emails. Moves phone into person_phones.
-- Adds person_id FK to users, players, coaches.
-- Adds user_id to admins (code expects admins.user_id, not admins.id=users.id).
--
-- This bridges the old UUID-based schema to the new normalized model.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

-- ──────────────────────────────────────────────────────────────────────
-- 1. Create persons table (SERIAL INTEGER PK, matching 00-schema.sql)
-- ──────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS persons (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birth_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_persons_name ON persons(last_name, first_name);
CREATE INDEX IF NOT EXISTS idx_persons_birth_date ON persons(birth_date);

-- ──────────────────────────────────────────────────────────────────────
-- 2. Create email_types and phone_types lookup tables
-- ──────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS email_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO email_types (id, name, description, sort_order) VALUES
    (1, 'personal', 'Personal email address', 1),
    (2, 'work', 'Work email address', 2),
    (3, 'school', 'School/university email', 3)
ON CONFLICT (name) DO NOTHING;

CREATE TABLE IF NOT EXISTS phone_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO phone_types (id, name, description, sort_order) VALUES
    (1, 'mobile', 'Mobile phone', 1),
    (2, 'home', 'Home phone', 2),
    (3, 'work', 'Work phone', 3),
    (4, 'emergency', 'Emergency contact phone', 4)
ON CONFLICT (name) DO NOTHING;

-- ──────────────────────────────────────────────────────────────────────
-- 3. Create person_emails table
-- ──────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS person_emails (
    id SERIAL PRIMARY KEY,
    person_id INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL UNIQUE,
    email_type_id INTEGER REFERENCES email_types(id),
    is_primary BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(person_id, email)
);

CREATE INDEX IF NOT EXISTS idx_person_emails_person ON person_emails(person_id);
CREATE INDEX IF NOT EXISTS idx_person_emails_email ON person_emails(email);
CREATE INDEX IF NOT EXISTS idx_person_emails_primary ON person_emails(person_id, is_primary) WHERE is_primary = true;

-- ──────────────────────────────────────────────────────────────────────
-- 4. Create person_phones table
-- ──────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS person_phones (
    id SERIAL PRIMARY KEY,
    person_id INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    phone_number VARCHAR(20) NOT NULL,
    phone_type_id INTEGER REFERENCES phone_types(id),
    is_primary BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    can_receive_sms BOOLEAN DEFAULT true,
    can_receive_calls BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(person_id, phone_number)
);

CREATE INDEX IF NOT EXISTS idx_person_phones_person ON person_phones(person_id);
CREATE INDEX IF NOT EXISTS idx_person_phones_number ON person_phones(phone_number);
CREATE INDEX IF NOT EXISTS idx_person_phones_primary ON person_phones(person_id, is_primary) WHERE is_primary = true;

-- ──────────────────────────────────────────────────────────────────────
-- 5. Add person_id to users, populate from existing data
-- ──────────────────────────────────────────────────────────────────────

-- Create a person for every existing user
INSERT INTO persons (first_name, last_name, birth_date)
SELECT first_name, last_name, date_of_birth
FROM users
ORDER BY last_name, first_name;

-- Add person_id column to users
ALTER TABLE users ADD COLUMN IF NOT EXISTS person_id INTEGER UNIQUE REFERENCES persons(id) ON DELETE CASCADE;

-- Populate person_id by matching on name (unique in persons)
UPDATE users u
SET person_id = p.id
FROM persons p
WHERE p.first_name = u.first_name AND p.last_name = u.last_name;

CREATE INDEX IF NOT EXISTS idx_users_person ON users(person_id);

-- Migrate emails to person_emails
INSERT INTO person_emails (person_id, email, email_type_id, is_primary, is_verified)
SELECT u.person_id, u.email, 1, true, true
FROM users u
WHERE u.email IS NOT NULL AND u.email != '' AND u.person_id IS NOT NULL
ON CONFLICT (email) DO NOTHING;

-- Migrate phones to person_phones
INSERT INTO person_phones (person_id, phone_number, phone_type_id, is_primary)
SELECT u.person_id, u.phone, 1, true
FROM users u
WHERE u.phone IS NOT NULL AND u.phone != '' AND u.person_id IS NOT NULL
ON CONFLICT (person_id, phone_number) DO NOTHING;

-- ──────────────────────────────────────────────────────────────────────
-- 6. Add person_id to players, populate from existing data
-- ──────────────────────────────────────────────────────────────────────
-- Current: players.id FK→ users.id (UUID). We add person_id INTEGER FK→ persons.
ALTER TABLE players ADD COLUMN IF NOT EXISTS person_id INTEGER UNIQUE REFERENCES persons(id) ON DELETE CASCADE;

-- Players.id = users.id, so look up the person_id from users
UPDATE players pl
SET person_id = u.person_id
FROM users u
WHERE pl.id = u.id AND u.person_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_players_person ON players(person_id);

-- ──────────────────────────────────────────────────────────────────────
-- 7. Add person_id to coaches, populate from existing data
-- ──────────────────────────────────────────────────────────────────────
-- Current: coaches.id FK→ users.id (UUID). We add person_id INTEGER FK→ persons.
ALTER TABLE coaches ADD COLUMN IF NOT EXISTS person_id INTEGER UNIQUE REFERENCES persons(id) ON DELETE CASCADE;

-- Coaches.id = users.id, so look up the person_id from users
UPDATE coaches c
SET person_id = u.person_id
FROM users u
WHERE c.id = u.id AND u.person_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_coaches_person ON coaches(person_id);

-- ──────────────────────────────────────────────────────────────────────
-- 8. Add user_id to admins (code expects admins.user_id, not admins.id=users.id)
-- ──────────────────────────────────────────────────────────────────────
-- Current: admins.id FK→ users.id (admins.id IS the user UUID)
-- Code expects: admins.user_id FK→ users.id (separate column)
ALTER TABLE admins ADD COLUMN IF NOT EXISTS user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE;

-- Populate: the current admins.id IS the user's UUID
UPDATE admins SET user_id = id WHERE user_id IS NULL;

CREATE INDEX IF NOT EXISTS idx_admins_user ON admins(user_id);

COMMIT;
