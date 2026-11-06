-- 1120 (2026-11-06) — 🎯 Tactics: coach-drawn situations per formation,
-- starting with 3-5-2 (3-R2) for Sunday's APSL game.
--
-- Owner: "can we use the current graphic to show or add a pill for game
-- to show the tactics depending on where opponents and ball are" → "A,
-- start with 3R2 for sunday" (A = coach-drawn situations, not computed).
--
-- Storage is the long-standing tactical board schema, unused until now:
-- one TEMPLATE board per formation (tactical_boards.formation_id,
-- is_template, board type 'template'), one frame per situation
-- (tactical_frames.label = situation, notes = the coaching cue), our
-- eleven as tactical_frame_players by position_id (= shirt number, mig
-- 296; slot_number = position_id), opponents as is_opponent rows (slot
-- 101+, generic_label = their role), the ball a tactical_frame_objects
-- 'ball'.  x 0–100 left → right as we attack; y 0 = our goal line, 100 =
-- theirs.  Positions only — Game Center lays the day's lineup on them by
-- position.  Coaches drag the pieces in Game Center to change these
-- (PUT /api/formation-tactics/situations/:id); these are first drafts.
-- Opponents drawn as a 4-4-2 (their common shape) — drag to suit.

CREATE UNIQUE INDEX IF NOT EXISTS tactical_boards_one_template_per_formation
    ON tactical_boards (formation_id) WHERE is_template AND formation_id IS NOT NULL;

DO $$
DECLARE
  v_board int;
  v_frame int;
