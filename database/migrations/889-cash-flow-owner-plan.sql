-- 889 (2026-10-30) — #cash-flow: the owner's plan for the months ahead.
--
-- Owner: "november expenses. what is in gcal. assume no league fees or
-- purchases except another 3 orders of paint", "december no expenses except
-- coach pay from gcal".  Three orders are priced at the latest order, $122.21.
-- Months after December follow December until the owner says otherwise.

ALTER TABLE cash_flow_policies ADD COLUMN IF NOT EXISTS refs_through DATE;
UPDATE cash_flow_policies SET refs_through = '2026-11-30' WHERE club_id = 134;
ALTER TABLE cash_flow_policies ALTER COLUMN refs_through SET NOT NULL;

CREATE TABLE IF NOT EXISTS cash_flow_planned (
    id     SERIAL PRIMARY KEY,
    ym     TEXT NOT NULL CHECK (ym ~ '^\d{4}-\d{2}$'),
    label  TEXT NOT NULL,
    amount NUMERIC(10,2) NOT NULL
);
COMMENT ON TABLE cash_flow_planned IS 'mig 889: purchases the owner expects in a month ahead, counted in #cash-flow money out.';
INSERT INTO cash_flow_planned (ym, label, amount)
SELECT '2026-11', 'Field paint, 3 orders', 366.63
 WHERE NOT EXISTS (SELECT 1 FROM cash_flow_planned WHERE ym = '2026-11' AND label = 'Field paint, 3 orders');

UPDATE message_templates SET body = 'Ahead: money in is members × {rate} a month, less {fee}% LeagueApps fees (last 12 months); pickup memberships are not projected. Money out is coach pay from the calendar at each coach''s rate, referee fees for home games on the calendar through {through}, and planned purchases. League fees and other purchases are not projected.'
 WHERE kind = 'cash_flow' AND tier = 'ahead_note';
