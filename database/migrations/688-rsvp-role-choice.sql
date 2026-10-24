-- 688 (2026-10-24) — A coach who also plays on the same team says, when
-- Going, whether they are playing.  Owner: "i need for me a player role
-- and coach role on my rsvp right?" → "if i am going it can ask what
-- role? default to both? so players like luke breslin don't get flooded
-- with options".
--
-- Only dual-role people on that event's team (coach AND rostered player
-- — today James Breslin on Liga 1 / Reserves, Jamie Arevalo on Women's)
-- see Both / Playing / Coaching only after tapping Going; Both is the
-- default (NULL).  Both and Playing count them as a player everywhere
-- (#rsvps totals, #my lists, Game Center lineup pool); Coaching only
-- keeps them with the coaches and out of the player counts and the pool.
-- Everyone else answers exactly as before.

ALTER TABLE fh_event_rsvps
    ADD COLUMN IF NOT EXISTS role_choice TEXT CHECK (role_choice IN ('both', 'player', 'coach'));
COMMENT ON COLUMN fh_event_rsvps.role_choice IS
    'mig 688: a dual-role (coach + player on the event''s team) person''s hat when Going — NULL/both = playing and coaching, player, coach = coaching only.';

-- Coach AND rostered player on a team tagged on this event.
CREATE OR REPLACE FUNCTION fh_event_dual_role(p_fh_event_id bigint, p_person int) RETURNS boolean
LANGUAGE sql STABLE AS $$
    SELECT EXISTS (
        SELECT 1 FROM fh_event_teams fet
          JOIN team_coaches tc ON tc.team_id = fet.team_id AND tc.ended_at IS NULL
          JOIN coaches co ON co.id = tc.coach_id AND co.person_id = p_person
          JOIN team_persons tp ON tp.team_id = fet.team_id AND tp.person_id = p_person
                              AND tp.removed_at IS NULL AND NOT tp.invite_only
         WHERE fet.fh_event_id = p_fh_event_id)
$$;
COMMENT ON FUNCTION fh_event_dual_role(bigint, int) IS 'mig 688: coaches and plays on a team of this event — gets the Both / Playing / Coaching only choice.';

-- Is this person counted as a PLAYER on the event: a dual-role person
-- unless they chose Coaching only.
CREATE OR REPLACE FUNCTION fh_event_counts_as_player(p_fh_event_id bigint, p_person int) RETURNS boolean
LANGUAGE sql STABLE AS $$
    SELECT fh_event_dual_role(p_fh_event_id, p_person)
       AND NOT EXISTS (SELECT 1 FROM fh_event_rsvps r
                        WHERE r.fh_event_id = p_fh_event_id AND r.person_id = p_person AND r.role_choice = 'coach')
$$;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'System', v.l, 'my_role', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('both',          'Role pill — coach who also plays',          'COACH + PLAYER', 10),
    ('choice_q',      'Going as — question (dual-role only)',      'Going as:', 11),
    ('choice_both',   'Going as — both (default)',                 'Both', 12),
    ('choice_player', 'Going as — playing',                        'Playing', 13),
    ('choice_coach',  'Going as — coaching only',                  'Coaching only', 14)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'my_role' AND m.tier = v.t);