BEGIN
  INSERT INTO tactical_boards (board_type_id, formation_id, title, description, is_template)
  SELECT bt.id, f.id, 'Tactics · ' || f.code, 'Coach-drawn situations (mig 1120)', true
    FROM tactical_board_types bt, formations f
   WHERE bt.code = 'template' AND f.code = '3-5-2 (3-R2)'
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_board;
  IF v_board IS NULL THEN RETURN; END IF;  -- already seeded


  INSERT INTO tactical_frames (board_id, frame_number, label, notes)
  VALUES (v_board, 1, 'Build-up — ball with our 6', 'Back three split wide; the 10 and 8 show between their two strikers and their midfield; 3 and 2 hold the width high; 7 sits in the right half-space behind their midfield; 11 pins their centre backs.') RETURNING id INTO v_frame;
  INSERT INTO tactical_frame_objects (frame_id, object_type, x, y) VALUES (v_frame, 'ball', 50, 16);
  INSERT INTO tactical_frame_players (frame_id, position_id, slot_number, is_starter, is_opponent, x, y) VALUES
    (v_frame, 1, 1, true, false, 50, 4),
    (v_frame, 5, 5, true, false, 22, 16),
    (v_frame, 6, 6, true, false, 50, 13),
    (v_frame, 4, 4, true, false, 78, 16),
    (v_frame, 3, 3, true, false, 6, 44),
    (v_frame, 2, 2, true, false, 94, 44),
    (v_frame, 10, 10, true, false, 35, 31),
    (v_frame, 9, 9, true, false, 50, 38),
    (v_frame, 8, 8, true, false, 65, 31),
    (v_frame, 7, 7, true, false, 64, 56),
    (v_frame, 11, 11, true, false, 50, 70);
  INSERT INTO tactical_frame_players (frame_id, generic_label, slot_number, is_starter, is_opponent, x, y) VALUES
    (v_frame, 'GK', 101, true, true, 50, 96),
    (v_frame, 'LB', 102, true, true, 84, 70),
    (v_frame, 'CB', 103, true, true, 60, 74),
    (v_frame, 'CB', 104, true, true, 40, 74),
    (v_frame, 'RB', 105, true, true, 16, 70),
    (v_frame, 'LM', 106, true, true, 86, 54),
    (v_frame, 'CM', 107, true, true, 60, 52),
    (v_frame, 'CM', 108, true, true, 40, 52),
    (v_frame, 'RM', 109, true, true, 14, 54),
    (v_frame, 'ST', 110, true, true, 58, 34),
    (v_frame, 'ST', 111, true, true, 42, 34);

  INSERT INTO tactical_frames (board_id, frame_number, label, notes)
  VALUES (v_board, 2, 'Final third — ball with our 2 out wide', '2 has it on the touchline: 7 attacks the half-space inside him, 11 the near post, 10 arrives late at the far post; 9 holds the edge of the box; back three push up to halfway; far-side 3 stays a step deeper as cover.') RETURNING id INTO v_frame;
  INSERT INTO tactical_frame_objects (frame_id, object_type, x, y) VALUES (v_frame, 'ball', 92, 76);
  INSERT INTO tactical_frame_players (frame_id, position_id, slot_number, is_starter, is_opponent, x, y) VALUES
    (v_frame, 1, 1, true, false, 50, 22),
    (v_frame, 5, 5, true, false, 30, 46),
    (v_frame, 6, 6, true, false, 50, 43),
    (v_frame, 4, 4, true, false, 70, 47),
    (v_frame, 3, 3, true, false, 12, 62),
    (v_frame, 2, 2, true, false, 92, 76),
    (v_frame, 10, 10, true, false, 38, 74),
    (v_frame, 9, 9, true, false, 52, 64),
    (v_frame, 8, 8, true, false, 70, 62),
    (v_frame, 7, 7, true, false, 76, 84),
    (v_frame, 11, 11, true, false, 52, 90);
  INSERT INTO tactical_frame_players (frame_id, generic_label, slot_number, is_starter, is_opponent, x, y) VALUES
    (v_frame, 'GK', 101, true, true, 50, 97),
    (v_frame, 'RB', 102, true, true, 86, 84),
    (v_frame, 'CB', 103, true, true, 64, 88),
    (v_frame, 'CB', 104, true, true, 46, 88),
    (v_frame, 'LB', 105, true, true, 28, 84),
    (v_frame, 'RM', 106, true, true, 86, 72),
    (v_frame, 'CM', 107, true, true, 64, 76),
    (v_frame, 'CM', 108, true, true, 46, 76),
    (v_frame, 'LM', 109, true, true, 22, 72),
    (v_frame, 'ST', 110, true, true, 56, 56),
    (v_frame, 'ST', 111, true, true, 40, 56);

  INSERT INTO tactical_frames (board_id, frame_number, label, notes)
  VALUES (v_board, 3, 'Mid block — ball with their right back', 'Ball-side 3 jumps their full back; far-side 2 tucks in to make a back four; the block slides to the ball; 10 and 9 lock the inside pass; 11 curves his run to cut the pass back to their centre back.') RETURNING id INTO v_frame;
  INSERT INTO tactical_frame_objects (frame_id, object_type, x, y) VALUES (v_frame, 'ball', 12, 62);
  INSERT INTO tactical_frame_players (frame_id, position_id, slot_number, is_starter, is_opponent, x, y) VALUES
    (v_frame, 1, 1, true, false, 48, 6),
    (v_frame, 5, 5, true, false, 28, 36),
    (v_frame, 6, 6, true, false, 42, 32),
    (v_frame, 4, 4, true, false, 58, 34),
    (v_frame, 3, 3, true, false, 14, 58),
    (v_frame, 2, 2, true, false, 72, 36),
    (v_frame, 10, 10, true, false, 26, 50),
    (v_frame, 9, 9, true, false, 40, 47),
    (v_frame, 8, 8, true, false, 54, 48),
    (v_frame, 7, 7, true, false, 60, 60),
    (v_frame, 11, 11, true, false, 36, 66);
  INSERT INTO tactical_frame_players (frame_id, generic_label, slot_number, is_starter, is_opponent, x, y) VALUES
    (v_frame, 'GK', 101, true, true, 50, 95),
    (v_frame, 'RB', 102, true, true, 12, 64),
    (v_frame, 'CB', 103, true, true, 36, 72),
    (v_frame, 'CB', 104, true, true, 58, 72),
    (v_frame, 'LB', 105, true, true, 86, 64),
    (v_frame, 'RM', 106, true, true, 20, 48),
    (v_frame, 'CM', 107, true, true, 40, 50),
    (v_frame, 'CM', 108, true, true, 60, 50),
    (v_frame, 'LM', 109, true, true, 82, 52),
    (v_frame, 'ST', 110, true, true, 42, 38),
    (v_frame, 'ST', 111, true, true, 60, 40);

  INSERT INTO tactical_frames (board_id, frame_number, label, notes)
  VALUES (v_board, 4, 'Defending deep — ball in our right corner', 'Back five: 2 on their winger, 4 covers him, 6 and 5 mark the box, 3 tucks onto the far post; 8 and 7 double the wide man; 9 and 10 screen the cut-back; 11 stays up for the outlet.') RETURNING id INTO v_frame;
  INSERT INTO tactical_frame_objects (frame_id, object_type, x, y) VALUES (v_frame, 'ball', 88, 12);
  INSERT INTO tactical_frame_players (frame_id, position_id, slot_number, is_starter, is_opponent, x, y) VALUES
    (v_frame, 1, 1, true, false, 54, 4),
    (v_frame, 5, 5, true, false, 40, 10),
    (v_frame, 6, 6, true, false, 54, 8),
    (v_frame, 4, 4, true, false, 70, 10),
    (v_frame, 3, 3, true, false, 26, 14),
    (v_frame, 2, 2, true, false, 86, 14),
    (v_frame, 10, 10, true, false, 46, 24),
    (v_frame, 9, 9, true, false, 60, 22),
    (v_frame, 8, 8, true, false, 74, 22),
    (v_frame, 7, 7, true, false, 78, 34),
    (v_frame, 11, 11, true, false, 54, 42);
  INSERT INTO tactical_frame_players (frame_id, generic_label, slot_number, is_starter, is_opponent, x, y) VALUES
    (v_frame, 'GK', 101, true, true, 50, 95),
    (v_frame, 'LW', 102, true, true, 88, 12),
    (v_frame, 'ST', 103, true, true, 52, 12),
    (v_frame, 'ST', 104, true, true, 62, 16),
    (v_frame, 'RW', 105, true, true, 30, 24),
    (v_frame, 'CM', 106, true, true, 50, 30),
    (v_frame, 'CM', 107, true, true, 70, 28),
    (v_frame, 'RB', 108, true, true, 92, 30),
    (v_frame, 'CB', 109, true, true, 60, 52),
    (v_frame, 'CB', 110, true, true, 40, 52),
    (v_frame, 'LB', 111, true, true, 14, 40);
