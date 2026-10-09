-- 557 (2026-10-09) — #cup-rosters: ✉️ Email sheet.
-- Owner: "here is email of cup commissioner … also … epsa president … so we
-- can have an email with attachment of roster".  The people a cup roster
-- goes to live in cup_roster_recipients (names and emails are loaded into
-- the DB directly, never into a migration file); the button opens a Gmail
-- compose to all of them with the sheet's public link — a browser cannot
-- attach a file to a compose window, so the body points at the printable
-- sheet and the sender attaches the saved PDF if the league wants one.
CREATE TABLE IF NOT EXISTS cup_roster_recipients (
    id          SERIAL PRIMARY KEY,
    name        TEXT NOT NULL,
    role        TEXT NOT NULL DEFAULT '',
    email       TEXT NOT NULL,
    is_active   BOOLEAN NOT NULL DEFAULT true,
    sort_order  INTEGER NOT NULL DEFAULT 0,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE cup_roster_recipients IS 'mig 557: who a cup roster sheet is emailed to (cup commissioner, state association president); loaded by hand, not by migration.';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Cup rosters', l, 'cup_roster', t, sj, b, o, true, true, false
  FROM (VALUES
    ('email',        'Email to the recipients ({team} {cup} {competition} {count} {link} {sender})',
                     '{team} — {cup} player pool',
                     'Hello,' || E'\n\n' || 'Please find the {team} player pool for the {cup} ({competition}) here:' || E'\n' || '{link}' || E'\n\n' || 'That page prints to PDF as the USASA Region I Player Pool form; {count} players are listed. The PDF is attached as well.' || E'\n\n' || 'Thank you,' || E'\n' || '{sender}', 902),
    ('email_btn',    'Email sheet button',                      NULL, '✉️ Email sheet', 903),
    ('email_none',   'No recipients loaded',                    NULL, 'No cup roster recipients are loaded yet.', 904),
    ('email_to',     'Line under the email button ({names})',   NULL, 'Goes to {names}', 905)
  ) AS v(t, l, sj, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'cup_roster' AND m.tier = v.t);
