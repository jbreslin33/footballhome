-- 763 (2026-10-27) — Game Center: several players per position, and split squads.
--
-- Owner: "we need ability to do for a game a split squad … split off squad
-- into 2 'teams' that will split time … could we put them in lineup under
-- the starter?" then "so each position has x players you can put in" and
-- "in events" (the 📋 Event Center game page).
--
-- A position keeps ONE starter (zone 'starter', as before).  The players
-- who share it are bench players with shares_position_id = that position
-- and share_order 2, 3, … (2 = next in).  They stay zone 'bench', so every
-- count, cap, notice and the sub-cards pass-on keep working unchanged;
-- the pitch graphic draws them under the starter instead of in the bench
-- list.  Split squad (match_lineup_metadata.split_squad) is the view where
-- the starters are Squad A and every 2nd is Squad B, with the swap times.

ALTER TABLE match_lineups ADD COLUMN IF NOT EXISTS shares_position_id INTEGER REFERENCES positions(id);
ALTER TABLE match_lineups ADD COLUMN IF NOT EXISTS share_order SMALLINT CHECK (share_order >= 2);
COMMENT ON COLUMN match_lineups.shares_position_id IS 'mig 763: a bench player who shares this starting position (comes on for its starter); NULL = an ordinary sub.';
COMMENT ON COLUMN match_lineups.share_order IS 'mig 763: order at the shared position — 2 = next in after the starter, 3 after that.';

ALTER TABLE match_lineup_draft_rows ADD COLUMN IF NOT EXISTS shares_position_id INTEGER REFERENCES positions(id);
ALTER TABLE match_lineup_draft_rows ADD COLUMN IF NOT EXISTS share_order SMALLINT CHECK (share_order >= 2);

ALTER TABLE match_lineup_metadata ADD COLUMN IF NOT EXISTS split_squad BOOLEAN NOT NULL DEFAULT false;
COMMENT ON COLUMN match_lineup_metadata.split_squad IS 'mig 763: show this game as a split squad — starters = Squad A, every 2nd = Squad B.';

-- Wording: the swap sheet's share rows (kind lineup_swap, mig 453) and the
-- split-squad bits (kind lineup_split).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', l, k, t, NULL, b, o, true, true
  FROM (VALUES
    ('lineup_swap',  'share',        'Swap sheet — share the spot ({player} {other} {position} {nth})', '➕ {player} shares {position} — {nth} in after {other}', 40),
    ('lineup_swap',  'share_note',   'Swap sheet — share row note ({player})', '{player} goes on the bench and comes on for this spot', 41),
    ('lineup_swap',  'unshare',      'Swap sheet — stop sharing ({player} {position})', '✕ {player} stops sharing {position} (stays on the bench)', 42),
    ('lineup_swap',  'spot_share',   'Swap sheet — a sharing player''s spot ({nth} {position})', '{nth} at {position}', 43),
    ('lineup_move',  'share_up',     'Move sheet — move a sharing player up one ({player} {nth})', '⬆ {player} moves up to {nth}', 50),
    ('lineup_split', 'button_on',    'Split squad button while off', '👥 Split squad', 10),
    ('lineup_split', 'button_off',   'Split squad button while on', '👥 Split squad ✓', 11),
    ('lineup_split', 'fill',         'Split squad — fill every open 2nd from the bench ({n})', '➕ Fill {n} open 2nd spots from the bench', 12),
    ('lineup_split', 'band',         'Split squad — graphic band', 'SQUAD A · SQUAD B', 13),
    ('lineup_split', 'times',        'Split squad — swap times under the pitch', 'A starts · B on at 22′ · A back at half-time · B on at 67′', 14),
    ('lineup_split', 'hint',         'Split squad — how it works, coach view', 'Starters are Squad A; every 2nd is Squad B. Tap a name to move it; a position with no 2nd keeps its starter all game.', 15),
    ('lineup_split', 'unpaired',     'Split squad — positions with no 2nd ({positions})', 'No 2nd yet: {positions}', 16)
  ) AS v(k, t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.k AND m.tier = v.t);