END $$;

-- Copy (client-side, read by MessageCopy.block('tactics', tier)).  An
-- early cut had a toggle button (tiers button / button_on); the owner
-- wanted a pill beside the post pills instead, so those rows go.
DELETE FROM message_templates WHERE kind = 'tactics' AND tier IN ('button', 'button_on');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', l, 'tactics', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('pill',      'Game Center — 🎯 Tactics pill title (beside the post pills)', 'Tactics', 1200),
    ('hint',      'Game Center — what the tactics pitch shows',        'Where we stand in each situation — pick one. Blue = us (today''s lineup), red = them, white = the ball.', 1202),
    ('edit',      'Game Center — coach: start moving pieces',          '✏️ Move pieces', 1203),
    ('save',      'Game Center — coach: save the moved pieces',        '💾 Save', 1204),
    ('cancel',    'Game Center — coach: drop unsaved moves',           'Cancel', 1205),
    ('saved',     'Game Center — after a save',                        'Saved ✓', 1206),
    ('editing',   'Game Center — coach editing hint',                  'Drag any piece — us, them or the ball — then Save.', 1207),
    ('none',      'Game Center — formation has no situations yet',     'No situations drawn for {formation} yet.', 1208),
    ('empty_slot','Game Center — nobody in this slot yet',             '—', 1209)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'tactics' AND m.tier = v.t);
