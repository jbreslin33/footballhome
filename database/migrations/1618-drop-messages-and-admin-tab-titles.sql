-- 🧹 #messages loses its page title + subtitle like every other screen (mig
-- 1617; James 11/20 "this needs to be removed on entire site" + "i don't like
-- old code laying around ever"). These two rows (mig 1597) fed only that header.
DELETE FROM message_templates WHERE kind = 'messages_page' AND tier IN ('title', 'subtitle');
