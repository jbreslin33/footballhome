-- 674 (2026-10-24) — James Breslin is ONE person: merge 22306 ("Jim")
-- into 1 ("James").
--
-- Owner: "why is my contact card not have text option at all lol. its
-- greye out" → "is there too many James or Jim Breslin persons lol" →
-- "we should merge lol right?"
--
-- Cause: two live LeagueApps accounts for one human (same shape as Dylan
-- Martinez, mig 602).  LA user 52030649 "James" built person 1 on 4/29
-- (admin login, mobile, lock-up alerts, 129 RSVPs); LA user 46457251
-- "Jim" — the account that PAYS the Men's program — built person 22306
-- on 6/20 with its own Gmail login (user 207).  22306 holds the live
-- rosters (APSL Reserves 938, USASA Cup 939, Liga 1 120) and the PAID
-- 5039300 membership but no phone, so Game Center's card for him had
-- no way to text.  person_phones.phone_number is globally unique, so
-- the number can't sit on both rows — the fix is the merge.
--
-- What moves where:
--   * LA: 46457251 (paid) becomes person 1's primary; both ids alias to
--     person 1 (person_la_user_ids, mig 602), so the alias-aware sync
--     resolves either account here and the pin trigger stops ping-pong.
--     The paid membership row moves as-is (person 1's own 5039300 row
--     ended 7/13, so the open-row unique index has room).
--   * players: 22306's player row (22395) folds into person 1's (22183)
--     — one lineup row (match 9326) and one draft row repointed, none
--     clash; players_person_id_key allows one per person.
--   * fh_event_rsvps / first answers: both rows answered 'yes' for event
--     75692313 — person 1's kept, 22306's dropped.  All others move.
--   * person_addresses: 22306's moves as a non-primary address.
--   * person_emails: the Gmail moves (non-primary), so a Google sign-in
--     with it resolves to person 1 → user 1 (OAuthController matches on
--     person_emails).  users_person_id_key allows one login per person,
--     so user 207 is retired (its one password-reset token cascades).
--   * Everything else: EVERY foreign key that references persons(id) is
--     repointed by a catalogue loop, not a hand list — PersonMerge's
--     static list predates ~30 person-owning tables.  A clash aborts
--     the whole migration (nothing half-done).
--
-- Audit: person_merges row with a snapshot of 22306 and every row that
-- pointed at it, its player row and login.  Idempotent: no-op once
-- 22306 is gone.

