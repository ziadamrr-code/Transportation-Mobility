use trips_db
----------------------------------------------
--City-Level Fare and Trip Summary Report 
----------------------------------------------
--Total Trips 
select  round (count(trip_id),0) Total_Trips
from fact_trips


--Avg Fare per km 
Select
CAST(SUM(fare_amount) * 1.0 / SUM(distance_travelled_km) AS DECIMAL(10,2)) AS avg_fare_per_km
from fact_trips
where distance_travelled_km >0

--Avg Fare per trip 
select 
Cast(Sum(fare_amount) *1.0 / Count(trip_id) as decimal (10,2)) as Avg_Fare_per_trip
from fact_trips

-- Percentage Contribution of each city trips to the overall trips 
SELECT 
    c.city_name,
    COUNT(*) AS total_trips,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS pct_contribution
FROM fact_trips f
JOIN dbo.dim_city c ON c.city_id = f.city_id
GROUP BY c.city_name
ORDER BY pct_contribution DESC

----------------------------------------------
--Monthly City-Level Trips Target Perfotmance Report
----------------------------------------------
SELECT 
    c.city_name,
    d.start_of_month AS [month],
    COUNT(*)                     AS actual_trips,
    t.total_target_trips         AS target_trips,
    CASE 
        WHEN COUNT(*) > t.total_target_trips THEN 'Above Target'
        ELSE 'Below Target'
    END AS performance_status
FROM dbo.fact_trips f
JOIN dbo.dim_city c   ON c.city_id = f.city_id
JOIN dbo.dim_date d   ON d.[date]  = f.[date]
JOIN dbo.target_monthly_trips t 
      ON t.city_id = f.city_id 
     AND t.[month] = d.start_of_month
GROUP BY c.city_name, d.start_of_month, t.total_target_trips
ORDER BY c.city_name, d.start_of_month


----------------------------------------------
--City-Level Repeat Passenger Trip Frequency Report
----------------------------------------------
SELECT 
    c.city_name,
    CAST(SUM(CASE WHEN r.trip_count = '2-Trips'  THEN r.repeat_passenger_count ELSE 0 END) * 100.0 / SUM(r.repeat_passenger_count) AS DECIMAL(5,2)) AS [2-Trips],
    CAST(SUM(CASE WHEN r.trip_count = '3-Trips'  THEN r.repeat_passenger_count ELSE 0 END) * 100.0 / SUM(r.repeat_passenger_count) AS DECIMAL(5,2)) AS [3-Trips],
    CAST(SUM(CASE WHEN r.trip_count = '4-Trips'  THEN r.repeat_passenger_count ELSE 0 END) * 100.0 / SUM(r.repeat_passenger_count) AS DECIMAL(5,2)) AS [4-Trips],
    CAST(SUM(CASE WHEN r.trip_count = '5-Trips'  THEN r.repeat_passenger_count ELSE 0 END) * 100.0 / SUM(r.repeat_passenger_count) AS DECIMAL(5,2)) AS [5-Trips],
    CAST(SUM(CASE WHEN r.trip_count = '6-Trips'  THEN r.repeat_passenger_count ELSE 0 END) * 100.0 / SUM(r.repeat_passenger_count) AS DECIMAL(5,2)) AS [6-Trips],
    CAST(SUM(CASE WHEN r.trip_count = '7-Trips'  THEN r.repeat_passenger_count ELSE 0 END) * 100.0 / SUM(r.repeat_passenger_count) AS DECIMAL(5,2)) AS [7-Trips],
    CAST(SUM(CASE WHEN r.trip_count = '8-Trips'  THEN r.repeat_passenger_count ELSE 0 END) * 100.0 / SUM(r.repeat_passenger_count) AS DECIMAL(5,2)) AS [8-Trips],
    CAST(SUM(CASE WHEN r.trip_count = '9-Trips'  THEN r.repeat_passenger_count ELSE 0 END) * 100.0 / SUM(r.repeat_passenger_count) AS DECIMAL(5,2)) AS [9-Trips],
    CAST(SUM(CASE WHEN r.trip_count = '10-Trips' THEN r.repeat_passenger_count ELSE 0 END) * 100.0 / SUM(r.repeat_passenger_count) AS DECIMAL(5,2)) AS [10-Trips]
FROM dbo.dim_repeat_trip_distribution r
JOIN dbo.dim_city c ON c.city_id = r.city_id
GROUP BY c.city_name
ORDER BY c.city_name

----------------------------------------------
--Identify Cities with Highest and Lowest Total New Passengers 
----------------------------------------------
SELECT 
    city_name,
    total_new_passengers,
    CASE 
        WHEN rnk <= 3               THEN 'Top 3'
        WHEN rnk > total_cities - 3 THEN 'Bottom 3'
    END AS city_category
FROM (
    SELECT 
        c.city_name,
        SUM(p.new_passengers) AS total_new_passengers,
        RANK() OVER (ORDER BY SUM(p.new_passengers) DESC) AS rnk,
        COUNT(*) OVER () AS total_cities
    FROM dbo.fact_passenger_summary p
    JOIN dbo.dim_city c ON c.city_id = p.city_id
    GROUP BY c.city_name
) t
WHERE rnk <= 3 OR rnk > total_cities - 3
ORDER BY total_new_passengers DESC

----------------------------------------------
--Identify Month with Highest Revenue for Each City
----------------------------------------------
WITH monthly_revenue AS (
    SELECT 
        c.city_name,
        d.month_name,
        SUM(f.fare_amount) AS revenue
    FROM dbo.fact_trips f
    JOIN dbo.dim_city c ON c.city_id = f.city_id
    JOIN dbo.dim_date d ON d.[date]  = f.[date]
    GROUP BY c.city_name, d.month_name
),
ranked AS (
    SELECT 
        city_name,
        month_name,
        revenue,
        RANK() OVER (PARTITION BY city_name ORDER BY revenue DESC) AS rnk,
        SUM(revenue) OVER (PARTITION BY city_name)                 AS city_total_revenue
    FROM monthly_revenue
)
SELECT 
    city_name,
    month_name AS highest_revenue_month,
    revenue,
    CAST(revenue * 100.0 / city_total_revenue AS DECIMAL(5,2)) AS percentage_contribution
FROM ranked
WHERE rnk = 1
ORDER BY city_name

----------------------------------------------
--Reapeat Passenger Rate Analysis
----------------------------------------------

SELECT 
    c.city_name,
    p.[month],
    p.total_passengers,
    p.repeat_passengers,
    CAST(p.repeat_passengers * 100.0 / p.total_passengers AS DECIMAL(5,2)) AS monthly_repeat_passenger_rate,
    CAST(
        SUM(p.repeat_passengers) OVER (PARTITION BY c.city_name) * 100.0
        / SUM(p.total_passengers) OVER (PARTITION BY c.city_name)
        AS DECIMAL(5,2)
    ) AS city_repeat_passenger_rate
FROM dbo.fact_passenger_summary p
JOIN dbo.dim_city c ON c.city_id = p.city_id
ORDER BY c.city_name, p.[month]