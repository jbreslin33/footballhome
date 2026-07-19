-- Migration 231: sim_scenarios seed for one_v_one_attack_defend (id=7)
--
-- Adds M3 Slice 34.1's 1v1 attack-vs-defend scenario. The scenario
-- declares a regulation 105x68 m pitch, two goal AABBs copied from
-- GoalDrillScenario, a human-claimable ST9 attacker starting on the
-- ball at x=-15, and an LCB Defender-kind AiController starting at
-- x=+10 with mark_target=SlotId{1}. The defender slot may carry an
-- ai_profile_source PersonId; ProfileStore loading is wired in Slice
-- 34.2, so this migration only registers the scenario catalog row.
--
-- Scenario ID contract: IDs are hand-managed integers >= 0. Each new
-- scenario adds a DB row here and runtime branches in Replay.cpp and
-- main.cpp. sim_matches.scenario_id FKs into this table.

BEGIN;

INSERT INTO sim_scenarios (id, code_id, display, description, milestone, enabled) VALUES
    (7, 'one_v_one_attack_defend', '1v1 Attack vs Defend',
     '105x68 m pitch with two goal AABBs. Slot 1 is a human-claimable '
     'ST9 attacker starting on the ball at x=-15 facing east. Slot 2 '
     'is an LCB Defender-kind AiController starting at x=+10 facing '
     'west with mark_target=slot 1 and optional ai_profile_source for '
     'Slice 34.2 ProfileStore loading. Success is carrying the ball '
     'into the east goal; reset timer is 20 seconds.',
     3, TRUE)
ON CONFLICT (code_id) DO NOTHING;

SELECT setval(
    pg_get_serial_sequence('sim_scenarios', 'id'),
    GREATEST((SELECT MAX(id) FROM sim_scenarios), 7)
);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sim_scenarios
                    WHERE code_id = 'one_v_one_attack_defend' AND id = 7) THEN
        RAISE EXCEPTION
            'migration 231 post-check failed: one_v_one_attack_defend is not at id=7';
    END IF;
END $$;

COMMIT;