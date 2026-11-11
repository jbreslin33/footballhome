-- 1244 (2026-11-11) — Main menu = six groups; a group's pages are pills.
--
-- Owner 2026-11-11: "main menu … is too cluttered … x amount of basic
-- standard categories on main menu and then from there we can do a lot of
-- navigating with … pills.  like financial stuff could prob be pills" /
-- "rsvp and this week are same thing" / "yes build it".
--
-- #role-selection draws one button per group; tapping it opens the group's
-- last-used page (players: the first, RSVP).  Every page of a group carries
-- the same pill row on top (frontend/js/lib/main-menu.js), so moving inside a
-- group is one tap.  Which page sits in which group, the order, the words
-- and the icons are these rows — change by migration.
--
-- audience = who saw the old tile, unchanged:
--   everyone  — any signed-in user
--   coach     — coaches (team_coaches / admins row of type coach) + admins
--   admin     — admin levels (club / sport_division / team / super / system / league)
--   marketing — the marketing role + admins
-- screens = the screen states that count as this page (lights its pill).
-- href = a link instead of a screen (new_tab opens a tab; download saves).

CREATE TABLE menu_groups (
    code        text PRIMARY KEY,
    label       text NOT NULL,
    icon        text NOT NULL,
    sort_order  integer NOT NULL
);

CREATE TABLE menu_pages (
    code        text PRIMARY KEY,          -- the old tile's data-role (MainMenu.open)
    group_code  text NOT NULL REFERENCES menu_groups(code) ON DELETE CASCADE,
    label       text NOT NULL,
    icon        text NOT NULL,
    audience    text NOT NULL CHECK (audience IN ('everyone', 'coach', 'admin', 'marketing')),
    sort_order  integer NOT NULL,
    screens     text[] NOT NULL DEFAULT '{}',
    href        text,
    new_tab     boolean NOT NULL DEFAULT false,
    download    boolean NOT NULL DEFAULT false,
    is_active   boolean NOT NULL DEFAULT true
);
CREATE INDEX menu_pages_group_idx ON menu_pages (group_code, sort_order);

COMMENT ON TABLE menu_groups IS 'mig 1244: the main menu buttons (#role-selection); pages in menu_pages ride as pills.';
COMMENT ON TABLE menu_pages  IS 'mig 1244: one pill per page; audience = who sees it (same as the old tile).';

INSERT INTO menu_groups (code, label, icon, sort_order) VALUES
    ('week',     'This Week', '🗓️', 1),
    ('people',   'People',    '👥', 2),
    ('money',    'Money',     '💰', 3),
    ('football', 'Football',  '⚽', 4),
    ('leagues',  'Leagues',   '🏆', 5),
    ('club',     'Club',      '⚙️', 6);

INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens, href, new_tab, download) VALUES
    -- 🗓️ This Week
    ('player',            'week',     'RSVP',             '☑️', 'everyone',  1, '{my}', NULL, false, false),
    ('calendar',          'week',     'Calendar',         '🗓️', 'everyone',  2, '{calendar,player-calendar}', NULL, false, false),
    ('dashboard',         'week',     'Dashboard',        '📊', 'admin',     3, '{dashboard}', NULL, false, false),
    ('game-center',       'week',     'Event Center',     '📋', 'coach',     4, '{event-center,game-center,attendance,event,practice,game-lineup,game-day-roster,lineups}', NULL, false, false),
    ('rsvps',             'week',     'RSVP Reminders',   '✅', 'admin',     5, '{rsvps}', NULL, false, false),
    ('jobs',              'week',     'Jobs',             '🧹', 'admin',     6, '{jobs}', NULL, false, false),
    ('coach-schedule',    'week',     'Coach Schedule',   '🗓️', 'admin',     7, '{coach-schedule}', NULL, false, false),
    ('security',          'week',     'Security',         '🔐', 'admin',     8, '{security}', NULL, false, false),
    -- 👥 People
    ('teams',             'people',   'Teams',            '👥', 'coach',     1, '{teams,rosters,youth-roster,person}', NULL, false, false),
    ('contacts',          'people',   'Contacts',         '📇', 'admin',     2, '{contacts}', NULL, false, false),
    ('texts',             'people',   'Texts',            '📲', 'admin',     3, '{texts}', NULL, false, false),
    ('kit',               'people',   'Uniforms & Kit',   '👕', 'coach',     4, '{kit}', NULL, false, false),
    ('awards',            'people',   'Awards',           '🏅', 'admin',     5, '{awards}', NULL, false, false),
    -- 💰 Money
    ('financial',         'money',    'Tuition',          '💳', 'admin',     1, '{payments}', NULL, false, false),
    ('fines',             'money',    'Fines',            '💸', 'admin',     2, '{fines}', NULL, false, false),
    ('finances',          'money',    'Finances',         '📈', 'admin',     3, '{finances}', NULL, false, false),
    ('cash-flow',         'money',    'Money In & Out',   '💵', 'admin',     4, '{cash-flow}', NULL, false, false),
    ('invoices',          'money',    'Invoices',         '🧾', 'admin',     5, '{invoices}', NULL, false, false),
    -- ⚽ Football
    ('tactical',          'football', 'Tactical',         '♟️', 'coach',     1, '{tactical,tactical-board,tactical-live,game-model,game-model-admin}', NULL, false, false),
    ('reports',           'football', 'Reports',          '📊', 'coach',     2, '{reports}', NULL, false, false),
    ('game',              'football', 'Game',             '🎮', 'everyone',  3, '{}', '/game.html', false, false),
    ('in-house-proposal', 'football', 'In-House Proposal','🏠', 'admin',     4, '{in-house-proposal}', NULL, false, false),
    -- 🏆 Leagues
    ('casa',              'leagues',  'CASA',             '⚽', 'admin',     1, '{casa,casa-contacts,casa-schedule,casa-scores}', NULL, false, false),
    ('apsl',              'leagues',  'APSL',             '🔺', 'admin',     2, '{apsl,apsl-pyramid,apsl-messages}', NULL, false, false),
    ('opponents',         'leagues',  'Opponents',        '📇', 'admin',     3, '{opponents}', NULL, false, false),
    ('league-schedules',  'leagues',  'League Schedules', '🗓', 'admin',     4, '{league-schedules}', NULL, false, false),
    ('cup-rosters',       'leagues',  'Cup Rosters',      '🏆', 'admin',     5, '{cup-rosters}', NULL, false, false),
    ('logos',             'leagues',  'Club Logos',       '🛡️', 'admin',     6, '{logos}', NULL, false, false),
    -- ⚙️ Club
    ('files',             'club',     'Files',            '📁', 'everyone',  1, '{files}', NULL, false, false),
    ('marketing',         'club',     'Marketing',        '📣', 'marketing', 2, '{marketing-home,leads,leads-analytics,social-schedule,holiday-posts,promo-posts,content-posts,flyers,match-social,ad-preview}', NULL, false, false),
    ('profiles',          'club',     'Profiles',         '🎞️', 'admin',     3, '{}', '/profiles/', true, false),
    ('club-admin',        'club',     'Club Admin',       '🏢', 'admin',     4, '{admin-club,admin-club-teams,members,people-workbench,club-directory,club-detail,messages,rsvp-eligibility}', NULL, false, false),
    ('admin',             'club',     'Admin',            '👨‍💼', 'admin',     5, '{admin-level-selection,admin-entity-list,admin-system}', NULL, false, false),
    ('fh-texter',         'club',     'FH Texter',        '📱', 'admin',     6, '{}', '/app/fh-texter.apk', false, true);

-- The words around the menu (kind main_menu).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Main menu', v.label, 'main_menu', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('subtitle',  'Main menu — under the welcome',        'Where to?', 1),
    ('home_pill', 'Pill row — back to the main menu',     '☰ Menu', 2),
    ('unavailable','Main menu — menu failed to load',     'Menu did not load — refresh the page.', 3)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'main_menu' AND t.tier = v.tier);
