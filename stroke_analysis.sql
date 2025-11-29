
USE
STROKE_ANALYSIS

SELECT TOP 20 * FROM Stroke_data;
SELECT COUNT(*) FROM Stroke_data;

Check NULLs
SELECT 
    SUM(CASE WHEN bmi IS NULL THEN 1 END) AS Null_BMI,
    SUM(CASE WHEN smoking_status IS NULL THEN 1 END) AS Null_Smoking
FROM Stroke_data;


Creating Age groups
ALTER TABLE Stroke_data ADD age_group nvarchar(20);

UPDATE Stroke_data
SET age_group =
    CASE 
        WHEN age < 30 THEN '18–29'
        WHEN age >= 30 AND age < 45 THEN '30–44'
        WHEN age >= 45 AND age < 60 THEN '45–59'
        ELSE '60+'
    END;

Creating Smoking_status Risk groups 
ALTER TABLE Stroke_data ADD smoking_risk nvarchar(20);
Update Stroke_data
SET smoking_risk =
CASE
        WHEN smoking_status = 'smokes' THEN 'High'
        WHEN smoking_status = 'formerly smoked' THEN 'Medium'
        WHEN smoking_status = 'never smoked' THEN 'Low'
        ELSE 'Unknown'
    END 
	FROM DBO.[Stroke_data];

Creating BMI_Categories
SELECT 
    id,
    bmi,
    TRY_CAST(bmi AS FLOAT) AS bmi_float
FROM Stroke_data;

ALTER TABLE Stroke_data
DROP COLUMN bmi_category;

ALTER TABLE Stroke_data
ADD bmi_category NVARCHAR(20) NULL;

UPDATE Stroke_data
SET bmi_category =
    CASE 
        WHEN TRY_CAST(bmi AS FLOAT) IS NULL THEN 'Unknown'
        WHEN TRY_CAST(bmi AS FLOAT) < 18.5 THEN 'Underweight'
        WHEN TRY_CAST(bmi AS FLOAT) >= 18.5 AND TRY_CAST(bmi AS FLOAT) < 25 THEN 'Normal'
        WHEN TRY_CAST(bmi AS FLOAT) >= 25   AND TRY_CAST(bmi AS FLOAT) < 30 THEN 'Overweight'
        ELSE 'Obese'
    END;

	SELECT TOP 50 bmi, bmi_category
FROM Stroke_data;

CORE ANALYSIS 

Overall STROKE PREVALENCE
SElect
COUNT (*) AS total_records,
SUM(CASE WHEN stroke = 1 THEN 1 ELSE 0 END) AS stroke_cases,
Round(AVG(CAST(stroke AS float)) * 100, 2) AS stroke_prevalence_percent
FROM dbo.[Stroke_data];

STROKE BY GENDER
SELECT 
gender,
COUNT (*) as total_population,
SUM(CASE WHEN stroke = 1 THEN 1 ELSE 0 END) AS stroke_cases,
Round(AVG(CAST(stroke AS float)) * 100, 2) AS stroke_prevalence_percent
FROM dbo.[Stroke_data]
GROUP BY	gender
ORDER BY stroke_prevalence_percent DESC;

STROKE BY RESIDENCE TYPE (URBAN VS RURAL)
SELECT
Residence_type,
COUNT (*) AS total_records,
SUM(CASE WHEN stroke = 1 THEN 1 ELSE 0 END) AS stroke_cases,
Round(AVG(CAST(stroke AS float)) * 100, 2) AS stroke_prevalence_percent
FROM dbo.[Stroke_data]
GROUP BY Residence_type
ORDER BY stroke_prevalence_percent DESC;

STROKE BY SMOKING STATUS 
SELECT
smoking_status,
COUNT (*) AS total_records,
SUM(CASE WHEN stroke = 1 THEN 1 ELSE 0 END) AS stroke_cases,
Round(AVG(CAST(stroke AS float)) * 100, 2) AS stroke_prevalence_percent
FROM dbo.[Stroke_data]
GROUP BY smoking_status
ORDER BY stroke_prevalence_percent DESC;

