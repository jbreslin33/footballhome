-- 🎯 Tactics: ⭐ Shortcuts at the top of every job dropdown (owner
-- 2026-11-07: "i need anything tactic we use to become part of short cut
-- list at top. and i need to be able to add and take away from short cut
-- list").
--
-- One row per job kind that has ever been on the list.  on_list = shown.
-- A job is added the first time anyone picks it (trigger below).  Taking
-- one away keeps its row with on_list = false, so saving a plan that still
-- uses it doesn't put it back; only ⭐ Add does.  Club-wide (one club).
CREATE TABLE IF NOT EXISTS tactic_job_shortcuts (
    kind        text PRIMARY KEY REFERENCES tactic_job_kinds(code) ON DELETE CASCADE ON UPDATE CASCADE,
    on_list     boolean NOT NULL DEFAULT true,
    changed_by_user_id integer REFERENCES users(id),
    changed_at  timestamptz NOT NULL DEFAULT now()
);

-- Picked = on the list, unless someone already took it away.
CREATE OR REPLACE FUNCTION fh_tactic_job_shortcut_on_use() RETURNS trigger AS $$
BEGIN
    INSERT INTO tactic_job_shortcuts (kind) VALUES (NEW.kind) ON CONFLICT (kind) DO NOTHING;
    RETURN NEW;
END $$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tactic_jobs_shortcut_on_use ON tactic_jobs;
CREATE TRIGGER tactic_jobs_shortcut_on_use AFTER INSERT OR UPDATE OF kind ON tactic_jobs
    FOR EACH ROW EXECUTE FUNCTION fh_tactic_job_shortcut_on_use();

-- Everything in use today.
INSERT INTO tactic_job_shortcuts (kind) SELECT DISTINCT kind FROM tactic_jobs ON CONFLICT (kind) DO NOTHING;

-- Copy (MessageCopy.block('tactics', tier)).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', l, 'tactics', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('fam_shortcuts',   'Game Center — 🎯 Tactics: the shortcut group atop the job dropdown', '⭐ Shortcuts', 1254),
    ('shortcut_add',    'Game Center — 🎯 Tactics: ☆ button tip, put this job on the shortcuts', 'Add this job to ⭐ Shortcuts', 1255),
    ('shortcut_remove', 'Game Center — 🎯 Tactics: ★ button tip, take this job off the shortcuts', 'Take this job off ⭐ Shortcuts', 1256)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'tactics' AND m.tier = v.t);
