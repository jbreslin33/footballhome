-- 1554 (2026-11-19) — #teams sort pill 🚩 Behind → 🤝 Committed, most committed first.
--
-- Owner: "its not working becaue erick david is both and he should be last
-- right?" → "maybe the pill should say 'commited' and then we sort asc" →
-- "so most commited".  Erick: owes $35 and last answered 11/9 (yellow).
--   · order = the owner's list: up to date → behind on RSVP → behind on
--     dues → behind on both (mig 1552 had it worst-first)
--   · behind on RSVP = anything not green (yellow counts; was red only)
--   · the pill id is 'committed'; the count line tc_tally is unchanged
UPDATE message_templates SET tier = 'board_sort_committed', body = '🤝 Committed',
       label = 'Sort pill: most committed first (RSVP + dues)'
 WHERE kind = 'roster_sheet' AND tier = 'board_sort_behind';
