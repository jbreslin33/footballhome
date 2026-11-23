-- 1741 (2026-11-23) — SafeSport step: numbered instructions (owner: "is there
-- instructions?").  The popup shows a step's how text line by line.
-- Sources: U.S. Soccer's SafeSport guide (log in or sign up at
-- learning.ussoccer.com), Eastern New York's instructions (the core course
-- is "SafeSport Trained – U.S. Soccer Federation"), USASA SafeSport policy
-- (a current annual certificate for adults on a team with a U18 player).
UPDATE onboarding_steps SET how = E'Why: U.S. Soccer requires SafeSport training for every adult on a team that has a player under 18 — both our men''s teams do.\n1. Tap Take the course › and log in at learning.ussoccer.com. No account? Tap Sign up — use your own name and email.\n2. Find the course "SafeSport Trained – U.S. Soccer Federation" and start it. That is the one that counts the first time.\n3. Finish it — about 90 minutes. You can stop and pick it up again later.\n4. Download your certificate (or screenshot it so your name and the date show).\n5. Come back here and tap 📎 Upload.\nIt is good for one year. After that you take the short SafeSport Refresher and upload the new certificate. Already did SafeSport somewhere else this year? Just upload that certificate.'
 WHERE code = 'safesport';
