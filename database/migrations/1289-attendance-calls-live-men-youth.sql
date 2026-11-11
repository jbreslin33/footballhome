-- 1289 (2026-11-11): 📞 attendance calls go LIVE for Men + Youth (mig 1277
-- shipped test mode: every call rang James).  Owner: "are victor and luke
-- getting called? i am … i should get call for men as coach. you have luke
-- and victor numbers."  Live = the practice's Going coaches are rung.
-- Women stay test mode with no test person, so nobody is rung for them
-- until the owner says so.

UPDATE attendance_call_policies SET live = true WHERE category IN ('mens', 'boys', 'girls');
UPDATE attendance_call_policies SET test_person_id = NULL WHERE category = 'womens';

INSERT INTO schema_migrations (filename) VALUES ('1289-attendance-calls-live-men-youth.sql') ON CONFLICT DO NOTHING;
