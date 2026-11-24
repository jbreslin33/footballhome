-- 1792 (2026-11-24) — 🔺 #apsl-pyramid "How a club climbs": the note over
-- the pro leagues adds the member-owned clubs (owner: "US Soccer currently
-- bans club setups like Real Madrid and Barcelona among many, many others
-- from being pro in the us. this is anti-competitive lessens us as a soccer
-- nation").  The fact behind it: the Professional League Standards ask each
-- team for a wealthy principal owner, which a club owned by its members
-- does not have.  Words only.
BEGIN;
UPDATE message_templates
   SET body = 'Unfortunately, in the U.S. there is no advancement to the pro leagues based on sporting merit. Today a club moves up only by meeting U.S. Soccer''s Professional League Standards (PLS) and joining a league sanctioned at that division. Those standards require a wealthy principal owner, so clubs owned by their members — the way Real Madrid and Barcelona are, among many, many others — are barred from being professional here. We think that is anti-competitive and lessens us as a soccer nation. Hopefully U.S. Soccer fixes this — it would improve soccer in the U.S. and make it truly the people''s game and the premier sport in the country.'
 WHERE kind = 'apsl_pyramid' AND tier = 'path_pro_note';
COMMIT;
