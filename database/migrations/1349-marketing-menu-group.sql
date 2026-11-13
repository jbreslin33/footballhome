-- 📣 Marketing gets its own main-menu button (owner 11/13: "marketing
-- either needs its own button on main or a button under club"; "club
-- takes us to marketing-home that seems off"). Until now Marketing was a
-- pill inside ⚙️ Club, so Club reopened marketing-home for anyone whose
-- last Club page was a marketing screen.
--
-- New group between Leagues and Club; pages (pills):
--   🏠 Home   marketing-home + the socials/flyers screens it opens
--   📱 Ads    #ad-preview — live ads first, with graphic, text and stats
--   📋 Leads  #leads + #leads-analytics
-- Audience stays 'marketing' (marketing role + admins).

BEGIN;

INSERT INTO menu_groups (code, label, icon, sort_order) VALUES
    ('marketing', 'Marketing', '📣', 6)
ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, icon = EXCLUDED.icon, sort_order = EXCLUDED.sort_order;

UPDATE menu_groups SET sort_order = 7 WHERE code = 'club';

UPDATE menu_pages
   SET group_code = 'marketing', label = 'Home', icon = '🏠', sort_order = 1,
       screens = '{marketing-home,social-schedule,holiday-posts,promo-posts,content-posts,flyers,match-social}'
 WHERE code = 'marketing';

INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens) VALUES
    ('ad-preview', 'marketing', 'Ads',   '📱', 'marketing', 2, '{ad-preview}'),
    ('leads',      'marketing', 'Leads', '📋', 'marketing', 3, '{leads,leads-analytics}')
ON CONFLICT (code) DO UPDATE SET group_code = EXCLUDED.group_code, label = EXCLUDED.label,
    icon = EXCLUDED.icon, audience = EXCLUDED.audience, sort_order = EXCLUDED.sort_order,
    screens = EXCLUDED.screens, is_active = true;

COMMIT;
