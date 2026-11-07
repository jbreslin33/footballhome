-- 1152: youth dues notices name the real consequence (owner 2026-11-06:
-- "kids we don't do it we just have to cut them. parents who don't pay
-- almost always soft quit i think").  The plain behind_N tiers now go only
-- to members outside the selection rule (Men + Women get *_selection since
-- mig 1149/1151) — i.e. youth.  There is no practice/game block (off since
-- 10/3), so "not being eligible for practice and games, or even" goes; the
-- release from the team roster stays.
UPDATE message_templates
   SET body = replace(body, 'not being eligible for practice and games, or even release from the team roster',
                            'release from the team roster'),
       updated_at = now()
 WHERE kind IN ('payment_notice_email', 'payment_notice_sms')
   AND tier IN ('behind_1', 'behind_2', 'behind_3')
   AND is_active
   AND body LIKE '%not being eligible for practice and games, or even release from the team roster%';
