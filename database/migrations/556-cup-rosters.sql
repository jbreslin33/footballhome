-- 556 (2026-10-09) — #cup-rosters: the USASA Region I Player Pool sheet
-- (the EPSA / USASA cup roster form) built from the men's rosters.
-- Owner: "we need a new section in footballhome. for example for cup
-- rosters we fill out special form … can you reproduce this like we did
-- for invoices. have a blank one and then allow me to check off players
-- to fill it from apsl and liga 1 and reserves?"
--
-- One cup_rosters row per sheet (its header: team, cup, association,
-- competition, state, uniform colours, coach/manager, verification line)
-- and the ticked players in cup_roster_players; names and dates of birth
-- are read from persons when the sheet is drawn, so a corrected person
-- corrects the sheet.  A new sheet copies the last sheet's header; the
-- very first one starts from the defaults below.  public_slug is the key
-- of /cup-roster?k=… (the printable page, like /invoice?k=…).
CREATE TABLE IF NOT EXISTS cup_rosters (
    id                  SERIAL PRIMARY KEY,
    title               TEXT NOT NULL DEFAULT '',
    team_name           TEXT NOT NULL DEFAULT '',
    cup                 TEXT NOT NULL DEFAULT '',
    state_association   TEXT NOT NULL DEFAULT '',
    competition         TEXT NOT NULL DEFAULT '',
    state               TEXT NOT NULL DEFAULT '',
    shirt_primary       TEXT NOT NULL DEFAULT '',
    shorts_primary      TEXT NOT NULL DEFAULT '',
    socks_primary       TEXT NOT NULL DEFAULT '',
    shirt_alt           TEXT NOT NULL DEFAULT '',
    shorts_alt          TEXT NOT NULL DEFAULT '',
    socks_alt           TEXT NOT NULL DEFAULT '',
    coach_name          TEXT NOT NULL DEFAULT '',
    coach_email         TEXT NOT NULL DEFAULT '',
    coach_phone         TEXT NOT NULL DEFAULT '',
    verification_name   TEXT NOT NULL DEFAULT '',
    sheet_date          DATE,
    public_slug         UUID NOT NULL DEFAULT gen_random_uuid(),
    created_by_user_id  INTEGER,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS cup_rosters_public_slug_idx ON cup_rosters (public_slug);
COMMENT ON TABLE cup_rosters IS 'mig 556: one USASA Region I Player Pool sheet (cup roster) — header fields; players in cup_roster_players.';
CREATE TABLE IF NOT EXISTS cup_roster_players (
    cup_roster_id  INTEGER NOT NULL REFERENCES cup_rosters(id) ON DELETE CASCADE,
    person_id      INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    sort_order     INTEGER NOT NULL DEFAULT 0,
    added_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (cup_roster_id, person_id)
);
COMMENT ON TABLE cup_roster_players IS 'mig 556: the players ticked onto a cup roster sheet; name and DOB come from persons at draw time.';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Cup rosters', l, 'cup_roster', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('tile_title',    'Picker tile — title',                                'Cup Rosters', 880),
    ('tile_sub',      'Picker tile — line under the title',                 'USASA / EPSA player pool sheets — tick players from APSL, Reserves and Liga 1, print to PDF', 881),
    ('title',         'Page title',                                         '🏆 Cup Rosters', 882),
    ('subtitle',      'Page subtitle',                                      'The USASA Region I Player Pool form, filled from the men''s rosters. Names and dates of birth come from each player''s record. Pool is 30.', 883),
    ('new',           'New sheet button',                                   '+ New sheet', 884),
    ('blank',         'Blank sheet button',                                 '🖨 Blank form', 885),
    ('print',         'Print button',                                       '🖨 Print / Save PDF', 886),
    ('copy_link',     'Copy public link button',                            '🔗 Copy link', 887),
    ('delete',        'Delete sheet button',                                '🗑 Delete', 888),
    ('players_h',     'Heading over the tick list ({n} {max})',             'Players — {n} of {max}', 889),
    ('full',          'Pool full note ({max})',                             'Pool is set at {max}. No more additions allowed.', 890),
    ('no_dob',        'Tag on a player with no date of birth on file',      'no DOB on file', 891),
    ('empty_list',    'No sheets yet',                                      'No sheets yet. New sheet starts one; Blank form prints the empty form.', 892),
    ('sheet_title',   'Sheet — title bar',                                  'USASA Region I Player Pool', 893),
    ('sheet_type',    'Sheet — line above the title bar',                   'TYPE ALL INFORMATION', 894),
    ('sheet_pool',    'Sheet — pool note ({max})',                          'Pool is set at {max}.', 895),
    ('sheet_pool2',   'Sheet — pool note, second line ({max})',             'No more additions allowed after {max} is reached.', 896),
    ('default_team_name',  'First sheet default — team name',               'Lighthouse 1893', 897),
    ('default_assoc',      'First sheet default — state association',       'EPSA', 898),
    ('default_state',      'First sheet default — state',                   'PA', 899),
    ('default_competition','First sheet default — competition',             'APSL', 900),
    ('default_cup',        'First sheet default — cup',                     'US Open Cup', 901)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'cup_roster' AND m.tier = v.t);
