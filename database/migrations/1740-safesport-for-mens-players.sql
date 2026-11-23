-- 1740 (2026-11-23) — SafeSport on every men's player's to-do list, with a
-- place to upload the certificate.  Owner: "we [need] safesport added to the
-- todo list for every player and place to upload their certificate" → "us
-- soccer mandates if we have player under 18 all players must take it. and
-- we have that on both mens teams." → "this is only for men right now".
--
-- Built on the 🎓 onboarding checklist (mig 1526 / 1538: steps, uploads, the
-- club's ✅ check, renewals).  A third stage, 'player', needs no
-- person_onboarding row — who gets it is derived:
--   onboarding_stage_sections   which club sections a stage covers
--                               (player → Mens; add a row to widen it)
--   onboarding_steps.min_age    a step only for people that old (SafeSport's
--                               course is for adults; unknown birth date = shown)
--   onboarding_people (view)    everyone with a checklist: person_onboarding
--                               rows (volunteer / paid) + every live player
--                               on an active team of a covered section
--                               (track 'player' when not on a staff track).

ALTER TABLE onboarding_steps  DROP CONSTRAINT IF EXISTS onboarding_steps_stage_check;
ALTER TABLE onboarding_steps  ADD  CONSTRAINT onboarding_steps_stage_check  CHECK (stage IN ('player', 'volunteer', 'paid'));
ALTER TABLE onboarding_stages DROP CONSTRAINT IF EXISTS onboarding_stages_stage_check;
ALTER TABLE onboarding_stages ADD  CONSTRAINT onboarding_stages_stage_check CHECK (stage IN ('player', 'volunteer', 'paid'));
ALTER TABLE onboarding_steps  ADD COLUMN IF NOT EXISTS min_age integer CHECK (min_age IS NULL OR min_age > 0);

-- no email_to: a player's certificate stays with the club, nothing is sent on
INSERT INTO onboarding_stages (stage, email_to, email_to_name, sort_order) VALUES ('player', NULL, '', 0)
ON CONFLICT (stage) DO NOTHING;

CREATE TABLE IF NOT EXISTS onboarding_stage_sections (
    stage            text    NOT NULL REFERENCES onboarding_stages(stage) ON DELETE CASCADE,
    club_section_id  integer NOT NULL REFERENCES club_sections(id) ON DELETE CASCADE,
    PRIMARY KEY (stage, club_section_id)
);
INSERT INTO onboarding_stage_sections (stage, club_section_id)
SELECT 'player', id FROM club_sections WHERE code = 'M'
ON CONFLICT DO NOTHING;

INSERT INTO onboarding_steps (code, stage, label, short_label, how, cost_usd, link_url, link_label, renew_months, sort_order, min_age)
VALUES ('safesport', 'player', 'SafeSport training', 'SafeSport',
        'U.S. Soccer requires SafeSport training for every adult on a team that has a player under 18 — both our men''s teams do. Take the SafeSport course online (about 90 minutes the first time, a short refresher each year after), then upload your certificate here — a photo or the PDF.',
        0.00, 'https://learning.ussoccer.com', 'Take the course ›', 12, 0, 18)
ON CONFLICT (code) DO NOTHING;

CREATE OR REPLACE VIEW onboarding_people AS
WITH pl AS (
    SELECT DISTINCT tp.person_id
      FROM team_persons tp
      JOIN teams t ON t.id = tp.team_id AND t.is_active
      JOIN onboarding_stage_sections ss ON ss.club_section_id = t.club_section_id AND ss.stage = 'player'
     WHERE tp.removed_at IS NULL)
SELECT po.person_id, po.track, po.note, (po.person_id IN (SELECT person_id FROM pl)) AS is_player
  FROM person_onboarding po
UNION ALL
SELECT pl.person_id, 'player', NULL, true
  FROM pl WHERE NOT EXISTS (SELECT 1 FROM person_onboarding po WHERE po.person_id = pl.person_id);

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, is_active, client_side, is_public)
SELECT 'Onboarding', v.label, 'onboarding', v.tier, v.body, v.ord, true, true, false
  FROM (VALUES
    ('Popup — player stage heading', 'stage_player', '⚽ Player · SafeSport', 80),
    ('Popup — intro, player', 'intro_player', 'One thing every men''s player has to do: SafeSport training. Take the course, upload your certificate, done.', 81),
    ('Popup — player stage done', 'player_done', '🎉 Certificate uploaded! The club checks it and it turns ✅.', 82),
    ('Page — players pill ({n})', 'pill_player', '⚽ Players ({n})', 83),
    ('Page — players pill note', 'player_note', 'Every men''s player 18 or older, automatically. Uploaded = 🟡; tap the chip to see the certificate and mark it ✅ Checked.', 84)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'onboarding' AND m.tier = v.tier);

-- the band box is no longer only staff onboarding
UPDATE message_templates SET body = '⛔ Required — {left} to do: {list}' WHERE kind = 'event_center' AND tier = 'seg_onboarding';
UPDATE message_templates SET body = '📋 Your required steps at Lighthouse' WHERE kind = 'event_center' AND tier = 'sheet_onboarding';
