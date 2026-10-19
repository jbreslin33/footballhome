-- 597 (2026-10-19) — Dylan Martinez can't see events: LA userId drift.
--
-- Owner: "dylan martinez number is 2155013619 he can't see events!"
--
-- Dylan is person 22311 (born 2008-06-28, phone +12155013619, login
-- users 57, LA userId 58059689, men's membership since 7/3, rostered
-- Liga 1 + APSL Reserves + USASA Cup pool).  On 2026-10-16 the
-- LeagueApps export re-keyed the SAME registration (105546864, PAID) to
-- a NEW userId 57367721, so the sync: created duplicate person 22749,
-- gave it the men's-active membership, ended 22311's membership, and
-- fn_sweep_invalid_rosters + cup_pool_sync then removed all three of
-- 22311's roster rows.  His login still lands on 22311 — a person with
-- no teams and no live membership, hence no events.  Someone also set
-- 22311.parent_person_id = 22749 (the dupe posing as "parent").
--
-- Keep 22311 (login, history, RSVPs, contacts), drop 22749, and move
-- the CURRENT LA userId 57367721 onto 22311 so the next sync matches
-- him instead of re-creating the duplicate (PersonMergeController would
-- keep the kept row's OLD id on conflict — exactly wrong for drift,
-- which is why this is a migration).  The old userId 58059689 lives on
-- in the person_merges snapshot.  Un-end membership row 47, restore the
-- three roster rows swept 10/16.  Idempotent: no-ops once 22749 is gone.

DO $$
DECLARE
  kept  CONSTANT int := 22311;   -- Dylan Martinez, the real row
  drop_ CONSTANT int := 22749;   -- 10/16 drift duplicate
BEGIN
  IF NOT EXISTS (SELECT 1 FROM persons WHERE id = drop_) THEN
    RAISE NOTICE 'person % already gone — skipping', drop_;
    RETURN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM persons WHERE id = drop_ AND la_user_id = '57367721') THEN
    RAISE NOTICE 'person % does not carry la_user_id 57367721 — skipping', drop_;
    RETURN;
  END IF;

  -- 1. Audit snapshot (only four tables reference 22749 — verified).
  INSERT INTO person_merges (kept_person_id, dropped_person_id, dropped_snapshot, merged_by_user_id)
  SELECT kept, drop_,
         jsonb_build_object(
           'persons', (SELECT to_jsonb(p) FROM persons p WHERE id = drop_),
           'note', 'mig 597: LA userId drift — kept person''s old la_user_id was 58059689, adopted 57367721',
           'children', jsonb_build_object(
             'person_la_memberships',   COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM person_la_memberships t WHERE person_id = drop_), '[]'::jsonb),
             'players',                 COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM players t WHERE person_id = drop_), '[]'::jsonb),
             'person_dues_balance_log', COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM person_dues_balance_log t WHERE person_id = drop_), '[]'::jsonb))),
         NULL;

  -- 2. Membership: 22311's original row 47 (joined 7/3) comes back to
  --    life with the duplicate row's fresh LA snapshot; the duplicate
  --    row goes.  Same la_registration_id 105546864 on both.
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
   WHERE k.person_id = kept AND k.la_program_id = 5039300
     AND d.person_id = drop_ AND d.la_program_id = 5039300;
  DELETE FROM person_la_memberships WHERE person_id = drop_;

  -- 3. Dues-balance history moves; the duplicate players row (nothing
  --    references it) goes.
  UPDATE person_dues_balance_log SET person_id = kept WHERE person_id = drop_;
  DELETE FROM players WHERE person_id = drop_;

  -- 4. Dylan is his own man (18): drop the dupe-as-parent link, free the
  --    drifted userId and adopt it, then drop the duplicate person.
  UPDATE persons SET parent_person_id = NULL WHERE id = kept AND parent_person_id = drop_;
  UPDATE persons SET la_user_id = NULL WHERE id = drop_;
  UPDATE persons SET la_user_id = '57367721', updated_at = now() WHERE id = kept;
  DELETE FROM persons WHERE id = drop_;

  -- 5. Restore the three roster rows the 10/16 sweep removed — the
  --    membership they demand is live again.
  UPDATE team_persons
     SET removed_at = NULL, removed_reason = NULL, removed_details = NULL
   WHERE person_id = kept AND removed_at::date = DATE '2026-10-16'
     AND team_id IN (120, 938, 939);

  RAISE NOTICE 'Dylan Martinez merged: % kept, % dropped, la_user_id 57367721 adopted, rosters restored', kept, drop_;
END $$;
