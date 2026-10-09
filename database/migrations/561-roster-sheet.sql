-- 561 (2026-10-09) — the league roster sheet from Game Center, for every game.
-- Owner: "we need rosters to be able to be printed from the game center for
-- each game" — "could we reproduce the youth roster" (the EPYSA / GotSport
-- Official Roster, U10 sheet on file 2026-10-09) — "same coaches for u12
-- and u8 and it would be diff players based on who is listed on roster in
-- fh".
--
-- team_roster_sheets  what the sheet's header says for a team: the roster
--                     title, club and team names as the league prints them,
--                     association, season line, level, the league's team
--                     number, division, colour.  One row per team; a team
--                     without one prints with blanks there.
-- The players are the team's Football Home roster (team_persons, statuses
-- that show on the official roster), the coaches those with a roster
-- status on team_coaches (mig 560), jersey numbers from the Kit board
-- (person_uniform_numbers), birth years from persons.  The league's own
-- photos, registration numbers and approval dates are not ours to hold,
-- so those cells print empty.
CREATE TABLE IF NOT EXISTS team_roster_sheets (
    team_id            INTEGER PRIMARY KEY REFERENCES teams(id) ON DELETE CASCADE,
    roster_title       TEXT NOT NULL DEFAULT '',
    club_name          TEXT NOT NULL DEFAULT '',
    team_name          TEXT NOT NULL DEFAULT '',
    association        TEXT NOT NULL DEFAULT '',
    season_label       TEXT NOT NULL DEFAULT '',
    official_label     TEXT NOT NULL DEFAULT '',
    level              TEXT NOT NULL DEFAULT '',
    gender_label       TEXT NOT NULL DEFAULT '',
    external_team_id   TEXT NOT NULL DEFAULT '',
    division           TEXT NOT NULL DEFAULT '',
    color              TEXT NOT NULL DEFAULT '',
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE team_roster_sheets IS 'mig 561: the header of a team''s league roster sheet as the league prints it (title, names, association, season, level, team number).';
INSERT INTO team_roster_sheets (team_id, roster_title, club_name, team_name, association, season_label, official_label, level, gender_label, external_team_id)
SELECT t.id, '2026 - 2027 Eastern Pennsylvania Youth Soccer Roster', 'Lighthouse 1893',
       'Lighthouse 1893 Boys Club 1897 ' || v.age, 'PAE', 'PPR Travel Soccer & Eastern Pennsylvania Youth Soccer', 'Official Roster 26/27', 'Travel', 'Male', v.ext
  FROM teams t JOIN (VALUES ('⚽ U8 Travel', 'U8', ''), ('⚽ U10 Travel', 'U10', '793357'), ('⚽ U12 Travel', 'U12', '')) AS v(label, age, ext) ON v.label = COALESCE(t.label, t.name)
 WHERE NOT EXISTS (SELECT 1 FROM team_roster_sheets s WHERE s.team_id = t.id);

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', l, 'roster_sheet', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('panel_title',   'Game Center panel title',                       '🖨 Roster sheet', 920),
    ('panel_hint',    'Game Center panel hint',                        'The league roster drawn from this team''s Football Home roster — coaches on roster, players with jersey numbers and birth years, starters marked ★ once the lineup is set. Photos, registration numbers and approval dates are the league''s and print blank.', 921),
    ('print',         'Print button',                                  '🖨 Print roster', 922),
    ('coaches_h',     'Team boards — coaches strip heading',           'COACHES', 923),
    ('coach_no_status','Team boards — coach with no roster status',    'Not on roster', 924),
    ('signed',        'Sheet — signature line',                        'Signed:', 925),
    ('date',          'Sheet — date line',                             'Date:', 926),
    ('coach_word',    'Sheet — under the signature line',              'Coach', 927),
    ('printed_for',   'Sheet — footer ({game} {when})',                'Printed from Football Home for {game} · {when}', 928)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.t);
