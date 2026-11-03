-- 1002 (2026-11-03) — Match plan checklist: "Player ID / league card" on
-- cup games only.  Owner: "take out player id card from all. except cup
-- games. its only needed for cups".
--
-- match_day_checklist_items.league_label scopes an item the same way
-- warmup_routines.league_label scopes a routine (mig 966): NULL = every
-- game; set = only games whose fh_events.league is that label.  Another
-- cup = another row with its label (or widen this one) by migration.

ALTER TABLE match_day_checklist_items ADD COLUMN IF NOT EXISTS league_label TEXT;
COMMENT ON COLUMN match_day_checklist_items.league_label IS
    'mig 1002: NULL = on every game''s checklist; set = only games whose fh_events.league matches (e.g. USASA Cup).';

UPDATE match_day_checklist_items i
   SET league_label = 'USASA Cup'
  FROM match_day_stages s
 WHERE s.id = i.stage_id AND s.slug = 'get-there' AND i.slug = 'id'
   AND i.league_label IS NULL;
