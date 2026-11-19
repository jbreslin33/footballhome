-- 1564 (2026-11-19) — Undo mig 1465: the three U13s are off tonight's U15+ / men practice.
-- Owner: "wait why is ashten griffin listed" "for practice tonight" "and
-- dior" → "they don't belong in u15 and men lol. they are now with the u12
-- etc".  Mig 1465 (11/18) invited Ashten Griffin-Tull, Zane Stone and Dior
-- Evans-Diarra to the Thu 11/19 7 PM practice (fh_event 75821984) after the
-- 5:30 U13–U16 one was cancelled.  sees = false keeps the record and hides
-- it; Zane's "no" stays on the event, harmless.
UPDATE event_person_sees
   SET sees = false, note = note || ' — removed 11/19 (mig 1564): with the U12s now'
 WHERE fh_event_id = 75821984 AND person_id IN (22465, 22664, 22690) AND sees;
