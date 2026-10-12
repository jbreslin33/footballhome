-- 567 (2026-10-12) — a USASA Cup container team, so a cup tie classifies
-- like any other game without opening it to a whole league roster.
-- Owner: "Game for APSL this weekend … is not apsl game. its a usasa cup
-- game … we should only be allowing those players [the submitted cup
-- roster] to rsvp to it. its like an apsl game but no reserves and the
-- roster is the cup roster."
--
-- The team carries NO players (nobody becomes eligible through it) and is
-- archived off the team boards; the gcal event tags `Team: USASA Cup /
-- Club: Mens` so the classifier resolves kind, opponent, home/away, league
-- and kickoff as usual.  Who actually sees and RSVPs the game is the cup
-- roster, invited by fh_event_invites rows (mig 568) — the same mechanism
-- as youth call-ups (mig 355).

INSERT INTO teams (club_id, name, label, short_label, gender_category, club_section_id,
                   roster_source, board_sort_order, board_archived_at, is_active)
SELECT 134, 'USASA Cup', 'USASA Cup', 'Cup', 'mens',
       (SELECT id FROM club_sections WHERE LOWER(name) = 'mens' LIMIT 1),
       'direct', NULL, now(), true
 WHERE NOT EXISTS (SELECT 1 FROM teams WHERE club_id = 134 AND name = 'USASA Cup');

INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes)
SELECT v.club_alias, 'usasa cup', t.id, 'Cup container team (mig 567): no players; cup squad is invited per game'
  FROM (VALUES ('men'), ('mens')) AS v(club_alias)
  CROSS JOIN (SELECT id FROM teams WHERE club_id = 134 AND name = 'USASA Cup') t
 WHERE NOT EXISTS (SELECT 1 FROM gcal_team_aliases g WHERE g.club_alias = v.club_alias AND g.team_alias = 'usasa cup');
