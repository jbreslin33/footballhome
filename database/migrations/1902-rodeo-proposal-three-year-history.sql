-- 📣 Rodeo-day proposal: the rodeo schedule from the ops calendar over the
-- last three seasons, not just 2026 (James 11/25 "show rodeo schedule from
-- gcal on proposal" / "from last like 2 years right so we have idea of
-- typcial times and dates and amounts").
--
-- Source: Google Calendar sports@lighthouse1893.org read directly with the
-- gcal-sync service account (events.list 2023-06-01 → 2027, singleEvents).
-- The gcal_events mirror only reaches back ~30 days before its first sync
-- (May 2026), so it holds no 2023–2025 rodeos.  Rows titled Ramiro / Romero
-- Rodeo (and "Ramiro rode his", Oct 24 2026); planning meetings, the police
-- check drop-off and duplicate entries on one day left out.  Google now has
-- the Sep 2026 rodeo as Sunday the 13th (all day) and the Concert and Western
-- Event on Saturday the 12th.  No crowd sizes or rodeo fees are written on
-- any rodeo entry; the one amount on a Ramiro booking is a $1,500 barn party
-- (Feb 24 2024).

BEGIN;

UPDATE proposal_sections s
   SET heading = 'Rodeo days, 2023 to 2026',
       body = $b$From the Lighthouse ops calendar (Google), June 2023 to October 2026.
|Season|Rodeo days|Days of the week|Usual hours
|2023|14|7 Saturdays, 7 Sundays|Noon to 8 PM
|2024|17|14 Saturdays, 3 Sundays|Noon to midnight
|2025|11|All Saturdays|2 PM to 10 PM
|2026|11|10 Saturdays, 1 Sunday|2 PM to midnight
**The pattern:** since 2024 the rodeo is a **Saturday** thing, about **every second or third Saturday from April to October**, 11 to 17 a season. The season opens on the **second Saturday of April** (April 13 2024, April 12 2025, April 11 2026) and closes on the **Columbus Day weekend Saturday** (October 12 2024, October 11 2025, October 10 2026). The gates open at 2 PM. For 2027 expect about April 10 to October 9.
|Month|2024|2025|2026
|April|13, 27|12, 26|11
|May|11, 25, Sun 26|24|16, 23
|June|1|28|27
|July|6, Sun 7, 20|19, 26|11 (Barn Post Rodeo after, 9 PM–2 AM)
|August|10, 24 (small), 31|9, 30|8
|September|7, Sun 15, 21, 28 (small)|13, 20|5, **Sun 13**, 19
|October|12|11|10, 24
**Our home games:** not one 2026 men's or women's home game was on a rodeo Saturday. APSL v Persepolis was Sunday August 9, the day after a rodeo. On Sunday September 13 the calendar has the rodeo all day and the APSL and Liga 1 at home; a Liga 1 game in 2026 had to move to turf because of a rodeo.
**Amounts:** the calendar holds no crowd size or rodeo fee. The only figure on a Ramiro booking is **$1,500** for a barn party (February 24 2024). The crowd figure ("thousands") is James's; Ramiro is the one to ask for real gate numbers.$b$
  FROM proposals p
 WHERE p.id = s.proposal_id AND p.code = 'rodeo-day-crowds' AND s.sort_order = 2;

UPDATE proposal_sections s
   SET body = replace(s.body,
       '|Fri September 11, 2026|Concert and Western Event|A Friday night game under the concert lights, if the league allows',
       '|Sat September 12, 2026|Concert and Western Event|An evening home game before the concert, if the league allows')
  FROM proposals p
 WHERE p.id = s.proposal_id AND p.code = 'rodeo-day-crowds' AND s.sort_order = 5;

UPDATE proposal_sections s
   SET body = replace(s.body,
       'every men''s and women''s home game in 2026 was on a Sunday, and every rodeo was on a Saturday.',
       'every men''s and women''s home game in 2026 was on a Sunday, and since 2024 almost every rodeo has been on a Saturday: 11 to 17 of them a season, April to October.')
  FROM proposals p
 WHERE p.id = s.proposal_id AND p.code = 'rodeo-day-crowds' AND s.sort_order = 1;

UPDATE proposals SET as_of = '2026-11-25' WHERE code = 'rodeo-day-crowds';

COMMIT;
