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

-- Avg number of procedures per patient by specialty 
SELECT medical_specialty,
ROUND(AVG(num_procedures),1) as avg_procedures,
COUNT(*) as num_of_patients
FROM health
GROUP BY medical_specialty
HAVING num_of_patients > 50
ORDER BY avg_procedures DESC;

-- Procedures by race
SELECT race,
AVG(num_lab_procedures) as num_avg_procedures
FROM health
INNER JOIN demographics ON health.patient_nbr = demographics.patient_nbr
GROUP BY race
ORDER BY num_avg_procedures desc;