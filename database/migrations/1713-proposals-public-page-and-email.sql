-- 📑 Proposals: a public standalone page and an email button (James 11/23
-- "can this be accessible as a stand alone web page wo rest of fh showing?"
-- → fully public; "the Public link should be on the page itsetp up top for
-- me to share"; "i should be able to email for proposals edwin, julian,
-- anita and gil and michael" + "and norma"; "i should have option to
-- include").
--
-- proposals.is_public: a flagged proposal can be read without a login at
-- /proposals/#<code> (frontend/proposals/index.html, GET
-- /api/proposals/public/<code>).  On for the two turf proposals; off for the
-- rest until someone turns it on.
--
-- proposal_recipients: who a proposal is emailed to.  The in-app page shows
-- them with a tick-box each and one ✉️ button that opens an email to the
-- ticked ones, carrying the public link.  Names and roles are seeded here;
-- the ADDRESSES are typed on the page or loaded straight into the database,
-- never committed (third-party contact details stay out of git).

BEGIN;

ALTER TABLE proposals ADD COLUMN IF NOT EXISTS is_public boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN proposals.is_public IS 'mig 1713: readable without a login at /proposals/#<code>.';
UPDATE proposals SET is_public = true WHERE code IN ('turf-mini-pitch', 'field-turf-pitches');

CREATE TABLE IF NOT EXISTS proposal_recipients (
    id          serial PRIMARY KEY,
    name        text NOT NULL UNIQUE,
    role        text NOT NULL DEFAULT '',
    email       text,
    sort_order  int  NOT NULL DEFAULT 100,
    is_active   boolean NOT NULL DEFAULT true,
    created_at  timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE proposal_recipients IS 'mig 1713: who club proposals are emailed to (#proposals ✉️). Addresses are entered on the page, not in migrations.';

INSERT INTO proposal_recipients (name, role, sort_order) VALUES
    ('Edwin Desamour',  'Executive Director', 1),
    ('Julian Makarechi','Deputy Director',    2),
    ('Anita Lyndaker',  'Grant Writer',       3),
    ('Gilbert Vega',    '',                   4),
    ('Michael Lopez',   '',                   5),
    ('Normaris Escalera','',                  6)
ON CONFLICT (name) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Proposals', v.l, 'proposals', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('public_link',    'Before the public link',                 'Public link', 6),
    ('copy_link',      'Button that copies the public link',     'Copy link', 7),
    ('copied',         'After the link is copied',               'Copied ✓', 8),
    ('public_missing', 'Public page: no such public proposal',   'This proposal is not available.', 9),
    ('email_button',   'Button that opens the email',            '✉️ Email this proposal', 10),
    ('email_to',       'Before the list of people to include',   'Include:', 11),
    ('email_subject',  'Email subject ({title})',                'Proposal: {title}', 12),
    ('email_body',     'Email body ({title}, {url})',            E'Here is the proposal: {title}\n\n{url}\n\nJames', 13),
    ('email_none',     'Nobody ticked has an address',           'Tick at least one person who has an email address.', 14),
    ('email_add',      'Placeholder for a missing address',      'email address', 15),
    ('email_save',     'Button that saves an address',           'Save', 16)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'proposals' AND m.tier = v.t);

COMMIT;
