-- ----------------------------------------
-- Uploading large files
-- ----------------------------------------
SET GLOBAL local_infile = 1;

-- --------------------------------------------------------
-- New database created priviously from create new schema
-- Using the database created
-- --------------------------------------------------------
USE depi;

ALTER DATABASE final_project -- Code for arabic and unknown letters to be written right
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- ----------------------------------------
-- Create a new raw table
-- ----------------------------------------
CREATE TABLE IF NOT EXISTS global_climate (
	event_id VARCHAR (10) PRIMARY KEY,
	date DATE,
	year INT,
	month INT,
	country VARCHAR (50),
	event_type VARCHAR (50),
	severity INT,
	duration_days INT,
	affected_population INT,
	deaths INT,
	injuries INT,
	economic_impact_million_usd DECIMAL (6,2),
    infrastructure_damage_score DECIMAL (6,2),
    response_time_hours INT,
    international_aid_million_usd DECIMAL (6, 2),
    latitude DECIMAL (10,4),
    longitude DECIMAL (10,4),
    total_casualties INT,
    impact_per_capita DECIMAL (4,2),
    aid_percentage DECIMAL (4,2)
);
-- DROP TABLE global_climate;
-- ----------------------------------------
-- Loading Local Data
-- ----------------------------------------
LOAD DATA LOCAL INFILE 'C:/Users/Ahmed Bahaa/Desktop/Final Project - DEPI/global_climate_events_economic_impact_2020_2025.csv'
INTO TABLE global_climate
FIELDS TERMINATED BY','
ENCLOSED BY ""
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM global_climate;
DESCRIBE global_climate;
-- DROP TABLE global_climate;

-- ----------------------------------------
-- Setting safe updates
-- ----------------------------------------
SET SQL_SAFE_UPDATES = 0;

-- ----------------------------------------
-- Data Preprocesssing
-- ----------------------------------------

-- ----------------------------------------
-- 1. Summarizing missing values
-- ----------------------------------------
SELECT
	SUM(event_id IS NULL) AS missing_event_id,
	SUM(date IS NULL) AS missing_date,
	SUM(year IS NULL) AS missing_year,
	SUM(month IS NULL ) AS missing_month,
	SUM(country IS NULL) AS missing_country,
	SUM(event_type IS NULL) AS missing_event_type,
	SUM(severity IS NULL) AS missing_severity,
	SUM(duration_days IS NULL) AS missing_duration_days,
	SUM(affected_population IS NULL) AS missing_affected_population,
	SUM(deaths IS NULL) AS missing_deaths,
	SUM(injuries IS NULL) AS missing_injuries,
	SUM(economic_impact_million_usd IS NULL) AS missing_economic_impact_million_usd,
	SUM(infrastructure_damage_score IS NULL) AS missing_infrastructure_damage_score,
	SUM(response_time_hours IS NULL) AS missing_response_time_hours,
	SUM(international_aid_million_usd IS NULL) AS missing_international_aid_million_usd,
	SUM(latitude IS NULL) AS missing_latitude,
	SUM(longitude IS NULL) AS missing_longitude,
	SUM(total_casualties IS NULL) AS missing_total_casualties,
	SUM(impact_per_capita IS NULL) AS missing_impact_per_capita,
	SUM(aid_percentage IS NULL) AS missing_aid_percentage
FROM global_climate;

-- ----------------------------------------
-- 2. Summarizing duplicates by event id
-- ----------------------------------------
SELECT event_id, COUNT(*) AS cnt
FROM global_climate
WHERE event_id IS NOT NULL
GROUP BY event_id
HAVING COUNT(*) > 1;

-- ----------------------------------------------------------------------------------------
-- 3. Summarizing country column (categorical) to check if something needs standardization
-- ----------------------------------------------------------------------------------------
SELECT country, COUNT(*) AS cnt
FROM global_climate
GROUP BY country
ORDER BY cnt DESC;

-- -------------------------------------------------------------------------------------------
-- 4. Summarizing event type column (categorical) to check if something needs standardization
-- -------------------------------------------------------------------------------------------
SELECT event_type, COUNT(*) AS cnt
FROM global_climate
GROUP BY event_type
ORDER BY cnt DESC;

-- ----------------------------
-- Descriptive Statistics
-- ----------------------------

-- ----------------------------
-- 1. Severity Column
-- ----------------------------
SELECT 
    COUNT(severity) AS count_severity,
	ROUND(AVG(severity), 2) AS mean_severity,
    MIN(severity) As minimum_severity,
    MAX(severity) AS maximum_severity,
    MAX(severity) - MIN(severity) AS range_severity,
    ROUND(STDDEV(severity), 2) AS std_deviation_severity,  
    ROUND(VARIANCE(severity), 2) As variance_severity       
FROM global_climate;

-- Median Calculatios
WITH statistics AS (
    SELECT 
        severity,
        ROW_NUMBER() OVER (ORDER BY severity) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
)
SELECT 
    ROUND(AVG(CASE 
        WHEN row_num IN (FLOOR((total_count + 1) / 2), CEIL((total_count + 1) / 2)) 
        THEN severity 
    END), 2) AS median_severity
FROM statistics;

--  Mode Calculation
SELECT severity AS mode_severity
FROM global_climate
GROUP BY severity
ORDER BY COUNT(*) DESC
LIMIT 1;

-- ----------------------------
-- 2. Duration Days Column
-- ----------------------------
SELECT 
    COUNT(duration_days) AS count_duration_days,
	ROUND(AVG(duration_days), 2) AS mean_duration_days,
    MIN(duration_days) As minimum_duration_days,
    MAX(duration_days) AS maximum_duration_days,
    MAX(duration_days) - MIN(duration_days) AS range_duration_days,
    ROUND(STDDEV(duration_days), 2) AS std_deviation_duration_days,  
    ROUND(VARIANCE(duration_days), 2) As variance_duration_days       
FROM global_climate;

-- Median Calculatios
WITH statistics AS (
    SELECT 
        duration_days,
        ROW_NUMBER() OVER (ORDER BY duration_days) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
)
SELECT 
    ROUND(AVG(CASE 
        WHEN row_num IN (FLOOR((total_count + 1) / 2), CEIL((total_count + 1) / 2)) 
        THEN duration_days 
    END), 2) AS median_duration_days
    FROM statistics;

--  Mode Calculation
SELECT duration_days AS mode_duration_days
FROM global_climate
GROUP BY duration_days
ORDER BY COUNT(*) DESC
LIMIT 1;

-- ------------------------------
-- 3. Affected Population Column
-- ------------------------------
SELECT 
    COUNT(affected_population) AS count_affected_population,
	ROUND(AVG(affected_population), 2) AS mean_affected_population,
    MIN(affected_population) As minimum_affected_population,
    MAX(affected_population) AS maximum_affected_population,
    MAX(affected_population) - MIN(affected_population) AS range_affected_population,
    ROUND(STDDEV(affected_population), 2) AS std_deviation_affected_population,  
    ROUND(VARIANCE(affected_population), 2) As variance_affected_population       
FROM global_climate;

-- Median Calculatios
WITH statistics AS (
    SELECT 
        affected_population,
        ROW_NUMBER() OVER (ORDER BY affected_population) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
)
SELECT 
    ROUND(AVG(CASE 
        WHEN row_num IN (FLOOR((total_count + 1) / 2), CEIL((total_count + 1) / 2)) 
        THEN affected_population
    END), 2) AS median_affected_population
    FROM statistics;

--  Mode Calculation
SELECT duration_days AS mode_duration_days
FROM global_climate
GROUP BY duration_days
ORDER BY COUNT(*) DESC
LIMIT 1;

-- ----------------------------
-- 4. Deaths Column
-- ----------------------------
SELECT 
    COUNT(deaths) AS count_deaths,
	ROUND(AVG(deaths), 2) AS mean_deaths,
    MIN(deaths) As minimum_deaths,
    MAX(deaths) AS maximum_deaths,
    MAX(deaths) - MIN(deaths) AS range_deaths,
    ROUND(STDDEV(deaths), 2) AS std_deviation_deaths,  
    ROUND(VARIANCE(deaths), 2) As variance_deaths       
FROM global_climate;

