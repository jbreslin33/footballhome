-- 746: the PPR contact sheet calls Torresdale's second U10 Boys Blue team
-- "Stingers"; GotSport (event 57473) names it "Strikers" — the name on our
-- fixtures. Relabel contact 145 to the GotSport name (owner 2026-10-27).
UPDATE club_contacts
   SET role = 'Coach — U10 Boys Blue, Torresdale Strikers', updated_at = now()
 WHERE id = 145 AND role = 'Coach — U10 Boys Blue, Torresdale Stingers';
