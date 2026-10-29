-- 814 (2026-10-29) — words for the card's TEAM dropdown on #teams.
--
-- Owner: "we need a drop down for roster status and another drop down for
-- team status" … "injured everywhere".  Each men's card now carries two
-- independent dropdowns: Roster (league paperwork, roster_statuses) and
-- Team (his role on this team).  Team = Plays / Paper spot / Call-in
-- (team_persons.invite_only + call_in, migs 619/637, per team) plus every
-- injured health_statuses row (per person, mig 510/715).  The 📄 toggle
-- and the separate health dropdown on men's cards are gone.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', l, 'roster_sheet', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('team_status_plays',  'Team boards — Team dropdown: full player on this team',            '✅ Plays',       960),
    ('team_status_paper',  'Team boards — Team dropdown: 📄 paper spot (invite-only, mig 619)', '📄 Paper spot',  961),
    ('team_status_callin', 'Team boards — Team dropdown: ↔ call-in (mig 637)',                  '↔ Call-in',      962),
    ('team_status_title',  'Team boards — Team dropdown tooltip',
     'His role on this team — Plays (games, RSVPs, lineups), Paper spot (holds the place, plays only when invited), Call-in, or injured (every team, no RSVPs or fines). The other dropdown is the league roster.', 963)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.t);
