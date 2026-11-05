-- 1105: carpool heads-up on every game / practice card (#my, Event Center
-- tiles) — owner 2026-11-05: "show carpool details on game or practice
-- card?" + "so we get a quick heads up? with carpool and names?".
-- fh_event_carpool_summary(event, viewer) = one JSON object per carpool:
-- driver, seats / open, its stops in order with who is picked up at each,
-- and where the viewer (or their kid) rides, if anywhere.  The calendar
-- feed attaches it as ev.carpools; EventLabels.carpoolLines() words it.

CREATE OR REPLACE FUNCTION fh_event_carpool_summary(p_fh_event_id bigint, p_viewer integer)
RETURNS json LANGUAGE sql STABLE AS $$
  SELECT COALESCE(json_agg(c ORDER BY c.first_at, c.id), '[]'::json) FROM (
    SELECT h.id, h.seats,
           (SELECT min(x.depart_at) FROM fh_event_departures x
             WHERE (x.id = h.id OR x.stop_of = h.id) AND x.cancelled_at IS NULL) AS first_at,
           COALESCE(dp.first_name, '') AS driver_first,
           NULLIF(trim(COALESCE(dp.first_name,'') || ' ' || COALESCE(dp.last_name,'')), '') AS driver,
           (h.driver_person_id = p_viewer) AS i_drive,
           (SELECT count(*) FROM fh_event_departure_signups s JOIN fh_event_departures x ON x.id = s.departure_id
             WHERE (x.id = h.id OR x.stop_of = h.id) AND x.cancelled_at IS NULL
               AND s.left_at IS NULL AND s.role = 'rider') AS passengers,
           (SELECT json_agg(json_build_object(
                      'place', x.place,
                      'time',  to_char(x.depart_at AT TIME ZONE 'America/New_York', 'FMHH12:MI AM'),
                      'names', (SELECT COALESCE(json_agg(p.first_name || COALESCE(' ' || left(p.last_name, 1) || '.', '') ORDER BY s.created_at), '[]'::json)
                                  FROM fh_event_departure_signups s JOIN persons p ON p.id = s.person_id
                                 WHERE s.departure_id = x.id AND s.left_at IS NULL AND s.role = 'rider'),
                      'mine',  (SELECT COALESCE(json_agg(p.first_name), '[]'::json)
                                  FROM fh_event_departure_signups s JOIN persons p ON p.id = s.person_id
                                 WHERE s.departure_id = x.id AND s.left_at IS NULL AND s.role = 'rider'
                                   AND (s.person_id = p_viewer OR COALESCE(fh_is_guardian(p_viewer, s.person_id), false))))
                    ORDER BY x.depart_at, x.id)
              FROM fh_event_departures x
             WHERE (x.id = h.id OR x.stop_of = h.id) AND x.cancelled_at IS NULL) AS stops
      FROM fh_event_departures h
      LEFT JOIN persons dp ON dp.id = h.driver_person_id
     WHERE h.fh_event_id = p_fh_event_id AND h.stop_of IS NULL AND h.cancelled_at IS NULL
  ) c
$$;
COMMENT ON FUNCTION fh_event_carpool_summary(bigint, integer) IS
  'mig 1105: the carpools on an event for a card heads-up — driver, seats, passengers, stops with names, viewer''s own stop.';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Carpool', v.label, 'carpool', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Card heads-up — one carpool ({driver}, {stops}, {open})', 'card_line', '🚗 {driver} drives: {stops} · {open} open', 240),
    ('Card heads-up — full carpool ({driver}, {stops})', 'card_line_full', '🚗 {driver} drives: {stops} · full', 241),
    ('Card heads-up — you drive', 'card_you_drive', '(you drive)', 242),
    ('Card heads-up — you ride ({who}, {place}, {time})', 'card_you_ride', '✓ {who}: {place} {time}', 243)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'carpool' AND m.tier = v.tier);
