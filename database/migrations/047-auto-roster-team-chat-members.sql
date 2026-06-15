-- Migration 047: Auto-roster team-chat members (e.g. Trialists) onto their team
--
-- Goal: when a person is a linked member of a chat that is bound to a team
-- (chats.team_id IS NOT NULL AND chats.chat_type_id = 1 'team'), they should
-- automatically appear on that team's `rosters`. This makes the lineup screen,
-- eligibility query, and game-day roster see GroupMe Trialists as roster
-- players without manual roster entry.
--
-- Safety properties:
--   * If a (team_id, player_id) row exists in `rosters` in ANY state — active
--     or with left_at set — we do NOT insert another. This preserves manual
--     "remove from roster" overrides indefinitely.
--   * Auto-rostering only fires for chats that are explicitly team-bound
--     (chats.team_id IS NOT NULL) so club/league/pickup/training chats are
--     never auto-rostered onto a team.
--   * person_id must be linked on the chat_external_members row. NULL stays
--     untouched (those need the "Link" flow in the lineup UI first).
--   * source_system_id on the auto-created roster row is left NULL so we can
--     tell it apart from imported (LeagueApps/APSL) rosters if needed.

-- ─────────────────────────────────────────────────────────────────────────
-- Trigger function: run on insert/update of chat_external_members
-- ─────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION fn_auto_roster_team_chat_member()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_team_id      INT;
    v_chat_type_id INT;
    v_player_id    INT;
BEGIN
    -- Nothing to do for unlinked members
    IF NEW.person_id IS NULL THEN
        RETURN NEW;
    END IF;

    SELECT c.team_id, c.chat_type_id
    INTO v_team_id, v_chat_type_id
    FROM chats c
    WHERE c.id = NEW.chat_id;

    -- Only team-bound team chats trigger auto-roster
    IF v_team_id IS NULL OR v_chat_type_id <> 1 THEN
        RETURN NEW;
    END IF;

    SELECT p.id INTO v_player_id FROM players p WHERE p.person_id = NEW.person_id;
    IF v_player_id IS NULL THEN
        -- Person exists but has no player record yet — skip silently. Player
        -- creation lives in the player-management flow, not here.
        RETURN NEW;
    END IF;

    -- Insert a roster row only if no row exists at all for (team, player).
    -- This preserves manual removals (left_at IS NOT NULL).
    INSERT INTO rosters (team_id, player_id, joined_at, left_at)
    SELECT v_team_id, v_player_id, CURRENT_TIMESTAMP, NULL
    WHERE NOT EXISTS (
        SELECT 1 FROM rosters r
        WHERE r.team_id = v_team_id AND r.player_id = v_player_id
    );

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_auto_roster_team_chat_member ON chat_external_members;
CREATE TRIGGER trg_auto_roster_team_chat_member
AFTER INSERT OR UPDATE OF person_id ON chat_external_members
FOR EACH ROW
EXECUTE FUNCTION fn_auto_roster_team_chat_member();

-- ─────────────────────────────────────────────────────────────────────────
-- One-time backfill: roster every currently-linked team-chat member who
-- doesn't yet have ANY roster row for that team.
-- ─────────────────────────────────────────────────────────────────────────
INSERT INTO rosters (team_id, player_id, joined_at, left_at)
SELECT DISTINCT c.team_id, p.id, CURRENT_TIMESTAMP, NULL::timestamp
FROM chat_external_members cem
JOIN chats   c ON c.id = cem.chat_id
JOIN players p ON p.person_id = cem.person_id
WHERE cem.person_id IS NOT NULL
  AND c.team_id IS NOT NULL
  AND c.chat_type_id = 1
  AND NOT EXISTS (
      SELECT 1 FROM rosters r
      WHERE r.team_id = c.team_id AND r.player_id = p.id
  );
