-- 532 (2026-10-06) — #calendar: home-field clash check.
-- Owner: "check for any overlap of games at lighthouse sports complex of
-- game start times … and end times" … "u12 is 9v9. u8 and u10 is 7v7" …
-- "yes build the overlap check on #calendar".
--
-- field_formats says how much of a full field a game format takes: an
-- 11v11 the whole field; a 9v9 a half across, but only on a field at
-- least 70 yards wide, so it is counted as the whole field until the
-- owner says otherwise; a 7v7 a half; a 4v4 a quarter.  A team's format
-- is teams.field_size (mig 322).  fh_field_clashes() finds every instant
-- at a facility where the games running together need more than one
-- field; #calendar shows them in a strip and the all-clear when none.
CREATE TABLE IF NOT EXISTS field_formats (
    players_per_side SMALLINT PRIMARY KEY,
    label            TEXT NOT NULL,
    field_share      NUMERIC(4,2) NOT NULL CHECK (field_share > 0 AND field_share <= 1),
    note             TEXT
);
COMMENT ON TABLE field_formats IS 'How much of a full-size field a game format takes (mig 532); games at one facility clash when the shares running together exceed 1.';
INSERT INTO field_formats (players_per_side, label, field_share, note) VALUES
    (11, '11v11', 1.00, 'The whole field.'),
    ( 9, '9v9',   1.00, 'A half across, but only on a field at least 70 yards wide — counted as the whole field (owner 2026-10-06: "fitting that field is pain"). Set 0.50 if the field is wide enough to run a 7v7 beside it.'),
    ( 7, '7v7',   0.50, 'A half across; two run side by side.'),
    ( 4, '4v4',   0.25, 'A quarter.')
ON CONFLICT (players_per_side) DO NOTHING;

-- Every instant between p_from and p_to at which the games on one
-- facility need more than one field.  A clash's peak always falls at some
-- game's kick-off, so each kick-off is checked against the games covering
-- it; the same set of games is reported once, at its first such instant.
-- An event's share is the biggest of its teams' formats (APSL + Reserves
-- share one game); a team without a field_size counts as the whole field.
CREATE OR REPLACE FUNCTION fh_field_clashes(p_from TIMESTAMPTZ, p_to TIMESTAMPTZ)
RETURNS TABLE (facility_id INT, facility TEXT, at_instant TIMESTAMPTZ, total_share NUMERIC, fh_event_ids BIGINT[])
LANGUAGE sql STABLE AS $$
    WITH g AS (
        SELECT fe.id, fe.facility_id, ge.starts_at, ge.ends_at,
               COALESCE((SELECT max(COALESCE(ff.field_share, 1.0))
                           FROM fh_event_teams fet
                           JOIN teams t ON t.id = fet.team_id
                           LEFT JOIN field_formats ff ON ff.players_per_side = t.field_size
                          WHERE fet.fh_event_id = fe.id), 1.0) AS share
          FROM fh_events fe
          JOIN gcal_events ge ON ge.id = fe.gcal_event_id
         WHERE fe.kind IN ('match', 'intrasquad')
           AND fe.facility_id IS NOT NULL
           AND ge.deleted_at IS NULL AND ge.status IS DISTINCT FROM 'cancelled'
           AND ge.ends_at > p_from AND ge.starts_at < p_to
    ), inst AS (
        SELECT a.facility_id, a.starts_at AS at_instant,
               sum(b.share) AS total_share,
               array_agg(b.id ORDER BY b.starts_at, b.id) AS ids
          FROM g a
          JOIN g b ON b.facility_id = a.facility_id AND b.starts_at <= a.starts_at AND b.ends_at > a.starts_at
         GROUP BY a.facility_id, a.starts_at
        HAVING sum(b.share) > 1
    )
    SELECT DISTINCT ON (i.facility_id, i.ids) i.facility_id, f.name, i.at_instant, i.total_share, i.ids
      FROM inst i JOIN facilities f ON f.id = i.facility_id
     ORDER BY i.facility_id, i.ids, i.at_instant
$$;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Calendar', l, 'calendar', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('clash_title',   'Calendar — field clash strip title',           '⚠ Field clash', 770),
    ('clash_line',    'Calendar — one clash ({facility} {day} {time} {total})', '{facility} · {day} at {time} — these games need {total} fields at once:', 771),
    ('clash_none',    'Calendar — no clashes ({through})',            '✅ No field clashes on the calendar through {through}.', 772),
    ('clash_unknown', 'Calendar — team format unknown',               'format not set — counted as the whole field', 773),
    ('clash_hint',    'Calendar — how the check works',               'A game takes the share of the field its format needs (11v11 and 9v9 the whole field, 7v7 a half, 4v4 a quarter); games on one field at the same time clash when the shares add up to more than one field.', 774)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'calendar' AND m.tier = v.t);
