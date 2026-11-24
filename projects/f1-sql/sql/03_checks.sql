-- 03_checks.sql: prove the load worked before analyzing anything
USE f1;

-- Row counts (data through the 2026 Las Vegas GP):
-- circuits 78, races 1172, drivers 885, status 143, results 27700
SELECT 'circuits' AS tbl, COUNT(*) AS n FROM circuits
UNION ALL SELECT 'races',    COUNT(*) FROM races
UNION ALL SELECT 'drivers',  COUNT(*) FROM drivers
UNION ALL SELECT 'status',   COUNT(*) FROM status
UNION ALL SELECT 'results',  COUNT(*) FROM results;

-- Exactly one winner per race? Returns 3 races from the 1950s
-- where drivers shared a car and both were credited.
SELECT race_id, COUNT(*) AS winners
FROM results WHERE position = 1
GROUP BY race_id HAVING COUNT(*) <> 1;

-- Pit-lane starts and unclassified finishers (expect 1638 and 10953)
SELECT SUM(grid = 0) AS pit_lane_starts,
       SUM(position IS NULL) AS not_classified
FROM results;

-- Gut check: Hamilton's career wins (106 through the 2026 Las Vegas GP)
SELECT d.forename, d.surname, COUNT(*) AS wins
FROM results r JOIN drivers d ON d.driver_id = r.driver_id
WHERE r.position = 1 AND d.surname = 'Hamilton'
GROUP BY d.forename, d.surname;
