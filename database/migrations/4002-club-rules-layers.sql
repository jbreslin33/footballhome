-- 4002 📋 Rules in layers: 🏠 Club → section (👨 Men / 👩 Women / 👦 Boys /
-- 👧 Girls) → ⚽ team. Owner 11/27: "where is club rules and we need a club
-- wide rules, mens wide rule, youth wide rules etc right? then team rules?"
-- · "it just has to make sense adn be navigatable".
--
-- club_rules: one row per rule, scoped to the club, a club section or a
-- team. GET /api/rules hands a person exactly their layers (club + the
-- sections and teams they play / coach / are a parent on; admins see all).
-- #player-team-rules renders them with a pill per layer to jump to it.
-- The old hard-coded page text moves here unchanged, filed by layer —
-- except "set availability at My" (page retired) → the Calendar.
-- Body format: blank line = new paragraph, "- " bullet, "1. " numbered,
-- **bold**, [text](#route).  (Numbered in a gap below the max on purpose.)
BEGIN;

CREATE TABLE IF NOT EXISTS club_rules (
    id              serial PRIMARY KEY,
    scope           text NOT NULL CHECK (scope IN ('club', 'section', 'team')),
    club_section_id integer REFERENCES club_sections(id) ON DELETE CASCADE,
    team_id         integer REFERENCES teams(id) ON DELETE CASCADE,
    title           text NOT NULL,
    body            text NOT NULL,
    sort_order      integer NOT NULL DEFAULT 0,
    is_active       boolean NOT NULL DEFAULT true,
    created_at      timestamptz NOT NULL DEFAULT now(),
    CHECK ((scope = 'club'    AND club_section_id IS NULL AND team_id IS NULL)
        OR (scope = 'section' AND club_section_id IS NOT NULL AND team_id IS NULL)
        OR (scope = 'team'    AND team_id IS NOT NULL AND club_section_id IS NULL))
);
CREATE INDEX IF NOT EXISTS club_rules_scope_idx ON club_rules (scope, club_section_id, team_id) WHERE is_active;

-- Seed once (re-runnable: only when the table is empty).
INSERT INTO club_rules (scope, club_section_id, team_id, title, body, sort_order)
SELECT v.scope, v.sec, NULL, v.title, v.body, v.so
  FROM (VALUES
  -- 🏠 Club — everyone
  ('club', NULL::int, 'Etiquette', $r$- **Only the captain may discuss calls with referees.** Players who speak to the referees without being the captain will be **immediately benched**.
- **Players are not to ask during matches about their own playing time.** When called to the bench, players should not show disrespect to the player coming on by questioning the decision.
- **Respect all levels of play.** Players should be respectful of the different ability levels at the club, and that expectation goes both ways. Players should not complain about another player’s ability level.
- **Training focus will vary.** Players should understand that higher-level players may be the focus of training at times, and that is part of the club’s development approach.$r$, 10),
  ('club', NULL::int, 'RSVP & Availability', $r$- **Set availability every week:** All players must keep their availability current for games, practices, and pickup sessions on the [Calendar](#calendar).
- **Weekly deadlines matter:** Availability should be updated before the stated weekly cutoff so selection and planning remain accurate.$r$, 20),
  ('club', NULL::int, 'Commitment', $r$**Consistency, honesty, and commitment are expected every week.**$r$, 30),

  -- 👨 Men
  ('section', 1, 'Dues', $r$**Dues are $35/month.** Dues are due on the **1st Friday of each month**.

Starting on the **2nd Friday of each month**, a **$5 late charge** will be added to the invoice if the card fails or dues are not paid.

If a player cannot pay dues in full, there are alternatives available, including but not limited to **coaching youth players before men’s practice at Lighthouse**, **coaching youth games**, **team manager duties**, **practice assistant** responsibilities, such as arriving early to practice and helping set up the session, and **social media assistant** responsibilities.

**Please make sure a valid credit card is on file.**$r$, 10),
  ('section', 1, 'RSVP & Availability (Men)', $r$- **APSL Reserve Team Policy:** **Liga 1 is the official APSL Reserve Team.** ALL Liga 1 players are expected to RSVP for APSL games in case call-ups are needed.
- **Goalkeepers Note:** **All goalkeepers are listed on the Liga 1 roster** ([player roster](#player-roster)) so they remain fully eligible for both APSL and Liga 1 fixtures.
- **Mandatory Policy:** Setting accurate availability on the [Calendar](#calendar) by the weekly deadline is strictly required. Missing or inaccurate RSVPs for an event will result in a **$1 fine for each event** and may also affect playing time.$r$, 20),
  ('section', 1, 'Practice Rules', $r$- **Practice Attendance:** A player may arrive late or leave early from practice without penalty. Showing up for practice still counts as a practice.
- **Practice still matters:** Attendance is still part of the evaluation process for selection and roster decisions.
- **Practice cancellations are rare:** We usually move practice due to weather or field availability because we have indoor facilities, rather than canceling it outright.
- **No leaving feet at practice except keepers.** Players will sit out if they leave their feet.
- **Clean play expected:** Players will sit out if they are fouling needlessly.
- **Defensive style at Lighthouse:** We do not hack or push from behind. When defending behind a player with the ball, we are to stop the turn rather than foul the player. This is a skill to promote. We hustle and get in front of the ball to stop progress cleanly, not from behind or the side.$r$, 30),
  ('section', 1, '20-Man Selection', $r$To keep squad structure transparent and competitive:

- **APSL & Liga 1 Squad Selection:** Players are assigned to either the **APSL Squad** or the **Liga 1 Squad**. You can view current team assignments on the official [Player Roster](#player-roster).
- **Week-to-Week Movement:** Squad assignments are **not permanent**. Selection is evaluated on a **week-to-week basis**, and players can be promoted or moved between squads based strictly on performance, commitment, and merit.$r$, 40),
  ('section', 1, 'Initial Starters & Bench Selection', $r$- **Lineup & Bench Priority:** Within each squad, starting 11 and bench spots are earned based on **ability + practice attendance** in this order:

1. **Best players with 2 practices**
1. **Best players with 1 practice**
1. **Players with 0 practices** (only if needed to fill remaining roster spots)$r$, 50),
  ('section', 1, 'Game-Day Rules', $r$- **Selection Process:** Initial starting lineup selection is **Step 1**. Final selection takes place at the **beginning of warmups**, which start **45 minutes before APSL matches** and **30 minutes before Liga 1 matches**.
- **Warmup Replacement Rule:** If a player is **not in warmup when it begins**, they will be replaced in the lineup by **another player in warmup**, regardless of practice attendance, because the coach needs a positional replacement.$r$, 60),
  ('section', 1, '📅 Weekly Selection Timeline', $r$- **Thursday @ Midnight:** **HARD DEADLINE** to set availability on the [Calendar](#calendar) for Sunday’s match.
- **Friday:** Official **20-man roster** is selected and announced.
- **Saturday:** **Starting 11** is finalized.$r$, 70)
  ) AS v(scope, sec, title, body, so)
 WHERE NOT EXISTS (SELECT 1 FROM club_rules);

-- Page wording (MessageCopy kind 'rules').
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'Rules', v.label, 'rules', v.tier, v.body, v.so, true, false
FROM (VALUES
  ('Rules page — title', 'title', '📋 Rules', 1),
  ('Rules page — under the title', 'intro', 'Club rules first, then your section, then your team. Tap a pill to jump.', 2),
  ('Rules page — club layer pill / header', 'layer_club', '🏠 Club', 3),
  ('Rules page — a layer with no rules yet', 'empty', 'No rules here yet.', 4),
  ('Rules page — could not load', 'error', 'Could not load the rules.', 5),
  ('Rules page — Men layer pill / header (club_sections.code M)',   'section_M', '👨 Men', 6),
  ('Rules page — Women layer pill / header (club_sections.code W)', 'section_W', '👩 Women', 7),
  ('Rules page — Boys layer pill / header (club_sections.code B)',  'section_B', '👦 Boys', 8),
  ('Rules page — Girls layer pill / header (club_sections.code G)', 'section_G', '👧 Girls', 9)
) AS v(label, tier, body, so)
WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'rules' AND m.tier = v.tier);

-- Top bar: 📋 Rules beside 📅 Calendar, for everyone.
INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens)
SELECT 'rules', 'week', 'Rules', '📋', 'everyone', 2, ARRAY['rules', 'player-team-rules']
 WHERE NOT EXISTS (SELECT 1 FROM menu_pages WHERE code = 'rules');

INSERT INTO schema_migrations (filename) VALUES ('4002-club-rules-layers.sql') ON CONFLICT DO NOTHING;
COMMIT;
