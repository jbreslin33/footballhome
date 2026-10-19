-- 602 (2026-10-19) — Dylan Martinez STILL can't see events: one person,
-- TWO live LeagueApps userIds. Alias table + re-merge + pin.
--
-- Owner: "dylan martinez still can't see his events. 215-501-3619"
--
-- What happened after mig 597 (applied 14:11 UTC today): 597 adopted the
-- drifted userId 57367721 onto person 22311 on the assumption the old id
-- 58059689 was dead.  It is not.  Today's LA exports carry BOTH ids at
-- once: 57367721 owns the PAID men's registration 105546864 (program
-- 5039300) and 58059689 still owns a free registration 106608896 on the
-- boys-pickup program 5064618.  persons.la_user_id can hold only one id
-- (uq_persons_la_user_id), so the 5-minute LaSyncScheduler ping-ponged
-- it between the two program syncs (PersonLinker::linkLa step 4
-- overwrites on the name-match path), raced a fresh duplicate person
-- 22751 into existence at 14:16, moved the paid membership onto it at
-- 14:51, and closeStaleMemberships + fn_sweep_invalid_rosters ended
-- 22311's paid membership and removed his Liga 1 (120), APSL Reserves
-- (938) and USASA Cup (939) team rows at 14:21.  Dylan logs in as 22311
-- → no active teams → no events.
--
-- Fix, three parts:
--   1. person_la_user_ids: N LeagueApps userIds → 1 person.  Backfilled
--      from persons.la_user_id.  PersonLinker becomes alias-aware in the
--      same commit (fast path, write path, closeStaleMemberships).
--   2. Re-merge duplicate 22751 into 22311 (same shape as mig 597),
--      register BOTH ids as aliases of 22311, primary = 57367721 (the
--      paid account), restore the three team rows swept at 14:21.
--   3. persons_pin_la_user_id trigger: when an UPDATE tries to flip
--      la_user_id between two ids that are BOTH already aliases of the
--      same person, keep the current one.  Data-driven (no person id
--      baked into the function): it only ever bites people explicitly
--      recorded as multi-id.  This is what stops the still-running
--      pre-alias backend from re-splitting Dylan in the window before
--      the alias-aware backend deploys; it stays on afterwards as a
--      belt-and-braces guard (the alias fast path makes step-4 updates
--      stop happening for multi-id people anyway).
--
-- Known cosmetic churn until the alias-aware backend ships: the old
-- closeStaleMemberships compares persons.la_user_id (pinned: 57367721)
-- against the boys-pickup active set (has 58059689), so it will close
-- and re-open 22311's free 5064618 membership row each 5-minute cycle.
-- Harmless — no team requires 5064618 for Dylan — and it stops at the
-- next backend deploy.
--
-- Idempotent: table/trigger are IF NOT EXISTS / OR REPLACE; the merge
-- no-ops once 22751 is gone.

