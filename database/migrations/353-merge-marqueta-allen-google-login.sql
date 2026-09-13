-- 353 — Merge Marqueta Allen's Google-login orphan into her LeagueApps person.
--
-- Marqueta Allen (person 22625, LA user 58387860) is the parent of
-- Suhaylah Jones (22624), a PAID Girl's Club member on the U8 Travel
-- roster.  LeagueApps has her as allen_marqueta@yahoo.com.  On
-- 2026-09-01 23:04 UTC she signed in with Google as
-- marqueta1210@gmail.com — an address LA never had — so
-- OAuthController::findOrCreateUser found no match and created a blank
-- orphan (22647, last name only) holding that email + users row 144,
-- with no children, roster ties, or LA membership.
--
-- Result: her phone holds a Google JWT for 22647.  MyController's
-- requireSession checks the bearer token before the session cookie, so
-- the SMS magic link minted for 22625 on 9/11 (opened eight times) never
-- took effect — every request still resolved to the empty orphan, hence
-- "not a member of any club chat" and "no games show" the day before
-- U8 Travel's 9/13 game.  Same split as 321/323/.../346.
--
-- Merge the orphan into 22625 exactly the way PersonMerge::merge() does
-- (audit row + reparent + drop), so it is reversible from the person
-- profile like every other GM→LA merge in person_merges.  users 144 and
-- the gmail row move onto 22625, so her existing Google login works
-- immediately with no action on her side.
--
-- Idempotent: no-ops if 22647 is already gone or no longer owns the email.
DO $$
DECLARE
  kept  CONSTANT int := 22625;
  drop_ CONSTANT int := 22647;
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
                  WHERE person_id = drop_ AND lower(email) = 'marqueta1210@gmail.com') THEN
    RAISE NOTICE 'person % does not own marqueta1210@gmail.com — skipping', drop_;
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

  -- 2. Reparent.  users is UNIQUE(person_id): move only if kept has none
  --    (22625 has never had one, so users 144 becomes hers).
  UPDATE users SET person_id = kept
   WHERE person_id = drop_
     AND NOT EXISTS (SELECT 1 FROM users WHERE person_id = kept);

  -- person_emails / person_phones are UNIQUE(person_id, col): move unless
  -- kept already has the same value.  22625 owns only the yahoo address,
  -- so the gmail row moves and she ends up with both.
  UPDATE person_emails d SET person_id = kept
   WHERE d.person_id = drop_
     AND NOT EXISTS (SELECT 1 FROM person_emails k
                      WHERE k.person_id = kept AND lower(k.email) = lower(d.email));
  UPDATE person_phones d SET person_id = kept
   WHERE d.person_id = drop_
     AND NOT EXISTS (SELECT 1 FROM person_phones k
                      WHERE k.person_id = kept AND k.phone_number IS NOT DISTINCT FROM d.phone_number);

  -- Push subscriptions carry over so any push she enabled under the
  -- orphan keeps working (0 rows as of 2026-09-12, harmless if so).
  UPDATE push_subscriptions SET person_id = kept WHERE person_id = drop_;

  -- 3. Anything left on the dropped person is in the snapshot; clear it so
  --    the persons DELETE can't trip a FK.  (All zero rows as of 2026-09-12.)
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

  RAISE NOTICE 'merged person % into % (users row 144 now on Marqueta Allen)', drop_, kept;
END $$;
