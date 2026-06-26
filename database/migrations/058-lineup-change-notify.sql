-- 058 — pg_notify('fh_lineups', …) on every change that affects the
-- /dashboard#lineups screen.  Drives the SSE channel `/api/stream` served
-- by the meta-leads-webhook (it holds a LISTEN connection and broadcasts
-- each payload to every connected admin browser).
--
-- Payload shape (JSON):
--   { "kind": "rsvp" | "lineup" | "roster" | "coach" | "chat_member",
--     "affected_team_ids": [903, 905]  -- or "all" for screen-wide refresh
--   }
--
-- Frontend reaction:
--   for each visible team column whose id ∈ affected_team_ids → re-fetch
--   `/api/matches/:matchId/roster-players?teamId=…` and re-render that
--   column.  "all" → refresh every visible column.
--
-- Adding a new source table later
-- ───────────────────────────────
-- Copy one of the trigger blocks at the bottom of this file and write the
-- team-resolution branch in `fn_notify_lineup_change()`.  No webhook /
-- frontend changes needed — they just react to whatever NOTIFY tells them.

BEGIN;

-- ───────────────────────────────────────────────────────────────────────
-- Helper: resolve a chat_event_id → array of affected team_ids OR 'all'.
-- Training/Pickup chats are global because their RSVPs feed the T x/5
-- pill on every team's cards.
-- ───────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION fn_lineups_teams_for_chat_event(p_chat_event_id int)
RETURNS text
LANGUAGE plpgsql STABLE AS $$
DECLARE
  v_chat_name text;
  v_team_id   int;
BEGIN
  SELECT c.name, c.team_id
    INTO v_chat_name, v_team_id
    FROM chat_events ce
    JOIN chats c ON c.id = ce.chat_id
   WHERE ce.id = p_chat_event_id;

  IF v_chat_name IN ('Training Lighthouse', 'Philadelphia Pickup') THEN
    RETURN '"all"';
  END IF;
  IF v_team_id IS NOT NULL THEN
    RETURN '[' || v_team_id || ']';
  END IF;
  RETURN '"all"';
END
$$;

-- ───────────────────────────────────────────────────────────────────────
-- Helper: resolve a match_id → array of affected team_ids (home + away).
-- ───────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION fn_lineups_teams_for_match(p_match_id int)
RETURNS text
LANGUAGE plpgsql STABLE AS $$
DECLARE
  v_home int;
  v_away int;
  v_ids  int[];
BEGIN
  SELECT home_team_id, away_team_id
    INTO v_home, v_away
    FROM matches WHERE id = p_match_id;
  v_ids := ARRAY[]::int[];
  IF v_home IS NOT NULL THEN v_ids := array_append(v_ids, v_home); END IF;
  IF v_away IS NOT NULL THEN v_ids := array_append(v_ids, v_away); END IF;
  IF array_length(v_ids, 1) IS NULL THEN RETURN '"all"'; END IF;
  RETURN to_jsonb(v_ids)::text;
END
$$;

-- ───────────────────────────────────────────────────────────────────────
-- Main trigger function — branches on TG_TABLE_NAME and emits NOTIFY.
-- Trigger args: none.  Uses NEW for INSERT/UPDATE, OLD for DELETE.
-- ───────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION fn_notify_lineup_change()
RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
  v_row             record;
  v_kind            text;
  v_team_ids_json   text;
  v_payload         text;
