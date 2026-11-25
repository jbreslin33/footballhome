-- 📣 Rodeo-day proposal: a SPRING section (James 11/25 "are we checking the
-- gcal for spring events and list them in a section and comment?").
--
-- Source: Google Calendar sports@lighthouse1893.org, March–June 2024–2027,
-- read directly with the gcal-sync service account (the gcal_events mirror
-- starts May 2026).  Listed: rodeos, Ramiro's festival / pageant / soccer
-- matches, Barn Nights, the FIFA fan festival, the 2027 music festival
-- hold.  Left out: private barn rentals (parties, proms, graduations,
-- 50–150 guests), walk-throughs, staff and school events.  The LFC v
-- Atlantic City entry (May 18 2025) says 4:30–8:30 PM but "Kickoff 2:30pm",
-- so no time is given for it.  The music festival hold is Jun 11–13 2027 in
-- Google (section 5 said Jun 10–12; fixed).

BEGIN;

-- make room for the new section 3
UPDATE proposal_sections s SET sort_order = s.sort_order + 100
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'rodeo-day-crowds' AND s.sort_order >= 3;
UPDATE proposal_sections s SET sort_order = s.sort_order - 99
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'rodeo-day-crowds' AND s.sort_order >= 103;

INSERT INTO proposal_sections (proposal_id, sort_order, heading, body)
SELECT p.id, 3, 'Spring at Lighthouse', $b$From the ops calendar, March to June, 2024 to 2026: the crowd days in the spring half of our season.
|When|Event|Hours
|2024 rodeos|Sat April 13, April 27, May 11, May 25, Sun May 26, Sat June 1|Noon to midnight
|2025 rodeos|Sat April 12, April 26, May 24, June 28|2 PM to 10 PM
|2026 rodeos|Sat April 11, May 16, May 23, June 27|2 PM to midnight
|Sat May 3, 2025|Ramiro Festival|3 PM to 10:30 PM
|Sat May 31, 2025|Ramiro Pageant|5 PM to midnight
|May–June 2025|Ramiro's LFC soccer at Lighthouse: Sat May 10 v FC Monmouth (gates 4 PM, kickoff 5:30), Sun May 18 v Atlantic City, Sun June 1 v Met Oval (6 PM), Sun June 8 U23 women v Steel United (6 PM), Sun June 15 v KSC (6 PM)|Evenings
|2025–2026|Barn Nights: April 18, May 16, Sat June 21 2025; Fri April 10, May 15, June 19 2026|7 PM to midnight
|Mon June 29, 2026|FIFA Fan Festival with the Lighthouse summer camp|Noon to 3:30 PM
|June 11–13, 2027|Music festival (held)|
Private barn rentals (parties, proms, graduations, 50 to 150 guests) fill most spring Saturdays as well. They are not a crowd for a game and are left out.
**What the spring tells us:**
- **The rodeo season opens on the second Saturday of April**, every year, and there are four to six rodeos by the end of June, one every two to four weeks.
- **Memorial Day weekend has a rodeo every year:** May 25–26 2024, May 24 2025, May 23 2026. In 2027 that is Saturday May 29, the best single date to ask for.
- **Ramiro already puts soccer in front of his crowd.** In spring 2025 his LFC played five home games at Lighthouse, with gates and evening kickoffs around his events. Ask him how many came, and whether our games can share his dates instead of competing with them.
- **Barn Night is a Friday every month in 2026** (7 PM to midnight). A Friday evening game before it is an option where a league allows Friday games.
- **Nothing for spring 2027 is on the calendar yet** except the music festival hold. The spring rodeo dates have to come from Ramiro before the spring schedules are made.$b$
  FROM proposals p WHERE p.code = 'rodeo-day-crowds'
ON CONFLICT (proposal_id, sort_order) DO NOTHING;

UPDATE proposal_sections s
   SET body = replace(s.body, '|June 10–12, 2027|Music festival (held)|', '|June 11–13, 2027|Music festival (held)|')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'rodeo-day-crowds' AND s.heading = 'Other big days';

COMMIT;
