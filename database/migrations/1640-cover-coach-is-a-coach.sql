-- 1640 (2026-11-20) — 🔁 A coach covering one event IS a coach on it.
-- Owner 11/20: "do it like reserves but it would not have shown before but
-- now it does" — like a reserve's second team row, the cover opens the
-- event to the covering coach and they count as its coach: they see it,
-- answer it, are listed with the coaches, checked in and reminded as one.
-- Mig 1634 used an invite row (event_person_sees) when the cover coach was
-- not on the event's teams; that showed them as an invited PLAYER.  The
-- callers now ask fh_event_covering() instead, so those rows go.
-- Also: the cover ask text carries the coach's own sign-in link, minted
-- like every player / parent reminder (owner: "why are we not using same
-- as we do with players and parents"), landing on the event.
BEGIN;

CREATE OR REPLACE FUNCTION fh_event_covering(p_fh_event_id bigint, p_person_id integer)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT EXISTS (SELECT 1 FROM coach_covers cc JOIN coaches c ON c.id = cc.cover_coach_id
                  WHERE cc.fh_event_id = p_fh_event_id AND cc.status = 'covered' AND c.person_id = p_person_id)
$$;
COMMENT ON FUNCTION fh_event_covering(bigint, integer) IS
  'mig 1640: this person covers this event for another coach (coach_covers) — a coach on it, like its own.';

-- Asked to cover it (still open): the event is on their calendar with a
-- 🆘 badge and opens from the ask's text — they answer it once they take it.
CREATE OR REPLACE FUNCTION fh_event_cover_asked(p_fh_event_id bigint, p_person_id integer)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT EXISTS (SELECT 1 FROM coach_covers cc
                   JOIN coach_cover_asks a ON a.cover_id = cc.id
                   JOIN coaches c ON c.id = a.coach_id
                  WHERE cc.fh_event_id = p_fh_event_id AND cc.status = 'open' AND c.person_id = p_person_id)
$$;

-- The event page's permission (mig 1362): covering = the coach tier.
CREATE OR REPLACE FUNCTION fh_event_viewer_tier(p_fh_event_id bigint, p_person_id integer)
 RETURNS text
 LANGUAGE sql
 STABLE
AS $function$
  SELECT CASE
    WHEN EXISTS (SELECT 1 FROM admins a JOIN users u ON u.id = a.user_id
                  WHERE u.person_id = p_person_id) THEN 'admin'
    WHEN EXISTS (SELECT 1 FROM fh_event_teams fet
                   JOIN team_coaches tc ON tc.team_id = fet.team_id AND tc.ended_at IS NULL
                   JOIN coaches co      ON co.id = tc.coach_id
                  WHERE fet.fh_event_id = p_fh_event_id
                    AND co.person_id = p_person_id) THEN 'coach'
    WHEN fh_event_covering(p_fh_event_id, p_person_id) THEN 'coach'   -- mig 1640
    ELSE 'player'
  END
$function$;

DELETE FROM event_person_sees WHERE note LIKE 'coach cover #%';

UPDATE message_templates
   SET body = 'Hi {first}, can you cover {event} on {when} for {coach}? Tap to take it: {link}'
 WHERE kind = 'coach_schedule' AND tier = 'cover_sms';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Coach Schedule', v.l, 'coach_schedule', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('cover_banner_ask',  'Event page: you were asked', '🆘 {coach} asked you to cover this', 60),
    ('cover_banner_open', 'Event page: open ask',       '🆘 {coach} needs cover for this', 61),
    ('cover_banner_mine', 'Event page: your own ask',   '🆘 You asked for cover — waiting', 62),
    ('cover_banner_done', 'Event page: covered',        '🔁 {cover} is covering for {coach}', 63),
    ('cover_card_badge',  'Calendar card badge',        '🆘 Cover', 64)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'coach_schedule' AND m.tier = v.t);

COMMIT;
