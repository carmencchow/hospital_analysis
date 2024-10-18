-- Check data types -- 
SELECT 
	column_name,
DATA_TYPE from INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'health';

-- Return first 10 rows
SELECT * FROM health
LIMIT 10

SELECT * FROM demographics
LIMIT 10

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
WHERE race <> "?"
GROUP BY race
ORDER BY num_avg_procedures desc;

-- Duration at hospital -- 
SELECT 
	time_in_hospital,
	COUNT(*) AS count
FROM health
GROUP BY time_in_hospital
ORDER BY count desc

-- Emergency patients who stayed < avg time  
WITH avg_time as (SELECT AVG(time_in_hospital) FROM health)
SELECT * FROM health
WHERE admission_type_id = 1 -- 1 = emergency
AND time_in_hospital < (SELECT * FROM avg_time);

-- Summary stats --
SELECT 
	MIN(num_lab_procedures),
    ROUND(AVG(num_lab_procedures),2),
    MAX(num_lab_procedures)
FROM health;

-- average time based on procedure frequnency
SELECT 
    AVG(time_in_hospital) as avg_time,
CASE 
	WHEN num_lab_procedures >= 1 AND num_lab_procedures < 33 THEN 'few'
	WHEN num_lab_procedures >= 33 AND num_lab_procedures < 55 THEN 'average'
	ELSE 'many'
    END AS procedure_frequency
FROM patient.health
GROUP BY procedure_frequency
ORDER BY avg_time DESC

-- Types of readmissions per race --
SELECT 
  demographics.race,
  COUNT(CASE WHEN health.readmitted = 'NO' THEN 1 END) AS 'NO',
  COUNT(CASE WHEN health.readmitted = '<30' THEN 1 END) AS '<30',
  COUNT(CASE WHEN health.readmitted = '>30' THEN 1 END) AS '>30',
  COUNT(demographics.patient_nbr) AS patient_count
FROM demographics 
INNER JOIN health 
  ON health.patient_nbr = demographics.patient_nbr
WHERE race <> '?'
GROUP BY 
  demographics.race;

-- % Types of readmissions per race --
SELECT 
	demographics.race,
	ROUND((COUNT(CASE WHEN health.readmitted = 'NO' THEN 1 END) * 100.0 / COUNT(demographics.patient_nbr)),1) AS 'not readmitted %',
	ROUND((COUNT(CASE WHEN health.readmitted = '<30' THEN 1 END) * 100.0 / COUNT(demographics.patient_nbr)),1) AS 'readmitted <30 %',
	ROUND((COUNT(CASE WHEN health.readmitted = '>30' THEN 1 END) * 100.0 / COUNT(demographics.patient_nbr)),1) AS 'readmitted >30 %'
FROM demographics 
INNER JOIN health 
    ON health.patient_nbr = demographics.patient_nbr
GROUP BY 
    demographics.race;

-- Metformin patients --
SELECT 
	patient_nbr, 
    race
FROM demographics 
WHERE race = 'AfricanAmerican' 
UNION 
SELECT 
	patient_nbr,
    '' AS race
FROM health 
WHERE metformin = 'Up';

-- Return a summary of top 50 patients --
SELECT 
  CONCAT(
    'Patient ', health.patient_nbr, 
    ' was ', demographics.race, 
    ' and ', 
    (
      CASE 
      WHEN readmitted = 'NO' THEN 'was not readmitted. They had ' 
      ELSE 'was readmitted. They had ' 
      END
    ), 
    num_medications, ' medications and ', 
    num_lab_procedures, ' lab procedures.'
) AS summary, 
race
FROM 
  health
INNER JOIN 
  demographics 
  ON demographics.patient_nbr = health.patient_nbr
ORDER BY 
  num_lab_procedures DESC,
  num_medications DESC 
LIMIT 50;

-- Add subquery to count number of patients from each race --
SELECT 
  race,
  COUNT(*) AS race_count
FROM (
  SELECT 
    demographics.race,
    CONCAT(
      'Patient ', health.patient_nbr, 
      ' was ', demographics.race, 
      ' and ', 
      (
        CASE 
        WHEN readmitted = 'NO' THEN 'was not readmitted. They had ' 
        ELSE 'was readmitted. They had ' 
        END
      ), 
      num_medications, ' medications and ', 
      num_lab_procedures, ' lab procedures.'
    ) AS summary
  FROM 
    health
  INNER JOIN 
    demographics 
    ON demographics.patient_nbr = health.patient_nbr
  ORDER BY 
    num_lab_procedures DESC,
    num_medications DESC 
  LIMIT 50
) AS patient_data
GROUP BY 
  race;