DO $$
DECLARE
  kept      CONSTANT int := 1;      -- James Breslin: admin, mobile, history
  drop_     CONSTANT int := 22306;  -- "Jim" Breslin: LA 46457251 duplicate
  kept_pl   int;
  drop_pl   int;
  drop_user int;
  snap      jsonb := '{}'::jsonb;
  c         record;
  rows_     jsonb;
  n         bigint;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM persons WHERE id = drop_ AND la_user_id = '46457251') THEN
    RAISE NOTICE 'mig 674: person % already gone — merge skipped', drop_;
    RETURN;
  END IF;
  SELECT id INTO kept_pl   FROM players WHERE person_id = kept;
  SELECT id INTO drop_pl   FROM players WHERE person_id = drop_;
  SELECT id INTO drop_user FROM users   WHERE person_id = drop_;

  -- 1. Audit snapshot: every row of every table that points at 22306.
  FOR c IN
    SELECT DISTINCT con.conrelid::regclass::text AS tbl, att.attname AS col
      FROM pg_constraint con
      JOIN pg_attribute att ON att.attrelid = con.conrelid AND att.attnum = con.conkey[1]
     WHERE con.contype = 'f' AND con.confrelid = 'persons'::regclass
       AND array_length(con.conkey, 1) = 1
  LOOP
    EXECUTE format('SELECT jsonb_agg(to_jsonb(t)) FROM %s t WHERE %I = $1', c.tbl, c.col)
       INTO rows_ USING drop_;
    IF rows_ IS NOT NULL THEN snap := snap || jsonb_build_object(c.tbl || '.' || c.col, rows_); END IF;
  END LOOP;
  INSERT INTO person_merges (kept_person_id, dropped_person_id, dropped_snapshot, merged_by_user_id)
  SELECT kept, drop_,
         jsonb_build_object(
           'persons',  (SELECT to_jsonb(p) FROM persons p WHERE id = drop_),
           'note',     'mig 674: one human, two LA accounts (46457251 paid "Jim", 52030649 "James"); both alias to person 1',
           'player',   (SELECT to_jsonb(pl) FROM players pl WHERE id = drop_pl),
           'player_rows', jsonb_build_object(
               'match_lineups',           (SELECT jsonb_agg(to_jsonb(t)) FROM match_lineups t WHERE player_id = drop_pl),
               'match_lineup_draft_rows', (SELECT jsonb_agg(to_jsonb(t)) FROM match_lineup_draft_rows t WHERE player_id = drop_pl)),
           'user',     (SELECT to_jsonb(u) - 'password_hash' FROM users u WHERE id = drop_user),
           'children', snap),
         NULL;

  -- 2. LeagueApps: the paid account becomes person 1's primary.  Free the
  --    unique persons.la_user_id first; set the primary while 46457251
  --    is still 22306's alias (the pin trigger only holds a flip between
  --    two ids that are BOTH aliases of the same person), then move it.
  UPDATE persons SET la_user_id = NULL, updated_at = now() WHERE id = drop_;
  UPDATE persons SET la_user_id = '46457251', updated_at = now() WHERE id = kept;
  UPDATE person_la_user_ids SET person_id = kept WHERE person_id = drop_;
  INSERT INTO person_la_user_ids (la_user_id, person_id)
  VALUES ('46457251', kept), ('52030649', kept)
  ON CONFLICT (la_user_id) DO UPDATE SET person_id = EXCLUDED.person_id;

  -- 3. One player row: repoint 22395's lineup and draft rows to 22183.
  UPDATE match_lineups           SET player_id = kept_pl WHERE player_id = drop_pl;
  UPDATE match_lineup_draft_rows SET player_id = kept_pl WHERE player_id = drop_pl;
  DELETE FROM players WHERE id = drop_pl;

  -- 4. Same-event answers: person 1's stays.
  DELETE FROM fh_event_rsvps d USING fh_event_rsvps k
   WHERE d.person_id = drop_ AND k.person_id = kept AND k.fh_event_id = d.fh_event_id;
  DELETE FROM fh_event_rsvp_first_answers d USING fh_event_rsvp_first_answers k
   WHERE d.person_id = drop_ AND k.person_id = kept AND k.fh_event_id = d.fh_event_id;

  -- 5. Secondary address / email; the Gmail now signs in as person 1.
  UPDATE person_addresses SET is_primary = false WHERE person_id = drop_;
  UPDATE person_emails    SET is_primary = false WHERE person_id = drop_;

  -- 6. Retire the second login (one users row per person).
  DELETE FROM users WHERE id = drop_user;

  -- 7. Every remaining reference to 22306, from the catalogue.
  FOR c IN
    SELECT DISTINCT con.conrelid::regclass::text AS tbl, att.attname AS col
      FROM pg_constraint con
      JOIN pg_attribute att ON att.attrelid = con.conrelid AND att.attnum = con.conkey[1]
     WHERE con.contype = 'f' AND con.confrelid = 'persons'::regclass
       AND array_length(con.conkey, 1) = 1
  LOOP
    EXECUTE format('UPDATE %s SET %I = $1 WHERE %I = $2', c.tbl, c.col, c.col) USING kept, drop_;
    GET DIAGNOSTICS n = ROW_COUNT;
    IF n > 0 THEN RAISE NOTICE 'mig 674: %.% → % row(s)', c.tbl, c.col, n; END IF;
  END LOOP;

  DELETE FROM persons WHERE id = drop_;
  RAISE NOTICE 'mig 674: person % merged into %', drop_, kept;
END $$;