BEGIN
  -- Use NEW for INSERT/UPDATE, OLD for DELETE.
  IF TG_OP = 'DELETE' THEN v_row := OLD; ELSE v_row := NEW; END IF;

  IF TG_TABLE_NAME = 'event_rsvps' OR TG_TABLE_NAME = 'chat_event_rsvps' THEN
    v_kind := 'rsvp';
    v_team_ids_json := fn_lineups_teams_for_chat_event(v_row.chat_event_id);

  ELSIF TG_TABLE_NAME = 'player_rsvp_history' THEN
    v_kind := 'rsvp';
    v_team_ids_json := fn_lineups_teams_for_match(v_row.event_id);

  ELSIF TG_TABLE_NAME = 'match_lineups' THEN
    v_kind := 'lineup';
    v_team_ids_json := fn_lineups_teams_for_match(v_row.match_id);

  ELSIF TG_TABLE_NAME = 'rosters' THEN
    -- Roster changes affect the R badge across multiple teams (the C++
    -- query hardcodes membership lookups against 'Lighthouse 1893 SC',
    -- 'Lighthouse Boys Club', 'Lighthouse Old Timers').  Cheapest +
    -- safest is to refresh everything visible.
    v_kind := 'roster';
    v_team_ids_json := '"all"';

  ELSIF TG_TABLE_NAME = 'team_coaches' THEN
    v_kind := 'coach';
    v_team_ids_json := '[' || COALESCE(v_row.team_id::text, '0') || ']';

  ELSIF TG_TABLE_NAME = 'chat_external_members' THEN
    -- Linking/unlinking a GM external user → person → may flip the
    -- gmOnly bucket on any team whose chat contains that external user.
    DECLARE
      v_team_id int;
    BEGIN
      SELECT team_id INTO v_team_id FROM chats WHERE id = v_row.chat_id;
      IF v_team_id IS NOT NULL THEN
        v_team_ids_json := '[' || v_team_id || ']';
      ELSE
        v_team_ids_json := '"all"';
      END IF;
    END;
    v_kind := 'chat_member';

  ELSE
    -- Unknown table — emit conservative refresh-all.
    v_kind := 'unknown';
    v_team_ids_json := '"all"';
  END IF;

  v_payload := '{"kind":"' || v_kind || '","affected_team_ids":' || v_team_ids_json || '}';

  -- pg_notify is async + nonblocking; payload max 8000 bytes.  Wrapping
  -- in PERFORM keeps the trigger return semantics clean.
  PERFORM pg_notify('fh_lineups', v_payload);

  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END
$$;

-- ───────────────────────────────────────────────────────────────────────
-- Triggers — one per source table.  AFTER so the row is committed (the
-- LISTEN/NOTIFY notification fires on commit, not statement-end).
-- ───────────────────────────────────────────────────────────────────────

DROP TRIGGER IF EXISTS trg_notify_event_rsvps       ON event_rsvps;
CREATE TRIGGER trg_notify_event_rsvps
AFTER INSERT OR UPDATE OR DELETE ON event_rsvps
FOR EACH ROW EXECUTE FUNCTION fn_notify_lineup_change();

DROP TRIGGER IF EXISTS trg_notify_chat_event_rsvps  ON chat_event_rsvps;
CREATE TRIGGER trg_notify_chat_event_rsvps
AFTER INSERT OR UPDATE OR DELETE ON chat_event_rsvps
FOR EACH ROW EXECUTE FUNCTION fn_notify_lineup_change();

DROP TRIGGER IF EXISTS trg_notify_player_rsvp_hist  ON player_rsvp_history;
CREATE TRIGGER trg_notify_player_rsvp_hist
AFTER INSERT OR UPDATE OR DELETE ON player_rsvp_history
FOR EACH ROW EXECUTE FUNCTION fn_notify_lineup_change();

DROP TRIGGER IF EXISTS trg_notify_match_lineups     ON match_lineups;
CREATE TRIGGER trg_notify_match_lineups
AFTER INSERT OR UPDATE OR DELETE ON match_lineups
FOR EACH ROW EXECUTE FUNCTION fn_notify_lineup_change();

DROP TRIGGER IF EXISTS trg_notify_rosters           ON rosters;
CREATE TRIGGER trg_notify_rosters
AFTER INSERT OR UPDATE OR DELETE ON rosters
FOR EACH ROW EXECUTE FUNCTION fn_notify_lineup_change();

DROP TRIGGER IF EXISTS trg_notify_team_coaches      ON team_coaches;
CREATE TRIGGER trg_notify_team_coaches
AFTER INSERT OR UPDATE OR DELETE ON team_coaches
FOR EACH ROW EXECUTE FUNCTION fn_notify_lineup_change();

DROP TRIGGER IF EXISTS trg_notify_chat_ext_members  ON chat_external_members;
CREATE TRIGGER trg_notify_chat_ext_members
AFTER INSERT OR UPDATE OR DELETE ON chat_external_members
FOR EACH ROW EXECUTE FUNCTION fn_notify_lineup_change();

COMMIT;
