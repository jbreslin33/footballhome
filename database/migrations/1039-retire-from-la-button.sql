-- 1039: ＋ from LA retired from the #teams Team pill (owner 2026-11-04:
-- "get rid of it. serves no purpose").  Every member is placed on a team
-- automatically (migs 902/1034/1038) and the player card's team menu adds
-- him to another team.  Its copy rows go inactive.

UPDATE message_templates SET is_active = false
 WHERE kind = 'roster_sheet' AND tier IN ('board_from_la_btn', 'board_from_la_search', 'board_from_la_on',
                                          'board_from_la_free', 'board_from_la_none');
