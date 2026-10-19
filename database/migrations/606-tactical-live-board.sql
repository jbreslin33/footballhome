-- 606 (2026-10-19) — Live tactical board: players drag their own piece.
--
-- Owner: "there is a tactical board that i use for our tactical meetings.
-- but how quick can we get one up that the players can use during tonights
-- meeting. the feature we need is for them to control thier own piece via
-- drag." / "name on piece coudl defulat to their last name unless they
-- over ride. right?"
--
-- #tactical-live: a coach opens a board for a team; pieces are seeded from
-- the active roster, one per player, labelled with the player's LAST NAME
-- (rename allowed), plus a ball and a rank of unowned opponent pieces.
-- Each signed-in player may drag only his own piece (the server checks
-- person_id); coaches and club/super admins drag anything.  Every move
-- UPDATE fires pg_notify on the existing 'fh_lineups' channel, which
-- LineupNotificationHub already fans out over GET /api/stream — so every
-- open phone sees the move instantly with no new streaming code.  The
-- lineups screen ignores these payloads (no affected_team_ids field).

BEGIN;

CREATE TABLE IF NOT EXISTS tactical_live_boards (
    id                 serial PRIMARY KEY,
    team_id            integer NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    title              text NOT NULL DEFAULT '',
    created_by_user_id integer REFERENCES users(id) ON DELETE SET NULL,
    created_at         timestamptz NOT NULL DEFAULT now(),
    closed_at          timestamptz
);
CREATE INDEX IF NOT EXISTS tactical_live_boards_open_idx
    ON tactical_live_boards (created_at DESC) WHERE closed_at IS NULL;

CREATE TABLE IF NOT EXISTS tactical_live_pieces (
    id                  serial PRIMARY KEY,
    board_id            integer NOT NULL REFERENCES tactical_live_boards(id) ON DELETE CASCADE,
    person_id           integer REFERENCES persons(id) ON DELETE SET NULL,  -- who may drag it
    label               text NOT NULL,
    kind                text NOT NULL DEFAULT 'player'
                        CHECK (kind IN ('player','opponent','ball')),
    -- Pitch fractions, 0..1 of the drawn pitch (x across, y down).
    x                   numeric(5,4) NOT NULL DEFAULT 0.5 CHECK (x BETWEEN 0 AND 1),
    y                   numeric(5,4) NOT NULL DEFAULT 0.5 CHECK (y BETWEEN 0 AND 1),
    moved_by_person_id  integer REFERENCES persons(id) ON DELETE SET NULL,
    updated_at          timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS tactical_live_pieces_board_idx
    ON tactical_live_pieces (board_id);

COMMENT ON TABLE tactical_live_pieces IS
    'Pieces on a #tactical-live board (mig 606). person_id = the player who '
    'may drag it (label defaults to his last name, rename allowed); NULL = '
    'coach-controlled (opponents) or shared (ball). Moves notify the '
    'fh_lineups channel for live fan-out.';

-- Every move/rename notifies every open screen, piece payload inline so
-- clients apply it without a refetch.  No affected_team_ids on purpose:
-- the lineups screen's SSE handler returns early without that field.
CREATE OR REPLACE FUNCTION fn_tactical_live_notify() RETURNS trigger AS $fn$
BEGIN
    PERFORM pg_notify('fh_lineups', json_build_object(
        'kind',     'tactical_live',
        'board_id', NEW.board_id,
        'piece', json_build_object(
            'id', NEW.id, 'x', NEW.x, 'y', NEW.y,
            'label', NEW.label, 'kind', NEW.kind,
            'person_id', NEW.person_id)
    )::text);
    RETURN NEW;
END $fn$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tactical_live_pieces_notify ON tactical_live_pieces;
CREATE TRIGGER tactical_live_pieces_notify
    AFTER INSERT OR UPDATE OF x, y, label ON tactical_live_pieces
    FOR EACH ROW EXECUTE FUNCTION fn_tactical_live_notify();

-- The screen's words (client_side rows, MessageCopy.block('tactical_live', tier)).
CREATE OR REPLACE FUNCTION pg_temp.add_client_tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

SELECT pg_temp.add_client_tpl('tactical_live', 'title', 'Live board — screen title',
  'Live Tactical Board', 1);
SELECT pg_temp.add_client_tpl('tactical_live', 'hint_player', 'Live board — player hint',
  'Drag your piece — everyone sees it move. Tap your name to change what your piece says.', 2);
SELECT pg_temp.add_client_tpl('tactical_live', 'hint_coach', 'Live board — coach hint',
  'You can drag every piece. Players drag their own.', 3);
SELECT pg_temp.add_client_tpl('tactical_live', 'no_board', 'Live board — none open',
  'No live board is open right now. Your coach starts one from this screen.', 4);
SELECT pg_temp.add_client_tpl('tactical_live', 'start', 'Live board — start button',
  'Start a board for {team}', 5);
SELECT pg_temp.add_client_tpl('tactical_live', 'close', 'Live board — close button',
  'End this board', 6);
SELECT pg_temp.add_client_tpl('tactical_live', 'your_piece', 'Live board — legend, own piece',
  'Your piece', 7);
SELECT pg_temp.add_client_tpl('tactical_live', 'rename_ph', 'Live board — rename placeholder',
  'Name on your piece', 8);
SELECT pg_temp.add_client_tpl('tactical_live', 'not_yours', 'Live board — tried to drag another piece',
  'Only {name} can move that piece.', 9);

COMMIT;
