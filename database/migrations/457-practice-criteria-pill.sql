-- 457 — Practice Criteria pill wording + colours (owner 2026-09-26: "say
-- Practice Criteria: Met, Needs x practices, Projected to meet on a pill …
-- if met you can show them exceeding or projected to exceed … green its
-- met, projected yellow, red not projected or not met, plus text
-- explaining").
--
-- Replaces the mig 456 pill tiers.  The frontend picks the tier; the
-- colour is fixed per tier (green met, yellow projected, red short).
-- "Exceeding" = more practices than the minimum (owner: "3 does not get
-- priority, but we want to see it").  Met at exactly the minimum with more
-- Going RSVPs ahead reads "projected to exceed".

UPDATE message_templates SET is_active = false
 WHERE kind = 'eligibility' AND tier IN ('pill_eligible', 'pill_on_track', 'pill_short', 'pill_missed');

CREATE OR REPLACE FUNCTION pg_temp.add_client_tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

-- green
SELECT pg_temp.add_client_tpl('eligibility', 'pill_met',           'Game Center — Practice Criteria pill: met',
  'Practice Criteria: Met · {attended} of {needed}', 11);
SELECT pg_temp.add_client_tpl('eligibility', 'pill_met_projected', 'Game Center — Practice Criteria pill: met, going to more',
  'Practice Criteria: Met · {attended} of {needed}, going to {projected} more', 12);
SELECT pg_temp.add_client_tpl('eligibility', 'pill_exceeding',     'Game Center — Practice Criteria pill: exceeding',
  'Practice Criteria: Met · {attended} of {needed}, exceeding', 13);
SELECT pg_temp.add_client_tpl('eligibility', 'pill_exceeding_projected', 'Game Center — Practice Criteria pill: met, projected to exceed',
  'Practice Criteria: Met · {attended} of {needed}, projected to exceed', 14);
-- yellow
SELECT pg_temp.add_client_tpl('eligibility', 'pill_projected',     'Game Center — Practice Criteria pill: projected to meet',
  'Practice Criteria: Projected to meet · {attended} made, going to {projected} more', 15);
-- red
SELECT pg_temp.add_client_tpl('eligibility', 'pill_needs',         'Game Center — Practice Criteria pill: needs more',
  'Practice Criteria: Needs {remaining} practice{plural}', 16);
SELECT pg_temp.add_client_tpl('eligibility', 'pill_not_met',       'Game Center — Practice Criteria pill: not met, none left',
  'Practice Criteria: Not met · {attended} of {needed}', 17);
-- explainer under the pill
SELECT pg_temp.add_client_tpl('eligibility', 'legend',             'Game Center — Practice Criteria colour legend',
  'Green: you have made the practices to start. Yellow: you will if you attend the practices you said Going to — you must be marked present for one to count. Red: short, and nothing you have said Going to gets you there yet.', 18);

-- Superseded by pill_exceeding_projected (same case).
UPDATE message_templates SET is_active = false WHERE kind = 'eligibility' AND tier = 'pill_met_projected';
