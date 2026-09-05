-- Zenia Bent (person 22581, LA user 58262672) registered with LeagueApps
-- under zeniabent@aol.com but signs in to FH with Google as
-- z.bent39@gmail.com.  Her first Google login (2026-09-02) minted a blank
-- orphan person (22657, last name only) holding the gmail + a users row
-- (id 160) and zero roster ties, so she could not see her son's team
-- (David Flanagan, person 22580, U10 Travel — parented to 22581).
--
-- person_emails.email is UNIQUE across all persons, so the gmail can't be
-- added to 22581 while the orphan still holds it.  Merge the orphan into
-- the LA-registered person exactly the way PersonMerge::merge() does
-- (audit row + reparent + drop), so the result is reversible from the
-- person profile like every other GM→LA merge in person_merges.
--
-- Idempotent: no-ops if 22657 is already gone or no longer owns the email.
DO $$
DECLARE
  kept  CONSTANT int := 22581;
  drop_ CONSTANT int := 22657;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM persons WHERE id = kept) THEN
    RAISE NOTICE 'kept person % missing — skipping', kept;
    RETURN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM persons WHERE id = drop_) THEN
    RAISE NOTICE 'dropped person % already gone — skipping', drop_;
    RETURN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM person_emails
                  WHERE person_id = drop_ AND lower(email) = 'z.bent39@gmail.com') THEN
    RAISE NOTICE 'person % does not own z.bent39@gmail.com — skipping', drop_;
    RETURN;
  END IF;

  -- 1. Audit snapshot (same catalogue as PersonMerge::childTables()).
  INSERT INTO person_merges (kept_person_id, dropped_person_id, dropped_snapshot, merged_by_user_id)
  SELECT kept, drop_,
         jsonb_build_object(
           'persons',  (SELECT to_jsonb(p) FROM persons p WHERE id = drop_),
           'children', jsonb_build_object(
             'users',                  COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM users t WHERE person_id = drop_), '[]'::jsonb),
             'person_emails',          COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM person_emails t WHERE person_id = drop_), '[]'::jsonb),
             'person_phones',          COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM person_phones t WHERE person_id = drop_), '[]'::jsonb),
             'external_identities',    COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM external_identities t WHERE person_id = drop_), '[]'::jsonb),
             'players',                COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM players t WHERE person_id = drop_), '[]'::jsonb),
             'coaches',                COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM coaches t WHERE person_id = drop_), '[]'::jsonb),
             'chat_event_rsvps',       COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM chat_event_rsvps t WHERE person_id = drop_), '[]'::jsonb),
             'event_rsvps',            COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM event_rsvps t WHERE person_id = drop_), '[]'::jsonb),
             'person_field_overrides', COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM person_field_overrides t WHERE person_id = drop_), '[]'::jsonb),
             'team_persons',           COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM team_persons t WHERE person_id = drop_), '[]'::jsonb),
             'fh_event_rsvps',         COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM fh_event_rsvps t WHERE person_id = drop_), '[]'::jsonb),
             'fh_event_attendance',    COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM fh_event_attendance t WHERE person_id = drop_), '[]'::jsonb),
             'person_la_memberships',  COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM person_la_memberships t WHERE person_id = drop_), '[]'::jsonb),
             'player_event_reminders', COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM player_event_reminders t WHERE person_id = drop_), '[]'::jsonb),
             'push_subscriptions',     COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM push_subscriptions t WHERE person_id = drop_), '[]'::jsonb),
             'trail_test_attempts',    COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM trail_test_attempts t WHERE person_id = drop_), '[]'::jsonb),
             'trail_test_results',     COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM trail_test_results t WHERE person_id = drop_), '[]'::jsonb),
             'rsvp_suspensions',       COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM rsvp_suspensions t WHERE person_id = drop_), '[]'::jsonb),
             'sim_player_profile',     COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM sim_player_profile t WHERE person_id = drop_), '[]'::jsonb),
             'sessions',               COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM sessions t WHERE person_id = drop_), '[]'::jsonb),
             'magic_link_tokens',      COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM magic_link_tokens t WHERE person_id = drop_), '[]'::jsonb)
           )
         ),
         1;  -- James Breslin (super admin), on whose instruction this ran

  -- 2. Reparent.  users is UNIQUE(person_id): move only if kept has none.
  UPDATE users SET person_id = kept
   WHERE person_id = drop_
     AND NOT EXISTS (SELECT 1 FROM users WHERE person_id = kept);

  -- person_emails / person_phones are UNIQUE(person_id, col): move unless
  -- kept already has the same value.
  UPDATE person_emails d SET person_id = kept
   WHERE d.person_id = drop_
     AND NOT EXISTS (SELECT 1 FROM person_emails k
                      WHERE k.person_id = kept AND k.email IS NOT DISTINCT FROM d.email);
  UPDATE person_phones d SET person_id = kept
   WHERE d.person_id = drop_
     AND NOT EXISTS (SELECT 1 FROM person_phones k
                      WHERE k.person_id = kept AND k.phone_number IS NOT DISTINCT FROM d.phone_number);

  -- 3. Anything left on the dropped person is in the snapshot; clear it so
  --    the persons DELETE can't trip a FK.  (All zero rows as of 2026-09-05.)
  DELETE FROM users                  WHERE person_id = drop_;
  DELETE FROM person_emails          WHERE person_id = drop_;
  DELETE FROM person_phones          WHERE person_id = drop_;
  DELETE FROM external_identities    WHERE person_id = drop_;
  DELETE FROM players                WHERE person_id = drop_;
  DELETE FROM coaches                WHERE person_id = drop_;
  DELETE FROM chat_event_rsvps       WHERE person_id = drop_;
  DELETE FROM event_rsvps            WHERE person_id = drop_;
  DELETE FROM person_field_overrides WHERE person_id = drop_;
  DELETE FROM team_persons           WHERE person_id = drop_;
  DELETE FROM fh_event_rsvps         WHERE person_id = drop_;
  DELETE FROM fh_event_attendance    WHERE person_id = drop_;
  DELETE FROM person_la_memberships  WHERE person_id = drop_;
  DELETE FROM player_event_reminders WHERE person_id = drop_;
  DELETE FROM push_subscriptions     WHERE person_id = drop_;
  DELETE FROM trail_test_attempts    WHERE person_id = drop_;
  DELETE FROM trail_test_results     WHERE person_id = drop_;
  DELETE FROM rsvp_suspensions       WHERE person_id = drop_;
  DELETE FROM sim_player_profile     WHERE person_id = drop_;
  DELETE FROM sessions               WHERE person_id = drop_;
  DELETE FROM magic_link_tokens      WHERE person_id = drop_;

  -- 4. Drop the orphan.  It has no la_user_id, so nothing to reconcile onto kept.
  DELETE FROM persons WHERE id = drop_;

  RAISE NOTICE 'merged person % into % (z.bent39@gmail.com + users row now on Zenia Bent)', drop_, kept;
END $$;
