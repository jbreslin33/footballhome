-- 807 (2026-10-29) — a player on the league's OFFICIAL list with no live
-- LeagueApps membership has been CUT; the league just hasn't been told.
-- Owner: "if a player is on official roster but not league apps then he
-- has been 'cut' but we just have not gotten around to removing him from
-- league roster … he would remain because it reflects official roster …
-- he counts in the official total until he is dropped but we track him".
--
-- Derived, never typed (LA → DB → render): fh_in_leagueapps() reads
-- person_la_memberships, the board paints the list row red and lists the
-- name under DROPPING.  It clears itself when the 🌐 pull stops finding
-- him on the list, or when he registers again.  (The live case: Anthony
-- Acevedo 22397 on the CASA Liga 1 list, swept off the team 8/14 for no
-- valid membership.)

CREATE OR REPLACE FUNCTION fh_in_leagueapps(p_person_id integer) RETURNS boolean
LANGUAGE sql STABLE AS $$
    SELECT EXISTS (SELECT 1 FROM person_la_memberships m
                    WHERE m.person_id = p_person_id AND m.ended_at IS NULL)
$$;
COMMENT ON FUNCTION fh_in_leagueapps(integer) IS 'mig 807: a live LeagueApps membership (any program). On a league list without one = cut, still owed a drop.';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', l, 'roster_sheet', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('board_official_cut', 'Team boards — Roster pill: list row for a player with no LeagueApps membership', '✂ not in LeagueApps — needs to be dropped', 950),
    ('board_cut_note',     'Team boards — Roster pill: DROPPING row note for a cut player',                  '✂ cut — not in LeagueApps',              951),
    ('board_cuts',         'Team boards — official banner suffix ({n})',                                      '{n} cut',                                 952)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.t);
