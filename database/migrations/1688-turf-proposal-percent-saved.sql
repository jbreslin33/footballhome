-- 🏟 Erie Avenue turf proposal: the percentage saved against building from
-- scratch (James 11/23 "so you can show what % is saved from from scrath").
-- % = $105,340 ÷ from-scratch cost: 79 / 73 / 70 / 62 / 58 / 54.
BEGIN;
UPDATE proposal_sections s SET body =
  replace(replace(replace(replace(replace(replace(
  replace(replace(replace(replace(replace(replace(s.body,
  '|$133,830|$105,340', '|$133,830|$105,340 (79%)'),
  '|$144,190|$105,340', '|$144,190|$105,340 (73%)'),
  '|$149,515|$105,340', '|$149,515|$105,340 (70%)'),
  '|$171,051|$105,340', '|$171,051|$105,340 (62%)'),
  '|$182,551|$105,340', '|$182,551|$105,340 (58%)'),
  '|$194,941|$105,340', '|$194,941|$105,340 (54%)'),
  'Built from scratch: $133,830. Saved: **$105,340**.', 'Built from scratch: $133,830. Saved: **$105,340, 79%** of that.'),
  'Built from scratch: $144,190. Saved: **$105,340**.', 'Built from scratch: $144,190. Saved: **$105,340, 73%** of that.'),
  'Built from scratch: $149,515. Saved: **$105,340**.', 'Built from scratch: $149,515. Saved: **$105,340, 70%** of that.'),
  'Built from scratch: $171,051. Saved: **$105,340**.', 'Built from scratch: $171,051. Saved: **$105,340, 62%** of that.'),
  'Built from scratch: $182,551. Saved: **$105,340**.', 'Built from scratch: $182,551. Saved: **$105,340, 58%** of that.'),
  'Built from scratch: $194,941. Saved: **$105,340**.', 'Built from scratch: $194,941. Saved: **$105,340, 54%** of that.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;
DO $$
DECLARE b text; n int;
BEGIN
  SELECT s.body INTO b FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code = 'erie-avenue-turf' AND s.sort_order = 4;
  n := (length(b) - length(replace(b, '%** of that.', ''))) / length('%** of that.');
  IF n <> 6 THEN RAISE EXCEPTION 'turf proposal: % of 6 package blocks carry the percentage', n; END IF;
  n := (length(b) - length(replace(b, '%)', ''))) / 2;
  IF n <> 6 THEN RAISE EXCEPTION 'turf proposal: % of 6 overview rows carry the percentage', n; END IF;
END $$;
COMMIT;
