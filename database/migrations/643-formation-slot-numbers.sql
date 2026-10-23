-- 643 (2026-10-22) — the traditional shirt NUMBER of each formation slot
-- (club data; the game shows it on the shirts).
--
-- James: "put names video game style last name over player and their
-- position number like 9 for striker etc". formations.positions_json's
-- position_id is not a shirt number (its CB = 3 is positions.id 3 "Left
-- Back"), so the numbering gets its own rows, one per formation slot, in
-- the classic WM-descended convention: 1 keeper, 2 right back, 3 left
-- back, 4 + 5 centre backs, 6 holding mid, 8 box-to-box, 10 playmaker,
-- 7 right wing, 9 striker, 11 left wing.

CREATE TABLE IF NOT EXISTS formation_slot_numbers (
    formation_code TEXT NOT NULL,
    slot           SMALLINT NOT NULL CHECK (slot BETWEEN 1 AND 11),
    shirt_number   SMALLINT NOT NULL CHECK (shirt_number BETWEEN 1 AND 99),
    PRIMARY KEY (formation_code, slot)
);
COMMENT ON TABLE formation_slot_numbers IS 'Traditional shirt number per formation slot (mig 643), e.g. 4-3-3 slot 10 (ST) = 9.';

INSERT INTO formation_slot_numbers (formation_code, slot, shirt_number) VALUES
 -- 4-3-3: GK RB CB CB LB CM CM CM RW ST LW
 ('4-3-3', 1, 1), ('4-3-3', 2, 2), ('4-3-3', 3, 4), ('4-3-3', 4, 5), ('4-3-3', 5, 3),
 ('4-3-3', 6, 6), ('4-3-3', 7, 8), ('4-3-3', 8, 10), ('4-3-3', 9, 7), ('4-3-3', 10, 9), ('4-3-3', 11, 11),
 -- 4-2-3-1: GK RB CB CB LB CDM CDM RW CAM LW ST
 ('4-2-3-1', 1, 1), ('4-2-3-1', 2, 2), ('4-2-3-1', 3, 4), ('4-2-3-1', 4, 5), ('4-2-3-1', 5, 3),
 ('4-2-3-1', 6, 6), ('4-2-3-1', 7, 8), ('4-2-3-1', 8, 7), ('4-2-3-1', 9, 10), ('4-2-3-1', 10, 11), ('4-2-3-1', 11, 9)
ON CONFLICT (formation_code, slot) DO NOTHING;
