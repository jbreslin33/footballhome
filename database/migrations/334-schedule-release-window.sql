-- Schedule release window, normalized (owner 2026-09-05).
--
-- Until now "next week posts Sunday 8 PM" was a function inside the My
-- Schedule page — the browser computed it, the server never knew, and
-- opening a week early meant editing JavaScript.  Owner: "its rare we
-- would open schedule early but we don't want it to be a hack."
--
-- Three pieces, and the window itself is never stored:
--   1. schedule_release_policies — the standing rule, one row per
--      (club, section, effective date).  Section beats club-wide; latest
--      effective_from that is not in the future wins.  History is kept.
--   2. schedule_week_releases    — the exception: one row per week opened
--      early.  Never deleted, only revoked, so the audit trail is whole.
--   3. fh_schedule_window_end()  — derived from 1 + 2 + now().  The
--      calendar API puts it on every event; My Schedule obeys it.
--
-- Also backfills club_section_id on the nine Lighthouse youth teams
-- (Boys, section 3) — they carried none, so section-scoped policies
-- could not have applied to them.  Girls play on the boys teams.

UPDATE teams SET club_section_id = 3
 WHERE club_id = 134 AND club_section_id IS NULL AND gender_category = 'boys';

CREATE TABLE IF NOT EXISTS schedule_release_policies (
  id                 serial PRIMARY KEY,
  club_id            int NOT NULL REFERENCES clubs(id),
  club_section_id    int REFERENCES club_sections(id),          -- NULL = whole club
  cutover_weekday    smallint NOT NULL CHECK (cutover_weekday BETWEEN 0 AND 6),  -- 0 = Sunday
  cutover_time       time NOT NULL,
  time_zone          text NOT NULL DEFAULT 'America/New_York',
  effective_from     date NOT NULL DEFAULT CURRENT_DATE,
  created_by_user_id int REFERENCES users(id),
  created_at         timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS schedule_release_policies_scope_idx
  ON schedule_release_policies (club_id, COALESCE(club_section_id, 0), effective_from);
COMMENT ON TABLE schedule_release_policies IS
  'Standing rule for when next week''s schedule posts to players/parents. Section-scoped row beats club-wide; latest effective_from <= today wins. Window itself is derived by fh_schedule_window_end().';

CREATE TABLE IF NOT EXISTS schedule_week_releases (
  id                  serial PRIMARY KEY,
  club_id             int NOT NULL REFERENCES clubs(id),
  club_section_id     int REFERENCES club_sections(id),
  week_start          date NOT NULL CHECK (EXTRACT(ISODOW FROM week_start) = 1),  -- a Monday
  released_at         timestamptz NOT NULL DEFAULT now(),
  released_by_user_id int REFERENCES users(id),
  revoked_at          timestamptz,
  revoked_by_user_id  int REFERENCES users(id),
  note                text
);
CREATE UNIQUE INDEX IF NOT EXISTS schedule_week_releases_scope_idx
  ON schedule_week_releases (club_id, COALESCE(club_section_id, 0), week_start);
COMMENT ON TABLE schedule_week_releases IS
  'A week opened early, ahead of the standing policy. Never deleted — revoke instead, so the audit trail stays whole.';

-- Lighthouse standing rule: Sunday 8 PM, whole club.
INSERT INTO schedule_release_policies (club_id, club_section_id, cutover_weekday, cutover_time, effective_from)
SELECT 134, NULL, 0, '20:00', DATE '2026-01-01'
 WHERE NOT EXISTS (SELECT 1 FROM schedule_release_policies WHERE club_id = 134 AND club_section_id IS NULL);

-- ── Derivation ──────────────────────────────────────────────────────────

-- Monday of the week containing at_ts, in tz.  (date_trunc('week') is ISO,
-- Monday-based — matches the Mon..Sun week My Schedule shows.)
CREATE OR REPLACE FUNCTION fh_week_start(at_ts timestamptz, tz text DEFAULT 'America/New_York')
RETURNS date LANGUAGE sql IMMUTABLE AS $$
  SELECT (date_trunc('week', (at_ts AT TIME ZONE tz)))::date
$$;

-- The policy in force for (club, section) at a moment.
CREATE OR REPLACE FUNCTION fh_schedule_policy(p_club_id int, p_section_id int, at_ts timestamptz)
RETURNS schedule_release_policies LANGUAGE sql STABLE AS $$
  SELECT p.* FROM schedule_release_policies p
   WHERE p.club_id = p_club_id
     AND (p.club_section_id IS NULL OR p.club_section_id = p_section_id)
     AND p.effective_from <= (at_ts AT TIME ZONE p.time_zone)::date
   ORDER BY (p.club_section_id IS NOT NULL) DESC, p.effective_from DESC, p.id DESC
   LIMIT 1
$$;

-- When the week starting p_week_start (a Monday) opens under the policy
-- alone: the cutover moment in the PREVIOUS week.  weekday 0 (Sun) →
-- offset 6 → the Sunday before; Saturday → 5; Monday → 0.
CREATE OR REPLACE FUNCTION fh_schedule_policy_opens_at(p_club_id int, p_section_id int, p_week_start date)
RETURNS timestamptz LANGUAGE sql STABLE AS $$
  SELECT ((p_week_start - 7 + ((pol.cutover_weekday + 6) % 7))::timestamp + pol.cutover_time) AT TIME ZONE pol.time_zone
    FROM fh_schedule_policy(p_club_id, p_section_id, (p_week_start::timestamp AT TIME ZONE 'America/New_York')) pol
   WHERE pol.id IS NOT NULL
$$;

-- The live (non-revoked) early release covering a week, if any.
CREATE OR REPLACE FUNCTION fh_schedule_week_release(p_club_id int, p_section_id int, p_week_start date)
RETURNS schedule_week_releases LANGUAGE sql STABLE AS $$
  SELECT r.* FROM schedule_week_releases r
   WHERE r.club_id = p_club_id AND r.week_start = p_week_start AND r.revoked_at IS NULL
     AND (r.club_section_id IS NULL OR r.club_section_id = p_section_id)
   ORDER BY (r.club_section_id IS NOT NULL) DESC, r.released_at ASC
   LIMIT 1
$$;

-- Effective open moment for a week: the earlier of the policy cutover and
-- an early release.  NULL when there is no policy and no release.
CREATE OR REPLACE FUNCTION fh_schedule_week_opens_at(p_club_id int, p_section_id int, p_week_start date)
RETURNS timestamptz LANGUAGE sql STABLE AS $$
  SELECT LEAST(
           fh_schedule_policy_opens_at(p_club_id, p_section_id, p_week_start),
           (SELECT r.released_at FROM fh_schedule_week_release(p_club_id, p_section_id, p_week_start) r WHERE r.id IS NOT NULL)
         )
$$;

-- End of the last week that is open at at_ts (Sunday 23:59:59.999 in tz).
-- Walks forward from the current week while the following week has
-- opened, so a week released two weeks early shows correctly.  With no
-- policy at all, only the current week is open.
CREATE OR REPLACE FUNCTION fh_schedule_window_end(p_club_id int, p_section_id int, at_ts timestamptz)
RETURNS timestamptz LANGUAGE plpgsql STABLE AS $$
DECLARE
  tz    text;
  wk    date;
  base  date;
  nxt   date;
  opens timestamptz;
BEGIN
  SELECT COALESCE(p.time_zone, 'America/New_York') INTO tz
    FROM fh_schedule_policy(p_club_id, p_section_id, at_ts) p;
  tz   := COALESCE(tz, 'America/New_York');
  base := fh_week_start(at_ts, tz);
  wk   := base;
  LOOP
    nxt   := wk + 7;
    opens := fh_schedule_week_opens_at(p_club_id, p_section_id, nxt);
    EXIT WHEN opens IS NULL OR opens > at_ts;
    wk := nxt;
    EXIT WHEN wk > base + 56;   -- never more than eight weeks ahead
  END LOOP;
  RETURN ((wk + 7)::timestamp AT TIME ZONE tz) - interval '1 millisecond';
END $$;
