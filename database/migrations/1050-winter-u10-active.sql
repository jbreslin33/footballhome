-- 1050: winter U10 (942) ACTIVE — twelve kids (owner 2026-11-04: "add to
-- u10 active: yigit, ian ortiz, mason davila, gian silvestry, leonardo
-- rodriquez, elliot rubero, elliano hudson, jalil sapp, jaxel almonte,
-- carmelo, alex basset, jordan greir-lomax").  Same as winter U12 (mig
-- 1048): no winter league list, so On Roster by hand gives a full spot the
-- youth rule keeps — Roster pill ON ROSTER, Team pill ACTIVE, U10 winter
-- games.  Yigit Torres 22336, Ian Ortiz 22337, Mason Davila 22629, Gian
-- Silvestry 22514, Leonardo Rodriguez 22619, Elliot Rubero 22605, Elliano
-- Hudson 22378, Jalil Sapp 22282, jaxel almonte 22673, Carmelo Passineau
-- 22380, Alex Bassett 22342, Jordan Grier-lomax 22600.

UPDATE team_persons SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'on_roster')
 WHERE team_id = 942 AND removed_at IS NULL
   AND person_id IN (22336, 22337, 22629, 22514, 22619, 22605, 22378, 22282, 22673, 22380, 22342, 22600);
