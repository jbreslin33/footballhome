-- 🏟 Erie Avenue turf proposal: the U.S. Soccer Foundation row still quoted
-- the old pole-to-pole turf area (5,510 sq ft). Since mig 1651 the turf is
-- layout B about 5,180 sq ft or layout A 5,890 sq ft.
UPDATE proposal_sections s SET body = replace(s.body, '(ours 5,510)', '(ours 5,180–5,890)')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 6;
