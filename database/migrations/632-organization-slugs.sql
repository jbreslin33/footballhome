-- 632: footballhome.org/<slug> — every club or league page lives at a
-- path on the one site (owner 2026-10-22: paths, not subdomains — one
-- login, one site; GitHub-style /<org>).  First user: /lighthouse, the
-- public club page recruiting ads / flyers / bios can point at.
--
-- organizations.slug is the address.  reserved_slugs holds every
-- top-level path the site already serves (nginx locations + frontend
-- directories) so no organization can ever shadow /api, /rc, /exhibit…
-- organization_page_links are the page's buttons (label + url per org),
-- and kind='org_page' message_templates rows are its headings — no
-- wording in OrganizationPage / public-org.js.

ALTER TABLE organizations ADD COLUMN IF NOT EXISTS slug text;

DO $$ BEGIN
    ALTER TABLE organizations ADD CONSTRAINT organizations_slug_format
        CHECK (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE UNIQUE INDEX IF NOT EXISTS organizations_slug_key ON organizations (slug);

CREATE TABLE IF NOT EXISTS reserved_slugs (
    slug   text PRIMARY KEY,
    reason text NOT NULL
);

INSERT INTO reserved_slugs (slug, reason) VALUES
    ('api',            'backend API (nginx /api/)'),
    ('health',         'backend health check'),
    ('pgadmin',        'pgAdmin'),
    ('webhook',        'Meta lead webhook (/webhook/meta-leads)'),
    ('game',           'fh-game WebSocket'),
    ('archive-drop',   'research-capture upload receiver'),
    ('rc',             'RSVP roll call cards (/rc/<slug>)'),
    ('pickup',         'pickup guest funnel'),
    ('invoice',        'public invoice sheet'),
    ('cup-roster',     'public USASA player pool sheet'),
    ('reset-password', 'password reset landing'),
    ('privacy',        'legal page'),
    ('terms',          'legal page'),
    ('sms',            'text-alert sign-up'),
    ('oauth-success',  'Google / magic-link sign-in landing (SPA)'),
    ('css',            'frontend directory'),
    ('js',             'frontend directory'),
    ('images',         'frontend directory'),
    ('vendor',         'frontend directory'),
    ('exhibit',        'frontend directory'),
    ('profiles',       'frontend directory'),
    ('operator',       'frontend directory')
ON CONFLICT (slug) DO NOTHING;

-- A CHECK can't look at another table, so a trigger keeps reserved
-- paths out of organizations.slug.
CREATE OR REPLACE FUNCTION fh_organizations_slug_not_reserved() RETURNS trigger AS $$
BEGIN
    IF NEW.slug IS NOT NULL AND EXISTS (SELECT 1 FROM reserved_slugs r WHERE r.slug = NEW.slug) THEN
        RAISE EXCEPTION 'organization slug "%" is a reserved site path', NEW.slug;
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS organizations_slug_not_reserved ON organizations;
CREATE TRIGGER organizations_slug_not_reserved
    BEFORE INSERT OR UPDATE OF slug ON organizations
    FOR EACH ROW EXECUTE FUNCTION fh_organizations_slug_not_reserved();

UPDATE organizations SET slug = 'lighthouse' WHERE id = 134 AND slug IS NULL;

-- The page's buttons.  group_code: 'join' (how to sign up) or 'more'
-- (other public pages).  url is site-absolute or external.
CREATE TABLE IF NOT EXISTS organization_page_links (
    id              serial PRIMARY KEY,
    organization_id integer NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    group_code      text NOT NULL CHECK (group_code IN ('join', 'more')),
    label           text NOT NULL,
    url             text NOT NULL,
    sort_order      integer NOT NULL DEFAULT 0,
    UNIQUE (organization_id, url)
);

-- Lighthouse: the join links are the existing #info flyer pages (they
-- carry the LeagueApps register buttons + program description), and the
-- #schedules directory.
INSERT INTO organization_page_links (organization_id, group_code, label, url, sort_order) VALUES
    (134, 'join', 'Youth — Boys & Girls',     '/#info/youth', 1),
    (134, 'join', 'Adults — Men''s & Women''s', '/#info/adult', 2),
    (134, 'more', 'Team schedules',            '/#schedules',  1)
ON CONFLICT (organization_id, url) DO NOTHING;

-- Headings.  is_public: the page is signed-out.  {year} = the club's
-- earliest club_sections.founded_year, {email} = clubs.outreach_email.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_public)
SELECT 'System', v.label, 'org_page', v.tier, NULL, v.body, v.sort_order, true
  FROM (VALUES
    ('Org page — founded line',          'founded',          'Est. {year}',                     1),
    ('Org page — section founded line',  'section_since',    'Since {year}',                    2),
    ('Org page — sections heading',      'sections_heading', 'Our clubs',                       3),
    ('Org page — join heading',          'join_heading',     'Join',                            4),
    ('Org page — more heading',          'more_heading',     'More',                            5),
    ('Org page — members heading',       'members_heading',  'Members',                         6),
    ('Org page — sign-in button',        'sign_in',          'Sign in',                         7),
    ('Org page — signed-in app button',  'open_app',         'Open my FootballHome',            8),
    ('Org page — contact line',          'contact',          'Questions? Email {email}',        9)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'org_page' AND m.tier = v.tier);
