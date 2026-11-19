-- 1559 (2026-11-19) — Liga 1 is their primary team: 🪑 Reserves on APSL.
--
-- Owner: "since all the eligible players apsl main or apsl reserves can
-- 'see' apsl games can i move some guys off apsl team? if they are on liga
-- 1 team. so they know what team is their primary? really apsl is smaller
-- group of regular starters and the bench really should be the apsl
-- reserves setting availabity" → "ah yes make them reserves on apsl".
--
-- Not removed from APSL (team 35): Bayo, Masi, Benzing, Delgado are on the
-- official APSL Active roster, and a list player can't be taken off the
-- team (mig 770).  🪑 Reserves = still sees every APSL game and can answer,
-- never chased for them (no reminders, no No response).  They stay ✅
-- Regular on Liga 1 (120) — their primary — so still chased for Liga 1
-- games and the practices tagged to it.  Evan Watson stays ✅ Regular on
-- APSL (first-team keeper); Armando Pena was already 🪑.
UPDATE team_persons
   SET squad_status_id = (SELECT id FROM squad_statuses WHERE code = 'standby')
 WHERE team_id = 35 AND removed_at IS NULL
   AND person_id IN (3488,    -- Aboubacar Bayo II
                     3500,    -- David Masi
                     22241,   -- Joey Benzing
                     3492,    -- Marco Delgado
                     22698);  -- Lucca Santos
