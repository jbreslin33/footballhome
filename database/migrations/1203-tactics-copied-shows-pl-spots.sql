-- 1203 (2026-11-09): 🎯 Tactics — a copied Premier League step shows ours
-- where the PL side's men actually stood (owner: "we want to copy premier
-- league").  The board draws copied_from.ours on a copied step; authored
-- steps still solve our spots from the jobs.  The note says so.

UPDATE message_templates
   SET body = 'Copied from the game: {home} v {away} at {clock}. Everyone stands where they stood; the jobs say what each of ours was doing.'
 WHERE kind = 'tactics' AND tier = 'copied_note';
