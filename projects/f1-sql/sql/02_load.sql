-- 02_load.sql: load the CSVs from TracingInsights/RaceData (data/ folder)
-- Before running: Workbench connection > Advanced > Others: OPT_LOCAL_INFILE=1
SET GLOBAL local_infile = 1;
USE f1;

-- Load parents before children so the foreign keys accept every row
LOAD DATA LOCAL INFILE 'C:/f1_sql/data/circuits.csv' INTO TABLE circuits
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(circuit_id, circuit_ref, name, location, country, @lat, @lng, @alt, @url);

LOAD DATA LOCAL INFILE 'C:/f1_sql/data/races.csv' INTO TABLE races
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(race_id, year, round, circuit_id, name, race_date, @time, @url,
 @x1, @x2, @x3, @x4, @x5, @x6, @x7, @x8, @x9, @x10);

LOAD DATA LOCAL INFILE 'C:/f1_sql/data/drivers.csv' INTO TABLE drivers
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(driver_id, driver_ref, @number, @code, forename, surname, @dob, nationality, @url)
SET code = NULLIF(@code, '\\N');

LOAD DATA LOCAL INFILE 'C:/f1_sql/data/status.csv' INTO TABLE status
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(status_id, status);

LOAD DATA LOCAL INFILE 'C:/f1_sql/data/results.csv' INTO TABLE results
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(result_id, race_id, driver_id, constructor_id, @number, grid, @position, @position_text,
 position_order, points, laps, @time, @ms, @fastest_lap, @fl_rank, @fl_time, @fl_speed, status_id)
SET position = NULLIF(@position, '\\N');
