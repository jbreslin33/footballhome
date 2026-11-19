-- 1534 (2026-11-19) — 🎓 the onboarding box names each step still to do
-- (owner 11/19, as Victor: "why does victor say 6 of 0 left lol. it should
-- show each one he has to do?").  "6 of 0" = the band's own {total} token
-- (the RSVP count) overwrote the onboarding total.  Then "or should it show
-- just that he has onboarding to do and then he clicks there and it takes
-- him to … popup": the box reads "⛔ Onboarding — 6 to do [Finish ›]" and
-- the popup lists each step (as the RSVP box does).  short_label is kept
-- for the box's tooltip ({list}).
ALTER TABLE onboarding_steps ADD COLUMN IF NOT EXISTS short_label text;
UPDATE onboarding_steps s SET short_label = v.short_label
  FROM (VALUES ('pa_criminal', 'PA criminal'), ('child_abuse', 'Child abuse'), ('fbi_receipt', 'FBI prints'),
               ('fbi_result', 'FBI results'), ('nsor', 'NSOR'), ('photo_id', 'Photo ID'),
               ('w9', 'W-9'), ('direct_deposit', 'Direct deposit')) AS v(code, short_label)
 WHERE s.code = v.code AND s.short_label IS NULL;
UPDATE message_templates SET body = '⛔ Onboarding — {left} to do', updated_at = now()
 WHERE kind = 'event_center' AND tier = 'seg_onboarding';
