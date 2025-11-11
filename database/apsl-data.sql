-- ========================================
-- APSL LEAGUE DATA (AUTO-GENERATED)
-- ========================================
-- Generated: 2025-11-11T21:18:51.536Z
-- Source: https://apslsoccer.com/standings/
-- Includes: Conferences, Divisions, Teams, Players
--
-- This file is automatically regenerated on rebuild.
-- Uses ON CONFLICT DO UPDATE for idempotent inserts.
-- ========================================

Fetching APSL standings page...
Scraping conferences and divisions...

-- ========================================
-- LEAGUE STRUCTURE
-- ========================================

-- APSL League
INSERT INTO leagues (id, name, display_name, sport_id, season, website, is_active)
VALUES ('00000000-0000-0000-0001-000000000001', 'APSL', 'American Premier Soccer League', '550e8400-e29b-41d4-a716-446655440101', '2024-2025', 'https://apslsoccer.com', true)
ON CONFLICT (id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  website = EXCLUDED.website,
  updated_at = CURRENT_TIMESTAMP;

-- Conferences
-- League Divisions

-- ========================================
-- CLUBS
-- ========================================

-- Sport Divisions
-- Teams

-- ========================================
-- USERS (PLAYERS)
-- ========================================

-- Note: Passwords are bcrypt-hashed. Default pattern: Player[random]!
-- Players should reset passwords on first login.

-- Player Entities
-- Team Rosters

-- ========================================
-- SCRAPE SUMMARY
-- ========================================
-- Conferences: 0
-- Divisions: 0
-- Clubs: 0
-- Teams: 0
-- Players: 0
-- Total User Accounts Created: 0
-- ========================================


✓ Scraping complete!
