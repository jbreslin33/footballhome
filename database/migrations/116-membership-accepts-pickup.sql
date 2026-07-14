-- ─────────────────────────────────────────────────────────────────────
-- 116-membership-accepts-pickup.sql (2026-07-14)
--
-- User directive (2026-07-14): "no artificial payment blocks. they are
-- in member section or pickup section on league apps. that determines
-- their status. payment is something we take on case by case basis."
--
-- Prior state (migration 108):
--   • Selection teams (APSL 35, Liga 1 120, Liga 2 121, Adult 122,
--     Old Timers 456, U23 Men 903, DR 904, PR 905) required an
--     ACTIVE-VARIANT membership: Men's 1893 (5039300) or Boys 1897
--     (5039252) only.  Pickup memberships did NOT count.
--   • Women teams (Women's Club 583, Tri County 901, U23 Women 902)
--     required only Women's 1895 active (5039340) — no pickup.
--
-- What this broke:
--   Players registered under Men's 1893 PICKUP (5070075) — which is
--   how LA classifies most casual / U23 signups — were being
--   auto-swept from U23 Men by fn_sweep_invalid_rosters() on every
--   /api/my/week fetch, and then couldn't see any RSVPs.  Because the
--   sweep drops player_rsvp_eligibility too, they went fully invisible
--   to the events query.  Confirmed 2026-07-14: 19 sweeps in past 7d,
--   ~half on team 903 U23 Men, every one of them a pickup-only member.
--
-- Fix — the LA source of truth is "member section OR pickup section":
--   • Every currently-restricted team accepts EITHER the active OR the
--     pickup variant of the corresponding club membership.
--   • Practice (908) + Pickup (909) already had this (no change).
--
-- Restore:
--   After adding the pickup rows, un-soft-delete any roster_assignments
--   swept with reason='no_valid_membership' that now pass the check.
--   The AFTER UPDATE trigger `fn_grant_default_rsvp_eligibility` on
--   roster_assignments re-grants default RSVP eligibility rows for
--   mens home teams (35/120/121/122 + 908/909 defaults).
-- ─────────────────────────────────────────────────────────────────────

BEGIN;

-- ── 1. Add pickup-variant acceptance to every restricted team ────────

-- Selection teams (mens domain): add Men's 1893 Pickup (5070075) +
-- Boys 1897 Pickup (5064618) alongside the existing active variants.
INSERT INTO team_membership_requirements (team_id, la_program_id)
SELECT t.id, p.program_id
  FROM teams t
  CROSS JOIN (VALUES (5070075::bigint), (5064618::bigint)) AS p(program_id)
 WHERE t.id IN (35, 120, 121, 122, 456, 903, 904, 905)
ON CONFLICT DO NOTHING;

-- Women teams: add Women's 1895 Pickup (5064686) alongside the active
-- variant (5039340).
INSERT INTO team_membership_requirements (team_id, la_program_id)
SELECT t.id, p.program_id
  FROM teams t
  CROSS JOIN (VALUES (5064686::bigint)) AS p(program_id)
 WHERE t.id IN (583, 901, 902)
ON CONFLICT DO NOTHING;

-- (Practice 908 + Pickup 909 already accept 5039300 + 5070075 — no change.)

-- ── 2. Restore swept players who now pass ────────────────────────────
-- Un-soft-delete every roster_assignments row that was auto-swept by
-- fn_sweep_invalid_rosters() and whose person now has an active
-- membership under the newly-expanded rules.  The AFTER UPDATE trigger
-- on roster_assignments (fn_grant_default_rsvp_eligibility) fires per
-- row and re-inserts the default eligibility rows.
--
-- Guards (must ALL pass):
--   • Not already live on the same (domain, uid, team_id) — protects
--     the general active-row uniqueness partial index.
--   • If the swept team is a mens-selection team (35/120/121/122),
--     the person must NOT already be live on ANY other mens-selection
--     team — protects `uniq_roster_assignments_mens_selection_one_of`
--     (migration 104).  A player consolidated from Liga 2 up to Liga 1
--     after being swept must stay on Liga 1; we do NOT resurrect Liga 2.
UPDATE roster_assignments ra
   SET removed_at      = NULL,
       removed_reason  = NULL,
       removed_details = NULL
 WHERE ra.removed_at IS NOT NULL
   AND ra.removed_reason = 'no_valid_membership'
   AND EXISTS (
         SELECT 1
           FROM team_membership_requirements tmr
           JOIN external_person_aliases epa
             ON epa.provider = 'leagueapps'
            AND epa.external_user_id = ra.leagueapps_user_id::text
           JOIN person_la_memberships plm
             ON plm.person_id      = epa.person_id
            AND plm.la_program_id  = tmr.la_program_id
            AND plm.ended_at       IS NULL
          WHERE tmr.team_id = ra.team_id
       )
   AND NOT EXISTS (
         SELECT 1 FROM roster_assignments ra2
          WHERE ra2.leagueapps_user_id = ra.leagueapps_user_id
            AND ra2.team_id            = ra.team_id
            AND ra2.removed_at IS NULL
       )
   AND NOT (
         ra.team_id IN (35, 120, 121, 122)
         AND EXISTS (
               SELECT 1 FROM roster_assignments ra3
                WHERE ra3.domain             = ra.domain
                  AND ra3.leagueapps_user_id = ra.leagueapps_user_id
                  AND ra3.team_id IN (35, 120, 121, 122)
                  AND ra3.removed_at IS NULL
             )
       );

COMMIT;
