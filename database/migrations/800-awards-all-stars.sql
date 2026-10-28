-- 800: #awards — All-Stars and end-of-season awards (owner 2026-10-28:
-- "need an all star/awards section to site. and email/text buttons to
-- send to u8 and u10 ppr commish. but also we need the AWARDS button so
-- we can give awards to a bunch of players. Most improved, most
-- dedicated, etc").
--
-- award_types           — the awards (label + emoji, DB copy).  is_league
--                         marks the ones that go to the league office
--                         (All-Star): the page offers ✉ / 💬 to the team's
--                         league director for those.
-- person_awards         — one player, one award, on one team, for one
--                         season (year_terms term + the year it started).
-- team_league_directors — who at the league a team reports to (a
--                         club_contacts row) + the league's own name for
--                         the team.  Contact details stay in the DB.
-- award_submissions     — each send of a team's league award list:
--                         when, how, by whom — the page's "sent ✓".
CREATE TABLE IF NOT EXISTS award_types (
  code       text PRIMARY KEY,
  label      text NOT NULL,
  emoji      text NOT NULL DEFAULT '🏅',
  is_league  boolean NOT NULL DEFAULT false,
  sort_order int NOT NULL DEFAULT 0,
  is_active  boolean NOT NULL DEFAULT true
);
COMMENT ON TABLE award_types IS 'Awards given on #awards (mig 800); is_league = sent to the league director (All-Star).';

INSERT INTO award_types (code, label, emoji, is_league, sort_order) VALUES
  ('all_star',       'All-Star',       '⭐', true,  1),
  ('most_improved',  'Most Improved',  '📈', false, 2),
  ('most_dedicated', 'Most Dedicated', '💪', false, 3)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS person_awards (
  id           bigserial PRIMARY KEY,
  person_id    integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  team_id      integer NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  award_code   text    NOT NULL REFERENCES award_types(code),
  term         text    NOT NULL REFERENCES year_terms(code),
  season_year  integer NOT NULL,
  awarded_by_person_id integer REFERENCES persons(id) ON DELETE SET NULL,
  created_at   timestamptz NOT NULL DEFAULT now(),
  UNIQUE (person_id, team_id, award_code, term, season_year)
);
COMMENT ON TABLE person_awards IS 'A player''s award on a team for a season (term + year it started) — #awards, mig 800.';

CREATE TABLE IF NOT EXISTS team_league_directors (
  team_id           integer PRIMARY KEY REFERENCES teams(id) ON DELETE CASCADE,
  club_contact_id   integer NOT NULL REFERENCES club_contacts(id),
  league_team_label text
);
COMMENT ON TABLE team_league_directors IS 'The league director a team''s league awards go to (club_contacts row) + the league''s name for the team (mig 800).';

-- PPR league directors (club 62 contacts, loaded 10/16): GotSport event
-- 57473 has us as U8 Boys Red, U10 Boys Blue and U12 Boys (mig 758).
INSERT INTO team_league_directors (team_id, club_contact_id, league_team_label) VALUES
  (912, 128, 'U8 Boys Red'),
  (913, 130, 'U10 Boys Blue'),
  (914, 133, 'U12 Boys')
ON CONFLICT (team_id) DO NOTHING;

CREATE TABLE IF NOT EXISTS award_submissions (
  id              bigserial PRIMARY KEY,
  team_id         integer NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  award_code      text    NOT NULL REFERENCES award_types(code),
  term            text    NOT NULL REFERENCES year_terms(code),
  season_year     integer NOT NULL,
  club_contact_id integer REFERENCES club_contacts(id),
  channel         text    NOT NULL CHECK (channel IN ('email', 'text', 'outside')),
  sent_by_person_id integer REFERENCES persons(id) ON DELETE SET NULL,
  sent_at         timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE award_submissions IS 'Each send of a team''s league award list to its director (mig 800); outside = sent before #awards existed.';

-- Fall 2026 All-Stars (owner 2026-10-28).  U12's list already went to
-- the U12 league director by hand — recorded as sent outside the app.
INSERT INTO person_awards (person_id, team_id, award_code, term, season_year, awarded_by_person_id)
SELECT v.person_id, v.team_id, 'all_star', 'fall', 2026, 1
  FROM (VALUES (22372, 912), (22624, 912), (22357, 912),     -- U8 Travel: 3 picks
               (22673, 913), (22282, 913), (22415, 913),     -- U10 Travel: 3 picks
               (22336, 914), (22711, 914), (22413, 914))     -- U12 Travel: 3 picks
       AS v(person_id, team_id)
ON CONFLICT DO NOTHING;

INSERT INTO award_submissions (team_id, award_code, term, season_year, club_contact_id, channel, sent_by_person_id, sent_at)
SELECT 914, 'all_star', 'fall', 2026, 133, 'outside', 1, '2026-10-28 12:00-04'
 WHERE NOT EXISTS (SELECT 1 FROM award_submissions WHERE team_id = 914 AND award_code = 'all_star' AND term = 'fall' AND season_year = 2026);

-- Copy (kind = awards).  Email/text tokens: {director} first name,
-- {league_team} the league's name for our team, {award}, {season},
-- {players} one per line, {sender}.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Awards', l, 'awards', t, s, b, o, true, true, false
  FROM (VALUES
    ('tile_title', 'Role picker tile — title',          NULL, 'Awards', 1300),
    ('tile_sub',   'Role picker tile — subtitle',       NULL, 'All-Stars to the league, Most Improved, Most Dedicated — per team, per season', 1301),
    ('title',      'Page title',                        NULL, '🏅 Awards', 1302),
    ('sub',        'Page subtitle',                     NULL, 'Pick a season and a team, tap an award on a player', 1303),
    ('email',      'League award list — email ({director} {league_team} {award} {season} {players} {sender})',
                   'Lighthouse {league_team} — {season} {award}s',
                   E'Hi {director},\n\nHere are Lighthouse''s {season} {award} selections for {league_team}:\n\n{players}\n\nThanks,\n{sender}\nLighthouse Boys Club', 1304),
    ('text',       'League award list — text',          NULL,
                   E'Hi {director}, Lighthouse {league_team} {season} {award}s:\n{players}\nThanks — {sender}', 1305),
    ('sent',       'Sent note ({channel} {when})',      NULL, 'Sent {when} by {channel} ✓', 1306),
    ('not_sent',   'Not sent yet note',                 NULL, 'Not sent to the league yet', 1307)
  ) AS v(t, l, s, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'awards' AND m.tier = v.t);
