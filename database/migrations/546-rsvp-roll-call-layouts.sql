-- 546 (2026-10-07) — roll call card layouts per section.
-- Owner: "can we break down kids for me at least u6 intramural, u8 intra,
-- u8 travel. For parents it can just be a list. for men it can look like
-- mine."
--   columns  the Men's card as built: a game, three columns of names
--   teams    the youth card: grouped by team (U6 Intramural, U8 Intramural,
--            U8 Travel …), each game a compact block; a signed-in parent
--            gets "Your games" first — a plain list of their own children's
--            games with the Going / Not going buttons
ALTER TABLE club_sections
    ADD COLUMN IF NOT EXISTS roll_call_layout TEXT NOT NULL DEFAULT 'columns'
        CHECK (roll_call_layout IN ('columns', 'teams'));
COMMENT ON COLUMN club_sections.roll_call_layout IS 'How /rc/<slug> draws this section: columns (one game, three name columns) or teams (grouped by team, compact; parents get a list of their own first) — mig 546.';
UPDATE club_sections SET roll_call_layout = 'teams' WHERE code IN ('B', 'G');

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'RSVP', v.l, 'rsvp_roll_call', v.t, NULL, v.b, v.o, true, false, true
  FROM (VALUES
    ('your_games',  'Card — heading over a parent''s own list',       'Your games', 60),
    ('your_none',   'Card — parent''s list when nothing is open',     'Nothing of yours is open for RSVPs this week.', 61),
    ('team_none',   'Card (teams layout) — a team with no game',      'No game open this week.', 62)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'rsvp_roll_call' AND m.tier = v.t);
