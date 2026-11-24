-- 04_analysis.sql: does pole position actually win?
USE f1;

-- 1. Reusable view: join once, flag outcomes. COALESCE turns a DNF (NULL
--    position) into 0 so AVG() counts it instead of silently skipping it.
CREATE OR REPLACE VIEW race_results AS
SELECT r.race_id, ra.year, ra.name AS race_name, c.name AS circuit,
       CONCAT(d.forename, ' ', d.surname) AS driver,
       r.grid, r.position, s.status,
       COALESCE(r.position = 1, 0)  AS won,
       COALESCE(r.position <= 3, 0) AS podium,
       (r.position IS NOT NULL)     AS finished
FROM results r
JOIN races ra   ON ra.race_id = r.race_id
JOIN circuits c ON c.circuit_id = ra.circuit_id
JOIN drivers d  ON d.driver_id = r.driver_id
JOIN status s   ON s.status_id = r.status_id
WHERE r.grid > 0;   -- drop pit-lane starts

-- 2. Win and podium rate by grid slot (headline result)
SELECT grid,
       COUNT(*)                     AS starts,
       SUM(won)                     AS wins,
       ROUND(100 * AVG(won), 1)     AS win_pct,
       ROUND(100 * AVG(podium), 1)  AS podium_pct
FROM race_results
WHERE grid <= 10
GROUP BY grid
ORDER BY grid;

-- 3. Share of all wins by starting zone (window function over grouped rows)
SELECT CASE
         WHEN grid = 1   THEN 'Pole'
         WHEN grid <= 3  THEN 'P2-P3'
         WHEN grid <= 10 THEN 'P4-P10'
         ELSE 'P11+'
       END AS start_zone,
       COUNT(*) AS wins,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_all_wins
FROM race_results
WHERE won = 1
GROUP BY start_zone
ORDER BY MIN(grid);

-- 4. Has pole gotten more powerful? Pole win rate by decade, with LAG
WITH by_decade AS (
  SELECT FLOOR(year / 10) * 10 AS decade,
         COUNT(*) AS poles,
         ROUND(100 * AVG(won), 1) AS pole_win_pct
  FROM race_results
  WHERE grid = 1
  GROUP BY decade
)
SELECT decade, poles, pole_win_pct,
       pole_win_pct - LAG(pole_win_pct) OVER (ORDER BY decade) AS change_vs_prev
FROM by_decade;

-- 5. Which tracks reward pole the most? (10+ races so small samples don't mislead)
SELECT circuit,
       COUNT(*) AS races,
       ROUND(100 * AVG(won), 1) AS pole_win_pct
FROM race_results
WHERE grid = 1
GROUP BY circuit
HAVING COUNT(*) >= 10
ORDER BY pole_win_pct DESC;

-- 6. Who gains the most places? Hybrid era (2014+), finishers, 50+ finishes
WITH gains AS (
  SELECT driver,
         COUNT(*) AS finishes,
         ROUND(AVG(grid - position), 2) AS avg_places_gained
  FROM race_results
  WHERE year >= 2014 AND position IS NOT NULL
  GROUP BY driver
  HAVING COUNT(*) >= 50
)
SELECT RANK() OVER (ORDER BY avg_places_gained DESC) AS rnk, gains.*
FROM gains;

-- 7. Las Vegas Strip races: front-row starters and podium finishers
SELECT year, driver, grid, position, status
FROM race_results
WHERE race_name LIKE '%Las Vegas%' AND year >= 2023
  AND (grid <= 5 OR position <= 3)
ORDER BY year, grid;
