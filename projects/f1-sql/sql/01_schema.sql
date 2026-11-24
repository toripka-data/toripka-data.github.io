-- 01_schema.sql: create the f1 database (MySQL 8.0+)
CREATE DATABASE IF NOT EXISTS f1;
USE f1;

DROP TABLE IF EXISTS results, races, drivers, circuits, status;

CREATE TABLE circuits (
  circuit_id   INT PRIMARY KEY,
  circuit_ref  VARCHAR(50),
  name         VARCHAR(100),
  location     VARCHAR(100),
  country      VARCHAR(50)
);

CREATE TABLE races (
  race_id     INT PRIMARY KEY,
  year        INT,
  round       INT,
  circuit_id  INT,
  name        VARCHAR(100),
  race_date   DATE,
  FOREIGN KEY (circuit_id) REFERENCES circuits(circuit_id)
);

CREATE TABLE drivers (
  driver_id    INT PRIMARY KEY,
  driver_ref   VARCHAR(50),
  code         CHAR(3),
  forename     VARCHAR(50),
  surname      VARCHAR(50),
  nationality  VARCHAR(50)
);

CREATE TABLE status (
  status_id  INT PRIMARY KEY,
  status     VARCHAR(50)
);

CREATE TABLE results (
  result_id       INT PRIMARY KEY,
  race_id         INT,
  driver_id       INT,
  constructor_id  INT,
  grid            INT,             -- 0 = pit-lane start
  position        INT NULL,        -- NULL = not classified (DNF etc.)
  position_order  INT,
  points          DECIMAL(5,2),
  laps            INT,
  status_id       INT,
  FOREIGN KEY (race_id)   REFERENCES races(race_id),
  FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
  FOREIGN KEY (status_id) REFERENCES status(status_id)
);
