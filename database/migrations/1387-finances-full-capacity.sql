-- 1387 (2026-11-15) — #finances 👥 Full capacity: every team filled with
-- paying players, a coach per team (paid or volunteer).
--
-- Owner 2026-11-15: "can we have a projection if we fill all teams to
-- capicity with paid players. so u5 to u16. all 12 total excep u12 16 and
-- u13 to u16 18. then for u17, u18, u19 amd men that is 2 total teams at 35
-- each so 70 total. women we will expect no dues just expenses lol. have
-- option to also make the coach for each "team" paid or voluneter. this
-- would go in its own pill right? allow it for finish of this year and for
-- next etc" → coach cost: "go by practice schedule on gcal. remember it will
-- change in spring but whatever is there use it. assume a game for allt eams
-- above u9. assume like 20 games." → "actuall $10 an hour lol." → "we would
-- pay more with more expericen" (rate per team coach, editable).
--
-- Capacity = teams.max_roster (U12 → 16, U13–U16 → 18 below). u17–u19 play
-- on the men's two teams (APSL 35 + Liga 1 35 = 70), so team 956 (U16, which
-- also carries the u17–u19 winter aliases) counts 18 youth here. Practice
-- hours per week come from the calendar at read time (CapacityPlan).

UPDATE teams SET max_roster = 16 WHERE id = 940;                    -- U12 winter
UPDATE teams SET max_roster = 18 WHERE id IN (947, 955, 941, 956);  -- U13–U16 winter

-- The scenario's standing assumptions. Change = a new row, latest wins.
CREATE TABLE IF NOT EXISTS capacity_plan_settings (
    id                  serial PRIMARY KEY,
    club_id             integer NOT NULL,
    effective_from      date    NOT NULL DEFAULT CURRENT_DATE,
    coach_rate_per_hour numeric(8,2) NOT NULL,   -- a new team coach's rate
    weeks_per_year      numeric(5,2) NOT NULL,   -- practice weeks in a full year
    practice_weeks_read integer NOT NULL,        -- calendar weeks averaged for hours/week
    note                text
);

-- The teams in the scenario: games a year, a coach's hours per game, dues.
CREATE TABLE IF NOT EXISTS capacity_plan_teams (
    team_id        integer PRIMARY KEY REFERENCES teams(id),
    club_id        integer NOT NULL,
    sort_order     integer NOT NULL DEFAULT 0,
    games          integer NOT NULL DEFAULT 0,
    hours_per_game numeric(5,2) NOT NULL DEFAULT 0,
    pays_dues      boolean NOT NULL DEFAULT true,
    note           text
);

-- Each team coach per budget year: paid or volunteer, and the hourly rate.
-- No row = paid at the settings rate.
CREATE TABLE IF NOT EXISTS capacity_plan_coaches (
    team_id            integer NOT NULL REFERENCES teams(id),
    budget_year        text    NOT NULL,
    is_paid            boolean NOT NULL DEFAULT true,
    rate_per_hour      numeric(8,2),
    updated_at         timestamptz NOT NULL DEFAULT now(),
    updated_by_user_id integer,
    PRIMARY KEY (team_id, budget_year)
);

INSERT INTO capacity_plan_settings (club_id, effective_from, coach_rate_per_hour, weeks_per_year, practice_weeks_read, note)
SELECT 134, '2026-11-15', 10.00, 50, 4, 'Owner 11/15: $10/h; 50 practice weeks as the Year plan; hours/week = the calendar''s next 4 weeks'
 WHERE NOT EXISTS (SELECT 1 FROM capacity_plan_settings WHERE club_id = 134);

