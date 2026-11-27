-- Migration 2210: the PPR Indoor 2027 U12 registration on James's to-do.
-- Owner 11/27: "why is the ppr u12 etc email stuff not up on todo? until i
-- say its done!" — league entry 1 (mig 1746) has its four items open and was
-- never sent. One open item on person 1's list; it stays until he ticks it.
BEGIN;
INSERT INTO person_todos (person_id, body)
SELECT 1, 'PPR Indoor 2027 U12 — finish the registration on #league-registration: club commitment form, U12 team commitment form, U12 official roster, check to the City of Philadelphia, then email it to the league'
 WHERE NOT EXISTS (SELECT 1 FROM person_todos WHERE person_id = 1 AND done_at IS NULL AND body LIKE 'PPR Indoor 2027 U12%');
COMMIT;
