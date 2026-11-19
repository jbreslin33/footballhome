-- 1572 (2026-11-19) — 📑 #proposals: one page for every club proposal.
--
-- Owner 11/19: "where is the proposals page on fh" → "we need a proposals
-- page".  Until now the only proposal was #in-house-proposal (mig 900), a
-- hand-built page with its own menu pill; the Erie Avenue turf pitch
-- proposal lived only in a Claude doc.
--
-- proposals = one row per proposal (the #proposals list).  A proposal with
-- its own hand-built page names it in `screen` (In-House keeps its page);
-- every other proposal is drawn from its proposal_sections rows at
-- #proposals/<code>.  Section body format (ProposalsScreen):
--   a line starting "- " is a bullet; lines starting "|" are a table
--   (first one = header, cells split by |); anything else is a paragraph;
--   **bold** and [text](https://…) work inside a line.
-- Page wording = message_templates kind 'proposals'.
--
-- The ⚽ Football menu pill becomes 📑 Proposals (it covers In-House too).

CREATE TABLE IF NOT EXISTS proposal_statuses (
    code        text PRIMARY KEY,
    label       text NOT NULL,
    icon        text NOT NULL,
    sort_order  int  NOT NULL
);
COMMENT ON TABLE proposal_statuses IS 'mig 1572: where a proposal stands (#proposals pill).';

INSERT INTO proposal_statuses (code, label, icon, sort_order) VALUES
    ('draft',    'Draft',    '📝', 1),
    ('sent',     'Sent',     '📨', 2),
    ('approved', 'Approved', '✅', 3),
    ('declined', 'Declined', '❌', 4)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS proposals (
    id          serial PRIMARY KEY,
    code        text NOT NULL UNIQUE,
    icon        text NOT NULL,
    title       text NOT NULL,
    summary     text NOT NULL,
    status_code text NOT NULL REFERENCES proposal_statuses(code),
    as_of       date NOT NULL,
    screen      text,
    sort_order  int  NOT NULL DEFAULT 100,
    is_active   boolean NOT NULL DEFAULT true,
    created_at  timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE proposals IS 'mig 1572: #proposals list; screen = its own hand-built page, else drawn from proposal_sections.';

CREATE TABLE IF NOT EXISTS proposal_sections (
    id          serial PRIMARY KEY,
    proposal_id int  NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
    sort_order  int  NOT NULL,
    heading     text NOT NULL,
    body        text NOT NULL,
    UNIQUE (proposal_id, sort_order)
);
COMMENT ON TABLE proposal_sections IS 'mig 1572: a proposal''s page, in order. Body: "- " bullet, "|" table row (first = header), else paragraph; **bold**, [text](url).';

INSERT INTO proposals (code, icon, title, summary, status_code, as_of, screen, sort_order) VALUES
    ('erie-avenue-turf', '🏟', 'Erie Avenue Turf Pitch',
     'Turf over the 76ers court at Lighthouse Sports Complex. $63,000–$113,000 base; PA DCNR round Jan 11 – Apr 30, 2027.',
     'draft', '2026-11-19', NULL, 1),
    ('in-house', '🏠', 'In-House Proposal',
     'Youth U8 and U10 in-house (Lighthouse blue vs white); one U12 travel team.',
     'draft', '2026-10-30', 'in-house-proposal', 2)
ON CONFLICT (code) DO NOTHING;

INSERT INTO proposal_sections (proposal_id, sort_order, heading, body)
SELECT p.id, v.o, v.h, v.b
  FROM proposals p
  JOIN (VALUES
    (1, 'Summary', $b$Lighthouse asks for about **$63,000–$113,000** to lay a synthetic turf mini-pitch over the existing 76ers basketball court at Lighthouse Sports Complex, 101 East Erie Avenue. The asphalt is already there, so there is no excavation, paving or drainage work: a low-risk build a funder can see finished in one season.
The pitch would be about 30 × 17 m (100 × 57 ft). It gives year-round small-sided soccer to the youth teams (U8–U12), free open play for neighbourhood kids, and futsal-style training for the men's and women's teams, who all now share grass that closes in wet weather and winter.$b$),

    (2, 'The site', $b$The court fits a turf mini-pitch of about **30 × 17 m (100 × 57 ft)** with no new paving. It sits at the west end of Lighthouse Field, inside its own fence (40.0083, -75.1263).
|Feature|Size (m)|Size (ft)|Area|How measured
|Painted basketball lines|28.6 × 15.2|94 × 50|4,700 sq ft|NBA standard; matches OpenStreetMap (28.3 × 14.9 m)
|Blue court surface, edge to edge|30.7 × 17.4|101 × 57|5,750 sq ft|Google Maps satellite, scale bar
|Fenced enclosure (court + grass strip)|~37 × 21|~122 × 68|~8,300 sq ft|Google Maps satellite, scale bar
Aerial measurements are within about ±5%. A tape measure and a look at the cracks and drainage come before any bid.
**Land.** The court is on The Light House's own parcel, 101 E Erie Ave (OPA 777705000), owned since 1943 and tax-exempt, about 14.8 acres. It is not City parkland.
**76ers.** The Sixers Youth Foundation lists the court as renovated in 2019 with The Lighthouse as partner. No terms are published.$b$),

    (3, 'Scope of work', $b$A turf-over-court system: clean and patch the asphalt, lay a drainable shock pad, then turf and infill on top. The court stays underneath, so it can be undone.
- **Prep the court.** Pressure-wash, fill cracks, grind lifted edges, check that water drains off.
- **Shock pad.** 15–25 mm drainable foam or rubber pad over the asphalt.
- **Turf.** Short-pile soccer/futsal turf (30–40 mm) with non-rubber infill (sand or cork).
- **Edges.** Aluminium or timber edge strip where turf meets fence.
- **Lines and goals.** Small-sided lines tufted in; two 4 × 2 m (12 × 6 ft) anchored goals.
- **Ball containment.** Taller netting behind the goals.
Add-alternates, priced separately so a funder can pick one up:
- **A1 Turf out to the fence (~36 × 20 m).** Stone base over the grass strip and east end, then turf.
- **A2 LED lights.** Two to four poles for evening play.
- **A3 Kickboards.** Low boards along the long sides.
- **A4 Storage box and benches.**$b$),

    (4, 'Budget', $b$Base pitch about **$63,000–$113,000** on 5,750 sq ft. Planning figures from published per-square-foot ranges, not quotes; two contractor bids replace them before any application.
|Line|Basis|Low|High
|Court prep (wash, crack fill, grind)|lump sum|$3,000|$8,000
|Drainable shock pad|5,750 sq ft × $2–$4|$11,500|$23,000
|Turf + non-rubber infill, installed|5,750 sq ft × $5–$8|$29,000|$46,000
|Edge strip|~95 m perimeter|$2,000|$4,000
|Two goals + nets, anchored|pair|$3,000|$6,000
|End ball netting|two ends|$5,000|$10,000
|Design, permit, mobilisation|lump sum|$4,000|$6,000
|Contingency|10%|$5,750|$10,300
|**Base total**||**~$63,000**|**~$113,000**

|Add-alternate|Basis|Low|High
|A1 Turf out to the fence|~2,550 sq ft × $18–$30|$46,000|$77,000
|A2 LED lights|2–4 poles|$60,000|$120,000
|A3 Kickboards|long sides|$8,000|$15,000
|A4 Storage box + benches|lump sum|$3,000|$6,000
Turf lasts about 8–10 years, so the plan sets aside about $5,000 a year for replacement.$b$),

    (5, 'Who it serves', $b$About **40 hours a week of soccer and open play**, all year. Grass at the complex closes after rain and through winter; turf drains in minutes.
|Group|Use|Hours a week
|Youth teams U8–U12 (57 kids on fall rosters, Nov 2026)|Weeknight training, small-sided games, winter sessions|12
|Free open play for neighbourhood kids|After school and weekends; no fee|15
|Men's and women's teams (83 players on four adult rosters)|Futsal-style technical training, winter fitness|6
|Schools and community partners nearby|Booked daytime and summer camp blocks|7
ZIP 19140: 53,385 people; median household income $36,226 (city $61,953); 37.3% below poverty (city 21.4%); 25.3% under 18 (city 21.2%). [ACS 2024 5-year, Census Reporter](https://censusreporter.org/profiles/86000US19140-19140/)
Reported to funders each year: hours of use, different players and how many are new, share of free hours (target half), wet/winter sessions saved, girls' participation.$b$),

    (6, 'Funding', $b$Stack PA DCNR's Park Rehabilitation and Development grant (round **Jan 11 – Apr 30, 2027**) with sponsors and the 76ers as named partner. DCNR awards are typically $100,000–$250,000 with a dollar-for-dollar match, so base + lights ($123,000–$233,000) fits their range.
|Source|Funds|Fit|Next step
|[PA DCNR C2P2 Park Rehab & Development](https://www.pa.gov/services/dcnr/apply-for-dcnr-park-rehabilitation-and-development-grants)|Public parks and recreation facilities|Strong: nonprofits eligible; must be open to the public|Call the DCNR Regional Advisor first
|[U.S. Soccer Foundation](https://ussoccerfoundation.org/programs/safe-places-to-play/)|Mini-pitches, ~$150,000 each (2026)|Weak for turf: hard-court only, 4,000–8,000 sq ft (ours 5,750). Strong for a hard-court pitch|info@ussoccerfoundation.org; "Suggest a Location" form
|[Sixers Youth Foundation](https://sixersyouthfoundation.org/renovated-courts-and-play-spaces/)|Court renovations; did this court in 2019|Partner, not a grant: they don't take unsolicited proposals|info@sixersyouthfoundation.org, 215-952-7000
|Philadelphia Soccer 2026 / City Rebuild|Mini-pitches ($2M legacy; Rebuild $3.5M for 15)|Legacy money probably spent; Rebuild worth asking|Ask both whether money is left
|[Musco + U.S. Soccer Foundation lighting](https://ussoccerfoundation.tfaforms.net/4871632)|Sports lighting|A2 only|Rolling: Mar 31, Jun 30, Sep 30, Dec 31
|Corporate sponsors|Naming and signage|Good for the match|Approach with the DCNR award letter
**Match.** DCNR's match can be cash or in-kind: in-house services, donated services, equipment use, volunteer labour (Grant Manual p.17). Volunteer hours count at the PA Independent Sector Volunteer Rate; meeting and admin time doesn't.$b$),

    (7, 'What DCNR requires', $b$From the [C2P2 Grant Manual 2026–27](https://elibrary.dcnr.pa.gov/GetDocument?docId=3491054&DocName=GrantManual.pdf):
- **Site control.** The applicant owns the site or holds a lease of at least 25 years. If the club applies rather than The Light House, it needs that lease.
- **Public for life.** The pitch stays open to the public for its useful life; no conversion without DCNR's written approval.
- **Applicant.** A 501(c)(3) registered with the PA Bureau of Charitable Organizations.
- **Paperwork.** Site drawings by a licensed design professional, PNDI receipt, notice letters to the City and County, match commitment letters, ADA access.
- **Turf.** The manual never mentions synthetic turf. First question for the Regional Advisor.$b$),

    (8, 'Upkeep', $b$The club takes on upkeep, about **$7,000 a year** with the replacement fund, from the club budget.
|Task|How often|Who|Yearly cost
|Blow off leaves, check edges and goal anchors|Weekly|Volunteers|$0
|Brush and top up infill|Monthly in season|Volunteers, hired brush|$500
|Deep clean and seam check|Yearly|Turf contractor|$1,500
|Turf replacement fund (8–10 year life)|Yearly|Club budget|$5,000$b$),

    (9, 'Timeline', $b$- **Dec 2026:** decide the applicant (The Light House or the club); talk to the Sixers Youth Foundation; tape-measure; two contractor bids.
- **Jan 2027:** call the DCNR Regional Advisor (turf? which fund?); collect letters of support and match commitments.
- **Jan 11 – Apr 30, 2027:** DCNR application window.
- **Fall 2027:** awards; line up sponsors for the match.
- **2028:** about 2 weeks to build on the existing court, then open.$b$),

    (10, 'Still to settle', $b$- Who applies: The Light House (owns the land) or the club (needs a 25-year lease).
- Turf, or a hard-court mini-pitch the U.S. Soccer Foundation would fund?
- Does the 2019 Sixers court deal limit covering it?
- Is turf over a court eligible for DCNR?
- Tape measure, crack and drainage check, two contractor bids.$b$)
  ) AS v(o, h, b) ON true
 WHERE p.code = 'erie-avenue-turf'
ON CONFLICT (proposal_id, sort_order) DO NOTHING;

-- The words around the page.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Proposals', v.l, 'proposals', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('title',     'Page title',                  '📑 Proposals', 1),
    ('subtitle',  'Under the page title',        'Club proposals: what we are asking for, and where each one stands.', 2),
    ('empty',     'No proposals yet',            'No proposals yet.', 3),
    ('as_of',     'Before the as-of date',       'As of', 4),
    ('missing',   'Proposal link that is gone',  'That proposal is not here any more.', 5)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'proposals' AND m.tier = v.t);

-- ⚽ Football: one 📑 Proposals pill (In-House opens from it).
INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens, href, new_tab, download)
VALUES ('proposals', 'football', 'Proposals', '📑', 'admin', 4, '{proposals,in-house-proposal}', NULL, false, false)
ON CONFLICT (code) DO NOTHING;
UPDATE menu_pages SET is_active = false WHERE code = 'in-house-proposal';
