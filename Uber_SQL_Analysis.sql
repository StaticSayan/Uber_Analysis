-- 1. Create and select the database
CREATE DATABASE IF NOT EXISTS uber_analysis;
USE uber_analysis;

-- 2. Create the table
DROP TABLE IF EXISTS uber_data;
CREATE TABLE uber_data (
    request_id INT,
    pickup_point VARCHAR(50),
    status VARCHAR(50),
    request_timestamp DATETIME,
    drop_timestamp DATETIME,
    request_time VARCHAR(20),
    drop_time VARCHAR(20),
    request_hour INT,
    trip_duration INT,
    trip_category VARCHAR(20),
    day_of_week VARCHAR(20)
);

-- 3. Load CSV into the table
SHOW VARIABLES LIKE 'secure_file_priv';
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Uberdata_Cleaned.csv'
INTO TABLE uber_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(request_id, pickup_point, @driver_id, status, request_timestamp, drop_timestamp, request_time, drop_time, request_hour, trip_duration, trip_category, day_of_week);

-- 4. Analysis Queries

-- (1) Ride demand by hour
SELECT request_hour AS hour_of_day, COUNT(*) AS total_requests
FROM uber_data
GROUP BY request_hour
ORDER BY request_hour;

-- (2) Unfulfilled requests by hour
SELECT request_hour AS hour_of_day, status, COUNT(*) AS total_unfulfilled
FROM uber_data
WHERE status IN ('Cancelled', 'No Cars Available')
GROUP BY request_hour, status
ORDER BY request_hour;

-- (3) Trip completions vs failures by pickup point
SELECT pickup_point, status, COUNT(*) AS total_requests
FROM uber_data
GROUP BY pickup_point, status
ORDER BY pickup_point, status;

-- (4) Trip duration distribution
SELECT trip_category, COUNT(*) AS total_trips, ROUND(AVG(trip_duration), 2) AS avg_duration
FROM uber_data
WHERE status = 'Trip Completed'
GROUP BY trip_category
ORDER BY FIELD(trip_category, 'Short', 'Medium', 'Long', 'Very Long');

-- (5) Completed trips by pickup point and trip type
SELECT pickup_point, trip_category, COUNT(*) AS completed_trips
FROM uber_data
WHERE status = 'Trip Completed'
GROUP BY pickup_point, trip_category
ORDER BY pickup_point, FIELD(trip_category, 'Short', 'Medium', 'Long', 'Very Long');
