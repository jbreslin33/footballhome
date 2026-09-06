-- Youth paperwork steps in the roster-status pipeline (owner 2026-09-06).
--
-- The status dropdown already carries the men's paperwork pipeline
-- (Needs ITC → Submitted ITC → Needs Transfer → Awaiting Transfer →
-- On Roster).  Youth players moving from intramural to travel need
-- their own two steps: the Philadelphia Parks & Rec league wants a
-- birth certificate + headshot uploaded before a travel spot is
-- confirmed.
--
--   needs_docs — coach has asked (or should ask) for the upload.  The
--                📄 DOCS button and the welcome email's docs paragraph
--                key off this.
--   has_docs   — documents in hand; player is ready to move up but may
--                be waiting on a travel spot.  Green on the card so the
--                coach never asks twice.
--
-- Both count for RSVP; neither is an official roster placement.  The
-- docs steps sort just before Awaiting Roster Spot, so the youth
-- pipeline reads Needs Docs → Has Docs → Awaiting Roster Spot → On
-- Roster.  MensTeamAssignments carries a docs status across a move to
-- a new team, because the documents are a fact about the child, not
-- the team.
BEGIN;
INSERT INTO roster_statuses
    (id, code, display_name, description, show_in_rsvp, show_in_official_roster, sort_order, is_active)
VALUES
    (11, 'needs_docs', 'Needs Docs', 'Birth certificate + headshot not yet uploaded — ask the parent (📄 DOCS)', true, false, 6, true),
    (12, 'has_docs',   'Has Docs',   'Birth certificate + headshot received — ready to move up when a spot opens', true, false, 7, true)
ON CONFLICT (id) DO NOTHING;
UPDATE roster_statuses SET sort_order = 8  WHERE code = 'awaiting_roster_spot';
UPDATE roster_statuses SET sort_order = 9  WHERE code = 'awaiting_approval';
UPDATE roster_statuses SET sort_order = 10 WHERE code = 'on_roster';
UPDATE roster_statuses SET sort_order = 11 WHERE code = 'possible_drop';
UPDATE roster_statuses SET sort_order = 12 WHERE code = 'suspended';
COMMIT;