-- Median Calculatios
WITH statistics AS (
    SELECT 
        deaths,
        ROW_NUMBER() OVER (ORDER BY deaths) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
)
SELECT 
    ROUND(AVG(CASE 
        WHEN row_num IN (FLOOR((total_count + 1) / 2), CEIL((total_count + 1) / 2)) 
        THEN deaths
    END), 2) AS median_deaths
    FROM statistics;

--  Mode Calculation
SELECT deaths AS mode_deaths
FROM global_climate
GROUP BY deaths
ORDER BY COUNT(*) DESC
LIMIT 1;

-- ----------------------------
-- 5. Injuries Column
-- ----------------------------
SELECT 
    COUNT(injuries) AS count_injuries,
	ROUND(AVG(injuries), 2) AS mean_injuries,
    MIN(injuries) As minimum_injuries,
    MAX(injuries) AS maximum_injuries,
    MAX(injuries) - MIN(injuries) AS range_injuries,
    ROUND(STDDEV(injuries), 2) AS std_deviation_injuries,  
    ROUND(VARIANCE(injuries), 2) As variance_injuries       
FROM global_climate;

-- Median Calculatios
WITH statistics AS (
    SELECT 
        injuries,
        ROW_NUMBER() OVER (ORDER BY injuries) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
)
SELECT 
    ROUND(AVG(CASE 
        WHEN row_num IN (FLOOR((total_count + 1) / 2), CEIL((total_count + 1) / 2)) 
        THEN injuries
    END), 2) AS median_injuries
    FROM statistics;
    
   --  Mode Calculation
SELECT injuries AS mode_injuries
FROM global_climate
GROUP BY injuries
ORDER BY COUNT(*) DESC
LIMIT 1; 

-- --------------------------------------
-- 6. Economic Impact Million USD Column
-- --------------------------------------
SELECT 
    COUNT(economic_impact_million_usd) AS count_economic_impact_million_usd,
	ROUND(AVG(economic_impact_million_usd), 2) AS mean_economic_impact_million_usd,
    MIN(economic_impact_million_usd) As minimum_economic_impact_million_usd,
    MAX(economic_impact_million_usd) AS maximum_economic_impact_million_usd,
    MAX(economic_impact_million_usd) - MIN(economic_impact_million_usd) AS range_economic_impact_million_usd,
    ROUND(STDDEV(economic_impact_million_usd), 2) AS std_deviation_economic_impact_million_usd,  
    ROUND(VARIANCE(economic_impact_million_usd), 2) As variance_economic_impact_million_usd       
FROM global_climate;

-- Median Calculatios
WITH statistics AS (
    SELECT 
        economic_impact_million_usd,
        ROW_NUMBER() OVER (ORDER BY economic_impact_million_usd) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
)
SELECT 
    ROUND(AVG(CASE 
        WHEN row_num IN (FLOOR((total_count + 1) / 2), CEIL((total_count + 1) / 2)) 
        THEN economic_impact_million_usd
    END), 2) AS median_injuries
    FROM statistics;
    
--  Mode Calculation
SELECT economic_impact_million_usd AS mode_economic_impact_million_usd
FROM global_climate
GROUP BY economic_impact_million_usd
ORDER BY COUNT(*) DESC
LIMIT 1; 

-- --------------------------------------
-- 7. Infrastructure Damage Score Column
-- --------------------------------------
SELECT 
    COUNT(infrastructure_damage_score) AS count_infrastructure_damage_score,
	ROUND(AVG(infrastructure_damage_score), 2) AS mean_infrastructure_damage_score,
    MIN(infrastructure_damage_score) As minimum_infrastructure_damage_score,
    MAX(infrastructure_damage_score) AS maximum_infrastructure_damage_score,
    MAX(infrastructure_damage_score) - MIN(infrastructure_damage_score) AS range_infrastructure_damage_score,
    ROUND(STDDEV(infrastructure_damage_score), 2) AS std_deviation_infrastructure_damage_score,  
    ROUND(VARIANCE(infrastructure_damage_score), 2) As variance_infrastructure_damage_score       
FROM global_climate;

-- Median Calculatios
WITH statistics AS (
    SELECT 
        infrastructure_damage_score,
        ROW_NUMBER() OVER (ORDER BY infrastructure_damage_score) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
)
SELECT 
    ROUND(AVG(CASE 
        WHEN row_num IN (FLOOR((total_count + 1) / 2), CEIL((total_count + 1) / 2)) 
        THEN infrastructure_damage_score
    END), 2) AS median_infrastructure_damage_score
    FROM statistics;

--  Mode Calculation
SELECT infrastructure_damage_score AS mode_infrastructure_damage_score
FROM global_climate
GROUP BY infrastructure_damage_score
ORDER BY COUNT(*) DESC
LIMIT 1; 

-- --------------------------------------
-- 8. Response Time Hours Column
-- --------------------------------------
SELECT 
    COUNT(response_time_hours) AS count_response_time_hours,
	ROUND(AVG(response_time_hours), 2) AS mean_response_time_hours,
    MIN(response_time_hours) As minimum_response_time_hours,
    MAX(response_time_hours) AS maximum_response_time_hours,
    MAX(response_time_hours) - MIN(response_time_hours) AS range_response_time_hours,
    ROUND(STDDEV(response_time_hours), 2) AS std_deviation_response_time_hours,  
    ROUND(VARIANCE(response_time_hours), 2) As variance_response_time_hours       
FROM global_climate;

-- Median Calculatios
WITH statistics AS (
    SELECT 
        response_time_hours,
        ROW_NUMBER() OVER (ORDER BY response_time_hours) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
)
SELECT 
    ROUND(AVG(CASE 
        WHEN row_num IN (FLOOR((total_count + 1) / 2), CEIL((total_count + 1) / 2)) 
        THEN response_time_hours
    END), 2) AS median_response_time_hours
    FROM statistics;

--  Mode Calculation
SELECT response_time_hours AS response_time_hours
FROM global_climate
GROUP BY response_time_hours
ORDER BY COUNT(*) DESC
LIMIT 1; 

-- ----------------------------------------
-- 9. International Aid Million USD Column
-- ----------------------------------------
SELECT 
    COUNT(international_aid_million_usd) AS count_international_aid_million_usd,
	ROUND(AVG(international_aid_million_usd), 2) AS mean_international_aid_million_usd,
    MIN(international_aid_million_usd) As minimum_international_aid_million_usd,
    MAX(international_aid_million_usd) AS maximum_international_aid_million_usd,
    MAX(international_aid_million_usd) - MIN(international_aid_million_usd) AS range_international_aid_million_usd,
    ROUND(STDDEV(international_aid_million_usd), 2) AS std_deviation_international_aid_million_usd,  
    ROUND(VARIANCE(international_aid_million_usd), 2) As variance_international_aid_million_usd       
FROM global_climate;

-- Median Calculatios
WITH statistics AS (
    SELECT 
        international_aid_million_usd,
        ROW_NUMBER() OVER (ORDER BY international_aid_million_usd) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
)
SELECT 
    ROUND(AVG(CASE 
        WHEN row_num IN (FLOOR((total_count + 1) / 2), CEIL((total_count + 1) / 2)) 
        THEN international_aid_million_usd
    END), 2) AS median_international_aid_million_usd
    FROM statistics;
    
--  Mode Calculation
SELECT international_aid_million_usd AS mode_international_aid_million_usd
FROM global_climate
GROUP BY international_aid_million_usd
ORDER BY COUNT(*) DESC
LIMIT 1; 

-- -----------------------------------------
-- 10. Total Casualties Column
-- -----------------------------------------
SELECT 
    COUNT(total_casualties) AS count_total_casualties,
	ROUND(AVG(total_casualties), 2) AS mean_total_casualties,
    MIN(total_casualties) As minimum_total_casualties,
    MAX(total_casualties) AS maximum_total_casualties,
    MAX(total_casualties) - MIN(total_casualties) AS range_total_casualties,
    ROUND(STDDEV(total_casualties), 2) AS std_deviation_total_casualties,  
    ROUND(VARIANCE(total_casualties), 2) As variance_total_casualties       
FROM global_climate;

