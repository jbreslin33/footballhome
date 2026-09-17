-- 369 — #leads / #messages chips, moved into the DB (pass 3a).
--
-- Owner 2026-09-17: "we need all messages in db no hard code not even for
-- nudges".  Migrations 364–368 covered backend-written messages and the
-- roster/member cards; this is the lead funnel: the touch-1 intro and every
-- reply chip LeadsScreen.messageSnippets() used to type out in JS
-- (frontend/js/screens/leads.js, also rendered by #messages).
--
-- How a lead row is chosen: the screen asks for a kind and tries, in order,
--   tier = the funnel label      ('PR Men', 'Boys Club (U11/U12)', …)
--   tier = the funnel's base     ('U23 Men' for the combined 'U23 Men + PR')
--   tier = the audience          boys | girls | youth | men | women
--   tier = 'parent'              any youth funnel (the reader is a parent)
--   tier = 'all'
-- so one row covers every funnel until a funnel needs its own wording.
-- 'youth' is the legacy combined form, where the lead's gender is unknown
-- and both registration links are offered.
--
-- Two sorts of kinds:
--   lead_<fact>    a fact about the funnel (programme name, practice days,
--                  fee, venue…) — rendered first and handed to the messages
--                  as a token of the same name.
--   lead_<message> what the coach sends.  Lead tokens {first} {full}
--                  {phone} {coach} {coachFirst} are filled per lead.
--
-- What changed in the wording, on purpose:
--   • Men's practice is what the calendar actually runs (Tue–Fri 7–8:30pm,
--     Sat 11am–12:30pm).  The old copy sold Tue/Sat as "pickups that count
--     as a practice" — men are all practice now (see migration 367).
--   • Youth practice matches the calendar and the programme description
--     (3rd grade and older also train Fridays); the old chip said Mon/Wed.
--   • The 📅 chips no longer tell women "$1 locks your spot" — registering
--     with Lighthouse is free for them.
--   • The ⚽ Pickup chip drops the event title (never the gcal title in
--     player-facing text) — and the "next pickup" branch, which nothing
--     ever fed.
--   • The placeholder "(TODO — fill this in…)" schedule chip is gone: a
--     funnel with no lead_games_day row simply has no 📅 chips.
--   • "Practice is … 5:30–7pm.." (double full stop) in the youth welcome.
--
-- NOT converted here (owner decision pending — see docs/messages-in-db.md):
-- the season one-offs (Spring → re-register, Practice schedule, Alumni
-- return), and lib/program-info.js, which public pages use without a login.

-- ── Links ──────────────────────────────────────────────────────────────
INSERT INTO club_forms (club_id, code, label, url) VALUES
  (134, 'mens_handbook',          'Men''s handbook (Google Doc)',
        'https://docs.google.com/document/d/1xjekFzKZeYGnFL-QIy9YzII8trd50Nrz-tn1D-HQH_c/edit?usp=sharing'),
  (134, 'casa_grassroots_roster', 'CASA Philly Grassroots Cup — player roster form (PR / Brazil Men)',
        'https://casasoccerleagues.sportngin.com/register/form/824938975'),
  (134, 'casa_grassroots_schedule', 'CASA Philly Grassroots Cup — public schedule',
        'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9345724'),
  (134, 'u23_mens_schedule',      'U23 Men — season schedule (Google Sheet)',
        'https://docs.google.com/spreadsheets/d/e/2PACX-1vRFh_2Do_e8aOsItIW3yohRF70hoxsNJDSnuin99F_9TPBYBsqddMNhNg8GESaSng/pubhtml'),
  (134, 'maps_outdoor',           'Google Maps — Lighthouse Sports Complex (outdoor)',
        'https://maps.google.com/?q=Lighthouse+Sport+Complex+Field'),
  (134, 'maps_indoor',            'Google Maps — Lighthouse Community Center (indoor)',
        'https://maps.google.com/?q=141+W+Somerset+St+Philadelphia+PA+19140'),
  (134, 'footballhome',           'Football Home', 'https://footballhome.org')
ON CONFLICT (club_id, code) DO NOTHING;

