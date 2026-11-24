-- 1858 (2026-11-24) — 🔺 Pyramid: the UPSL comes off the page.
-- Owner: "no need to draw somethnig on multiple sides. mls side shouod be apsl side. screw upsl lol".
-- Its 300-odd club names in one row made its side of the shape unreadable (drawn at a quarter
-- size) and it was the only other league on the fall–spring pyramid.  Switched off, not
-- deleted: the rows and the club lists read from Wikipedia (mig 1847) stay; to bring it back,
-- set is_active = true on the two rows.
UPDATE pro_leagues SET is_active = false
 WHERE name IN ('United Premier Soccer League', 'UPSL Division 1') AND is_active;