-- Median Calculatios
WITH statistics AS (
    SELECT 
        total_casualties,
        ROW_NUMBER() OVER (ORDER BY total_casualties) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
)
SELECT 
    ROUND(AVG(CASE 
        WHEN row_num IN (FLOOR((total_count + 1) / 2), CEIL((total_count + 1) / 2)) 
        THEN total_casualties
    END), 2) AS median_total_casualties
    FROM statistics;
    
--  Mode Calculation
SELECT total_casualties AS mode_total_casualties
FROM global_climate
GROUP BY total_casualties
ORDER BY COUNT(*) DESC
LIMIT 1; 

-- -----------------------------------------
-- 11. Impact Per Capita Column
-- -----------------------------------------
SELECT 
    COUNT(impact_per_capita) AS count_impact_per_capita,
	ROUND(AVG(impact_per_capita), 2) AS mean_impact_per_capita,
    MIN(impact_per_capita) As minimum_impact_per_capita,
    MAX(impact_per_capita) AS maximum_impact_per_capita,
    MAX(impact_per_capita) - MIN(impact_per_capita) AS range_impact_per_capita,
    ROUND(STDDEV(impact_per_capita), 2) AS std_deviation_impact_per_capita,  
    ROUND(VARIANCE(impact_per_capita), 2) As variance_impact_per_capita       
FROM global_climate;

-- Median Calculatios
WITH statistics AS (
    SELECT 
        impact_per_capita,
        ROW_NUMBER() OVER (ORDER BY impact_per_capita) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
)
SELECT 
    ROUND(AVG(CASE 
        WHEN row_num IN (FLOOR((total_count + 1) / 2), CEIL((total_count + 1) / 2)) 
        THEN impact_per_capita
    END), 2) AS median_impact_per_capita
    FROM statistics;

--  Mode Calculation
SELECT impact_per_capita AS mode_impact_per_capita
FROM global_climate
GROUP BY impact_per_capita
ORDER BY COUNT(*) DESC
LIMIT 1; 

-- -----------------------------------------
-- 12. Aid Percentage Column
-- -----------------------------------------
SELECT 
    COUNT(aid_percentage) AS count_aid_percentage,
	ROUND(AVG(aid_percentage), 2) AS mean_aid_percentage,
    MIN(aid_percentage) As minimum_aid_percentage,
    MAX(aid_percentage) AS maximum_aid_percentage,
    MAX(aid_percentage) - MIN(aid_percentage) AS range_aid_percentage,
    ROUND(STDDEV(aid_percentage), 2) AS std_deviation_aid_percentage,  
    ROUND(VARIANCE(aid_percentage), 2) As variance_aid_percentage       
FROM global_climate;

-- Median Calculatios
WITH statistics AS (
    SELECT 
        aid_percentage,
        ROW_NUMBER() OVER (ORDER BY aid_percentage) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
)
SELECT 
    ROUND(AVG(CASE 
        WHEN row_num IN (FLOOR((total_count + 1) / 2), CEIL((total_count + 1) / 2)) 
        THEN aid_percentage
    END), 2) AS median_aid_percentage
    FROM statistics;

--  Mode Calculation
SELECT aid_percentage AS mode_aid_percentage
FROM global_climate
GROUP BY aid_percentage
ORDER BY COUNT(*) DESC
LIMIT 1; 

-- -----------------------------------------
-- Calculations to Determine Outliers
-- -----------------------------------------
-- --------------------------------------------------------------------------
-- 1. Q1, Q3 , Lower Bound and Upper Bound Calculations for Severity Column
-- --------------------------------------------------------------------------
WITH ordered_data AS (
    SELECT 
        severity,
        ROW_NUMBER() OVER (ORDER BY severity) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
),
quartiles AS (
    SELECT
        MAX(CASE WHEN row_num <= 0.25 * total_count THEN severity END) AS Q1_severity,
        MAX(CASE WHEN row_num <= 0.75 * total_count THEN severity END) AS Q3_severity
    FROM ordered_data
),
bounds AS (
    SELECT 
        Q1_severity,
        Q3_severity,
        Q3_severity - Q1_severity AS IQR_severity,
        Q1_severity - 1.5 * (Q3_severity - Q1_severity) AS lower_bound_severity,
        Q3_severity + 1.5 * (Q3_severity - Q1_severity) AS upper_bound_severity
    FROM quartiles
)
SELECT * FROM bounds;

-- **// Based on the UB, LB, Min, and Max values, THERE ARE NO OUTLIERS IN THE SEVERITY COLUMN

-- -------------------------------------------------------------------------------
-- 2. Q1, Q3 , Lower Bound and Upper Bound Calculations for Durations Days Column
-- -------------------------------------------------------------------------------
WITH ordered_data AS (
    SELECT 
        duration_days,
        ROW_NUMBER() OVER (ORDER BY duration_days) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
),
quartiles AS (
    SELECT
        MAX(CASE WHEN row_num <= 0.25 * total_count THEN duration_days END) AS Q1_duration_days,
        MAX(CASE WHEN row_num <= 0.75 * total_count THEN duration_days END) AS Q3_duration_days
    FROM ordered_data
),
bounds AS (
    SELECT 
        Q1_duration_days,
        Q3_duration_days,
        Q3_duration_days - Q1_duration_days AS IQR_duration_days,
        Q1_duration_days - 1.5 * (Q3_duration_days - Q1_duration_days) AS lower_bound_duration_days,
        Q3_duration_days + 1.5 * (Q3_duration_days - Q1_duration_days) AS upper_bound_duration_days
    FROM quartiles
)
SELECT * FROM bounds;

-- **// Based on the UB, LB, Min, and Max values, THERE ARE OUTLIERS IN THE DURATION DAYS COLUMN,
-- However due to the nature of the data some events take different and longer time periods depending on their type and severity 

-- ------------------------------------------------------------------------------------
-- 3. Q1, Q3 , Lower Bound and Upper Bound Calculations for Affected Population Column
-- ------------------------------------------------------------------------------------
WITH ordered_data AS (
    SELECT 
        affected_population,
        ROW_NUMBER() OVER (ORDER BY affected_population) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
),
quartiles AS (
    SELECT
        MAX(CASE WHEN row_num <= 0.25 * total_count THEN affected_population END) AS Q1_affected_population,
        MAX(CASE WHEN row_num <= 0.75 * total_count THEN affected_population END) AS Q3_affected_population
    FROM ordered_data
),
bounds AS (
    SELECT 
        Q1_affected_population,
        Q3_affected_population,
        Q3_affected_population - Q1_affected_population AS IQR_affected_population,
        Q1_affected_population - 1.5 * (Q3_affected_population - Q1_affected_population) AS lower_bound_affected_population,
        Q3_affected_population + 1.5 * (Q3_affected_population - Q1_affected_population) AS upper_bound_affected_population
    FROM quartiles
)
SELECT * FROM bounds;

-- **// Based on the UB, LB, Min, and Max values, THERE ARE OUTLIERS IN THE AFFECTED POPULATION COLUMN,
-- However due to the nature of the data THE AFFECTED POPULATION is one of the facts that represents the data 

-- ------------------------------------------------------------------------------------
-- 4. Q1, Q3 , Lower Bound and Upper Bound Calculations for Deaths Column
-- ------------------------------------------------------------------------------------
WITH ordered_data AS (
    SELECT 
        deaths,
        ROW_NUMBER() OVER (ORDER BY deaths) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
),
quartiles AS (
    SELECT
        MAX(CASE WHEN row_num <= 0.25 * total_count THEN deaths END) AS Q1_deaths,
        MAX(CASE WHEN row_num <= 0.75 * total_count THEN deaths END) AS Q3_deaths
    FROM ordered_data
),
bounds AS (
    SELECT 
        Q1_deaths,
        Q3_deaths,
        Q3_deaths - Q1_deaths AS IQR_deaths,
        Q1_deaths - 1.5 * (Q3_deaths - Q1_deaths) AS lower_bound_deaths,
        Q3_deaths + 1.5 * (Q3_deaths - Q1_deaths) AS upper_bound_deaths
    FROM quartiles
)
SELECT * FROM bounds;

-- **// Based on the UB, LB, Min, and Max values, THERE ARE OUTLIERS IN THE DEATHS COLUMN,
-- However due to the nature of the data THE NUMBER OF PEOPLE DIED is one of the facts that represents the data 

