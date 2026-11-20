-- 1607 (2026-11-20) — 🪑 Reserves until called up: asking = the call-up.
--
-- Owner 11/20: "if reserve then you sit in reserve until we send them a
-- rsvp reminder. you have to detect that. that is the 'call up' … an
-- invite is sufficient … so then for west chester if we remind oumar then
-- he immediately goes to not responded until he responds" + "if
-- 'reminding' a reserve we can make theres a bit more fancy and say we are
-- calling them up? that would apply to youth and men etc." → "go".
--
-- One rule for every section:
--   • Not a Regular on the event's team (🪑 Reserves on it, or only seeing
--     the game — official league list, standing call-down, a one-game
--     invite) and not yet ASKED for this event → the Reserves fold: sees
--     it, may answer, never counted, reminded or chased.
--   • ASKED for this event = an RSVP reminder logged for it (one-person
--     reminder, Remind all, 📣 Ask Reserves — rsvp_reminder_events) or a
--     🎟 call-up sent for it (event_person_sees with a channel).  From then
--     on he is on the list → No response until he answers.  Per event.
--
-- The 🎟 call-up message words say "calling you up" (event_invite rows).

CREATE OR REPLACE FUNCTION fh_event_asked(p_event bigint, p_person integer)
RETURNS boolean LANGUAGE sql STABLE AS $$
    SELECT EXISTS (SELECT 1 FROM rsvp_reminder_events re
                     JOIN rsvp_reminders rr ON rr.id = re.rsvp_reminder_id
                    WHERE re.fh_event_id = p_event AND rr.person_id = p_person)
        OR EXISTS (SELECT 1 FROM event_person_sees o
                    WHERE o.fh_event_id = p_event AND o.person_id = p_person
                      AND o.sees AND o.channel IS NOT NULL)
$$;

-- Waiting in 🪑 Reserves for this event (answer not considered — callers
-- add their own response test): a Reserve/Inactive row on one of the
-- event's teams or a way to see it (invite), no Regular row there, not a
-- coach of it, not asked yet.
CREATE OR REPLACE FUNCTION fh_event_reserve_waiting(p_event bigint, p_person integer)
RETURNS boolean LANGUAGE sql STABLE AS $$
    SELECT (EXISTS (SELECT 1 FROM fh_event_teams fet
                      JOIN team_persons tp ON tp.team_id = fet.team_id AND tp.removed_at IS NULL
                      JOIN squad_statuses ss ON ss.id = tp.squad_status_id AND ss.code IN ('inactive', 'standby')
                     WHERE fet.fh_event_id = p_event AND tp.person_id = p_person)
            OR fh_event_invited(p_event, p_person))
       AND NOT EXISTS (SELECT 1 FROM fh_event_teams fet
                         JOIN team_persons tp ON tp.team_id = fet.team_id AND tp.removed_at IS NULL
                         LEFT JOIN squad_statuses ss ON ss.id = tp.squad_status_id
                        WHERE fet.fh_event_id = p_event AND tp.person_id = p_person
                          AND (ss.code IS NULL OR ss.code NOT IN ('inactive', 'standby')))
       AND NOT EXISTS (SELECT 1 FROM fh_event_teams fet
                         JOIN team_coaches tc ON tc.team_id = fet.team_id AND tc.ended_at IS NULL
                         JOIN coaches co ON co.id = tc.coach_id
                        WHERE fet.fh_event_id = p_event AND co.person_id = p_person)
       AND NOT fh_event_asked(p_event, p_person)
$$;

-- 🎟 Call-up words (owner: "say we are calling them up").
UPDATE message_templates SET
       subject = '🎟 Call-up: {team} — {kind}[[ vs {opponent}]][[ on {when}]]',
       body = E'Hi {first},\n\nWe''re calling you up to play with {team}[[ (up from {from_team})]] — {kind}[[ vs {opponent}]][[ on {when}]].\n\nCan you make it? Tap the link below on your phone to sign in — no password needed — and set Going or Not Going:\n{link}\n\nThe link works for 72 hours. Reply anytime with questions.'
 WHERE kind = 'event_invite' AND tier = 'adult';
UPDATE message_templates SET
       subject = '🎟 Call-up: {team} — {kind}[[ vs {opponent}]][[ on {when}]]',
       body = E'Hi {first},\n\nWe''d like to call {child} up to play with {team}[[ (up from {from_team})]] — {kind}[[ vs {opponent}]][[ on {when}]].\n\nCan {child} make it? Tap the link below on your phone to sign in — no password needed — and set Going or Not Going for {child}:\n{link}\n\nThe link works for 72 hours. Reply anytime with questions.'
 WHERE kind = 'event_invite' AND tier = 'parent';
UPDATE message_templates SET
       body = 'Hi {first} — we''re calling you up to play with {team}: {kind}[[ vs {opponent}]][[ on {when}]]. Can you make it? Tap to sign in and set Going or Not Going (no password needed): {link}'
 WHERE kind = 'event_invite_sms' AND tier = 'adult';
UPDATE message_templates SET
       body = 'Hi {first} — we''d like to call {child} up to play with {team}: {kind}[[ vs {opponent}]][[ on {when}]]. Can {child} make it? Tap to sign in and set Going or Not Going (no password needed): {link}'
 WHERE kind = 'event_invite_sms' AND tier = 'parent';

UPDATE message_templates SET body = '🎟 Call up for this game'
 WHERE kind = 'contact_popup' AND tier = 'msg_callup';
