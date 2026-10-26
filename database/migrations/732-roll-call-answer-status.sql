-- 732 (2026-10-26) — the roll call card tells each viewer where they
-- stand, right under the event line.  Owner: "make sure it says your
-- going all set or your not going all set or action needed."
-- One line per household row over its buttons: self wording for the
-- viewer, {name} wording for a kid.  Public rows, read by rollcall.html.
CREATE OR REPLACE FUNCTION pg_temp.set_tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  UPDATE message_templates SET body = p_body, label = p_label, sort_order = p_sort, is_active = true, is_public = true, updated_at = now()
   WHERE kind = p_kind AND tier = p_tier;
  IF NOT FOUND THEN
    INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
    VALUES ('RSVP', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, false, true);
  END IF;
END $$;
SELECT pg_temp.set_tpl('rsvp_roll_call', 'status_yes_self',  'Card — viewer answered Going',          '✅ You''re going — all set', 60);
SELECT pg_temp.set_tpl('rsvp_roll_call', 'status_no_self',   'Card — viewer answered Not going',      '❌ You''re not going — all set', 61);
SELECT pg_temp.set_tpl('rsvp_roll_call', 'status_none_self', 'Card — viewer has not answered',        '⚠️ Action needed — tap Going or Not going', 62);
SELECT pg_temp.set_tpl('rsvp_roll_call', 'status_yes_other', 'Card — kid answered Going ({name})',    '✅ {name} is going — all set', 63);
SELECT pg_temp.set_tpl('rsvp_roll_call', 'status_no_other',  'Card — kid answered Not going ({name})','❌ {name} is not going — all set', 64);
SELECT pg_temp.set_tpl('rsvp_roll_call', 'status_none_other','Card — kid has not answered ({name})',  '⚠️ Action needed for {name} — tap Going or Not going', 65);