-- ------------------------------------------------------------------------------------
-- 5. Q1, Q3 , Lower Bound and Upper Bound Calculations for Injuries Column
-- ------------------------------------------------------------------------------------
WITH ordered_data AS (
    SELECT 
        injuries,
        ROW_NUMBER() OVER (ORDER BY injuries) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
),
quartiles AS (
    SELECT
        MAX(CASE WHEN row_num <= 0.25 * total_count THEN injuries END) AS Q1_injuries,
        MAX(CASE WHEN row_num <= 0.75 * total_count THEN injuries END) AS Q3_injuries
    FROM ordered_data
),
bounds AS (
    SELECT 
        Q1_injuries,
        Q3_injuries,
        Q3_injuries - Q1_injuries AS IQR_injuries,
        Q1_injuries - 1.5 * (Q3_injuries - Q1_injuries) AS lower_bound_injuries,
        Q3_injuries + 1.5 * (Q3_injuries - Q1_injuries) AS upper_bound_injuries
    FROM quartiles
)
SELECT * FROM bounds;

-- **// Based on the UB, LB, Min, and Max values, THERE ARE OUTLIERS IN THE INJURIES COLUMN,
-- However due to the nature of the data THE NUMBER OF INJURIES is one of the facts that represents the data 

-- ---------------------------------------------------------------------------------------------
-- 6. Q1, Q3 , Lower Bound and Upper Bound Calculations for Economic Impact Million USD Column
-- ---------------------------------------------------------------------------------------------
WITH ordered_data AS (
    SELECT 
        economic_impact_million_usd,
        ROW_NUMBER() OVER (ORDER BY economic_impact_million_usd) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
),
quartiles AS (
    SELECT
        MAX(CASE WHEN row_num <= 0.25 * total_count THEN economic_impact_million_usd END) AS Q1_economic_impact_million_usd,
        MAX(CASE WHEN row_num <= 0.75 * total_count THEN economic_impact_million_usd END) AS Q3_economic_impact_million_usd
    FROM ordered_data
),
bounds AS (
    SELECT 
        Q1_economic_impact_million_usd,
        Q3_economic_impact_million_usd,
        Q3_economic_impact_million_usd - Q1_economic_impact_million_usd AS IQR_economic_impact_million_usd,
        Q1_economic_impact_million_usd - 1.5 * (Q3_economic_impact_million_usd - Q1_economic_impact_million_usd) AS lower_bound_economic_impact_million_usd,
        Q3_economic_impact_million_usd + 1.5 * (Q3_economic_impact_million_usd - Q1_economic_impact_million_usd) AS upper_bound_economic_impact_million_usd
    FROM quartiles
)
SELECT * FROM bounds;

-- **// Based on the UB, LB, Min, and Max values, THERE ARE OUTLIERS IN THE ECONOMIC IMPACT MILLION USD COLUMN,
-- However due to the nature of the data THE ECONOMIC IMPACT MILLION USD is one of the facts that represents the data

-- ---------------------------------------------------------------------------------------------
-- 7. Q1, Q3 , Lower Bound and Upper Bound Calculations for Infrastructure Damage Score Column
-- ---------------------------------------------------------------------------------------------
WITH ordered_data AS (
    SELECT 
        infrastructure_damage_score,
        ROW_NUMBER() OVER (ORDER BY infrastructure_damage_score) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
),
quartiles AS (
    SELECT
        MAX(CASE WHEN row_num <= 0.25 * total_count THEN infrastructure_damage_score END) AS Q1_infrastructure_damage_score,
        MAX(CASE WHEN row_num <= 0.75 * total_count THEN infrastructure_damage_score END) AS Q3_infrastructure_damage_score
    FROM ordered_data
),
bounds AS (
    SELECT 
        Q1_infrastructure_damage_score,
        Q3_infrastructure_damage_score,
        Q3_infrastructure_damage_score - Q1_infrastructure_damage_score AS IQR_infrastructure_damage_score,
        Q1_infrastructure_damage_score - 1.5 * (Q3_infrastructure_damage_score - Q1_infrastructure_damage_score) AS lower_bound_infrastructure_damage_score,
        Q3_infrastructure_damage_score + 1.5 * (Q3_infrastructure_damage_score - Q1_infrastructure_damage_score) AS upper_bound_infrastructure_damage_score
    FROM quartiles
)
SELECT * FROM bounds;

-- **// Based on the UB, LB, Min, and Max values, THERE ARE OUTLIERS IN THE INFRASTRUCTURE DAMAGE SCORE COLUMN,
-- However due to the nature of the data the INFRASTRUCTURE DAMAGE SCORE is one of the facts that represents the data

-- ---------------------------------------------------------------------------------------------
-- 8. Q1, Q3 , Lower Bound and Upper Bound Calculations for Response Time Hours Column
-- ---------------------------------------------------------------------------------------------
WITH ordered_data AS (
    SELECT 
        response_time_hours,
        ROW_NUMBER() OVER (ORDER BY response_time_hours) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
),
quartiles AS (
    SELECT
        MAX(CASE WHEN row_num <= 0.25 * total_count THEN response_time_hours END) AS Q1_response_time_hours,
        MAX(CASE WHEN row_num <= 0.75 * total_count THEN response_time_hours END) AS Q3_response_time_hours
    FROM ordered_data
),
bounds AS (
    SELECT 
        Q1_response_time_hours,
        Q3_response_time_hours,
        Q3_response_time_hours - Q1_response_time_hours AS IQR_response_time_hours,
        Q1_response_time_hours - 1.5 * (Q3_response_time_hours - Q1_response_time_hours) AS lower_bound_response_time_hours,
        Q3_response_time_hours + 1.5 * (Q3_response_time_hours - Q1_response_time_hours) AS upper_bound_response_time_hours
    FROM quartiles
)
SELECT * FROM bounds;

-- **// Based on the UB, LB, Min, and Max values, THERE ARE OUTLIERS IN THE RESPONSE TIME HOURS COLUMN,
-- However due to the nature of the data THE RESPONSE TIME HOURS is one of the facts that represents the data

-- --------------------------------------------------------------------------------------------------
-- 9. Q1, Q3 , Lower Bound and Upper Bound Calculations for International Aid Million Dollars Column
-- --------------------------------------------------------------------------------------------------
WITH ordered_data AS (
    SELECT 
        international_aid_million_usd,
        ROW_NUMBER() OVER (ORDER BY international_aid_million_usd) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
),
quartiles AS (
    SELECT
        MAX(CASE WHEN row_num <= 0.25 * total_count THEN international_aid_million_usd END) AS Q1_international_aid_million_usd,
        MAX(CASE WHEN row_num <= 0.75 * total_count THEN international_aid_million_usd END) AS Q3_international_aid_million_usd
    FROM ordered_data
),
bounds AS (
    SELECT 
        Q1_international_aid_million_usd,
        Q3_international_aid_million_usd,
        Q3_international_aid_million_usd - Q1_international_aid_million_usd AS IQR_international_aid_million_usd,
        Q1_international_aid_million_usd - 1.5 * (Q3_international_aid_million_usd - Q1_international_aid_million_usd) AS lower_bound_international_aid_million_usd,
        Q3_international_aid_million_usd + 1.5 * (Q3_international_aid_million_usd - Q1_international_aid_million_usd) AS upper_bound_international_aid_million_usd
    FROM quartiles
)
SELECT * FROM bounds;

-- **// Based on the UB, LB, Min, and Max values, THERE ARE OUTLIERS IN THE INTERNATIONAL AID MILLION USD COLUMN,
-- However due to the nature of the data THERE ARE SOME COUNTRIES GET AN INTERNATIONAL AID WHILE THE OTHERS NOT

-- --------------------------------------------------------------------------------------------------
-- 10. Q1, Q3 , Lower Bound and Upper Bound Calculations for Total Casualties Column
-- --------------------------------------------------------------------------------------------------
WITH ordered_data AS (
    SELECT 
        total_casualties,
        ROW_NUMBER() OVER (ORDER BY total_casualties) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
),
quartiles AS (
    SELECT
        MAX(CASE WHEN row_num <= 0.25 * total_count THEN total_casualties END) AS Q1_total_casualties,
        MAX(CASE WHEN row_num <= 0.75 * total_count THEN total_casualties END) AS Q3_total_casualties
    FROM ordered_data
),
bounds AS (
    SELECT 
        Q1_total_casualties,
        Q3_total_casualties,
        Q3_total_casualties - Q1_total_casualties AS IQR_total_casualties,
        Q1_total_casualties - 1.5 * (Q3_total_casualties - Q1_total_casualties) AS lower_bound_total_casualties,
        Q3_total_casualties + 1.5 * (Q3_total_casualties - Q1_total_casualties) AS upper_bound_total_casualties
    FROM quartiles
)
SELECT * FROM bounds;

