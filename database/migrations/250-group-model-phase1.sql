-- ─────────────────────────────────────────────────────────────────────
-- 250-group-model-phase1.sql (2026-07-31)
--
-- Phase 1 of the group-model normalization
-- (docs/adr/2026-07-30-roster-membership-rsvp-normalization.md).
--
-- Additive only — the running app keeps using rosters /
-- roster_assignments / player_rsvp_eligibility untouched.  This
-- migration:
--   1. teams: division_id nullable, adds `kind`, folds roster_columns
--      presentation fields in.
--   2. Creates team_persons (the one membership table),
--      rsvp_suspensions (exceptions only), and a backfill map.
--   3. Installs fn_backfill_team_persons() — IDEMPOTENT, called once
--      here and again inside the Phase 2 cutover window to close the
--      drift gap — and runs it.  Cross-team player_rsvp_eligibility
--      grants import as direct membership with on_roster=false
--      (league rules allow multi-team players; no one-home-team
--      mutex).
--
-- The strict "official ⇔ has division" CHECK is deferred to Phase 3:
-- pool teams (908/909) and admin buckets still carry division_id=73
-- and must keep working until the cutover completes.
-- ─────────────────────────────────────────────────────────────────────

BEGIN;

-- ═══ 1. teams alterations ════════════════════════════════════════════

ALTER TABLE teams ALTER COLUMN division_id DROP NOT NULL;

ALTER TABLE teams
    ADD COLUMN kind              TEXT NOT NULL DEFAULT 'official'
        CHECK (kind IN ('official', 'internal', 'admin_bucket')),
    -- roster_columns fold-in (board presentation):
    ADD COLUMN label             TEXT,
    ADD COLUMN short_label       TEXT,
    ADD COLUMN color             TEXT,
    ADD COLUMN board_sort_order  INTEGER,
    ADD COLUMN mutex_group       TEXT,
    ADD COLUMN max_roster        INTEGER,
    ADD COLUMN board_archived_at TIMESTAMPTZ;

-- Classification of existing FH-managed teams (survey 2026-07-31):
--   internal:     908/909 pools, 903/904/905 archived grassroots
--                 (U23 / DR / PR), 912/913/914 boys staging buckets
--   admin_bucket: 910/915 Dues Owed
--   official:     everything else (default) — real league teams,
--                 incl. all synced opponents.
UPDATE teams SET kind = 'internal'
 WHERE id IN (903, 904, 905, 908, 909, 912, 913, 914);
UPDATE teams SET kind = 'admin_bucket'
 WHERE id IN (910, 915);

-- Fold roster_columns presentation fields into teams.  (domain,
-- team_id) is unique and no team appears under two domains, so this
-- is 1:1.
UPDATE teams t
   SET label             = rc.label,
       short_label       = rc.short_label,
       color             = rc.color,
       board_sort_order  = rc.sort_order,
       mutex_group       = rc.mutex_group,
       max_roster        = rc.max_roster,
       board_archived_at = rc.archived_at
  FROM roster_columns rc
 WHERE rc.team_id = t.id;

-- ═══ 2. New tables ═══════════════════════════════════════════════════

CREATE TABLE team_persons (
    id                   SERIAL PRIMARY KEY,
    team_id              INTEGER NOT NULL REFERENCES teams(id)   ON DELETE CASCADE,
    person_id            INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    joined_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    removed_at           TIMESTAMPTZ,
    removed_reason       TEXT,
    removed_details      JSONB,
    on_roster            BOOLEAN NOT NULL DEFAULT false,
    jersey_number        VARCHAR(10),
    coach_sort_order     INTEGER,
    assigned_by_user_id  INTEGER REFERENCES users(id),
    CHECK (removed_at IS NULL OR removed_at > joined_at)
);
CREATE UNIQUE INDEX team_persons_active_unique
    ON team_persons (team_id, person_id) WHERE removed_at IS NULL;
-- NOTE deliberately NO one-home-team mutex: league rules allow a
-- player on multiple teams simultaneously (common case: moved up from
-- Liga 1 to APSL, replacement not found yet).  The old board's
-- uniq_roster_assignments_mens_selection_one_of forced that reality
-- into hand-maintained player_rsvp_eligibility grants — the group
-- model represents it as what it is: membership in both groups.
CREATE INDEX idx_team_persons_person ON team_persons (person_id);
CREATE INDEX idx_team_persons_team_active
    ON team_persons (team_id) WHERE removed_at IS NULL;

-- Exceptions only: "on the roster but barred".  team_id NULL = all
-- teams.  Default eligibility never lives here — it derives from
-- team_persons + fh_event_teams.
CREATE TABLE rsvp_suspensions (
    person_id          INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    team_id            INTEGER REFERENCES teams(id) ON DELETE CASCADE,
    starts_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    ends_at            TIMESTAMPTZ,
    reason             TEXT,
    created_by_user_id INTEGER REFERENCES users(id),
    PRIMARY KEY (person_id, starts_at)
);

