-- 🏟 Erie Avenue turf proposal: two of its open questions answered from
-- published sources (James 11/23 "continue with turf proposal").
--
-- 1. Option 2 was priced on indoor rolls. Their own pages rule them out for an
--    open slab: ATX Turf "This turf does not have drainage holes", Turf
--    Factory Direct "Perforations: No", both sold as indoor turf. Option 2 is
--    now priced on the two Practice Sports 5 mm padded rolls listed for indoor
--    or outdoor use (Triple Play $4.20, SportScape IV $4.81 per sq ft, read
--    11/23): turf $23,140–$26,500, all-in ~$36,500–$52,300 (was
--    ~$29,700–$52,500). Neither page says whether the backing drains, so that
--    stays a question for the seller.
-- 2. "Is turf eligible for DCNR?" DCNR's 2026 grants list (Oct 7, 2026) gives
--    Philadelphia Parks & Recreation $1,745,000 for Chew Playground including
--    "installation of artificial turf surfacing". Turf is funded; turf laid
--    over a court, and roll-up turf, is still a question for the advisor.

BEGIN;

UPDATE proposals SET as_of = '2026-11-23' WHERE code = 'erie-avenue-turf';

-- Budget
UPDATE proposal_sections s SET body = replace(replace(replace(s.body,
  $a$|2 New padded roll-out turf|Yes|New 5 mm foam-backed sports turf; volunteers lay it|$3.09–$4.85 ([ATX Turf](https://atxturf.com/product/5mm-padded-nylon-turf/), [Turf Factory Direct](https://turffactorydirect.com/product/tfd-sportmax-5mm/), [Practice Sports](https://practicesports.com/product-category/baseball-softball/turf/turf-by-the-foot/))|$17,030–$26,720$a$,
  $b$|2 New padded roll-out turf, outdoor-rated|Yes|New 5 mm foam-backed sports turf sold for indoor or outdoor use, UV-stabilised; volunteers lay it|$4.20–$4.81 (Practice Sports [Triple Play](https://practicesports.com/product/triple-play-48-oz-artificial-turf/), [SportScape IV](https://practicesports.com/product/sportscape-iv-sports-field-turf/))|$23,140–$26,500$b$),
  $a$Options 1 and 2 are sold as indoor turf. Outdoors they need a UV-stable, perforated (draining) version, which may cost more: ask each seller.$a$,
  $b$Option 2 is priced on turf its seller lists for indoor or outdoor use. The cheaper indoor rolls ($3.09–$3.99 a sq ft, [ATX Turf](https://atxturf.com/product/5mm-padded-nylon-turf/), [Turf Factory Direct](https://turffactorydirect.com/product/tfd-sportmax-5mm/)) have no drainage holes, so they are out. The sellers of options 1 and 2 don't say whether the backing drains: ask before buying, because foam-backed turf with no holes holds water on a slab.$b$),
  $a$|2 New padded roll-out|~$29,700|~$52,500$a$,
  $b$|2 New padded roll-out, outdoor-rated|~$36,500|~$52,300$b$)
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

-- Funding
UPDATE proposal_sections s SET body = replace(s.body, '($20,100–$52,500)', '($20,100–$52,300)')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 6;

-- What DCNR requires
UPDATE proposal_sections s SET body = replace(s.body,
  $a$- **Turf.** The manual never mentions synthetic turf. First question for the Regional Advisor.$a$,
  $b$- **Turf.** The manual never mentions synthetic turf, but DCNR pays for it: the 2026 round gave Philadelphia Parks & Recreation $1,745,000 for Chew Playground, including "installation of artificial turf surfacing" ([2026 grants list](https://elibrary.dcnr.pa.gov/PDFProvider.ashx?action=PDFStream&docID=11331800&chksum=&revision=0&docName=2026_C2P2_Grants_List&nativeExt=pdf&PromptToSave=False&Size=248221&ViewerMode=2&overlay=0)). That was a City field. Turf laid over a court, and turf that rolls up, are still questions for the Regional Advisor.$b$)
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 7;

-- Still to settle
UPDATE proposal_sections s SET body = replace(replace(s.body,
  $a$- Outdoor-rated versions and prices for options 1 and 2.$a$,
  $b$- Do the option 1 and 2 turfs drain? Ask Arena Warehouse and Practice Sports.$b$),
  $a$- Is turf over a court eligible for DCNR?$a$,
  $b$- Is turf over a court, and roll-up turf, eligible for DCNR? (Turf itself is: Chew Playground, 2026.)$b$)
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 10;

-- Every replace must have landed.
DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code = 'erie-avenue-turf' AND (
        (s.sort_order = 4  AND s.body LIKE '%Triple Play%' AND s.body LIKE '%have no drainage holes%' AND s.body LIKE '%~$36,500|~$52,300%')
     OR (s.sort_order = 6  AND s.body LIKE '%($20,100–$52,300)%')
     OR (s.sort_order = 7  AND s.body LIKE '%Chew Playground%')
     OR (s.sort_order = 10 AND s.body LIKE '%turfs drain?%' AND s.body LIKE '%Chew Playground, 2026%'));
  IF n <> 4 THEN RAISE EXCEPTION 'turf proposal: % of 4 sections updated', n; END IF;
END $$;

COMMIT;
