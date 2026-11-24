-- 1764 (2026-11-23): 🏟️ Club-wide — every cost beyond a competition, its own page in the Money menu.
--
-- Owner 2026-11-23: "now we have groups, competitions. do we need more costs?
-- like club wide that are beyond 'comps'? … would we call it club wide? …
-- uniforms should be done per member 1x … club wide i would think … its
-- beyond a comp".
--
-- #club-wide lists the budget_lines of the year (practice coaching, kits per
-- new member, equipment, field upkeep) by kind of cost: price × how many =
-- amount, who it is for, and the total.  Read-only; it shows the rows every
-- report already reads.  Menu row + wording; no numbers change.

BEGIN;

UPDATE menu_pages SET sort_order = 7 WHERE code = 'invoices' AND group_code = 'money';
INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens)
VALUES ('club-wide', 'money', 'Club-wide', '🏟️', 'admin', 6, '{club-wide}')
ON CONFLICT (code) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Finances', 'Finances — club-wide: ' || v.what, 'finances', v.tier, v.body, v.n, true
  FROM (VALUES
    ('title',            'cw_title',      'Club-wide', 970),
    ('note',             'cw_note',       'Every cost beyond a competition: practice coaching, kits, equipment and the field. Price × how many; the total is worked out, never typed.', 971),
    ('none',             'cw_none',       'No club-wide costs yet.', 972),
    ('column: for',      'cw_col_for',    'For', 973),
    ('for everyone',     'cw_everyone',   'Everyone', 974),
    ('estimate tag',     'cw_estimate',   'estimate', 975),
    ('unit: once',       'cw_unit_fixed', 'once a year', 976)
  ) v(what, tier, body, n)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'finances' AND m.tier = v.tier);

INSERT INTO schema_migrations (filename) VALUES ('1764-club-wide-page.sql') ON CONFLICT DO NOTHING;
COMMIT;