CREATE OR REPLACE FUNCTION pg_temp.add_lead_tpl(p_kind text, p_tier text, p_label text,
                                                p_subject text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, p_subject, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

-- ── Fallback words for the sender tokens ───────────────────────────────
SELECT pg_temp.add_lead_tpl('fallback', 'coachFirst', 'Fallback — sender has no name on file', NULL, 'Coach', 109);
SELECT pg_temp.add_lead_tpl('fallback', 'coach',      'Fallback — sender has no name on file ({coach})', NULL, 'Coach', 110);
-- {coach} = "Coach Mike": the title in front of the sender's first name.
SELECT pg_temp.add_lead_tpl('lead_coach_title', 'all', 'Lead — title in front of the sender''s first name', NULL, 'Coach {sender_first}', 300);

-- ── Facts: what each funnel is called ──────────────────────────────────
SELECT pg_temp.add_lead_tpl('lead_program', 'all',                     'Lead programme — unknown funnel', NULL, 'program', 301);
SELECT pg_temp.add_lead_tpl('lead_program', 'Youth (Grades 1–6)',      'Lead programme', NULL, 'youth soccer program (grades 1–6)', 302);
SELECT pg_temp.add_lead_tpl('lead_program', 'Boys Club (Grades 1–6)',  'Lead programme', NULL, 'Boys Club soccer program (grades 1–6)', 302);
SELECT pg_temp.add_lead_tpl('lead_program', 'Boys Club (K-12)',        'Lead programme', NULL, 'Boys Club soccer program', 302);
SELECT pg_temp.add_lead_tpl('lead_program', 'Boys Club (U11/U12)',     'Lead programme', NULL, 'Boys U11/U12 travel team', 302);
SELECT pg_temp.add_lead_tpl('lead_program', 'Girls Club (Grades 1–6)', 'Lead programme', NULL, 'Girls Club soccer program (grades 1–6)', 302);
SELECT pg_temp.add_lead_tpl('lead_program', 'Girls Club (K-12)',       'Lead programme', NULL, 'Girls Club soccer program', 302);
SELECT pg_temp.add_lead_tpl('lead_program', 'Girls Club (U11/U12)',    'Lead programme', NULL, 'Girls U11/U12 travel team (co-ed for fall 2026 — plays in the boys division)', 302);
SELECT pg_temp.add_lead_tpl('lead_program', 'Brazil Men',              'Lead programme', NULL, 'Brazilian Men''s team', 302);
SELECT pg_temp.add_lead_tpl('lead_program', 'PR Men',                  'Lead programme', NULL, 'Puerto Rican Men''s team', 302);
SELECT pg_temp.add_lead_tpl('lead_program', 'U23 Men',                 'Lead programme', NULL, 'U23 Men''s team', 302);
SELECT pg_temp.add_lead_tpl('lead_program', 'Men''s Club',             'Lead programme', NULL, 'Men''s Club soccer team', 302);
SELECT pg_temp.add_lead_tpl('lead_program', 'U23 Women',               'Lead programme', NULL, 'U23 Women''s team', 302);
SELECT pg_temp.add_lead_tpl('lead_program', 'Tri County Women',        'Lead programme', NULL, 'Tri County Women''s team', 302);
SELECT pg_temp.add_lead_tpl('lead_program', 'Women''s Club',           'Lead programme', NULL, 'Women''s Club soccer team', 302);
SELECT pg_temp.add_lead_tpl('lead_program', 'APSL / Liga 1',           'Lead programme', NULL, 'APSL / Liga 1 team', 302);
SELECT pg_temp.add_lead_tpl('lead_program', 'APSL Trials',             'Lead programme', NULL, 'APSL / Liga 1 team', 302);
SELECT pg_temp.add_lead_tpl('lead_program', 'LIGA 1 Trials',           'Lead programme', NULL, 'APSL / Liga 1 team', 302);

-- Branded club name — the touch-1 email subject.
SELECT pg_temp.add_lead_tpl('lead_club_title', 'all',   'Lead club title', NULL, 'Lighthouse Soccer Club 1893', 310);
SELECT pg_temp.add_lead_tpl('lead_club_title', 'youth', 'Lead club title', NULL, 'Lighthouse Boys & Girls Soccer Club 1893', 310);
SELECT pg_temp.add_lead_tpl('lead_club_title', 'boys',  'Lead club title', NULL, 'Lighthouse Boys Soccer Club 1893', 310);
SELECT pg_temp.add_lead_tpl('lead_club_title', 'girls', 'Lead club title', NULL, 'Lighthouse Girls Soccer Club 1893', 310);
SELECT pg_temp.add_lead_tpl('lead_club_title', 'men',   'Lead club title', NULL, 'Lighthouse Men''s Soccer Club 1893', 310);
SELECT pg_temp.add_lead_tpl('lead_club_title', 'women', 'Lead club title', NULL, 'Lighthouse Women''s Soccer Club 1893', 310);

-- "Great — {closer}." in the 📨 Close reply.
SELECT pg_temp.add_lead_tpl('lead_closer', 'all',   'Lead close opener', NULL, 'glad you want to play for Lighthouse', 311);
SELECT pg_temp.add_lead_tpl('lead_closer', 'women', 'Lead close opener', NULL, 'glad you want to play with Lighthouse', 311);
SELECT pg_temp.add_lead_tpl('lead_closer', 'boys',  'Lead close opener', NULL, 'glad your son wants to play for Lighthouse', 311);
SELECT pg_temp.add_lead_tpl('lead_closer', 'girls', 'Lead close opener', NULL, 'glad your daughter wants to play for Lighthouse', 311);
SELECT pg_temp.add_lead_tpl('lead_closer', 'youth', 'Lead close opener', NULL, 'glad your player wants to play for Lighthouse', 311);

-- Whose spot / who is the member.
SELECT pg_temp.add_lead_tpl('lead_whose', 'all',   'Lead — whose spot', NULL, 'your', 312);
SELECT pg_temp.add_lead_tpl('lead_whose', 'parent', 'Lead — whose spot', NULL, 'your player''s', 312);
SELECT pg_temp.add_lead_tpl('lead_member', 'all',   'Lead — who just became a member', NULL, 'You''re', 313);
SELECT pg_temp.add_lead_tpl('lead_member', 'parent', 'Lead — who just became a member', NULL, 'Your player''s', 313);
SELECT pg_temp.add_lead_tpl('lead_child', 'boys',  'Lead — the child', NULL, 'son', 314);
SELECT pg_temp.add_lead_tpl('lead_child', 'girls', 'Lead — the child', NULL, 'daughter', 314);

-- Fees.
SELECT pg_temp.add_lead_tpl('lead_fee',     'all',   'Lead fee — to register', NULL, '$1', 315);
SELECT pg_temp.add_lead_tpl('lead_fee',     'women', 'Lead fee — to register', NULL, 'Free', 315);
SELECT pg_temp.add_lead_tpl('lead_pricing', 'all',   'Lead fee — after registering', NULL, '$35/month', 316);
SELECT pg_temp.add_lead_tpl('lead_pricing', 'women', 'Lead fee — after registering', NULL, 'a few $/game for refs; $35 separately on the league site', 316);

-- The registration link(s) as they trail a sentence ending in ":".
SELECT pg_temp.add_lead_tpl('lead_links', 'all',   'Lead — registration link', NULL, ' {link}', 317);
SELECT pg_temp.add_lead_tpl('lead_links', 'youth', 'Lead — both registration links (gender unknown)', NULL, E'\n• Boys: {link_boys}\n• Girls: {link_girls}', 317);
SELECT pg_temp.add_lead_tpl('lead_links_inline', 'all',   'Lead — registration link, inline (SMS)', NULL, '{link}', 318);
SELECT pg_temp.add_lead_tpl('lead_links_inline', 'youth', 'Lead — both registration links, inline (SMS)', NULL, 'Boys: {link_boys} · Girls: {link_girls}', 318);
-- The soft close that ends the 📍/📅 chips.
SELECT pg_temp.add_lead_tpl('lead_lock', 'all',   'Lead — soft close on info chips', NULL, '{fee} locks {whose} spot:{links}', 319);
SELECT pg_temp.add_lead_tpl('lead_lock', 'women', 'Lead — soft close on info chips', NULL, 'Register here:{links}', 319);

-- Venues.
SELECT pg_temp.add_lead_tpl('lead_venue', 'outdoor',         'Venue — outdoor', NULL, 'Lighthouse Sports Complex — 199 E Erie Ave, Philadelphia PA 19140', 320);
SELECT pg_temp.add_lead_tpl('lead_venue', 'outdoor_address', 'Venue — outdoor, address only', NULL, '199 E Erie Ave, Philadelphia PA', 320);
SELECT pg_temp.add_lead_tpl('lead_venue', 'indoor',          'Venue — indoor', NULL, 'Lighthouse Community Center — 141 W Somerset St, Philadelphia PA 19133', 320);

-- Schedule facts.  No lead_games_day row ⇒ the funnel gets no 📅 chips.
SELECT pg_temp.add_lead_tpl('lead_games_day', 'men',              'Lead — game day', NULL, 'Sundays', 321);
SELECT pg_temp.add_lead_tpl('lead_games_day', 'parent',            'Lead — game day', NULL, 'Sunday mornings to early afternoon', 321);
SELECT pg_temp.add_lead_tpl('lead_games_day', 'Tri County Women', 'Lead — game day', NULL, 'Sundays, late morning to early afternoon', 321);

SELECT pg_temp.add_lead_tpl('lead_practice', 'men',   'Lead — practice days', NULL, 'Tuesday–Friday 7–8:30pm and Saturday 11am–12:30pm', 322);
SELECT pg_temp.add_lead_tpl('lead_practice', 'parent', 'Lead — practice days', NULL, '2nd grade and younger — Mondays & Wednesdays 4:30–5:30pm; 3rd grade and older — Mondays, Wednesdays & Fridays 5:30–7pm (grade in the upcoming school year)', 322);
SELECT pg_temp.add_lead_tpl('lead_practice', 'Boys Club (U11/U12)',  'Lead — practice days', NULL, 'Mondays, Wednesdays & Fridays 5:30–7pm (5th & 6th graders)', 322);
SELECT pg_temp.add_lead_tpl('lead_practice', 'Girls Club (U11/U12)', 'Lead — practice days', NULL, 'Mondays, Wednesdays & Fridays 5:30–7pm (5th & 6th graders)', 322);
SELECT pg_temp.add_lead_tpl('lead_practice_note', 'men', 'Lead — practice note', NULL,
  'Five sessions a week so it''s as easy as possible to make practice — aim for any two.', 323);

SELECT pg_temp.add_lead_tpl('lead_schedule_url',    'men',     'Lead — public schedule', NULL, '{form:casa_grassroots_schedule}', 324);
SELECT pg_temp.add_lead_tpl('lead_schedule_url',    'U23 Men', 'Lead — public schedule', NULL, '{form:u23_mens_schedule}', 324);
SELECT pg_temp.add_lead_tpl('lead_schedule_source', 'men',     'Lead — what the schedule link is', NULL, 'CASA Philly Grassroots Cup', 325);
SELECT pg_temp.add_lead_tpl('lead_schedule_source', 'U23 Men', 'Lead — what the schedule link is', NULL, 'season Google Sheet', 325);

SELECT pg_temp.add_lead_tpl('lead_handbook_url', 'men', 'Lead — handbook', NULL, '{form:mens_handbook}', 326);

-- League-side roster registration, asked for in the adult 🎉 Welcome.
SELECT pg_temp.add_lead_tpl('lead_roster_url',  'PR Men',       'Lead — league roster form', NULL, '{form:casa_grassroots_roster}', 327);
SELECT pg_temp.add_lead_tpl('lead_roster_url',  'Brazil Men',   'Lead — league roster form', NULL, '{form:casa_grassroots_roster}', 327);
SELECT pg_temp.add_lead_tpl('lead_roster_url',  'U23 Men + PR', 'Lead — league roster form', NULL, '{form:casa_grassroots_roster}', 327);
SELECT pg_temp.add_lead_tpl('lead_roster_team', 'PR Men',       'Lead — country to pick on the roster form', NULL, 'Puerto Rico', 328);
SELECT pg_temp.add_lead_tpl('lead_roster_team', 'Brazil Men',   'Lead — country to pick on the roster form', NULL, 'Brazil', 328);
SELECT pg_temp.add_lead_tpl('lead_roster_team', 'U23 Men + PR', 'Lead — country to pick on the roster form', NULL, 'Puerto Rico', 328);
SELECT pg_temp.add_lead_tpl('lead_roster_note', 'U23 Men',      'Lead — league registration arrives by email', NULL,
  'Watch your inbox for an email from Squadi — that''s our league''s registration platform. Open it and complete the player registration so you''re eligible for league games.', 329);

SELECT pg_temp.add_lead_tpl('lead_next_practice_label', 'all', 'Lead — label of the next-practice line in ℹ️ More info', NULL, 'Next practice:', 330);

-- ── Touch 1 — first contact ────────────────────────────────────────────
SELECT pg_temp.add_lead_tpl('lead_first_sms', 'all', 'Lead touch 1 — text', NULL,
  'Hi {first}, {coachFirst} here — Soccer Director at Lighthouse 1893. Are you looking to join our {program} this season?', 340);
SELECT pg_temp.add_lead_tpl('lead_first_email', 'all', 'Lead touch 1 — email', '{club_title}',
  E'Hi {first},\n\n{coachFirst} here, Soccer Director at Lighthouse 1893.\n\nAre you looking to join our {program} this season?\n\nThanks,\n{coachFirst}\nSoccer Director\nLighthouse 1893 SC\n{outreach_email}', 341);

-- ── 💳 Register ────────────────────────────────────────────────────────
SELECT pg_temp.add_lead_tpl('lead_register', 'all', 'Lead 💳 Register — adult', NULL,
  E'Great. To become a member of the club it''s {fee} registration on this link: {link}\nOnce you''re in you can start coming to trainings and games.', 350);
SELECT pg_temp.add_lead_tpl('lead_register', 'women', 'Lead 💳 Register — women', NULL,
  E'Great. Registering with Lighthouse is free — register here: {link}\nOnce you''re in you can start coming to trainings and games. Games run a few $ per player for refs, and you''ll separately register with the Women''s Tri County Soccer League for $35.', 350);
SELECT pg_temp.add_lead_tpl('lead_register', 'boys', 'Lead 💳 Register — parent', NULL,
  'Great. To register your {child} as a member of the soccer club, register here: {link}', 350);
SELECT pg_temp.add_lead_tpl('lead_register', 'girls', 'Lead 💳 Register — parent', NULL,
  'Great. To register your {child} as a member of the soccer club, register here: {link}', 350);

-- ── 🎉 Welcome (after the lead registers) ──────────────────────────────
SELECT pg_temp.add_lead_tpl('lead_welcome', 'all', 'Lead 🎉 Welcome — adult',
  'Welcome to Lighthouse 1893 SC! Next steps',
  E'🎉 {member} officially a member of the club.\n\n[[1. 📝 League team roster — required to play sanctioned games:\n   {roster_url}\n   ⚠️ When the form asks for your country, choose **{roster_team}**.\n   (You''re not locked into just {roster_team} games — we run friendlies every weekend, and you''re welcome in any of them.)\n]][[{roster_note_n}. 📬 League registration — {roster_note}\n]]\nReply anytime and I''ll send you the next practice and match details — including the RSVP link for each match.\n\nSee you on the field. 🤝', 351);
SELECT pg_temp.add_lead_tpl('lead_welcome', 'parent', 'Lead 🎉 Welcome — parent',
  'Welcome to Lighthouse 1893 SC! Next steps',
  E'🎉 {member} officially a member of the club. Next steps to play in games and attend practices:\n\n1. 📬 Practice & game schedule emails will go out before the season starts — keep an eye on this inbox.\n2. 🏃 Practice: {practice}.\n3. ⚽ Games are on {games_day}.\n4. 📍 Field address (practices and games):\n   {venue_outdoor}\n   {form:maps_outdoor}\n\nReply to this email with any questions — happy to help.', 351);

-- ── ⚽ Pickup — soft fallback for a hesitant adult ─────────────────────
SELECT pg_temp.add_lead_tpl('lead_pickup', 'all', 'Lead ⚽ Pickup — soft fallback', NULL,
  E'No pressure to commit yet — reply and I''ll let you know when the next pickup is scheduled.\nCome play, meet the squad, see if it''s your scene. If it is, {fee} to lock in your team spot.', 352);
SELECT pg_temp.add_lead_tpl('lead_pickup', 'women', 'Lead ⚽ Pickup — soft fallback, women', NULL,
  E'No pressure to commit yet — reply and I''ll let you know when the next pickup is scheduled.\nCome play, meet the squad, see if it''s your scene.', 352);

-- ── 📨 Close — the reply to a YES ──────────────────────────────────────
SELECT pg_temp.add_lead_tpl('lead_close_email', 'all', 'Lead 📨 Close — email', NULL,
  E'Hi {first},\n\nGreat — {closer}.\n\nRegister here (full program details on the page):{links_block}\n\nOnce you''re registered, I''ll send you a link to set your availability for practices and games.\n\nLet me know if you have any questions!\n\n— {coachFirst}\nSoccer Director\nLighthouse 1893 SC', 353);
SELECT pg_temp.add_lead_tpl('lead_close_sms', 'all', 'Lead 📨 Close — text', NULL,
  E'Great — {closer}. Register: {links_inline}\nOnce registered, I''ll send a link to set your availability for practices & games.\nLet me know if you have any questions!\n— {coachFirst}', 354);
-- The link under "Register here…:" sits on its own line.
SELECT pg_temp.add_lead_tpl('lead_links_block', 'all',   'Lead — registration link on its own line', NULL, E'\n{link}', 355);
SELECT pg_temp.add_lead_tpl('lead_links_block', 'youth', 'Lead — both registration links on their own lines', NULL, E'\n• Boys: {link_boys}\n• Girls: {link_girls}', 355);

-- ── ℹ️ More info — wraps the programme description ─────────────────────
SELECT pg_temp.add_lead_tpl('lead_more_info_email', 'all', 'Lead ℹ️ More info — email, adult', NULL,
  E'Hi {first},\n\nThat''s great that you want to play soccer for {club_title}!\n\nTo register, head here: {link}\n\nOnce registered you can join in practices and games to find your appropriate place at the club.\n\nHere''s the full program description:\n\n{description}', 356);
SELECT pg_temp.add_lead_tpl('lead_more_info_email', 'women', 'Lead ℹ️ More info — email, women', NULL,
  E'Hi {first},\n\nThat''s great that you want to play soccer for {club_title}!\n\nTo register, head here: {link}\n\nHere''s the full program description:\n\n{description}', 356);
SELECT pg_temp.add_lead_tpl('lead_more_info_email', 'parent', 'Lead ℹ️ More info — email, parent', NULL,
  E'Hi {first},\n\nLet me know any questions!\n\nTo register, head here:{links}\n\nHere''s the full program description:\n\n{description}', 356);
SELECT pg_temp.add_lead_tpl('lead_more_info_sms', 'all', 'Lead ℹ️ More info — text', NULL,
  E'Hi {first} — quick details on {program}:\n• Field: {venue_outdoor_address}\n• Cost: {fee} to register, then {pricing}\n• Card on file with sufficient funds required (auto-charged monthly)\nRegister: {links_inline}\nReply w/ any Qs — {coachFirst}', 357);
SELECT pg_temp.add_lead_tpl('lead_more_info_sms', 'women', 'Lead ℹ️ More info — text, women', NULL,
  E'Hi {first} — quick details on {program}:\n• Field: {venue_outdoor_address}\n• Cost: {fee} to register, then {pricing}\nRegister: {links_inline}\nReply w/ any Qs — {coachFirst}', 357);

-- ── 📍 Field ───────────────────────────────────────────────────────────
SELECT pg_temp.add_lead_tpl('lead_field', 'all', 'Lead 📍 Field', NULL,
  E'📍 {venue_outdoor} (outdoor)\n   {form:maps_outdoor}\n📍 {venue_indoor} (indoor)\n   {form:maps_indoor}\n\n{lock}', 358);

-- ── 📅 Practice · Games · Schedule ─────────────────────────────────────
SELECT pg_temp.add_lead_tpl('lead_practice_lines', 'all', 'Lead 📅 — the practice lines', NULL,
  E'Practice: {practice}\n{venue_outdoor}[[\n{practice_note}]]', 359);
SELECT pg_temp.add_lead_tpl('lead_games_lines', 'all', 'Lead 📅 — the games lines (public schedule exists)', NULL,
  E'Games are mostly on {games_day} — full schedule ({schedule_source}):\n{schedule_url}', 360);
SELECT pg_temp.add_lead_tpl('lead_games_lines_no_url', 'all', 'Lead 📅 — the games lines (no public schedule)', NULL,
  E'Games are mostly on {games_day}.\nSpecific times/fields confirm after rosters close.', 361);
SELECT pg_temp.add_lead_tpl('lead_practice_chip', 'all', 'Lead 📅 Practice', NULL, E'{practice_lines}\n\nIf it works, {lock}', 362);
SELECT pg_temp.add_lead_tpl('lead_games_chip',    'all', 'Lead 📅 Games',    NULL, E'{games_lines}\n\nIf it works, {lock}', 363);
SELECT pg_temp.add_lead_tpl('lead_schedule_chip', 'all', 'Lead 📅 Schedule', NULL, E'[[{practice_lines}\n]]{games_lines}\n\nIf it works, {lock}', 364);
SELECT pg_temp.add_lead_tpl('lead_games_chip',    'women', 'Lead 📅 Games — women',    NULL, E'{games_lines}\n\n{lock}', 363);
SELECT pg_temp.add_lead_tpl('lead_schedule_chip', 'women', 'Lead 📅 Schedule — women', NULL, E'[[{practice_lines}\n]]{games_lines}\n\n{lock}', 364);

-- ── 💵 Cost ────────────────────────────────────────────────────────────
SELECT pg_temp.add_lead_tpl('lead_cost', 'all', 'Lead 💵 Cost', NULL,
  E'{fee} today to lock {whose} spot. After that it''s {pricing}.\n\nRegister here:{links}', 365);
SELECT pg_temp.add_lead_tpl('lead_cost', 'women', 'Lead 💵 Cost — women', NULL,
  E'Registering with Lighthouse is free. After that it''s {pricing}.\n\nRegister here:{links}', 365);

-- ── 📚 Fall Format (youth) ─────────────────────────────────────────────
SELECT pg_temp.add_lead_tpl('lead_fall_format', 'parent', 'Lead 📚 Fall Format', NULL,
  E'Fall 2026 season format at Lighthouse 1893 SC:\n• PreK–1st grade: In-House league\n• 2nd–6th grade: Select/Travel teams — players not selected take part in the Lighthouse In-House League, tournaments, friendly games, festivals, practices & pickup sessions\n• 7th–12th grade: Lighthouse In-House League, tournaments, friendly games, festivals, practices & pickup sessions\n\nRegister here:{links}', 366);

-- ── 📣 Set availability at footballhome.org (men's broadcast) ──────────
-- Shown on the funnels that have a row.  "pickup" is gone from the copy:
-- men are all practice now.
SELECT pg_temp.add_lead_tpl('lead_set_availability', 'Men''s Club', 'Lead 📣 Set availability broadcast',
  'Lighthouse 1893 — set your availability at footballhome.org',
  E'Hi guys,\n\nWe track availability for games and practice on footballhome.org — which works on your phone or computer, and also installs as an app on your phone.\n\nHow to get in:\n1. Open {form:footballhome} on your phone or computer\n2. On your phone? Tap Share → Add to Home Screen (iOS) or Install app (Android) so it lives on your home screen like a real app.\n3. Tap Sign In\n4. Tap "Continue with Google" — use the same email you''re registered with on LeagueApps\n\nNo Google account? No problem:\n• Tap "Sign in with email & password"\n• Tap "Forgot / set password"\n• Enter your LeagueApps email — we''ll send you a link to set a password. Set it, then sign in.\n\nOnce you''re in, you''ll see your week under My Schedule. For every game / practice, just tap:\n• Going\n• Can''t go\n\nYou must set availability for EVERY event on your weekly schedule. Not sure? Tap Can''t go — you can always change it later if plans free up.\n\nPlease sign in and set your availability for this week. There''s also a button to set your **recurring** availability — everyone should commit to 2 recurring practices if you can. Then you only need to change it the week of if you CANNOT make it.\n\nOnly use recurring if your schedule actually allows it — we don''t want no-shows. If your week is unpredictable, just set availability week-by-week.\n\nGoing forward we''ll be fining no-shows AND anyone who shows up without setting their availability — it hurts the teams and the club when we can''t plan.\n\nAny questions, DM me — let''s keep the chat clear so everyone can see this message.\n\nThanks,\nLighthouse 1893 SC\n{outreach_email}', 367);
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', label, kind, 'APSL / Liga 1', subject, body, sort_order, true, true
  FROM message_templates m
 WHERE m.kind = 'lead_set_availability' AND m.tier = 'Men''s Club'
   AND NOT EXISTS (SELECT 1 FROM message_templates x WHERE x.kind = 'lead_set_availability' AND x.tier = 'APSL / Liga 1');
