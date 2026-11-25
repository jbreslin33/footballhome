-- 1919 (2026-11-25): the clip bar names the man he must stay in pressing distance of, not just him; on the pitch the
-- two are ringed and joined (line + metres) the whole clip. Owner 11/25: "we need to make it clear who they are
-- staying within pressing dist of right? with both players connected with a line and dist measure?"
UPDATE message_templates SET body = '#{num} {name} ({label}) → his man #{mnum} {mname}, {min}''',
       label = 'Concept viewer — clips: who ({num}, {name}, {label}, {mnum}, {mname}, {min})'
 WHERE kind = 'taxonomy' AND tier = 'clip_who';
