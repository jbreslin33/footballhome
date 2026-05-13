-- Migration 038: Remove family_discount concept entirely
-- family_discount is replaced by is_child (boolean, 0 sessions required)

ALTER TABLE players DROP COLUMN IF EXISTS has_family_discount;
ALTER TABLE eligibility_policies DROP COLUMN IF EXISTS family_discount;
