-- 788: PPR Indoor teams — U12 / U11 / U10 Indoor on the Boys board
-- (owner 2026-10-28: "u12,u11,u10 is the play and this way the u8 players
-- can play on u10"; "12 per roster"; "its ppr indoor"; "just add them, no
-- draft needed").
--
-- Ages run on the school year (Aug 1 cutoff, fh_youth_single_age) and a
-- kid may play UP, so U8s can be placed on U10 Indoor.
--
-- League → season → conference → division as every team hangs: PPR
-- (league 8) gets an "Indoor 2026–27" season.  The teams share their OWN
-- mutex group, boys-indoor: a kid holds at most one indoor team, and that
-- sits alongside his outdoor team (boys-selection) instead of replacing it.
-- is_travel = a selected squad (reminders carry the travel line, mig 509).
-- field_size stays NULL until the indoor format is known.
INSERT INTO seasons (league_id, name, is_active)
SELECT 8, 'Indoor 2026–27', true
 WHERE NOT EXISTS (SELECT 1 FROM seasons WHERE league_id = 8 AND name = 'Indoor 2026–27');

INSERT INTO conferences (season_id, name, abbreviation)
SELECT s.id, 'Youth Indoor', 'YI' FROM seasons s
 WHERE s.league_id = 8 AND s.name = 'Indoor 2026–27'
   AND NOT EXISTS (SELECT 1 FROM conferences c WHERE c.season_id = s.id AND c.name = 'Youth Indoor');

INSERT INTO divisions (season_id, conference_id, name)
SELECT s.id, c.id, 'Indoor' FROM seasons s JOIN conferences c ON c.season_id = s.id AND c.name = 'Youth Indoor'
 WHERE s.league_id = 8 AND s.name = 'Indoor 2026–27'
   AND NOT EXISTS (SELECT 1 FROM divisions d WHERE d.season_id = s.id AND d.name = 'Indoor');

-- After U12 Travel's column (board_sort_order 5) and before the intramurals.
UPDATE teams SET board_sort_order = board_sort_order + 3
 WHERE gender_category = 'boys' AND is_active AND board_sort_order > 5
   AND NOT EXISTS (SELECT 1 FROM teams WHERE name = 'U12 Indoor');

INSERT INTO teams (division_id, club_id, name, gender_category, roster_source, label, short_label, color,
                   board_sort_order, mutex_group, max_roster, is_active, club_section_id, is_travel,
                   rsvp_board, uniform_set_id, lineup_everyone_plays)
SELECT d.id, tpl.club_id, v.name, 'boys', 'direct', v.label, v.short, v.color,
       v.sort, 'boys-indoor', 12, true, tpl.club_section_id, true,
       tpl.rsvp_board, tpl.uniform_set_id, tpl.lineup_everyone_plays
  FROM (VALUES ('U12 Indoor', '🏠 U12 Indoor', 'U12 Ind', '#e11d48', 6),
               ('U11 Indoor', '🏠 U11 Indoor', 'U11 Ind', '#0d9488', 7),
               ('U10 Indoor', '🏠 U10 Indoor', 'U10 Ind', '#ea580c', 8)) AS v(name, label, short, color, sort)
  JOIN teams tpl ON tpl.id = 913                       -- U10 Travel: club, section, kit, lineup rule
  JOIN seasons s ON s.league_id = 8 AND s.name = 'Indoor 2026–27'
  JOIN divisions d ON d.season_id = s.id AND d.name = 'Indoor'
 WHERE NOT EXISTS (SELECT 1 FROM teams t WHERE t.name = v.name AND t.club_id = tpl.club_id);
