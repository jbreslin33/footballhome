-- 1894 (2026-11-25): undo mig 1891 — recover no longer cuts off pressing distance.
--
-- Owner 11/25: "wait we still nee the stay in pressing distance until i sign off" · "we are still on stay
-- in pressing distance" — asked: undo recover winning. The resolver and recover's spot-taking are
-- reverted in the engine (Machines, DefendingBlock); pressing distance is as it was before 1891.
DELETE FROM game_engine_behaviours WHERE code IN ('machine_resolver', 'recover_takes_his_spot');
UPDATE game_engine_terms SET note = 'ai/concepts/Machines — MachineId::Recover'
 WHERE kind = 'machine' AND code = 'recover';
