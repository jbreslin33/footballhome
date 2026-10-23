-- 634 (2026-10-22) — per-facility field layouts: the nested pitch.
-- Owner: "keep current 11v11 and 7v7 until sunday games are over.
-- meanwhile i would start marking out new nested field to be used going
-- forward and just keep it from double book" … "just 1 pitch 11v11 with
-- 9v9 and 7v7 nested inside".
--
-- field_formats (mig 532) says how much of A field each format takes, the
-- same everywhere.  A facility can now say otherwise from a date on:
-- facility_format_shares rows override field_formats for games at that
-- facility kicking off on/after effective_from (the latest row per format
-- wins).  Lighthouse Sport Complex from Mon 2026-10-26: the 9v9 and 7v7
-- are marked INSIDE the 11v11, so every format takes the whole pitch and
-- any two games at once clash.  Sunday 10-25 still runs the old layout
-- (11v11 + two 7v7 side by side).
CREATE TABLE IF NOT EXISTS facility_format_shares (
    facility_id      INT NOT NULL REFERENCES facilities(id) ON DELETE CASCADE,
    players_per_side SMALLINT NOT NULL REFERENCES field_formats(players_per_side),
    effective_from   TIMESTAMPTZ NOT NULL,
    field_share      NUMERIC(4,2) NOT NULL CHECK (field_share > 0 AND field_share <= 1),
    note             TEXT,
    PRIMARY KEY (facility_id, players_per_side, effective_from)
);
COMMENT ON TABLE facility_format_shares IS 'Per-facility override of field_formats.field_share from effective_from on (mig 634); the latest row at or before a game''s kick-off wins.';

INSERT INTO facility_format_shares (facility_id, players_per_side, effective_from, field_share, note)
SELECT f.id, v.pps, '2026-10-26 00:00 America/New_York'::timestamptz, 1.00,
       'Nested pitch: the 9v9 and 7v7 are marked inside the 11v11, so any game takes the whole pitch.'
  FROM facilities f
 CROSS JOIN (VALUES (11), (9), (7), (4)) AS v(pps)
 WHERE f.name = 'Lighthouse Sport Complex'
ON CONFLICT DO NOTHING;

-- One game's share of its facility's field: the biggest of its teams'
-- formats (APSL + Reserves share one game), each taken from the facility's
-- layout in force at kick-off, else field_formats; a team without a
-- field_size — or a game without teams — counts as the whole field.
CREATE OR REPLACE FUNCTION fh_event_field_share(p_fh_event_id BIGINT)
RETURNS NUMERIC LANGUAGE sql STABLE AS $$
    SELECT COALESCE(max(COALESCE(
               (SELECT s.field_share FROM facility_format_shares s
                 WHERE s.facility_id = fe.facility_id AND s.players_per_side = t.field_size
                   AND s.effective_from <= ge.starts_at
                 ORDER BY s.effective_from DESC LIMIT 1),
               ff.field_share, 1.0)), 1.0)
      FROM fh_events fe
      JOIN gcal_events ge ON ge.id = fe.gcal_event_id
      LEFT JOIN fh_event_teams fet ON fet.fh_event_id = fe.id
      LEFT JOIN teams t ON t.id = fet.team_id
      LEFT JOIN field_formats ff ON ff.players_per_side = t.field_size
     WHERE fe.id = p_fh_event_id
$$;

CREATE OR REPLACE FUNCTION fh_field_clashes(p_from TIMESTAMPTZ, p_to TIMESTAMPTZ)
RETURNS TABLE (facility_id INT, facility TEXT, at_instant TIMESTAMPTZ, total_share NUMERIC, fh_event_ids BIGINT[])
LANGUAGE sql STABLE AS $$
    WITH g AS (
        SELECT fe.id, fe.facility_id, ge.starts_at, ge.ends_at,
               fh_event_field_share(fe.id) AS share
          FROM fh_events fe
          JOIN gcal_events ge ON ge.id = fe.gcal_event_id
         WHERE fe.kind IN ('match', 'intrasquad')
           AND fe.facility_id IS NOT NULL
           AND ge.deleted_at IS NULL AND ge.status IS DISTINCT FROM 'cancelled'
           AND ge.ends_at > p_from AND ge.starts_at < p_to
    ), inst AS (
        -- each kick-off instant once: two games kicking off together used
        -- to double every share at that instant (mig 532's join on g)
        SELECT a.facility_id, a.starts_at AS at_instant,
               sum(b.share) AS total_share,
               array_agg(b.id ORDER BY b.starts_at, b.id) AS ids
          FROM (SELECT DISTINCT g.facility_id, g.starts_at FROM g) a
          JOIN g b ON b.facility_id = a.facility_id AND b.starts_at <= a.starts_at AND b.ends_at > a.starts_at
         GROUP BY a.facility_id, a.starts_at
        HAVING sum(b.share) > 1
    )
    SELECT DISTINCT ON (i.facility_id, i.ids) i.facility_id, f.name, i.at_instant, i.total_share, i.ids
      FROM inst i JOIN facilities f ON f.id = i.facility_id
     ORDER BY i.facility_id, i.ids, i.at_instant
$$;

UPDATE message_templates
   SET body = 'A game takes the share of the field its format needs (11v11 and 9v9 the whole field, 7v7 a half, 4v4 a quarter) unless its facility''s layout says otherwise — on a nested pitch every format takes the whole field. Games on one field at the same time clash when the shares add up to more than one field.'
 WHERE kind = 'calendar' AND tier = 'clash_hint';
