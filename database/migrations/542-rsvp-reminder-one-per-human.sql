-- 542 (2026-10-07) — one RSVP reminder per human.
-- Owner: "for parents that have multiple kids we need to make it easy for
-- them with rsvps and rsvp reminders" / "i don't want to send them 2x" /
-- "same with coaches who also play on team".
--
-- The per-player reminder (mig 363/538) now covers everything its
-- recipient answers for: their own open events in every hat (player,
-- coach, staff) and every child of theirs on a board team.  Reminding any
-- one of them sends ONE text or email, logged against each person it
-- covered so every sibling's card on #rsvps dims.  When more than one
-- person has something open the message uses tier 'multi' with a line
-- each ({per_child} from tier child_line; the recipient themself is the
-- you_word); one child, or one adult, still gets 'parent' / 'adult'.
CREATE OR REPLACE FUNCTION pg_temp.set_rr(p_tier text, p_label text, p_subject text, p_body text, p_sort int)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  UPDATE message_templates SET body = p_body, subject = p_subject, label = p_label, sort_order = p_sort,
                               is_active = true, updated_at = now()
   WHERE kind = 'rsvp_reminder' AND tier = p_tier;
  IF NOT FOUND THEN
    INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
    VALUES ('RSVP', p_label, 'rsvp_reminder', p_tier, p_subject, p_body, p_sort, true, false, false);
  END IF;
END $$;

SELECT pg_temp.set_rr('multi', 'RSVP reminder — several people in one household ({first} {children} {missing} {per_child} {link} {deadline} {fine_note} {travel} {sender})',
  'Lighthouse 1893 — please set your family''s availability',
E'Hi {first} — {children} are missing {missing}:\n{per_child}\nIt really helps the team to know who''s available. Going or Not Going, one tap for everyone: {link}[[\n\n{deadline}]][[\n\n{fine_note}]][[\n\n{travel}]]\n\n— {sender}, Lighthouse 1893', 12);
SELECT pg_temp.set_rr('child_line', 'One line of the household list ({child} {missing})', NULL, '• {child}: {missing}', 64);
SELECT pg_temp.set_rr('and_word',   'Joining word for the last name in a list', NULL, 'and', 65);
SELECT pg_temp.set_rr('you_word',   'How the recipient is named in their own line', NULL, 'you', 66);