-- **// Based on the UB, LB, Min, and Max values, THERE ARE OUTLIERS IN THE TOTAL CASUALTIES COLUMN,
-- However due to the nature of the data THE TOTAL CASUALTIES is one of the facts that represents the data

-- --------------------------------------------------------------------------------------------------
-- 11. Q1, Q3 , Lower Bound and Upper Bound Calculations for Impact Per Capita Column
-- --------------------------------------------------------------------------------------------------
WITH ordered_data AS (
    SELECT 
        impact_per_capita,
        ROW_NUMBER() OVER (ORDER BY impact_per_capita) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
),
quartiles AS (
    SELECT
        MAX(CASE WHEN row_num <= 0.25 * total_count THEN impact_per_capita END) AS Q1_impact_per_capita,
        MAX(CASE WHEN row_num <= 0.75 * total_count THEN impact_per_capita END) AS Q3_impact_per_capita
    FROM ordered_data
),
bounds AS (
    SELECT 
        Q1_impact_per_capita,
        Q3_impact_per_capita,
        Q3_impact_per_capita - Q1_impact_per_capita AS IQR_impact_per_capita,
        Q1_impact_per_capita - 1.5 * (Q3_impact_per_capita - Q1_impact_per_capita) AS lower_bound_impact_per_capita,
        Q3_impact_per_capita + 1.5 * (Q3_impact_per_capita - Q1_impact_per_capita) AS upper_bound_impact_per_capita
    FROM quartiles
)
SELECT * FROM bounds;

-- **// Based on the UB, LB, Min, and Max values, THERE ARE OUTLIERS IN THE IMPACT PER CAPITA COLUMN,
-- However due to the nature of the data THE IMPACT PER CAPITA is one of the facts that represents the data

-- --------------------------------------------------------------------------------------------------
-- 12. Q1, Q3 , Lower Bound and Upper Bound Calculations for Aid Percentage Column
-- --------------------------------------------------------------------------------------------------
WITH ordered_data AS (
    SELECT 
        aid_percentage,
        ROW_NUMBER() OVER (ORDER BY aid_percentage) AS row_num,
        COUNT(*) OVER () AS total_count
    FROM global_climate
),
quartiles AS (
    SELECT
        MAX(CASE WHEN row_num <= 0.25 * total_count THEN aid_percentage END) AS Q1_aid_percentage,
        MAX(CASE WHEN row_num <= 0.75 * total_count THEN aid_percentage END) AS Q3_aid_percentage
    FROM ordered_data
),
bounds AS (
    SELECT 
        Q1_aid_percentage,
        Q3_aid_percentage,
        Q3_aid_percentage - Q1_aid_percentage AS IQR_aid_percentage,
        Q1_aid_percentage - 1.5 * (Q3_aid_percentage - Q1_aid_percentage) AS lower_bound_aid_percentage,
        Q3_aid_percentage + 1.5 * (Q3_aid_percentage - Q1_aid_percentage) AS upper_bound_aid_percentage
    FROM quartiles
)
SELECT * FROM bounds;

-- **// Based on the UB, LB, Min, and Max values, THERE ARE OUTLIERS IN THE AID PERCENTAGE COLUMN,
-- However due to the nature of the data THERE ARE SOME COUNTRIES GET AN INTERNATIONAL AID WHILE THE OTHERS NOT

-- ---------------------------------------
-- Data Modeling and Feature Engineering
-- ---------------------------------------
-- **// We will divide the data into one fact table (global_climate_events) and 6 dimensions tables
-- (date, location, event_type, infrastructure_damage, response_time, severity)

-- ---------------------------------
-- Creating Dimension Table (Date)
-- ---------------------------------
CREATE TABLE IF NOT EXISTS dim_date (
    date_id INT PRIMARY KEY AUTO_INCREMENT,
    full_date DATE NOT NULL,
    year INT NOT NULL,
    quarter INT,
    month INT,
    month_name VARCHAR(20),
    day INT,
    day_of_week INT,
    day_name VARCHAR(20),
    week_of_year INT,
    season VARCHAR(10),
    is_weekend BOOLEAN DEFAULT FALSE
);

