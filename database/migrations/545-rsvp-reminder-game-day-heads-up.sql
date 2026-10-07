-- 545 (2026-10-07) — the individual RSVP reminder as a game-day heads-up.
-- Owner: "what if we ONLY sent the card to parents who didn't respond and
-- let them know that as a heads up that only they see it … like a game
-- day about to go out heads up your not on it yet!"
--
-- The per-player reminder already goes only to people with something
-- unanswered; now it says why it matters: the game day card is about to
-- go out to the team and they are not on it yet.  A parent is told that
-- just they get this and the team's card shows only how many have not
-- answered (youth sections: club_sections.roll_call_no_response_names =
-- false).  On the card itself, opened from their own link, the count box
-- names the viewer's own child (tier none_count_mine) — nobody else's.
CREATE OR REPLACE FUNCTION pg_temp.set_rr(p_kind text, p_tier text, p_body text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  UPDATE message_templates SET body = p_body, updated_at = now() WHERE kind = p_kind AND tier = p_tier;
END $$;

SELECT pg_temp.set_rr('rsvp_reminder', 'adult',
E'Hi {first} — the game day roll call is about to go out to the squad and you''re not on it yet ({missing}). Going or Not Going, one tap — and see who''s in: {link}[[\n\n{deadline}]][[\n\n{fine_note}]][[\n\n{travel}]]\n\n— {sender}, Lighthouse 1893');

SELECT pg_temp.set_rr('rsvp_reminder', 'parent',
E'Hi {first} — the game day card is about to go out to the team and {child} isn''t on it yet ({missing}). Just you get this heads-up; the team only sees how many haven''t answered, not who. Going or Not Going, one tap: {link}[[\n\n{deadline}]][[\n\n{travel}]]\n\n— {sender}, Lighthouse 1893');

SELECT pg_temp.set_rr('rsvp_reminder', 'multi',
E'Hi {first} — the game day card is about to go out and {children} aren''t on it yet ({missing}):\n{per_child}\nJust you get this heads-up; the team only sees how many haven''t answered, not who. Going or Not Going, one tap for everyone: {link}[[\n\n{deadline}]][[\n\n{fine_note}]][[\n\n{travel}]]\n\n— {sender}, Lighthouse 1893');

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'RSVP', 'Card — unanswered count naming the viewer''s own ({n} {names})', 'rsvp_roll_call', 'none_count_mine', NULL,
       '{n} still to answer — including {names}', 44, true, false, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'rsvp_roll_call' AND tier = 'none_count_mine');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'RSVP', 'Card — joining word for the viewer''s own names', 'rsvp_roll_call', 'and_word', NULL, 'and', 45, true, false, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'rsvp_roll_call' AND tier = 'and_word');
