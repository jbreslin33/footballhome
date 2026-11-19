-- 1531 (2026-11-19) — Tier 2 reads "Reserves" (owner: "i guess we could use
-- regulars and reserves. that is liteteray what the reserves are for in
-- apsl" … "its fine as we flag anyone not really eligbilbe right?").
-- Words only; the status code stays 'standby' (mig 1530).
UPDATE message_templates SET body = replace(replace(body, '📞 Standby', '🪑 Reserves'), '📞 STANDBY', '🪑 RESERVES'), updated_at = now()
 WHERE tier IN ('team_status_standby', 'board_standby_h', 'sec_standby');
UPDATE message_templates SET body = '📣 Ask Reserves ({n})', updated_at = now() WHERE kind = 'event_center' AND tier = 'ask_standby';
UPDATE message_templates SET body = '{team} Reserves', updated_at = now() WHERE kind = 'person_standing' AND tier = 'roster_standby';
UPDATE squad_statuses SET display_name = 'Reserves' WHERE code = 'standby';
