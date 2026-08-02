-- ─────────────────────────────────────────────────────────────────────
-- 255-reset-official-roster-new-season.sql (2026-08-02)
--
-- team_persons.on_roster means "officially rostered — eligible for
-- sanctioned matches" (see lineups.js's per-player "⚖️ Official
-- roster" toggle, POST /api/{boys,mens}-roster/roster-status). It's a
-- season-scoped confirmation, not carried over automatically.
--
-- New season, nobody has been re-confirmed yet. Every real column
-- already reads on_roster=false today except 21 stale true rows left
-- over from last season (19x U23 Men + 1 Pickup + 1 Practice), which
-- would otherwise show players as sanctioned-eligible with no one
-- having actually confirmed that for 2026.  Idempotent (safe to
-- re-run — no-op once already reset).
-- ─────────────────────────────────────────────────────────────────────

BEGIN;

UPDATE team_persons
   SET on_roster = false
 WHERE on_roster = true
   AND removed_at IS NULL;

COMMIT;
