-- Histogram showing distribution of patients
SELECT 
	time_in_hospital,
	COUNT(*) AS count
FROM health
GROUP BY time_in_hospital
ORDER BY count desc