-- 1. Alias table ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS person_la_user_ids (
    la_user_id TEXT PRIMARY KEY,
    person_id  INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_person_la_user_ids_person
    ON person_la_user_ids (person_id);

COMMENT ON TABLE person_la_user_ids IS
    'Every LeagueApps userId ever seen for a person (N ids -> 1 person). '
    'persons.la_user_id stays the most-recently-adopted PRIMARY id; sync '
    'code resolves exports through this table so a person whose ids drift '
    '(or who holds two live LA accounts, like Dylan Martinez 22311) never '
    'splits into duplicate persons rows again (mig 597/602).';

INSERT INTO person_la_user_ids (la_user_id, person_id)
SELECT la_user_id, id FROM persons WHERE la_user_id IS NOT NULL
ON CONFLICT (la_user_id) DO NOTHING;

-- 2. Re-merge 22751 → 22311, aliases, roster restore ────────────────────
DO $$
DECLARE
  kept  CONSTANT int := 22311;   -- Dylan Martinez: login users 57, history
  drop_ CONSTANT int := 22751;   -- today's 14:16 race duplicate
BEGIN
  IF EXISTS (SELECT 1 FROM persons WHERE id = drop_ AND la_user_id = '57367721') THEN

    -- 2a. Audit snapshot (person_merges), mirror of mig 597.
    INSERT INTO person_merges (kept_person_id, dropped_person_id, dropped_snapshot, merged_by_user_id)
    SELECT kept, drop_,
           jsonb_build_object(
             'persons', (SELECT to_jsonb(p) FROM persons p WHERE id = drop_),
             'note', 'mig 602: second LA split — 57367721 and 58059689 are BOTH live LA accounts of one human; both now alias to 22311',
             'children', jsonb_build_object(
               'person_la_memberships',   COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM person_la_memberships t WHERE person_id = drop_), '[]'::jsonb),
               'players',                 COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM players t WHERE person_id = drop_), '[]'::jsonb),
               'person_dues_balance_log', COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM person_dues_balance_log t WHERE person_id = drop_), '[]'::jsonb))),
           NULL;

    -- 2b. Revive 22311's paid membership row (ended 14:21 today) with the
    --     duplicate row's fresh LA snapshot; drop the duplicate's rows.
    UPDATE person_la_memberships k
       SET ended_at = NULL,
           next_due_at = d.next_due_at, next_due_source = d.next_due_source,
           next_due_updated_at = d.next_due_updated_at,
           la_amount_owed_cents = d.la_amount_owed_cents,
           la_amount_paid_cents = d.la_amount_paid_cents,
           la_payment_status = d.la_payment_status,
           la_snapshot_at = d.la_snapshot_at, months_overdue = d.months_overdue,
           updated_at = now()
      FROM person_la_memberships d
     WHERE k.person_id = kept  AND k.la_program_id = 5039300
       AND d.person_id = drop_ AND d.la_program_id = 5039300;
    DELETE FROM person_la_memberships WHERE person_id = drop_;

    UPDATE person_dues_balance_log SET person_id = kept WHERE person_id = drop_;
    DELETE FROM players WHERE person_id = drop_;

    -- 2c. Drop the duplicate (its backfilled alias row cascades away),
    --     keep the paid account as the primary id.
    DELETE FROM persons WHERE id = drop_;
    UPDATE persons SET la_user_id = '57367721', updated_at = now()
     WHERE id = kept AND la_user_id IS DISTINCT FROM '57367721';

    RAISE NOTICE 'mig 602: person % merged into %', drop_, kept;
  ELSE
    RAISE NOTICE 'mig 602: duplicate person % already gone — merge skipped', drop_;
  END IF;

  -- 2d. BOTH LA accounts belong to 22311 (runs even on re-apply).
  INSERT INTO person_la_user_ids (la_user_id, person_id)
  VALUES ('57367721', kept), ('58059689', kept)
  ON CONFLICT (la_user_id) DO UPDATE SET person_id = EXCLUDED.person_id;

  -- 2e. Restore the team rows swept today at 14:21 (latest removed row
  --     per team only, and never beside a live row — the partial unique
  --     index team_persons_active_unique allows one open row per pair).
  UPDATE team_persons tp
     SET removed_at = NULL, removed_reason = NULL, removed_details = NULL
   WHERE tp.id IN (
           SELECT DISTINCT ON (team_id) id
             FROM team_persons
            WHERE person_id = kept AND team_id IN (120, 938, 939)
              AND removed_at >= TIMESTAMPTZ '2026-10-19 14:00+00'
            ORDER BY team_id, removed_at DESC)
     AND NOT EXISTS (SELECT 1 FROM team_persons live
                      WHERE live.team_id = tp.team_id
                        AND live.person_id = tp.person_id
                        AND live.removed_at IS NULL);
END $$;

-- 3. Pin trigger ────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION persons_pin_la_user_id() RETURNS trigger AS $fn$
BEGIN
    -- Flipping between two ids that are BOTH recorded aliases of this
    -- same person is the sync ping-ponging over a multi-account human:
    -- keep the current primary.  Any other change (first id, genuine
    -- drift adoption, operator fix) passes through untouched.
    IF OLD.la_user_id IS NOT NULL AND NEW.la_user_id IS NOT NULL
       AND NEW.la_user_id IS DISTINCT FROM OLD.la_user_id
       AND (SELECT count(*) FROM person_la_user_ids a
             WHERE a.person_id = OLD.id
               AND a.la_user_id IN (OLD.la_user_id, NEW.la_user_id)) = 2
    THEN
        NEW.la_user_id := OLD.la_user_id;
    END IF;
    RETURN NEW;
END $fn$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS persons_pin_la_user_id ON persons;
CREATE TRIGGER persons_pin_la_user_id
    BEFORE UPDATE OF la_user_id ON persons
    FOR EACH ROW EXECUTE FUNCTION persons_pin_la_user_id();
