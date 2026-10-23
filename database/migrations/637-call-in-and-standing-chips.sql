-- 637 (2026-10-22) — men's invite categories: ⭐ Standing Call-up and
-- ↔ Call In.
-- Owner: "rhoden and pena should show like others but with standing call
-- up chip on name. lucca should be in sep cat called 'call in'. 'call
-- down' is like Luke Breslin etc".
--
-- Three kinds of Liga 1 invitee from the APSL side now read differently:
--   ⭐ Standing Call-up — a team_auto_invites rider (Rhoden, Pena): listed
--      in the team's column with everyone else, chip on the name; still
--      counts toward the APSL → CASA cap (team_invite_caps, mig 616).
--   ↔ Call In — rostered on the team but plays only when invited, from a
--      squad at the same level (Lucca: Liga 1 paper row, plays Reserves).
--      team_persons.call_in marks it; it rides on invite_only (mig 619),
--      so every visibility gate already treats it as invite-only.
--   🎟 Call Down — a per-game invite from the squad above (Luke Breslin
--      and the other APSL-only players), unchanged.
-- 📄 Paper stays for the roster-fillers who hold an APSL spot for the
-- league minimum (Benzing, Figueroa, Masi, Pena on APSL).
ALTER TABLE team_persons ADD COLUMN IF NOT EXISTS call_in BOOLEAN NOT NULL DEFAULT false;
COMMENT ON COLUMN team_persons.call_in IS 'mig 637: ↔ Call In — an invite_only row for a player from a same-level squad who plays here when invited; shown as its own category, never 📄 Paper. Only meaningful with invite_only.';
ALTER TABLE team_persons DROP CONSTRAINT IF EXISTS team_persons_call_in_needs_invite_only;
ALTER TABLE team_persons ADD CONSTRAINT team_persons_call_in_needs_invite_only CHECK (NOT call_in OR invite_only);

-- Lucca Santos: Liga 1 call-in (rostered on Reserves).
UPDATE team_persons tp SET call_in = true
  FROM persons p, teams t
 WHERE tp.person_id = p.id AND tp.team_id = t.id AND tp.removed_at IS NULL AND tp.invite_only
   AND p.first_name = 'Lucca' AND p.last_name = 'Santos' AND t.name = 'Lighthouse Mens Club Liga 1';

-- Chip and pill wording (client_side, read through MessageCopy).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Rosters', l, 'invite_chip', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('standing',     'Invite chip — standing invite rider (team_auto_invites)', '⭐ Standing Call-up', 880),
    ('call_in',      'Invite chip — same-level call-in (team_persons.call_in)',  '↔ Call In',          881),
    ('call_down',    'Invite chip — per-game call-down from the squad above',    '🎟 Call Down',        882),
    ('call_up',      'Invite chip — per-game call-up',                            '🎟 Call-up',          883),
    ('cat_call_in',  '#teams category pill — call-ins',                           '↔ Call In',          884),
    ('standing_tip', 'Hover — standing call-up chip on a #teams card ({team})',   'Standing invite — rides every {team} game automatically; still counts toward the call-down cap in the lineup. Manage with the ⭐ on the game''s 🎟 panel.', 885),
    ('call_in_tip',  'Hover — call-in chip on a #teams card',                     'Call In — on this roster, but sees games, reminders, fines and lineups only when invited (🎟). Same level, not a call-up or call-down.', 886)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'invite_chip' AND m.tier = v.t);
