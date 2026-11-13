-- 1351 (2026-11-13) — youth is Grades K–10 (ages 6 to 15) (owner: "for
-- youth i think we need to goto grades k-10 and then to say in parens
-- (ages 6 to 15)").  The live youth year-round ad's caption, its lead
-- form context-card title and every youth lead follow-up read K–10 now.
-- lead_program tiers keep their historical funnel labels (#leads keys) —
-- only the wording a parent reads changes.  The card graphic is
-- scripts/generate-year-round-cards.js (kicker).
BEGIN;
UPDATE message_templates SET body = replace(body, 'Grades K–9', 'Grades K–10 (ages 6 to 15)'), updated_at = now()
 WHERE kind = 'meta_ad_caption' AND tier = 'youth-year-round';
UPDATE message_templates SET subject = 'Lighthouse Youth Soccer — Boys & Girls, Grades K–10 (ages 6 to 15)', updated_at = now()
 WHERE kind = 'meta_context_card' AND tier = 'youth-year-round';
UPDATE message_templates SET body = replace(body, '(grades K–9)', '(grades K–10, ages 6 to 15)'), updated_at = now()
 WHERE kind = 'lead_program' AND body LIKE '%(grades K–9)%';
COMMIT;
