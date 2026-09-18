-- 370 — the programme description, moved into the DB (pass 3b).
--
-- Owner 2026-09-17: "we need all messages in db no hard code not even for
-- nudges".  frontend/js/lib/program-info.js typed the whole membership /
-- teams / schedule / billing description out twice (HTML and plain text)
-- for three audiences.  It feeds the public flyer-QR pages
-- (#public-program-info), #flyers, and the #leads / #messages
-- "📋 LA Program Description" and "ℹ️ More info" chips.
--
-- The public pages have no login, so rows a signed-out visitor may read are
-- flagged is_public and served by GET /api/public/program-copy.
--
-- One body per row, in a small markup the browser turns into both HTML and
-- plain text (program-info.js):
--   ### Heading      - bullet        (two spaces)- sub-bullet
--   **bold**         blank line = new paragraph
--
-- Tier lookup, most specific first:
--   youth → all      men (Men's Club) → adult → all
--   women → all      adult (the other men's funnels) → all
-- 'program_description' is the skeleton; every {program_*} token in it is
-- the row of that kind.  Fees and venues are the lead_fee / lead_pricing /
-- lead_venue rows of migration 369 — one place for a price or an address.
--
-- Wording changed on purpose: the adult schedule is what the calendar runs
-- (Tue–Fri 7–8:30pm + Sat 11am–12:30pm, all practice) — the old copy still
-- sold Tue/Sat as pickup, which migration 369 already dropped from the lead
-- chips.  Venues now read exactly as the lead chips do.
--
-- Also here: the stale season one-offs in leads.js (Spring → re-register,
-- Practice schedule "Summer/Fall 2026", Alumni return "rest of July / Fri
-- Aug 7") were deleted rather than converted.

ALTER TABLE message_templates
  ADD COLUMN IF NOT EXISTS is_public boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN message_templates.is_public IS
  'Served without a login by GET /api/public/program-copy (migration 370). Only copy that is already printed on flyers / public pages.';

UPDATE message_templates SET is_public = true
 WHERE (kind = 'lead_venue'   AND tier IN ('outdoor', 'indoor'))
    OR (kind = 'lead_fee'     AND tier IN ('all', 'women'))
    OR (kind = 'lead_pricing' AND tier = 'all');

CREATE OR REPLACE FUNCTION pg_temp.add_program_tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
  SELECT 'System', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, false, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

-- ── Skeleton ───────────────────────────────────────────────────────────
SELECT pg_temp.add_program_tpl('program_description', 'all', 'Programme description — skeleton',
E'{program_intro}\n\n{program_membership}\n\n[[{program_teams}\n\n]]### Schedule\n[[{program_schedule}\n]]- **Games:** {program_games}\n- **Home Outdoor Facility:** {venue_outdoor}\n- **Home Indoor Facility:** {venue_indoor}\n\n{program_billing}\n\n### Changes & questions\n{program_changes}', 400);

-- ── Small facts ────────────────────────────────────────────────────────
SELECT pg_temp.add_program_tpl('program_member', 'all',   'Programme — whose membership', 'Your membership', 401);
SELECT pg_temp.add_program_tpl('program_member', 'youth', 'Programme — whose membership', 'Your player''s membership', 401);
SELECT pg_temp.add_program_tpl('program_kit',    'all',   'Programme — whose uniform', 'your uniform', 402);
SELECT pg_temp.add_program_tpl('program_kit',    'youth', 'Programme — whose uniform', 'their uniform', 402);
-- Chip / button labels.
SELECT pg_temp.add_program_tpl('program_fee_short', 'all',   'Programme — fee, short (chip label)', '$35/mo', 403);
SELECT pg_temp.add_program_tpl('program_fee_short', 'women', 'Programme — fee, short (chip label)', 'Free', 403);
SELECT pg_temp.add_program_tpl('program_fee_label', 'all',   'Programme — fee on Register buttons and flyers', '{fee} to register, then {program_fee_short}', 404);
SELECT pg_temp.add_program_tpl('program_fee_label', 'women', 'Programme — fee on Register buttons and flyers', 'Free to register — $35 league fee + refs per game', 404);

SELECT pg_temp.add_program_tpl('program_games', 'all',   'Programme — when games are', 'Sundays', 405);
SELECT pg_temp.add_program_tpl('program_games', 'youth', 'Programme — when games are', 'Sunday mornings to early afternoon', 405);
SELECT pg_temp.add_program_tpl('program_games', 'women', 'Programme — when games are', 'Sundays, late morning to early afternoon — September through November, winter break, then resuming late March through June', 405);

-- ── Intro ──────────────────────────────────────────────────────────────
SELECT pg_temp.add_program_tpl('program_intro', 'all', 'Programme — who Lighthouse is',
E'**Lighthouse 1893** is the oldest nonprofit community organization in Philadelphia, serving the neighborhood for over 133 years. Our mission with soccer is to keep the game **affordable, accessible, local, and high-quality** for every family in our community.\n\nOur history speaks to that quality. Lighthouse teams have won **5 U-19 national championships** and sent **7 players to the U.S. Soccer Hall of Fame, 2 to the FIFA World Cup, and 4 to the U.S. Olympics** — and, more importantly, through its **Boys Club, Girls Club, Men''s Club, and Women''s Club**, Lighthouse has spent 133 years developing generations of neighbors into people of the highest character who go on to serve their families, careers, and communities. **It''s a club for life in the neighborhood.** Today, we bring modern coaching and player-development methodology honed over 133 years to every player, from first-time beginners to advanced competitors.', 410);

-- ── Membership ─────────────────────────────────────────────────────────
SELECT pg_temp.add_program_tpl('program_membership', 'all', 'Programme — membership',
E'### Membership\nFor 133 years, Lighthouse has operated on a membership model to build community and belonging — because a community is stronger when it''s organized together. {program_member} runs year-round and covers all four seasons (Winter, Spring, Summer, Fall), training, matches, tournaments, and {program_kit}. There are no per-season, per-tournament, indoor, or uniform fees.', 411);
SELECT pg_temp.add_program_tpl('program_membership', 'women', 'Programme — membership (women: free)',
E'### Membership\nRegistration with Lighthouse is **free** — there''s no LeagueApps membership fee, and {program_kit} is supplied at no cost by the club.', 411);

-- ── Teams (the other men's funnels have no teams block) ─────────────────
SELECT pg_temp.add_program_tpl('program_teams', 'youth', 'Programme — teams (youth)',
E'### Teams\n**Lighthouse League** is our in-house program — games played primarily at the Lighthouse fields, with occasional events elsewhere. It''s for players and families looking for a **local, low-to-no-travel soccer experience**, and it''s open to every member regardless of skill level, age, or experience.\n\nFor players who want to travel to games as part of their season, we also field select travel squads (Fall 2026):\n- **U8, U10, U12** — competing in a boys-division travel league. We encourage and have girls playing on these squads while we grow the girls program.\n\nWe add travel teams for additional age bands as interest and readiness grow.', 412);
SELECT pg_temp.add_program_tpl('program_teams', 'men', 'Programme — teams (Men''s Club)',
E'### Teams\n**Trials have begun** for the **U.S. Open Cup**, **APSL 1st Team**, and **U.S. National Amateur Cup**. Join the Men''s Club to be considered.\n- **U.S. Open Cup** — the oldest and most prestigious soccer competition in the U.S. (est. 1914). Open, single-elimination — MLS, USL Championship, USL League One, MLS Next Pro, and qualifying amateur clubs compete for the Lamar Hunt U.S. Open Cup.\n- **U.S. National Amateur Cup** — U.S. Soccer''s national championship for amateur clubs (est. 1923). Regional qualifiers feed a national bracket to crown the top amateur side in the country.\n- **APSL (American Premier Soccer League)** — a national semi-pro league operating below the professional divisions of the U.S. Soccer pyramid (MLS, USL Championship, USL League One). The APSL 1st Team is Lighthouse''s pathway into U.S. Open Cup and U.S. National Amateur Cup rosters.\n\nOur competitive squads (Fall 2026):\n- **APSL**\n- **Liga 1**\n- **Liga 2**\n\n**Lighthouse League** is our in-house program at the Lighthouse fields — for members who want a **local, low-to-no-travel soccer experience**, and for anyone not selected to a competitive squad. **We don''t cut members.**', 412);
SELECT pg_temp.add_program_tpl('program_teams', 'women', 'Programme — teams (women)',
E'### Teams\nOur competitive squad (Fall 2026):\n- **Tri County Women** (Women''s Tri County Soccer League, Division 2)', 412);

-- ── Practice lines of the Schedule list (women: games only, no row) ─────
SELECT pg_temp.add_program_tpl('program_schedule', 'youth', 'Programme — practice (youth)',
E'- **Practice:**\n  - 2nd grade and younger — Mondays & Wednesdays, 4:30–5:30pm\n  - 3rd grade and older — Mondays, Wednesdays & Fridays, 5:30–7pm\n- **Why multiple days:** We know families are busy, so we offer practice several days a week — the goal is that every player can make at least one. There''s no requirement to attend all of them; come to as many as work for your schedule.', 413);
SELECT pg_temp.add_program_tpl('program_schedule', 'adult', 'Programme — practice (men)',
E'- **Practice:** Tuesday–Friday, 7:00–8:30pm; Saturday, 11:00am–12:30pm\n- **Purpose of 5 weekly sessions:** Five sessions a week fit real work schedules — aim for any 2 of the 5 and you''re a regular — and cover all the fitness a player needs. Sessions pair tactical concepts with game play that applies them, so players work their technical actions in real game environments — not around a cone that can''t defend. Together they cover the four pillars of player development: **technical, tactical, physical, and psychological.**', 413);

-- ── Billing ────────────────────────────────────────────────────────────
SELECT pg_temp.add_program_tpl('program_billing', 'all', 'Programme — billing',
E'### Billing\nRegistration is {fee} at signup. After registration, we send a single prorated invoice covering the rest of the current month.\n\nFrom then on, the normal {pricing} membership is invoiced on the **first Friday of each month**.\n\n**Membership requires a valid card on file with sufficient funds** so we can auto-charge monthly dues. Cards saved at registration are charged automatically through LeagueApps and a receipt is emailed for each charge. Members can pause or cancel anytime.', 414);
SELECT pg_temp.add_program_tpl('program_billing', 'women', 'Programme — billing (women)',
E'### Billing\nGames cost a few dollars per player to cover referee fees, paid at the field.\n\nSeparately, players register directly with the **Women''s Tri County Soccer League** on their site for **$35**.', 414);

-- ── Changes & questions ────────────────────────────────────────────────
SELECT pg_temp.add_program_tpl('program_changes', 'all',   'Programme — changes & questions', 'To pause or cancel a membership, or ask a question, email {outreach_email}.', 415);
SELECT pg_temp.add_program_tpl('program_changes', 'women', 'Programme — changes & questions (women)', 'Questions? Email {outreach_email}.', 415);
