-- 566 (2026-10-12) — #league-schedules: the leagues' own schedule pages as
-- DB rows, shown on a page of their own.
-- Owner: "i have short cuts to all schedules in schedules bookmark on soccer
-- chrome" … "i will paste them but please save them and display links on a
-- page on fh. maybe we need a schedule maker page."
--
-- One row per shortcut (league_schedule_links); the page lists them and a
-- club admin adds / edits / retires them there, no migration needed.  The
-- six seeds are the owner's own bookmarks pasted 2026-10-12.  #schedules is
-- already the public team-schedule directory, so this page is
-- #league-schedules.

CREATE TABLE IF NOT EXISTS league_schedule_links (
    id          SERIAL PRIMARY KEY,
    label       TEXT NOT NULL,
    url         TEXT NOT NULL,
    note        TEXT,
    sort_order  INTEGER NOT NULL DEFAULT 0,
    is_active   BOOLEAN NOT NULL DEFAULT true,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE league_schedule_links IS 'The leagues'' own schedule pages (the owner''s "schedules" bookmarks), shown on #league-schedules (mig 566).';

INSERT INTO league_schedule_links (label, url, note, sort_order)
SELECT v.label, v.url, v.note, v.ord
  FROM (VALUES
    ('Tri County — Women', 'https://go.teamsnap.com/10717331/schedule?mode=list&pageSize=30',
     'TeamSnap team page (sign in as the team manager to edit)', 10),
    ('APSL — Men',         'https://app.teampass.com/APSL/Team/165430',
     'TeamPass team page; the team id changes each season', 20),
    ('Liga 1 — CASA',      'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9496152',
     'CASA season schedule tab', 30),
    ('U8 — PPR',           'https://system.gotsport.com/org_event/events/57473/schedules?team=4408462',
     'GotSport event 57473, U8 Boys Red', 40),
    ('U10 — PPR',          'https://system.gotsport.com/org_event/events/57473/schedules?team=4411988',
     'GotSport event 57473, U10 Boys Blue', 50),
    ('U12 — PPR',          'https://system.gotsport.com/org_event/events/57473/schedules?team=4411989',
     'GotSport event 57473, U12 Boys', 60)
  ) AS v(label, url, note, ord)
 WHERE NOT EXISTS (SELECT 1 FROM league_schedule_links l WHERE l.url = v.url);

-- Page + tile copy (never hardcode copy).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'League schedules', l, 'league_schedules', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('tile_title', 'League schedules — picker tile title',    'League Schedules', 10),
    ('tile_sub',   'League schedules — picker tile subtitle', 'The leagues'' own schedule pages — TeamSnap, TeamPass, CASA, GotSport — to check games against the calendar', 11),
    ('title',      'League schedules — page title',           '🗓 League Schedules', 20),
    ('subtitle',   'League schedules — page subtitle',        'Each league''s own published schedule, one tap away', 21),
    ('hint',       'League schedules — page hint',            'These open the league''s site in a new tab. Keep them current here when a league moves or a new season gets a new team id.', 22),
    ('empty',      'League schedules — no links',             'No schedule links yet — add the first one below.', 23),
    ('add_button', 'League schedules — add button',           '➕ Add link', 24),
    ('saved',      'League schedules — saved flash',          'Saved.', 25),
    ('removed',    'League schedules — removed flash',        'Link removed.', 26)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'league_schedules' AND m.tier = v.t);
