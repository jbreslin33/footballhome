-- 1245: every card on an event gets a CONTACT button (owner 2026-11-11:
-- "why don't coaches have contact button" / "we should never show a
-- person without a contact button").  fh_game_contact_states fed the
-- card's ✉ CONTACT sheet from the event's team players + live invites
-- only, so a coach card (team_coaches) — or anyone else on the event's
-- list through an RSVP — came back with no contact row and no button.
-- The people set now matches who Event Center / Game Center draw: team
-- players, live invites, the tagged teams' current coaches, and anyone
-- holding an RSVP on the event.
CREATE OR REPLACE FUNCTION public.fh_game_contact_states(p_fh_event_id bigint)
 RETURNS TABLE(person_id integer, recipient_person_id integer, recipient_name text, ord integer, consent text, phone text, email text, reply_body text, reply_at timestamp with time zone)
 LANGUAGE sql
 STABLE
AS $function$
    WITH ppl AS (
        SELECT DISTINCT p.id
          FROM persons p
         WHERE EXISTS (SELECT 1 FROM fh_event_teams fet JOIN team_persons tp
                         ON tp.team_id = fet.team_id AND tp.person_id = p.id AND tp.removed_at IS NULL
                        WHERE fet.fh_event_id = p_fh_event_id)
            OR EXISTS (SELECT 1 FROM fh_event_invites i WHERE i.fh_event_id = p_fh_event_id
                          AND i.person_id = p.id AND i.revoked_at IS NULL)
            OR EXISTS (SELECT 1 FROM fh_event_teams fet
                         JOIN team_coaches tc ON tc.team_id = fet.team_id AND tc.ended_at IS NULL
                         JOIN coaches co ON co.id = tc.coach_id
                        WHERE fet.fh_event_id = p_fh_event_id AND co.person_id = p.id)
            OR EXISTS (SELECT 1 FROM fh_event_rsvps er
                        WHERE er.fh_event_id = p_fh_event_id AND er.person_id = p.id)
    ),
    r AS (
        SELECT ppl.id, m.recipient_person_id AS rid, m.ord
          FROM ppl CROSS JOIN LATERAL fh_message_recipients(ppl.id) m
    )
    SELECT r.id, r.rid, COALESCE(rp.first_name, '')::text, r.ord,
           CASE WHEN fh_sms_consented_at(r.rid) IS NOT NULL THEN 'in'
                WHEN fh_sms_opted_out_at(r.rid) IS NOT NULL THEN 'stopped'
                ELSE 'none' END,
           (SELECT x.phone_number FROM person_phones x WHERE x.person_id = r.rid AND x.can_receive_sms
             ORDER BY x.is_primary DESC, x.id LIMIT 1)::text,
           (SELECT e.email FROM person_emails e WHERE e.person_id = r.rid
             ORDER BY e.is_primary DESC, e.id LIMIT 1)::text,
           rep.body, rep.created_at
      FROM r
      JOIN persons rp ON rp.id = r.rid
      LEFT JOIN LATERAL (
          SELECT s.body, s.created_at FROM sms_messages s
           WHERE s.direction = 'in' AND s.opt_out_type IS NULL AND s.person_id = r.rid
             AND s.created_at > now() - interval '14 days'
           ORDER BY s.created_at DESC LIMIT 1) rep ON true
$function$;
