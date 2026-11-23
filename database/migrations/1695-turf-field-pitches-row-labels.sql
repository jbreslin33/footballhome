-- 🏟 Turf Field Pitches: the overview rows read "5v5 (5v5)", "7v7 (7v7)",
-- "9v9 (9v9)". Say the format once.
UPDATE proposal_sections s SET body = replace(replace(replace(s.body, '|5v5 (5v5)|', '|5v5|'), '|7v7 (7v7)|', '|7v7|'), '|9v9 (9v9)|', '|9v9|')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'field-turf-pitches' AND s.sort_order = 4;
