-- ─────────────────────────────────────────────────────────────────────
-- 317-add-intrasquad-kind.sql (2026-08-28)
--
-- An intra-squad game is not a `match` (owner: "we need for kind a
-- special intrasquad var ... instead of match"). A match has an
-- opponent, a fixture, and a league result; an intra-squad game is one
-- club splitting itself across two sides for an afternoon.
--
-- Calling it a match caused a concrete failure the day before one:
-- ops modelled 2026-08-29 as TWO calendar events, "Lighthouse APSL vs
-- Lighthouse Liga 1" and its mirror, so players saw two fixtures at the
-- same time and RSVP'd to both. Of the 30 who answered both, 26 gave
-- the same answer twice — they were answering one question, twice —
-- and the other 4 contradicted themselves, which nobody could resolve.
-- Neither event's crest could tell them apart either, since Lighthouse
-- is on both sides of both.
--
-- With its own kind, one event carries the whole thing: one RSVP pool
-- ("am I coming?"), and the split into sides becomes a lineup decision
-- inside FH rather than a calendar-modelling trick. The sides live in
-- match_lineups keyed on fh_event_id (migration 316) — team_id for
-- intra-squad, where each side IS one of the event's fh_event_teams.
--
-- Value is 'intrasquad' — one word, lowercase.
--
-- Note the trap migration 287 fell into from the other side: jsNormAlias()
-- lowercases and collapses punctuation to single spaces, so a natural
-- "Type: Intra Squad" in a calendar description normalizes to
-- "intra squad" WITH a space and would fail this constraint. Rather than
-- store the spaced form (as 'barn night' does), parseDsl in
-- gcal-classify.js folds "intra squad" onto "intrasquad" so ops can type
-- it either way and only one value is ever stored. Keep that whitelist
-- and this constraint in step.
-- ─────────────────────────────────────────────────────────────────────

BEGIN;

ALTER TABLE fh_events DROP CONSTRAINT fh_events_kind_check;
ALTER TABLE fh_events ADD CONSTRAINT fh_events_kind_check
    CHECK (kind IN ('practice','pickup','match','meeting','camp','other','barn night','intrasquad'));

COMMIT;
