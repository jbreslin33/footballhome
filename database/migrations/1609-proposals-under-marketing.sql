-- 📑 Proposals moves from ⚽ Football to 📣 Marketing (James 11/20 "why is
-- proposals not under like marketing lol its under football"). It sat on
-- Football only because it replaced the old 🏠 In-House pill (mig 1572).
-- Audience stays admin (the API is club/super only); last pill in Marketing.
UPDATE menu_pages SET group_code = 'marketing', sort_order = 5 WHERE code = 'proposals';
