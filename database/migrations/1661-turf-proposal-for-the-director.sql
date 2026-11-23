-- 🏟 Erie Avenue turf proposal: it goes to the director to decide (James
-- 11/23 "so the proposal is going to our director let him decide"). The
-- closing section becomes his decision list. Status stays Draft until it is
-- actually sent.
BEGIN;
UPDATE proposal_sections s SET heading = 'For the director to decide',
  body = $b$- **Layout:** the whole slab cut around the poles (A), or inside the poles (B)?
- **Turf:** roll-up (court goes back to basketball) or permanent (the best)?
- **Package:** barebones, or with netting, fence, kickboards?
- **Hoops:** stay up during soccer, or come out?
- **Applicant:** The Light House (owns the land) or the club (needs a 25-year lease)?
Then one question for the DCNR Regional Advisor: is turf over a court, and roll-up turf, eligible? (Turf itself is: Chew Playground, 2026.)$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 10;
COMMIT;
