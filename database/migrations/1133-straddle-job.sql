-- 1133 (2026-11-06) — Straddle: two of ours bookend one of theirs.
--
-- Owner: "we need a straddle concept. so in current game but of course we
-- want it universal as a concept. we want the 7 and 11 to straddle or
-- bookend their 6. so maybe i click our 7 and pick straddle then who is 6
-- and then it asks who the 7 will straddle with (11) and then it updates
-- 11 too."
--
-- A group job: both players carry a straddle row on the same man, each
-- naming the other as partner (tactic_jobs.partner_position_id) — the API
-- refuses a pair that doesn't mirror.  Geometry (app lib/tactic-geometry.js
-- and the engine, same numbers): each stands dist_m to his side of the man,
-- across the ball→man line, press_m ball-side of him; the partner whose
-- formation spot is further left takes the left side.

INSERT INTO game_concepts (id, name, title, family, moment, taught_from, status, cue_answer, lacking)
VALUES (187, 'straddle', 'Straddle their man', 'group', 'out_of_possession', NULL, 'queued',
        'Out of possession, two of you bookend one of theirs: one each side of him, a step ball-side, so every pass into him runs through one of you — and either of you can step in when he gets it.',
        'Both standing on the same side, or level with him so the ball goes past you into his feet.')
ON CONFLICT (id) DO NOTHING;

ALTER TABLE tactic_job_kinds ADD COLUMN IF NOT EXISTS partner_label text;   -- set = the job pairs two of ours
ALTER TABLE tactic_jobs ADD COLUMN IF NOT EXISTS partner_position_id smallint
    CHECK (partner_position_id BETWEEN 2 AND 11);

INSERT INTO tactic_job_kinds (code, concept_id, label, target_a_label, target_b_label, partner_label, dist_m, press_m, sort_order)
VALUES ('straddle', 187, 'Straddle', 'straddle', NULL, 'with', 5, 2, 4)
ON CONFLICT (code) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', 'Game Center — Tactics: pick the partner for a paired job', 'tactics', 'with_who', NULL, '— with? —', 1234, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'tactics' AND m.tier = 'with_who');
