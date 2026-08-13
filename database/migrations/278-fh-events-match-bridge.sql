-- 278 — Bridge the current calendar event system (gcal_events → fh_events)
-- to the lineup system (matches / match_lineups), which today is only
-- reachable through the OLDER chat_events-based event system.
--
-- Mirrors the existing chat_event_create_match() trigger (see this file's
-- header comment vs. that function, ~L81 of 00-schema.sql), adapted for
-- fh_events/fh_event_teams:
--
--   * Fires AFTER INSERT on fh_event_teams (not fh_events) because
--     scripts/gcal-classify.js's classifyDsl() upserts fh_events THEN
--     rebuilds fh_event_teams in the SAME transaction — firing on the
--     junction table guarantees the parent fh_events row is already
--     visible (transaction-local MVCC) when this trigger runs.
--
--   * Only acts when the parent fh_event's kind = 'match' (the only kind
--     that denotes a real game; practice/pickup/meeting/camp/other are
--     not lineup-relevant).
--
--   * Home team = MIN(team_id) among ALL teams currently tagged on that
--     fh_event. Verified against live data: of the 11 kind='match' rows
--     ever synced, 6 have more than one team tagged — always our OWN
--     overlapping feeder-pool squads (first team + reserves + trialists)
--     called up to ONE external match, never two opposing internal
--     teams. MIN(team_id) matched the human-typed gcal summary's
--     intended team in all 6 cases. Known limitation, accepted given the
--     tiny volume: other tagged teams' coaches see that match read-only
--     rather than getting their own edit link.
--
--   * Away team is always NULL — fh_events.opponent is free text (see
--     migration 228), never a resolvable teams.id — same as the existing
--     chat_events path.
--
--   * match_type_id = 2 ('custom'), not 3 ('practice') like the
--     chat_events path uses — these ARE real matches. 2 is valid here
--     because check_match_teams exempts match_type_id IN (2,3,5) from
--     the "home AND away both NOT NULL" requirement.
--
--   * Since the trigger fires once per row inserted into the junction
--     (not once per event), and gcal-classify.js's INSERT ... SELECT
--     FROM unnest(...) can insert several team rows for one event in one
--     statement, this recomputes MIN(team_id) fresh on every firing.
--     Intermediate "wrong" picks during a multi-row batch are never
--     externally visible — nothing commits until classifyDsl()'s own
--     COMMIT, after which the MIN has converged to the final full set.
--
--   * Freeze guard: once match_lineups rows exist for the bridged match,
--     a later re-classify (e.g. a trialist promoted, teams re-tagged)
--     must not silently reassign an already-lineup'd match to a
--     different team.

BEGIN;

ALTER TABLE fh_events ADD COLUMN IF NOT EXISTS match_id INTEGER REFERENCES matches(id);
CREATE INDEX IF NOT EXISTS idx_fh_events_match_id ON fh_events (match_id) WHERE match_id IS NOT NULL;

CREATE OR REPLACE FUNCTION fh_event_team_create_match() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_kind             TEXT;
    v_fh_event_id      BIGINT;
    v_gcal_event_id    BIGINT;
    v_fh_notes         TEXT;
    v_primary_team_id  INTEGER;
    v_new_match_id     INTEGER;
BEGIN
    SELECT id, kind, gcal_event_id, fh_notes
      INTO v_fh_event_id, v_kind, v_gcal_event_id, v_fh_notes
      FROM fh_events WHERE id = NEW.fh_event_id;

    IF v_kind IS DISTINCT FROM 'match' THEN
        RETURN NULL;
    END IF;

    SELECT MIN(team_id) INTO v_primary_team_id
      FROM fh_event_teams WHERE fh_event_id = v_fh_event_id;

    IF v_primary_team_id IS NULL THEN
        RETURN NULL;
    END IF;

    INSERT INTO matches (
        match_type_id, home_team_id, away_team_id,
        match_date, match_time, title, description,
        source_system_id, external_id
    )
    SELECT 2, v_primary_team_id, NULL,
           (ge.starts_at AT TIME ZONE 'America/New_York')::date,
           (ge.starts_at AT TIME ZONE 'America/New_York')::time,
           ge.summary, v_fh_notes, 5, 'fh_event:' || v_fh_event_id::text
      FROM gcal_events ge WHERE ge.id = v_gcal_event_id
    ON CONFLICT (source_system_id, external_id) DO UPDATE
        SET home_team_id = EXCLUDED.home_team_id,
            match_date    = EXCLUDED.match_date,
            match_time    = EXCLUDED.match_time,
            title         = EXCLUDED.title
        WHERE NOT EXISTS (
                SELECT 1 FROM match_lineups ml WHERE ml.match_id = matches.id
              )
    RETURNING id INTO v_new_match_id;

    IF v_new_match_id IS NULL THEN
        -- ON CONFLICT hit the freeze guard (lineup already exists) —
        -- row keeps its existing match_id, nothing to backfill.
        RETURN NULL;
    END IF;

    UPDATE fh_events SET match_id = v_new_match_id
     WHERE id = v_fh_event_id AND match_id IS NULL;

    RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_fh_event_team_create_match ON fh_event_teams;
CREATE TRIGGER trg_fh_event_team_create_match
    AFTER INSERT ON fh_event_teams
    FOR EACH ROW EXECUTE FUNCTION fh_event_team_create_match();

-- ─── One-time backfill for already-existing kind='match' rows ─────────
-- (the trigger only fires on NEW fh_event_teams inserts going forward)
INSERT INTO matches (match_type_id, home_team_id, away_team_id, match_date, match_time,
                      title, description, source_system_id, external_id)
SELECT 2, p.team_id, NULL,
       (ge.starts_at AT TIME ZONE 'America/New_York')::date,
       (ge.starts_at AT TIME ZONE 'America/New_York')::time,
       ge.summary, fe.fh_notes, 5, 'fh_event:' || fe.id::text
FROM fh_events fe
JOIN gcal_events ge ON ge.id = fe.gcal_event_id
JOIN LATERAL (
    SELECT MIN(fet.team_id) AS team_id
    FROM fh_event_teams fet WHERE fet.fh_event_id = fe.id
) p ON p.team_id IS NOT NULL
WHERE fe.kind = 'match' AND fe.match_id IS NULL
ON CONFLICT (source_system_id, external_id) DO NOTHING;

UPDATE fh_events fe
   SET match_id = m.id
  FROM matches m
 WHERE fe.match_id IS NULL
   AND fe.kind = 'match'
   AND m.source_system_id = 5
   AND m.external_id = 'fh_event:' || fe.id::text;

COMMIT;
