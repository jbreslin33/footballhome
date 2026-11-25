-- 🚀 APSL Pro proposal: using the name before sanctioning (James 11/24 "can
-- we call it apsl pro before we get sanctioning?" → "yes add it").  New
-- section 3 "The name before sanctioning" (old 3–16 move to 4–17); Steps
-- step 1 asks the APSL for the name.  NISA named itself and its clubs before
-- its February 2019 sanctioning and ran the 2025 "NISA Pro Cup" while
-- unsanctioned (press, already in Sources).  Legal points are ours.

BEGIN;

UPDATE proposal_sections s SET sort_order = s.sort_order + 100
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'apsl-pro' AND s.sort_order >= 3;
UPDATE proposal_sections s SET sort_order = s.sort_order - 99
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'apsl-pro' AND s.sort_order >= 103;

INSERT INTO proposal_sections (proposal_id, sort_order, heading, body)
SELECT p.id, 3, 'The name before sanctioning', $b$We can call it **APSL Pro** from the start: for the project, the league company and the pre-pro season. Three cautions.
- **The APSL owns its name.** "APSL Pro" uses the APSL brand, so we need the APSL board's written agreement. We want it anyway: the pro league sits on top of the APSL.
- **Say what it is, not what it will be.** A name with "Pro" in it is fine. Calling the league sanctioned is not. Until U.S. Soccer approves it: no "Division III", no "sanctioned by U.S. Soccer", no U.S. Soccer logo. Say **"applying for Division III sanctioning"**.
- **Above all when selling shares.** Any supporter-share offer made before sanctioning says plainly that the league is not sanctioned yet and may never be. Otherwise a buyer could say "Pro" misled them.
**Check with the APSL.** During the pre-pro season the clubs still play under amateur sanctioning. Ask whether the name, or paying players, causes trouble under those rules.
**It has been done before.** NISA used its name and announced its clubs before it was sanctioned in February 2019, and in 2025 it ran a "NISA Pro Cup" while its sanctioning was in doubt.$b$
  FROM proposals p WHERE p.code = 'apsl-pro'
ON CONFLICT (proposal_id, sort_order) DO NOTHING;

UPDATE proposal_sections s SET body = replace(s.body,
  '- **1 The APSL.** Put APSL Pro to the APSL board. The pro league sits on top of the APSL, not against it.',
  '- **1 The APSL.** Put APSL Pro to the APSL board, and ask for written agreement to use the name. The pro league sits on top of the APSL, not against it.')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'apsl-pro' AND s.heading = 'Steps';

COMMIT;
