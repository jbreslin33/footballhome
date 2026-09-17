-- 365 — club_forms: one home for the external form links our messages
-- point at.
--
-- Owner 2026-09-17: "move the docs form url to the db too" (after "lets
-- never hard code!").  The youth travel-docs upload form lived in two
-- places: a constant in frontend/js/screens/boys-roster.js (sent along
-- with every WELCOME request) and, typed out again, inside the 📄 Docs
-- reminder template body (migration 357).  A new Google Form meant a JS
-- edit AND a template edit, and forgetting one sent parents to the old
-- form.
--
-- Now the link is one row here and copy refers to it by code with a
-- {form:<code>} token.  fh_fill_form_links() swaps the tokens in, and is
-- the only implementation: GET /api/messages/templates applies it to
-- what it serves (roster-card nudges, #messages) and WelcomeMessage
-- applies it to the welcome.  To point at a new form, UPDATE the url by
-- migration — no code, no template edit.
CREATE TABLE IF NOT EXISTS club_forms (
  id         serial PRIMARY KEY,
  club_id    integer NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
  code       text    NOT NULL CHECK (code ~ '^[a-z][a-z0-9_]*$'),
  label      text    NOT NULL,
  url        text    NOT NULL CHECK (url ~ '^https://'),
  is_active  boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (club_id, code)
);
COMMENT ON TABLE club_forms IS
  'External forms (Google Forms etc.) that club messages link to. Copy references a row as {form:<code>}; fh_fill_form_links() resolves it (migration 365).';

-- youth_travel_docs was the JS constant; the two men's registration forms
-- were typed into their roster-card nudges (migration 356).  Owner
-- 2026-09-17: "all messages in db no hard code not even for nudges".
INSERT INTO club_forms (club_id, code, label, url) VALUES
  (134, 'youth_travel_docs',       'Youth travel documents (birth certificate + headshot)',
        'https://forms.gle/n2bj8aHiTRqLs6cg9'),
  (134, 'mens_liga1_registration', 'Men''s Liga 1 / CASA league registration',
        'https://casasoccerleagues.sportngin.com/register/form/229198682'),
  (134, 'mens_apsl_registration',  'Men''s APSL registration (headshot + details)',
        'https://forms.gle/fki5wPqJk1x2fT9D7')
ON CONFLICT (club_id, code) DO NOTHING;

-- Replaces every {form:<code>} for the club's active forms.  A token
-- whose form is missing or inactive is left as-is, so a broken reference
-- is visible in the message preview instead of silently vanishing.
CREATE OR REPLACE FUNCTION fh_fill_form_links(p_text text, p_club_id int)
RETURNS text LANGUAGE plpgsql STABLE AS $$
DECLARE
  f   record;
  out text := p_text;
BEGIN
  IF out IS NULL OR position('{form:' IN out) = 0 THEN RETURN out; END IF;
  FOR f IN SELECT code, url FROM club_forms WHERE club_id = p_club_id AND is_active LOOP
    out := replace(out, '{form:' || f.code || '}', f.url);
  END LOOP;
  RETURN out;
END $$;

-- Point the existing copy at the rows instead of spelling the links out.
UPDATE message_templates t
   SET body = replace(t.body, f.url, '{form:' || f.code || '}'),
       updated_at = now()
  FROM club_forms f
 WHERE f.club_id = 134 AND position(f.url IN t.body) > 0;

-- The welcome's docs block (migration 364) took the link from the request
-- as {docs_link}; it now names the form itself.
UPDATE message_templates
   SET body = replace(body, '{docs_link}', '{form:youth_travel_docs}'),
       updated_at = now()
 WHERE kind = 'welcome_docs' AND body LIKE '%{docs_link}%';

-- Guard: no form link is written out in the copy any more, and every
-- form is referenced by at least one active template.
DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM message_templates t JOIN club_forms f ON position(f.url IN t.body) > 0;
  IF n <> 0 THEN RAISE EXCEPTION 'migration 365: % template(s) still spell out a form link', n; END IF;
  SELECT count(*) INTO n FROM club_forms f
   WHERE NOT EXISTS (SELECT 1 FROM message_templates t
                      WHERE t.is_active AND position('{form:' || f.code || '}' IN t.body) > 0);
  IF n <> 0 THEN RAISE EXCEPTION 'migration 365: % form(s) not referenced by any active template', n; END IF;
END $$;
