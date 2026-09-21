-- 395 — Arrival / warmup defaults per league.
--
-- Owner 2026-09-21: "for leagues there are set increments for arrival and
-- warmup from kickoff time ... if match and league with defaults in db I
-- don't need to type it out unless I override in gcal."
--
-- Minutes before kickoff, keyed on the league's organization — the same
-- row the gcal `League:` tag resolves to through gcal_league_aliases.
-- gcal-classify.js fills fh_events.arrival_at / warmup_at from these when
-- a match has no `Arrival:` / `Warmup:` tag; a typed tag always wins.
-- Kickoff itself defaults to the calendar event's start.  An event with
-- two leagues takes the earlier time.
CREATE TABLE IF NOT EXISTS league_matchday_offsets (
    organization_id        INT PRIMARY KEY REFERENCES organizations(id) ON DELETE CASCADE,
    arrival_minutes_before INT NOT NULL CHECK (arrival_minutes_before >= 0),
    warmup_minutes_before  INT NOT NULL CHECK (warmup_minutes_before  >= 0),
    CHECK (arrival_minutes_before >= warmup_minutes_before)
);

COMMENT ON TABLE league_matchday_offsets IS
    'Default arrival/warmup, in minutes before kickoff, for a league''s matches. Overridden per event by the gcal Arrival:/Warmup: tags.';

INSERT INTO league_matchday_offsets (organization_id, arrival_minutes_before, warmup_minutes_before) VALUES
    (1, 75, 45),   -- American Premier Soccer League
    (2, 60, 30),   -- CASA Soccer Leagues (Liga 1)
    (5, 30, 20),   -- Tri County Women's Soccer League
    (6, 30, 20)    -- Philadelphia Parks & Recreation
ON CONFLICT (organization_id) DO UPDATE
   SET arrival_minutes_before = EXCLUDED.arrival_minutes_before,
       warmup_minutes_before  = EXCLUDED.warmup_minutes_before;
