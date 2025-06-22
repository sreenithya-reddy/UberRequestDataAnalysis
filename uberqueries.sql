

/* table info */
PRAGMA table_info(uber_data);


-- Add a new column to store the converted datetime
ALTER TABLE uber_data ADD COLUMN Request_dt_cleaned TEXT;

/* updating */
UPDATE uber_data
SET Request_dt_cleaned = 
    substr("Request timestamp", 7, 4) || '-' ||  -- YYYY
    substr("Request timestamp", 4, 2) || '-' ||  -- MM
    substr("Request timestamp", 1, 2) || ' ' ||  -- DD
    substr("Request timestamp", 12) || ':00';    -- HH:MM + add :00 seconds



SELECT "Request timestamp", Request_dt_cleaned
FROM uber_data
LIMIT 5; /* first five rows*/



/* table info */
PRAGMA table_info(uber_data);


-- Add a new column to store the converted datetime
ALTER TABLE uber_data ADD COLUMN Drop_dt_cleaned TEXT;

/* Updating...*/

UPDATE uber_data
SET Drop_dt_cleaned = 
    CASE 
        WHEN "Drop timestamp" != 'NA'
        THEN 
            substr("Drop timestamp", 7, 4) || '-' || 
            substr("Drop timestamp", 4, 2) || '-' || 
            substr("Drop timestamp", 1, 2) || ' ' || 
            substr("Drop timestamp", 12) || ':00'
        ELSE NULL
    END;


SELECT "Request timestamp", Request_dt_cleaned
FROM uber_data
LIMIT 5; /* first five rows*/



/* 1. Total requests by status */

SELECT Status, COUNT(*) AS Total_Requests
FROM uber_data
GROUP BY Status;



/* 2. Cancellation rate */

SELECT 
  ROUND(
    100.0 * SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 
    2
  ) AS Cancellation_Percentage
FROM uber_data;



/* 3. Peak hours for demand (Request timestamp HOUR)*/

SELECT 
  strftime('%H', "Request_dt_cleaned") AS Hour,
  COUNT(*) AS Total_Requests
FROM uber_data
GROUP BY Hour
ORDER BY Total_Requests DESC;



/* 4. Most common pickup point */

SELECT "Pickup point", COUNT(*) AS Count
FROM uber_data
GROUP BY "Pickup point"
ORDER BY Count DESC;



/* 5. Average trip duration */

SELECT 
  ROUND(AVG(
    julianday(Drop_dt_cleaned) - julianday(Request_dt_cleaned)
  ) * 24 * 60, 2) AS Avg_Trip_Duration_Minutes
FROM uber_data
WHERE Status = 'Trip Completed'
  AND Drop_dt_cleaned IS NOT NULL
  AND Request_dt_cleaned IS NOT NULL;



/* 6. failure rate (No cars Available by time) */

SELECT 
  strftime('%H', "Request_dt_cleaned") AS Hour,
  COUNT(*) AS TotalRequests,
  SUM(CASE WHEN Status = 'No Cars Available' THEN 1 ELSE 0 END) AS No_Cars,
  ROUND(
    100.0 * SUM(CASE WHEN Status = 'No Cars Available' THEN 1 ELSE 0 END) 
    / COUNT(*), 2
  ) AS No_Car_Percentage
FROM uber_data
GROUP BY Hour
ORDER BY No_Car_Percentage DESC;


/* 7. Trip Cancellation Per Hour*/

SELECT
  strftime('%H', Request_dt_cleaned) AS Hour,
  COUNT(*) AS Cancelled_Requests
FROM uber_data
WHERE Status = 'Cancelled'
GROUP BY Hour
ORDER BY Hour;
