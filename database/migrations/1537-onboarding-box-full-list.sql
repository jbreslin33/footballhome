-- 1537 (2026-11-19) — 🎓 the band box names every step still to do (owner
-- 11/19 "i think it should show all his items at top? as a full
-- reminder?"): "⛔ Onboarding — 6 to do: PA criminal · Child abuse · FBI
-- prints · FBI results · NSOR · Photo ID [Finish ›]" ({list} = the short
-- names, onboarding_steps.short_label, mig 1534).
UPDATE message_templates SET body = '⛔ Onboarding — {left} to do: {list}', updated_at = now()
 WHERE kind = 'event_center' AND tier = 'seg_onboarding';
