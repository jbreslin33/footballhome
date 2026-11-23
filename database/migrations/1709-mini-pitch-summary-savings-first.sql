-- 🏟 Turf Mini Pitch: the summary leads with the savings, then the reversible
-- basketball court and the tiles (James 11/23 "it should also begin with the
-- savings because it is key to how this project could be cost effective.
-- then right away with the reversbile basketabll court and getting rid of or
-- storing the problematic tiles"). Same facts and figures as mig 1708.
BEGIN;
UPDATE proposal_sections s SET body = $b$From James Breslin. To Edwin Desamour, Executive Director, Julian Makarechi, Deputy Director, and Anita Lyndaker, Grant Writer, at Lighthouse.
This is the mini pitch proposal: roll-up synthetic turf on a shock pad on the 76ers court at Lighthouse Sports Complex, 101 East Erie Avenue.
- **It saves about $105,000.** The flat concrete slab and the lights are already there. Building the same pitch on open ground would mean digging, pouring a slab and putting up lights first. That is what makes this project cost effective.
- **The basketball court stays.** The turf rolls up. Basketball is generally not played outside from November to March, but soccer is, so the turf goes down for those months. In good weather the grounds crew rolls it up and the court is used for basketball again. The hoops stay up throughout.
- **It deals with the problem tiles.** Either the tiles go for good: the concrete slab is painted for basketball, and there is nothing to lay back, keep up or store. Or the tiles are lifted, stored on site and laid back each time.
- **It rests the grass field and extends training** into late fall, winter and early spring.
**What it costs**
The turf and shock pad cost **$16,835** (low-end turf inside the poles, laid by us) to **$64,790** (high-end turf over the whole slab, laid by a contractor). Netting, a fence, kickboards, pole padding and goals are add-ons, each priced on its own. Prices are estimates from published figures, not quotes.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;
COMMIT;
