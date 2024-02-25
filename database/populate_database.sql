CREATE SCHEMA IF NOT EXISTS datalake;

CREATE TABLE IF NOT EXISTS datalake.user_signed_up_at (
  id SERIAL PRIMARY KEY,
  user_id INT,
  date INT,
  month INT,
  year INT,
  created_time BIGINT
);

INSERT INTO datalake.user_signed_up_at (user_id, date, month, year, created_time)
VALUES 
('63', 16, 2, 2024, 1708000211691)
;
INSERT INTO datalake.user_signed_up_at (user_id, date, month, year, created_time)
VALUES 
('4', 16, 2, 2024, 1707992271360)
;
INSERT INTO datalake.user_signed_up_at (user_id, date, month, year, created_time)
VALUES 
('38', 16, 2, 2024, 1707997211872)
;
INSERT INTO datalake.user_signed_up_at (user_id, date, month, year, created_time)
VALUES 
('13', 16, 2, 2024, 1707993732710)
;