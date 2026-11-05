-- 1079: NEEDS ONBOARD cards on the #teams Team pill lead with when he
-- registered and whether a welcome went out (owner 2026-11-05: "show date
-- they registered for needs onboard players atleast so i know if i sent them
-- anything or if they just need to be dropped because they are ghost").
-- Dates come from person_la_memberships.la_registered_at (laRegisteredAt on
-- every board row) and the 👋 welcome log.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', v.l, 'roster_sheet', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('Team pill NEEDS ONBOARD — registered ({date}, {ago})', 'board_onboard_registered', '📝 Registered {date} · {ago}', 970),
    ('Team pill NEEDS ONBOARD — no registration date',       'board_onboard_reg_unknown', '📝 Registration date unknown', 971),
    ('Team pill NEEDS ONBOARD — welcome sent ({date}, {channel})', 'board_onboard_welcomed', '👋 Welcome sent {date}[[ by {channel}]]', 972),
    ('Team pill NEEDS ONBOARD — no welcome yet',              'board_onboard_not_welcomed', '👋 No welcome sent', 973)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.t);
