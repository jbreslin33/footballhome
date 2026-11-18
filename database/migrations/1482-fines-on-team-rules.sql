-- 1482 (2026-11-18) — ⚖️ A player's live fines live on Team Rules.  Owner 11/18:
-- "even on team rules is where we can show live fines".
--
-- The Team Rules page opens with the fines section (FinesPanel: what they owe,
-- each fine, the rules, "I was there — dispute"); the separate Fines link
-- leaves the players' row, which reads  📋 Rules & fines · 🔔 Alerts … ↪ Sign out.
UPDATE message_templates SET body = '📋 Rules & fines', updated_at = now()
 WHERE kind = 'event_center' AND tier = 'qlink_rules';