Stroke by smoking_risk (High / Medium / Low)
SELECT 
CASE 
 WHEN smoking_status = 'smokes' THEN 'High'
        WHEN smoking_status = 'formerly smoked' THEN 'Medium'
        WHEN smoking_status = 'never smoked' THEN 'Low'
        ELSE 'Unknown'
END AS smokingrisk_group,
COUNT (*) AS total_records,
SUM(CASE WHEN stroke = 1 THEN 1 ELSE 0 END) AS stroke_cases,
Round(AVG(CAST(stroke AS float)) * 100, 2) AS stroke_prevalence_percent
FROM dbo.[Stroke_data]
GROUP BY
CASE
WHEN smoking_status = 'smokes' THEN 'High'
        WHEN smoking_status = 'formerly smoked' THEN 'Medium'
        WHEN smoking_status = 'never smoked' THEN 'Low'
        ELSE 'Unknown'
		END
ORDER BY stroke_prevalence_percent DESC;

STROKE BY age_group
SELECT
CASE
When age < 30 then '18-29'
When age >= 30 and age <45 then '30-44'
When age >=45 and age <60 then '45-59'
Else '60+'
END AS age_group,
COUNT (*) AS total_records,
SUM(CASE WHEN stroke = 1 THEN 1 ELSE 0 END) AS stroke_cases,
Round(AVG(CAST(stroke AS float)) * 100, 2) AS stroke_prevalence_percent
FROM dbo.[Stroke_data]
GROUP BY
CASE
When age < 30 then '18-29'
When age >= 30 and age <45 then '30-44'
When age >=45 and age <60 then '45-59'
Else '60+'
END
ORDER BY stroke_prevalence_percent DESC;

Stroke by BMI category
SELECT 
    bmi_category,
    COUNT(*) AS total,
    SUM(CASE WHEN stroke = 1 THEN 1 ELSE 0 END) AS stroke_cases,
    ROUND(AVG(CAST(stroke AS FLOAT)) * 100, 2) AS stroke_prevalence_percent
FROM dbo.Stroke_data
GROUP BY bmi_category
ORDER BY stroke_prevalence_percent DESC;

Stroke by hypertension and heart disease
SELECT 
hypertension,
Count (*) AS total_records,
SUM(CASE WHEN stroke = 1 THEN 1 ELSE 0 END) as stroke_cases,
ROUND(AVG(CAST(stroke as float)) *100, 2) AS stroke_prevalence_percent
FROM dbo.Stroke_data
GROUP BY hypertension;

heart_disease
SELECT 
heart_disease,
Count (*) AS total_records,
SUM(CASE WHEN stroke = 1 THEN 1 ELSE 0 END) as stroke_cases,
ROUND(AVG(CAST(stroke as float)) *100, 2) AS stroke_prevalence_percent
FROM dbo.Stroke_data
GROUP BY heart_disease;

Glucose & BMI summary (central tendency + dispersion)
SELECT 
    AVG(avg_glucose_level) AS mean_glucose,
    STDEV(avg_glucose_level) AS sd_glucose,
    MIN(avg_glucose_level) AS min_glucose,
    MAX(avg_glucose_level) AS max_glucose
FROM dbo.Stroke_data;

SELECT 
    AVG(TRY_CAST(bmi AS FLOAT)) AS mean_bmi,
    STDEV(TRY_CAST(bmi AS FLOAT)) AS sd_bmi,
    MIN(TRY_CAST(bmi AS FLOAT)) AS min_bmi,
    MAX(TRY_CAST(bmi AS FLOAT)) AS max_bmi
FROM dbo.Stroke_data;

Cross-tab for smokers vs non-smokers (2×2 table for RR/OR)
SELECT 
    smoking_status,
    SUM(CASE WHEN stroke = 1 THEN 1 ELSE 0 END) AS stroke_yes,
    SUM(CASE WHEN stroke = 0 THEN 1 ELSE 0 END) AS stroke_no
FROM dbo.Stroke_data
WHERE smoking_status IN ('Smokes','Never Smoked')
GROUP BY smoking_status;