-- Games: 20 for every team above U9 (owner), none for U5–U9. Hours per game
-- from the coaching policies already on the books (ref_fee_policies kind
-- coaching): PPR U10 1.5 h, U12 2 h (→ U12 and up), APSL 3, Liga 1 2.45,
-- Tri County 2.
INSERT INTO capacity_plan_teams (team_id, club_id, sort_order, games, hours_per_game, pays_dues, note)
SELECT v.team_id, 134, v.ord, v.games, v.hpg, v.pays, v.note
  FROM (VALUES
    (954,  10,  0, 0.00, true,  NULL),
    (952,  20,  0, 0.00, true,  NULL),
    (949,  30,  0, 0.00, true,  NULL),
    (953,  40,  0, 0.00, true,  NULL),
    (945,  50,  0, 0.00, true,  NULL),
    (942,  60, 20, 1.50, true,  NULL),
    (946,  70, 20, 1.50, true,  NULL),
    (940,  80, 20, 2.00, true,  NULL),
    (947,  90, 20, 2.00, true,  NULL),
    (955, 100, 20, 2.00, true,  NULL),
    (941, 110, 20, 2.00, true,  NULL),
    (956, 120, 20, 2.00, true,  NULL),
    (35,  200, 20, 3.00, true,  'u17–u19 play on the men''s two teams'),
    (120, 210, 20, 2.45, true,  'u17–u19 play on the men''s two teams'),
    (901, 300, 20, 2.00, false, 'Women pay no dues — expenses only (owner 11/15)')
  ) AS v(team_id, ord, games, hpg, pays, note)
ON CONFLICT (team_id) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — pill: full capacity', 'pill_capacity', '👥 Full capacity', 300),
    ('Finances — full capacity: title', 'cap_title', 'Full capacity', 301),
    ('Finances — full capacity: note', 'cap_note', 'What the year looks like with every team full of paying players and a coach on every team. Women pay no dues. Coach pay = practice hours a week on the calendar × weeks + games × hours a game, at each coach''s rate. Everything else comes from the Operating Budget. A what-if — the real budget never reads it.', 302),
    ('Finances — full capacity: this year note', 'cap_note_this_year', 'Rest of {year}: dues and coaching so far are real; full teams from this month ({months} months, {weeks} practice weeks, {games} of each team''s games left).', 303),
    ('Finances — full capacity: next year note', 'cap_note_next_year', '{year}: a full year — 12 months of dues, {weeks} practice weeks, every game.', 304),
    ('Finances — full capacity: team columns', 'cap_columns', 'Team|Players|Dues|Coach|$/h|Practice h/wk|Games|Coach cost', 305),
    ('Finances — full capacity: paid', 'cap_paid', 'Paid', 306),
    ('Finances — full capacity: volunteer', 'cap_volunteer', 'Volunteer', 307),
    ('Finances — full capacity: no dues', 'cap_no_dues', 'no dues', 308),
    ('Finances — full capacity: teams total', 'cap_teams_total', 'All teams', 309),
    ('Finances — full capacity: dues line', 'cap_rev_dues', 'Dues — every team full', 310),
    ('Finances — full capacity: dues detail (this year)', 'cap_rev_dues_this', '{so_far} so far + {players} × {rate} × {months}', 311),
    ('Finances — full capacity: dues detail (next year)', 'cap_rev_dues_next', '{players} × {rate} × 12', 312),
    ('Finances — full capacity: coaching category', 'cap_coaching', 'Coaching — a coach per team', 313),
    ('Finances — full capacity: coaching so far', 'cap_coaching_so_far', 'Coaching paid so far', 314),
    ('Finances — full capacity: team coach line', 'cap_coach_line', '{team} coach', 315),
    ('Finances — full capacity: summary heading', 'cap_summary', 'The year at full capacity', 316),
    ('Finances — full capacity: coaching replaced', 'cap_replaces', 'Replaces the Operating Budget''s coaching ({amount}).', 317),
    ('Finances — full capacity: save failed', 'cap_save_failed', 'Could not save the coach change.', 318)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);

-- wording fix, same day (the months left count this month, as the Budget's dues do)
UPDATE message_templates SET body = replace(body, 'full teams from next month', 'full teams from this month')
 WHERE kind = 'finances' AND tier = 'cap_note_this_year';