-- Old-row → new-row provenance.  Powers (a) backfill idempotency and
-- (b) the Phase 2 roster_positions repoint (rosters.id →
-- team_persons.id becomes a mechanical join through this map).
CREATE TABLE team_persons_backfill_map (
    source         TEXT    NOT NULL CHECK (source IN ('roster_assignments', 'rosters')),
    source_id      INTEGER NOT NULL,
    team_person_id INTEGER NOT NULL REFERENCES team_persons(id) ON DELETE CASCADE,
    PRIMARY KEY (source, source_id)
);

-- ═══ 3. Idempotent backfill ══════════════════════════════════════════
-- Row-wise on purpose: ~500 rows total, and the merge rules (dup LA
-- aliases collapsing onto one person, rosters+roster_assignments both
-- describing the same membership) are much clearer as explicit logic
-- than as set operations.  Re-running only processes unmapped rows.

CREATE OR REPLACE FUNCTION fn_backfill_team_persons()
RETURNS void LANGUAGE plpgsql AS $$
DECLARE
  r         record;
  v_tp_id   integer;
  v_joined  timestamptz;
BEGIN
  -- ── A. roster_assignments (via the LeagueApps alias bridge) ──
  FOR r IN
    SELECT DISTINCT ON (ra.id)
           ra.id, ra.team_id, epa.person_id, ra.assigned_at,
           ra.removed_at, ra.removed_reason, ra.removed_details,
           ra.on_roster, ra.coach_sort_order, ra.assigned_by_user_id
      FROM roster_assignments ra
      JOIN external_person_aliases epa
        ON epa.provider = 'leagueapps'
       AND epa.external_user_id = ra.leagueapps_user_id::text
     WHERE NOT EXISTS (SELECT 1 FROM team_persons_backfill_map m
                        WHERE m.source = 'roster_assignments'
                          AND m.source_id = ra.id)
     ORDER BY ra.id, epa.person_id
  LOOP
    -- guard the removed_at > joined_at CHECK
    v_joined := r.assigned_at;
    IF r.removed_at IS NOT NULL AND r.removed_at <= v_joined THEN
      v_joined := r.removed_at - interval '1 second';
    END IF;

    IF r.removed_at IS NULL THEN
      SELECT id INTO v_tp_id FROM team_persons
       WHERE team_id = r.team_id AND person_id = r.person_id
         AND removed_at IS NULL;
      IF FOUND THEN
        -- second alias / second source for the same live membership:
        -- merge, don't duplicate
        UPDATE team_persons
           SET on_roster        = team_persons.on_roster OR r.on_roster,
               coach_sort_order = COALESCE(team_persons.coach_sort_order, r.coach_sort_order),
               joined_at        = LEAST(team_persons.joined_at, v_joined)
         WHERE id = v_tp_id;
      ELSE
        INSERT INTO team_persons (team_id, person_id, joined_at,
                                  on_roster, coach_sort_order,
                                  assigned_by_user_id)
        VALUES (r.team_id, r.person_id, v_joined,
                r.on_roster, r.coach_sort_order, r.assigned_by_user_id)
        RETURNING id INTO v_tp_id;
      END IF;
    ELSE
      INSERT INTO team_persons (team_id, person_id, joined_at,
                                removed_at, removed_reason, removed_details,
                                on_roster, coach_sort_order,
                                assigned_by_user_id)
      VALUES (r.team_id, r.person_id, v_joined,
              r.removed_at, r.removed_reason, r.removed_details,
              r.on_roster, r.coach_sort_order, r.assigned_by_user_id)
      RETURNING id INTO v_tp_id;
    END IF;

    INSERT INTO team_persons_backfill_map VALUES ('roster_assignments', r.id, v_tp_id);
  END LOOP;

  -- ── B. rosters (players.person_id is unique, 100% resolvable) ──
  -- Simultaneous active memberships across teams are LEGAL (league
  -- allows multi-team players) and import as-is.  Same-team duplicate
  -- actives merge via the existence check below.  Epoch-1970 sentinel
  -- joined_at values are kept on fresh inserts (faithful to source)
  -- but never allowed to pollute merged rows.
  FOR r IN
    SELECT ro.id, ro.team_id, pl.person_id, ro.jersey_number,
           ro.joined_at AT TIME ZONE 'UTC' AS joined_at,
           ro.left_at   AT TIME ZONE 'UTC' AS left_at
      FROM rosters ro
      JOIN players pl ON pl.id = ro.player_id
     WHERE NOT EXISTS (SELECT 1 FROM team_persons_backfill_map m
                        WHERE m.source = 'rosters'
                          AND m.source_id = ro.id)
     ORDER BY ro.joined_at DESC, ro.id DESC
  LOOP
    v_joined := r.joined_at;
    IF r.left_at IS NOT NULL AND r.left_at <= v_joined THEN
      v_joined := r.left_at - interval '1 second';
    END IF;

    IF r.left_at IS NULL THEN
      SELECT id INTO v_tp_id FROM team_persons
       WHERE team_id = r.team_id AND person_id = r.person_id
         AND removed_at IS NULL;
      IF FOUND THEN
        UPDATE team_persons
           SET jersey_number = COALESCE(team_persons.jersey_number, r.jersey_number),
               -- don't let epoch-1970 sentinels pollute real dates
               joined_at     = CASE WHEN v_joined >= '2000-01-01'
                                    THEN LEAST(team_persons.joined_at, v_joined)
                                    ELSE team_persons.joined_at END
         WHERE id = v_tp_id;
      ELSE
        INSERT INTO team_persons (team_id, person_id, joined_at, jersey_number)
        VALUES (r.team_id, r.person_id, v_joined, r.jersey_number)
        RETURNING id INTO v_tp_id;
      END IF;
    ELSE
      INSERT INTO team_persons (team_id, person_id, joined_at, removed_at, jersey_number)
      VALUES (r.team_id, r.person_id, v_joined, r.left_at, r.jersey_number)
      RETURNING id INTO v_tp_id;
    END IF;

    INSERT INTO team_persons_backfill_map VALUES ('rosters', r.id, v_tp_id);
  END LOOP;

  -- ── C. Pool teams 908/909: snapshot EFFECTIVE membership ──
  -- v_team_members includes the team_roster_sources union (76 people
  -- on 908 vs only 67 direct rows).  Under the group model the union
  -- machinery dies, so the effective membership becomes direct
  -- membership here; practice/pickup events keep resolving until ops
  -- retags the recurring series to the real teams.
  INSERT INTO team_persons (team_id, person_id, joined_at, on_roster)
  SELECT vtm.team_id, epa.person_id, vtm.assigned_at, vtm.on_roster
    FROM v_team_members vtm
    JOIN external_person_aliases epa
      ON epa.provider = 'leagueapps'
     AND epa.external_user_id = vtm.leagueapps_user_id::text
   WHERE vtm.team_id IN (908, 909)
  ON CONFLICT (team_id, person_id) WHERE removed_at IS NULL DO NOTHING;

  -- ── D. Cross-team RSVP grants → direct membership ──
  -- League rules allow a player on multiple teams (moved up, no
  -- replacement yet).  The old board's one-of constraint forced that
  -- into hand-maintained player_rsvp_eligibility grants; here each
  -- grant on a team the person isn't already a member of imports as
  -- real membership with on_roster=false (the board's existing
  -- "attached to the squad pool, not on the official roster"
  -- semantic).  Guard: only for persons with at least one active
  -- membership elsewhere — grants held by fully-lapsed members are
  -- stale and deliberately not carried (they show up as bucket (b)
  -- in the parity harness).
  INSERT INTO team_persons (team_id, person_id, joined_at, on_roster)
  SELECT ple.team_id, epa.person_id, ple.granted_at, false
    FROM player_rsvp_eligibility ple
    JOIN external_person_aliases epa
      ON epa.provider = 'leagueapps'
     AND epa.external_user_id = ple.leagueapps_user_id::text
   WHERE EXISTS (SELECT 1 FROM team_persons tp
                  WHERE tp.person_id = epa.person_id
                    AND tp.removed_at IS NULL)
  ON CONFLICT (team_id, person_id) WHERE removed_at IS NULL DO NOTHING;
END $$;

-- ═══ 4. Run the backfill ═════════════════════════════════════════════

SELECT fn_backfill_team_persons();

DO $$
DECLARE
  n_active  integer;
  n_total   integer;
  n_multi   integer;
  n_pool    integer;
BEGIN
  SELECT count(*) INTO n_total  FROM team_persons;
  SELECT count(*) INTO n_active FROM team_persons WHERE removed_at IS NULL;
  SELECT count(*) INTO n_multi  FROM (
    SELECT person_id FROM team_persons tp
     JOIN teams t ON t.id = tp.team_id
    WHERE tp.removed_at IS NULL AND t.kind = 'official'
    GROUP BY person_id HAVING count(*) > 1) m;
  SELECT count(*) INTO n_pool   FROM team_persons
   WHERE removed_at IS NULL AND on_roster = false;
  RAISE NOTICE 'team_persons backfill: % rows (% active, % squad-pool/on_roster=false, % persons on multiple official teams)',
               n_total, n_active, n_pool, n_multi;
END $$;

COMMIT;
