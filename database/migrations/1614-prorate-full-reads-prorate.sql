-- 1614 (2026-11-20) — The 💵 Prorate popup never calls a non-$35 charge a
-- "full month".
--
-- Owner: "34 is not a full month its a prorate. if its not 35 its a pro
-- rate right?"  A member who signed up before the billing Friday and has
-- only the $1 card fee in (Bam Parrilla, reg Nov 4, bill day Nov 6) owes
-- the straight $35 with the $1 counted toward it (owner 2026-07-09) =
-- $34 — but the line read "Full month $34".  Same amount, prorate words.

BEGIN;

UPDATE message_templates
   SET body  = 'Prorate {amount} — {monthly} less {paid} paid (signed up before the bill day)',
       label = 'Prorate popup: signed up before the billing Friday — monthly dues less what was paid ({amount}, {monthly}, {paid})'
 WHERE kind = 'event_center' AND tier = 'prorate_full';

COMMIT;