INSERT INTO dim_date (full_date, year, quarter, month, month_name, day, day_of_week, day_name, week_of_year, season, is_weekend)
SELECT DISTINCT
    date AS full_date,
    year,
    QUARTER(date) AS quarter,
    month,
    MONTHNAME(date) AS month_name,
    DAY(date) AS day,
    DAYOFWEEK(date) AS day_of_week,
    DAYNAME(date) AS day_name,
    WEEKOFYEAR(date) AS week_of_year,
    CASE 
        WHEN MONTH(date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(date) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(date) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Fall'
    END AS season,
    CASE WHEN DAYOFWEEK(date) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend
FROM global_climate
WHERE date IS NOT NULL;
SELECT * FROM dim_date;

-- ------------------------------------
-- Creating Dimension Table (Location)
-- ------------------------------------
CREATE TABLE IF NOT EXISTS dim_location (
    location_id INT PRIMARY KEY AUTO_INCREMENT,
    country VARCHAR(100) NOT NULL,
    continent VARCHAR(50),
    latitude DECIMAL(10, 6),
    longitude DECIMAL(10, 6)
);

INSERT INTO dim_location (country, continent, latitude, longitude) 
SELECT DISTINCT 
    country,
    CASE 
        WHEN country IN ('Japan', 'China', 'India', 'Vietnam', 'Thailand', 'Indonesia', 'Malaysia', 'Philippines', 'Singapore', 'Bangladesh', 'South Korea', 'Kazakhstan', 'UAE', 'Qatar', 'Saudi Arabia','Israel', 'Iraq', 'Turkey', 'Pakistan') THEN 'Asia'
        WHEN country IN ('United States', 'Canada', 'Mexico') THEN 'North America'
        WHEN country IN ('Brazil', 'Argentina', 'Chile', 'Peru', 'Colombia') THEN 'South America'
        WHEN country IN ('Germany', 'France', 'United Kingdom', 'Italy', 'Spain', 'Poland', 'Netherlands', 'Belgium', 'Sweden', 'Switzerland', 'Austria', 'Portugal', 'Denmark', 'Finland', 'Ireland', 'Czech Republic', 'Hungary', 'Romania', 'Greece') THEN 'Europe'
        WHEN country IN ('Australia', 'New Zealand') THEN 'Oceania'
        WHEN country IN ('South Africa', 'Nigeria', 'Egypt') THEN 'Africa'
        ELSE 'Middle East'
    END AS continent,
    latitude,
    longitude
FROM global_climate
WHERE country IS NOT NULL;
SELECT * FROM dim_location;

-- --------------------------------------
-- Creating Dimension Table (Event Type)
-- --------------------------------------
CREATE TABLE IF NOT EXISTS dim_event_type (
    event_type_id INT PRIMARY KEY AUTO_INCREMENT,
    event_type VARCHAR(100) NOT NULL,
    event_family VARCHAR(50)
);
 
INSERT INTO dim_event_type (event_type, event_family)
SELECT DISTINCT
    event_type,
    CASE 
        WHEN event_type IN ('Hurricane', 'Tornado', 'Cyclone') THEN 'Wind Storm'
        WHEN event_type IN ('Flood', 'Tsunami') THEN 'Water Related'
        WHEN event_type IN ('Earthquake', 'Volcanic Eruption', 'Landslide') THEN 'Geological'
        WHEN event_type IN ('Heatwave', 'Cold Wave', 'Drought', 'Hailstorm') THEN 'Temperature Extreme'
        WHEN event_type IN ('Wildfire') THEN 'Fire'
        ELSE 'Other'
    END AS event_family
FROM global_climate
WHERE event_type IS NOT NULL;
SELECT * FROM dim_event_type;

-- --------------------------------------------------
-- Creating Dimension Table (Infrastructure Damage)
-- --------------------------------------------------
CREATE TABLE IF NOT EXISTS dim_infrastructure_damage (
    infrastructure_damage_id INT PRIMARY KEY AUTO_INCREMENT,
    infrastructure_damage_score DECIMAL(6, 2),
    infrastructure_damage_level VARCHAR(30)  -- No damage, Low, Medium, High, Severe
);

INSERT INTO dim_infrastructure_damage (infrastructure_damage_score, infrastructure_damage_level)
SELECT DISTINCT
    infrastructure_damage_score,
    CASE 
        WHEN infrastructure_damage_score = 0 THEN 'No damage'
        WHEN infrastructure_damage_score < 10 THEN 'Low'
        WHEN infrastructure_damage_score < 30 THEN 'Medium'
        WHEN infrastructure_damage_score < 50 THEN 'High'
        ELSE 'Severe'
    END AS infrastructure_damage_level
FROM global_climate
WHERE infrastructure_damage_score IS NOT NULL;
SELECT * FROM dim_infrastructure_damage;

-- --------------------------------------------------
-- Creating Dimension Table (Response Time)
-- --------------------------------------------------
CREATE TABLE IF NOT EXISTS dim_response_time (
    response_time_id INT PRIMARY KEY AUTO_INCREMENT,
    response_time_hours INT,
    response_time_category VARCHAR(30)  -- Fast, Normal, Slow
);

INSERT INTO dim_response_time (response_time_hours, response_time_category)
SELECT DISTINCT
    response_time_hours,
    CASE 
        WHEN response_time_hours <= 6 THEN 'Fast'
        WHEN response_time_hours <= 24 THEN 'Normal'
        ELSE 'Slow'
    END AS response_time_category
FROM global_climate
WHERE response_time_hours IS NOT NULL;
SELECT * FROM dim_response_time;

-- --------------------------------------------------
-- Creating Dimension Table (Severity)
-- --------------------------------------------------
CREATE TABLE IF NOT EXISTS dim_severity (
    severity_category_id INT PRIMARY KEY AUTO_INCREMENT,
    severity INT,
    severity_category VARCHAR(20)  -- Low, Medium, High, Severe
);

INSERT INTO dim_severity (severity, severity_category)
SELECT DISTINCT
    severity,
    CASE 
        WHEN severity <= 2 THEN 'Low'
        WHEN severity <= 4 THEN 'Medium'
        WHEN severity <= 6 THEN 'High'
        ELSE 'Severe'
    END AS severity_category
FROM global_climate
WHERE severity IS NOT NULL;
SELECT * FROM dim_severity;

-- --------------------------------------------
-- Creating Fact Table (Global Climate Events)
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS fact_global_climate_events (
    event_id VARCHAR(10) PRIMARY KEY, -- Using original event_id (EV01539, etc.)
    date_id INT NOT NULL,
    location_id INT NOT NULL,
    event_type_id INT NOT NULL,
    infrastructure_damage_id INT,
    response_time_id INT,
    severity_category_id INT,
    duration_days INT,
    affected_population INT,
    deaths INT,
    injuries INT,
    economic_impact_million_usd DECIMAL(6, 2),
    international_aid_million_usd DECIMAL(6, 2),
    total_casualties INT,
    impact_per_capita DECIMAL(4, 2),
    aid_percentage DECIMAL(4, 2),

    FOREIGN KEY (date_id) REFERENCES dim_date(date_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (event_type_id) REFERENCES dim_event_type(event_type_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (infrastructure_damage_id) REFERENCES dim_infrastructure_damage(infrastructure_damage_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (response_time_id) REFERENCES dim_response_time(response_time_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (severity_category_id) REFERENCES dim_severity(severity_category_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

INSERT IGNORE INTO fact_global_climate_events (
    event_id, date_id, location_id, event_type_id,
    infrastructure_damage_id, response_time_id, severity_category_id, 
    duration_days, affected_population, deaths, injuries,
    economic_impact_million_usd, international_aid_million_usd, total_casualties, impact_per_capita, aid_percentage
)
SELECT 
    g.event_id,
    d.date_id,
    l.location_id,
    e.event_type_id,
    id.infrastructure_damage_id,
    rt.response_time_id,
    sv.severity_category_id,
    g.duration_days,
    g.affected_population,
    g.deaths,
    g.injuries,
    g.economic_impact_million_usd,
    g.international_aid_million_usd,
    g.total_casualties,
    g.impact_per_capita,
    g.aid_percentage
FROM global_climate g
JOIN dim_date d ON g.date = d.full_date
JOIN dim_location l ON g.country = l.country 
    AND ABS(g.latitude - l.latitude) < 0.01 
    AND ABS(g.longitude - l.longitude) < 0.01
JOIN dim_event_type e ON g.event_type = e.event_type
LEFT JOIN dim_infrastructure_damage id ON g.infrastructure_damage_score = id.infrastructure_damage_score
LEFT JOIN dim_response_time rt ON g.response_time_hours = rt.response_time_hours
LEFT JOIN dim_severity sv ON g.severity = sv.severity;
-- DROP TABLE fact_global_climate_events;
SELECT * FROM fact_global_climate_events;
    
-- -------------------------------------------
-- Data Analysis
-- -------------------------------------------

-- -------------------------------------------
-- Total Events
-- -------------------------------------------
SELECT COUNT(*) AS total_events FROM fact_global_climate_events;

-- -------------------------------------------
-- Total Deaths
-- -------------------------------------------
SELECT SUM(deaths) AS total_deaths FROM fact_global_climate_events;

-- -------------------------------------------
-- Total Economic Impact (Million USD)
-- -------------------------------------------
SELECT ROUND(SUM(economic_impact_million_usd), 2) AS total_economic_impact_million_usd 
FROM fact_global_climate_events;

-- -------------------------------------------
-- Average Severity (1-10)
-- -------------------------------------------
SELECT ROUND(AVG(sv.severity), 2) AS average_severity 
FROM fact_global_climate_events f
JOIN dim_severity sv ON f.severity_category_id = sv.severity_category_id;

-- -------------------------------------------
-- Average Response Time (Hours)
-- -------------------------------------------
SELECT ROUND(AVG(rt.response_time_hours), 1) AS average_response_time_hours 
FROM fact_global_climate_events f
JOIN dim_response_time rt ON f.response_time_id = rt.response_time_id;

-- -------------------------------------------
-- Most Deadly Event
-- -------------------------------------------
SELECT 
    f.event_id,
    et.event_type AS event_type,
    f.deaths
FROM fact_global_climate_events f
JOIN dim_event_type et ON f.event_type_id = et.event_type_id
ORDER BY f.deaths DESC
LIMIT 1;

-- -------------------------------------------
-- Most Common Event Type
-- -------------------------------------------
SELECT et.event_type, COUNT(*) AS event_count
FROM fact_global_climate_events f
JOIN dim_event_type et ON f.event_type_id = et.event_type_id
GROUP BY et.event_type
ORDER BY event_count DESC
LIMIT 1;

-- -------------------------------------------
-- Costliest Event
-- -------------------------------------------
SELECT 
    f.event_id,
    et.event_type,
    et.event_family,
    l.country,
    ROUND(f.economic_impact_million_usd, 2) AS economic_impact_million_usd
FROM fact_global_climate_events f
JOIN dim_event_type et ON f.event_type_id = et.event_type_id
JOIN dim_location l ON f.location_id = l.location_id
ORDER BY f.economic_impact_million_usd DESC
LIMIT 1;

-- -------------------------------------------
-- Country with Most Events
-- -------------------------------------------
SELECT 
    l.country,
    COUNT(*) AS total_events,
    (
        SELECT ev.event_type
        FROM fact_global_climate_events f2
        JOIN dim_location l2 ON f2.location_id = l2.location_id
        JOIN dim_event_type ev ON f2.event_type_id = ev.event_type_id
        WHERE l2.country = l.country
        GROUP BY ev.event_type
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) AS most_common_event_type
FROM fact_global_climate_events f
JOIN dim_location l ON f.location_id = l.location_id
GROUP BY l.country
ORDER BY total_events DESC
LIMIT 1;

-- -------------------------------------------
-- Deadliest Event Type
-- -------------------------------------------
SELECT et.event_type, SUM(f.deaths) AS total_deaths
FROM fact_global_climate_events f
JOIN dim_event_type et ON f.event_type_id = et.event_type_id
GROUP BY et.event_type
ORDER BY total_deaths DESC
LIMIT 1;

-- -------------------------------------------
-- Year with Most Events
-- -------------------------------------------
SELECT d.year, COUNT(*) AS event_count
FROM fact_global_climate_events f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year
ORDER BY event_count DESC
LIMIT 1;

-- -------------------------------------------
-- Season with Most Events
-- -------------------------------------------
SELECT d.season, COUNT(*) AS event_count
FROM fact_global_climate_events f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.season
ORDER BY event_count DESC
LIMIT 1;

-- -------------------------------------------
-- Total Affected Population
-- -------------------------------------------
SELECT SUM(affected_population) AS total_affected_population 
FROM fact_global_climate_events;

-- -------------------------------------------
-- Average Infrastructure Damage Score
-- -------------------------------------------
SELECT ROUND(AVG(infrastructure_damage_score), 2) AS avg_infrastructure_damage_score 
FROM dim_infrastructure_damage;

-- -------------------------------------------------
-- Percentage of Events Receiving International Aid
-- -------------------------------------------------
SELECT ROUND(SUM(CASE WHEN international_aid_million_usd > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS percentage_with_aid
FROM fact_global_climate_events;

-- -------------------------------------------
-- Yearly Trend (Years Comparison)
-- -------------------------------------------
SELECT 
    d.year,
    COUNT(*) AS event_count,
    SUM(f.deaths) AS total_deaths,
    SUM(f.injuries) AS total_injuries,
    ROUND(AVG(f.economic_impact_million_usd), 2) AS avg_impact_million_USD,
    ROUND(AVG(sv.severity), 2) AS avg_severity,
    ROUND(AVG(rt.response_time_hours), 2) AS avg_response_hours
FROM fact_global_climate_events f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_severity sv ON f.severity_category_id = sv.severity_category_id
JOIN dim_response_time rt ON f.response_time_id = rt.response_time_id
GROUP BY d.year
ORDER BY d.year;

-- -------------------------------------------
-- Monthly Events
-- -------------------------------------------
SELECT 
    d.month_name,
    COUNT(*) AS event_count,
    SUM(f.deaths) AS total_deaths,
    ROUND(AVG(f.economic_impact_million_usd), 2) AS avg_impact_million_USD,
    ROUND(AVG(sv.severity), 2) AS avg_severity
FROM fact_global_climate_events f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_severity sv ON f.severity_category_id = sv.severity_category_id
GROUP BY d.month, d.month_name
ORDER BY d.month;

-- -------------------------------------------
-- Event Types by Season
-- -------------------------------------------
SELECT 
    et.event_type,
    SUM(CASE WHEN d.season = 'Spring' THEN 1 ELSE 0 END) AS Spring,
    SUM(CASE WHEN d.season = 'Summer' THEN 1 ELSE 0 END) AS Summer,
    SUM(CASE WHEN d.season = 'Fall' THEN 1 ELSE 0 END) AS Fall,
    SUM(CASE WHEN d.season = 'Winter' THEN 1 ELSE 0 END) AS Winter,
    COUNT(*) AS total_events
FROM fact_global_climate_events f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_event_type et ON f.event_type_id = et.event_type_id
GROUP BY et.event_type
ORDER BY total_events DESC;

-- -------------------------------------------
-- Seasonal Events Analysis
-- -------------------------------------------
SELECT 
    d.season,
    COUNT(*) AS event_count,
    SUM(f.deaths) AS total_deaths,
    SUM(f.injuries) AS total_injuries,
    ROUND(SUM(f.economic_impact_million_usd), 2) AS total_impact,
    ROUND(AVG(sv.severity), 2) AS avg_severity,
    ROUND(AVG(f.duration_days), 2) AS avg_duration_days
FROM fact_global_climate_events f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_severity sv ON f.severity_category_id = sv.severity_category_id
GROUP BY d.season
ORDER BY event_count DESC;

-- --------------------------------------------
-- Total Economic Impact by Continent and Year
-- --------------------------------------------
SELECT 
    dl.continent,
    dd.year,
    ROUND(SUM(f.economic_impact_million_usd), 2) AS total_economic_impact_million_USD,
    SUM(f.deaths) AS total_deaths,
    COUNT(f.event_id) AS event_count
FROM fact_global_climate_events f
JOIN dim_location dl ON f.location_id = dl.location_id
JOIN dim_date dd ON f.date_id = dd.date_id
GROUP BY dl.continent, dd.year
ORDER BY dl.continent, dd.year;

-- --------------------------------------------
-- Most Severe Event Types by Region
-- --------------------------------------------
SELECT 
    dl.continent,
    et.event_type,
    ROUND(AVG(sv.severity), 2) AS avg_severity,
    SUM(f.total_casualties) AS total_casualties,
    ROUND(SUM(f.economic_impact_million_usd), 2) AS total_economic_impact
FROM fact_global_climate_events f
JOIN dim_location dl ON f.location_id = dl.location_id
JOIN dim_event_type et ON f.event_type_id = et.event_type_id
JOIN dim_severity sv ON f.severity_category_id = sv.severity_category_id
GROUP BY dl.continent, et.event_type
ORDER BY avg_severity DESC;

-- --------------------------------------------
-- Response Time Analysis by Severity
-- --------------------------------------------
SELECT 
    sv.severity_category,
    ROUND(AVG(rt.response_time_hours), 2) AS avg_response_time_hr,
    MIN(rt.response_time_hours) AS min_response_time_hr,
    MAX(rt.response_time_hours) AS max_response_time_hr,
    COUNT(*) AS event_count
FROM fact_global_climate_events f
JOIN dim_severity sv ON f.severity_category_id = sv.severity_category_id
JOIN dim_response_time rt ON f.response_time_id = rt.response_time_id
GROUP BY sv.severity_category
ORDER BY avg_response_time_hr;

-- --------------------------------------------
-- Seasonal Patterns of Disasters
-- --------------------------------------------
SELECT 
    d.season,
    et.event_type,
    COUNT(*) AS event_count,
    SUM(f.deaths) AS total_deaths,
    ROUND(AVG(f.economic_impact_million_usd), 2) AS avg_economic_impact_million_USD
FROM fact_global_climate_events f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_event_type et ON f.event_type_id = et.event_type_id
GROUP BY d.season, et.event_type  
ORDER BY event_count DESC;

-- --------------------------------------------
-- Most Dangerous Event Types
-- --------------------------------------------
SELECT 
    et.event_type,
    COUNT(f.event_id) AS occurrence_count,
    SUM(f.deaths) AS total_deaths,
    SUM(f.injuries) AS total_injuries,
    ROUND(AVG(sv.severity), 2) AS avg_severity,
    ROUND(SUM(f.economic_impact_million_usd), 2) AS total_impact_million_USD
FROM fact_global_climate_events f
JOIN dim_event_type et ON f.event_type_id = et.event_type_id
JOIN dim_severity sv ON f.severity_category_id = sv.severity_category_id
GROUP BY et.event_type
ORDER BY total_deaths DESC;

-- --------------------------------------------
-- Most Dangerous Event Types by Continent
-- --------------------------------------------
SELECT 
    l.continent,
    et.event_type,
    COUNT(*) AS occurrence_count,
    SUM(f.deaths) AS total_deaths,
    ROUND(AVG(f.deaths), 2) AS avg_deaths_per_event,
    ROUND(SUM(f.economic_impact_million_usd), 2) AS total_impact_million_USD,
    ROUND(AVG(sv.severity), 2) AS avg_severity
FROM fact_global_climate_events f
JOIN dim_location l ON f.location_id = l.location_id
JOIN dim_event_type et ON f.event_type_id = et.event_type_id
JOIN dim_severity sv ON f.severity_category_id = sv.severity_category_id
GROUP BY l.continent, et.event_type
ORDER BY total_deaths DESC, total_impact_million_USD DESC
LIMIT 20;

-- ----------------------------------------------
-- Top 10 Most Affected Countries (Economically)
-- ----------------------------------------------
SELECT 
    l.country,
    l.continent,
    COUNT(*) AS event_count,
    SUM(f.deaths) AS total_deaths,
    SUM(f.injuries) AS total_injuries,
    SUM(f.affected_population) AS total_affected_population,
    ROUND(SUM(f.economic_impact_million_usd), 2) AS total_economic_impact_million_USD,
    ROUND(AVG(rt.response_time_hours), 2) AS avg_response_time_hr,
    ROUND(AVG(sv.severity), 2) AS avg_severity
FROM fact_global_climate_events f
JOIN dim_location l ON f.location_id = l.location_id
JOIN dim_severity sv ON f.severity_category_id = sv.severity_category_id
JOIN dim_response_time rt ON f.response_time_id = rt.response_time_id
GROUP BY l.country, l.continent
ORDER BY total_economic_impact_million_USD DESC
LIMIT 10;

-- --------------------------------------------------
-- Which Events Have Fastest/Slowest Response Times?
-- --------------------------------------------------
SELECT 
    et.event_type,
    COUNT(*) AS event_count,
    ROUND(AVG(rt.response_time_hours), 2) AS avg_response_hours,
    MIN(rt.response_time_hours) AS fastest_response_hours,
    MAX(rt.response_time_hours) AS slowest_response_hours,
    ROUND(AVG(id.infrastructure_damage_score), 2) AS avg_damage_score,
    ROUND(AVG(f.deaths), 2) AS avg_deaths
FROM fact_global_climate_events f
JOIN dim_event_type et ON f.event_type_id = et.event_type_id
JOIN dim_response_time rt ON f.response_time_id = rt.response_time_id
JOIN dim_infrastructure_damage id ON f.infrastructure_damage_id = id.infrastructure_damage_id
GROUP BY et.event_type
ORDER BY avg_response_hours;

-- --------------------------------------------------
-- Impact Severity by Continent and Season
-- --------------------------------------------------
SELECT 
    l.continent,
    d.season,
    COUNT(*) AS event_count,
    SUM(f.deaths) AS total_deaths,
    ROUND(SUM(f.economic_impact_million_usd), 2) AS total_impact_million_USD,
    ROUND(AVG(sv.severity), 2) AS avg_severity,
    ROUND(AVG(f.duration_days), 2) AS avg_duration_days
FROM fact_global_climate_events f
JOIN dim_location l ON f.location_id = l.location_id
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_severity sv ON f.severity_category_id = sv.severity_category_id
GROUP BY l.continent, d.season
ORDER BY l.continent, d.season;

-- ------------------------------------------------------
-- Is Faster Response Time Correlated with Lower Impact?
-- ------------------------------------------------------
SELECT 
    rt.response_time_category,
    COUNT(*) AS event_count,
    ROUND(AVG(f.deaths), 2) AS avg_deaths,
    ROUND(AVG(f.economic_impact_million_usd), 2) AS avg_economic_impact_million_USD,
    ROUND(AVG(id.infrastructure_damage_score), 2) AS avg_damage_score,
    ROUND(AVG(sv.severity), 2) AS avg_severity
FROM fact_global_climate_events f
JOIN dim_response_time rt ON f.response_time_id = rt.response_time_id
JOIN dim_infrastructure_damage id ON f.infrastructure_damage_id = id.infrastructure_damage_id
JOIN dim_severity sv ON f.severity_category_id = sv.severity_category_id
GROUP BY rt.response_time_category
ORDER BY avg_economic_impact_million_USD;

-- ------------------------------------------------------
-- Top 5 Deadliest Events Each Year
-- ------------------------------------------------------
WITH deadliest_events AS (
    SELECT 
        d.year,
        f.event_id,
        l.country,
        et.event_type,
        f.deaths,
        f.economic_impact_million_usd,
        ROW_NUMBER() OVER (PARTITION BY d.year ORDER BY f.deaths DESC) AS rank_num
    FROM fact_global_climate_events f
    JOIN dim_date d ON f.date_id = d.date_id
    JOIN dim_location l ON f.location_id = l.location_id
    JOIN dim_event_type et ON f.event_type_id = et.event_type_id
    WHERE f.deaths > 0
)
SELECT 
    year,
    rank_num,
    event_id,
    country,
    event_type,
    deaths,
    ROUND(economic_impact_million_usd, 2) AS economic_impact_million_USD
FROM deadliest_events
WHERE rank_num <= 5
ORDER BY year, rank_num;

-- ------------------------------------------------------
-- Does International Aid Reduce Impact?
-- ------------------------------------------------------
SELECT 
    CASE 
        WHEN f.international_aid_million_usd > 0 THEN 'Aid given'
        ELSE 'Without Aid'
    END AS aid_status,
    COUNT(*) AS event_count,
    ROUND(AVG(f.deaths), 2) AS avg_deaths,
    ROUND(AVG(f.economic_impact_million_usd), 2) AS avg_impact_million_USD,
    ROUND(AVG(id.infrastructure_damage_score), 2) AS avg_damage_score,
    ROUND(AVG(rt.response_time_hours), 0) AS avg_response_time
FROM fact_global_climate_events f
JOIN dim_infrastructure_damage id ON f.infrastructure_damage_id = id.infrastructure_damage_id
JOIN dim_response_time rt ON f.response_time_id = rt.response_time_id
GROUP BY aid_status;

-- -------------------------------------------
-- Events Where Aid Coverage Was Most Effective
--    (High aid percentage relative to economic impact)
-- -------------------------------------------
SELECT 
    f.event_id,
    l.country,
    et.event_type,
    ROUND(f.economic_impact_million_usd, 2) AS economic_impact_million_usd,
    ROUND(f.international_aid_million_usd, 2) AS international_aid_million_usd,
    ROUND(f.aid_percentage, 2) AS aid_percentage
FROM fact_global_climate_events f
JOIN dim_location l ON f.location_id = l.location_id
JOIN dim_event_type et ON f.event_type_id = et.event_type_id
WHERE f.international_aid_million_usd > 0
ORDER BY f.aid_percentage DESC
LIMIT 10;

-- -------------------------------------------
-- 2. Most Economically Burdened Populations
--    (Highest impact per capita by country)
-- -------------------------------------------
SELECT 
    l.country,
    l.continent,
    COUNT(*) AS event_count,
    ROUND(AVG(f.impact_per_capita), 2) AS avg_impact_per_capita,
    ROUND(SUM(f.economic_impact_million_usd), 2) AS total_economic_impact_million_usd,
    SUM(f.affected_population) AS total_affected_population
FROM fact_global_climate_events f
JOIN dim_location l ON f.location_id = l.location_id
GROUP BY l.country, l.continent
ORDER BY avg_impact_per_capita DESC
LIMIT 10;

-- -------------------------------------------
-- 3. Total Casualties vs Aid Percentage by Event Type
--    (Do deadlier events attract more international aid?)
-- -------------------------------------------
SELECT 
    et.event_type,
    et.event_family,
    SUM(f.total_casualties) AS total_casualties,
    ROUND(AVG(f.aid_percentage), 2) AS avg_aid_percentage,
    ROUND(AVG(f.impact_per_capita), 2) AS avg_impact_per_capita,
    COUNT(*) AS event_count
FROM fact_global_climate_events f
JOIN dim_event_type et ON f.event_type_id = et.event_type_id
GROUP BY et.event_type, et.event_family
ORDER BY total_casualties DESC;

-- -------------------------------------------
-- 4. High Impact Per Capita but Low Aid Coverage
--    (Underserved events that needed more aid)
-- -------------------------------------------
SELECT 
    f.event_id,
    l.country,
    et.event_type,
    sv.severity_category,
    ROUND(f.impact_per_capita, 2) AS impact_per_capita,
    ROUND(f.aid_percentage, 2) AS aid_percentage,
    f.total_casualties
FROM fact_global_climate_events f
JOIN dim_location l ON f.location_id = l.location_id
JOIN dim_event_type et ON f.event_type_id = et.event_type_id
JOIN dim_severity sv ON f.severity_category_id = sv.severity_category_id
WHERE f.impact_per_capita > (SELECT AVG(impact_per_capita) FROM fact_global_climate_events)
  AND f.aid_percentage < (SELECT AVG(aid_percentage) FROM fact_global_climate_events)
ORDER BY f.impact_per_capita DESC
LIMIT 10;
