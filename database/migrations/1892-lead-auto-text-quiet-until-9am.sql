-- 1892: lead auto first-text waits until 9 AM Eastern, not 8 AM.
-- Owner 2026-11-25: "i think 8am too early lol" · "i think for txt 9am or 10am?"
-- Overnight leads (21:00–09:00 America/New_York) now get their first text at 9 AM.
UPDATE lead_auto_text_policy SET quiet_until = '09:00' WHERE id = 1;
