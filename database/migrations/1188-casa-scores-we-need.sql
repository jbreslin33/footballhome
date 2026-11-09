-- 1188 (2026-11-09): #casa-scores — "Scores we need" is the one section.
-- Owner: "they should not show their instagram highlighted as being able to
-- be selected if we already have their scores. there needs to be ONLY the
-- games/clubs whose scores we need in one clear section called scores we
-- need".  The every-team Instagram row is gone from the page (casa.js);
-- the Not scored heading reads "Scores we need".
UPDATE message_templates
   SET body = 'Scores we need', label = 'CASA scores — heading: scores we need', updated_at = now()
 WHERE kind = 'casa' AND tier = 'scores_waiting';
