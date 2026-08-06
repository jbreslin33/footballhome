-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 265: club_sections + teams.club_section_id
--
-- Implements the "New scope this ADR didn't cover: club sections" DDL
-- sketch in docs/adr/2026-07-30-roster-membership-rsvp-normalization.md.
-- Separate from roster membership — this is about the club/organization
-- hierarchy ("Mens Club"/"Boys Club"/etc under Lighthouse), which today
-- only exists as the bare string teams.gender_category with nothing to
-- hang section-specific config on and no composed display name
-- ("Lighthouse Mens Club") without hardcoding it somewhere.
--
-- `gender_category` stays as-is (read by 8 backend + 6 frontend files)
-- rather than a big-bang replace — club_section_id becomes the real
-- relationship in parallel; screens migrate onto composed labels
-- opportunistically.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

-- Same shape as match_types/admin_levels — section names have no
-- per-club attributes of their own, so one small lookup table covers
-- every club rather than a junction/config table per club.
CREATE TABLE club_sections (
    id         SERIAL PRIMARY KEY,
    name       TEXT NOT NULL UNIQUE,   -- 'Mens','Womens','Boys','Girls'
                                        -- (matches existing gender_category values)
    code       TEXT,
    sort_order INTEGER
);

INSERT INTO club_sections (name, code, sort_order) VALUES
    ('Mens',   'M', 1),
    ('Womens', 'W', 2),
    ('Boys',   'B', 3),
    ('Girls',  'G', 4);

-- A team's section applies only to kind='official' teams — internal/
-- admin_bucket teams stay unlinked from club_section_id, same as
-- they're already unlinked from division_id (decision 1: "internal
-- groups... connect to nothing"). Display label ("Lighthouse Mens
-- Club") is composed at read time by joining organizations/clubs/
-- club_sections, never stored.
ALTER TABLE teams ADD COLUMN club_section_id INTEGER REFERENCES club_sections(id);

-- Backfill from gender_category for the 16 Lighthouse (club_id=134)
-- official teams named in the ADR's session-update table. Scoped to
-- this club only — other clubs' official teams (opponents, etc.)
-- don't get a section relationship in this pass.
UPDATE teams t
   SET club_section_id = cs.id
  FROM club_sections cs
 WHERE t.club_id = 134
   AND t.kind = 'official'
   AND LOWER(cs.name) = t.gender_category;

COMMIT;
