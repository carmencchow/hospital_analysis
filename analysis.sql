-- Number of patients that spent # num of days in hospital
SELECT 
	time_in_hospital,
	COUNT(*) AS count
FROM health
GROUP BY time_in_hospital
ORDER BY count desc

-- Calculate average stay in hospital 
SELECT AVG(CAST(time_in_hospital AS DECIMAL)) AS avg_time_in_hospital
FROM health; -- average time 4.3960
