--- To Import files by creating a SCHEMA and TABLES for each of the files/Datasets.
CREATE SCHEMA Beat

CREATE TABLE Beat.Daily_Activities
(ID				Bigint NOT Null,
Activity_Date			Date,
Total_Steps			Int,
Total_Distance			Decimal,
Tracker_Distance		Decimal,
Logged_Activity_Distance	Decimal,
Very_Active_Distance		Decimal,
Moderate_Active_Distance	Decimal,
Light_Active_Distance		Decimal,
Sedentary_Active_Distance	Decimal,
Very_Active_Minutes		Int,
Fairly_Active_Minutes		Int,
Lightly_Active_Minutes		Int,
Sedentary_Active_Minutes	Int,
Calories			Int)

COPY Beat.Daily_Activities
FROM '/Users/DieuMerci/dailyActivity_merged.csv'
DELIMITER ',' CSV HEADER;

SELECT * FROM Beat.Daily_Activities

CREATE TABLE Beat.Daily_Sleep
(ID				Bigint NOT Null,
Sleep_Day			Timestamp,
Total_Sleep_Records		Int,
Total_Minute_Asleep		Int,
Tracker_Time_In_Bed		Int)

COPY Beat.Daily_Sleep
FROM '/Users/DieuMerci/sleepDay_merged.csv'
DELIMITER ',' CSV HEADER;

SELECT * FROM Beat.Daily_Sleep

CREATE TABLE Beat.Minute_Sleep
(ID				Bigint NOT Null,
Date				Timestamp,
Value				Int,
Log_Id				Bigint)

COPY Beat.Minute_Sleep
FROM '/Users/DieuMerci/minuteSleep_merged.csv'
DELIMITER ',' CSV HEADER;

SELECT * FROM Beat.Minute_Sleep

CREATE TABLE Beat.Hourly_Steps
(ID				Bigint NOT Null,
Activity_Hour			Timestamp,
Step_Total			Int)

COPY Beat.Hourly_Steps
FROM '/Users/DieuMerci/hourlySteps_merged.csv'
DELIMITER ',' CSV HEADER;

SELECT * FROM Beat.Hourly_Steps

--- To check for duplicates in Daily_Sleep & Minute_Sleep Tables
WITH Dup AS(
SELECT *,
    ROW_NUMBER() OVER(PARTITION BY id, sleep_day, total_sleep_records, total_minute_asleep,
	tracker_time_in_bed 
        ORDER BY id, sleep_day,  total_sleep_records, total_minute_asleep,
	tracker_time_in_bed
        ) AS Row_Number
FROM Beat.Daily_Sleep)
SELECT * FROM Dup WHERE Row_Number <> 1

SELECT id, date, value, log_id,
	COUNT(*)
FROM Beat.Minute_sleep
GROUP BY 1, 2, 3, 4
HAVING COUNT(*) > 1

--- To remove duplicates from daily_sleep and Minute_Sleep tables
SELECT *
INTO Daily_Sleep_1
FROM(select DISTINCT id, sleep_day, total_sleep_records, total_minute_asleep,
	tracker_time_in_bed
	from Beat.Daily_Sleep) y

SELECT * FROM Daily_Sleep_1

SELECT *
INTO Minute_Sleep_1
FROM(select DISTINCT id, date, value, log_id
	from Beat.Minute_sleep) z

SELECT * FROM Minute_Sleep_1

--- To analyze Summary Statistics For Daily Activity and Daily Sleep tables
/* First Quartile (Q1) is the 25th percentile while Third Quartile (Q3) is 75th percentile */
WITH RECURSIVE Summary_Stat AS(
SELECT
PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY total_steps) AS "Q1_total_steps",
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY total_steps) AS "Q3_total_steps",
PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY total_distance) AS "Q1_total_distance",
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY total_distance::int) AS "Q3_total_distance",
PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY sedentary_active_minutes) AS "Q1_sedentary_minutes",
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY sedentary_active_minutes) AS "Q3_sedentary_minutes",
PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY calories) AS "Q1_Calories",
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY calories) AS "Q3_Calories",
PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY total_sleep_records) AS "Q1_total_sleep_records",
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY total_sleep_records) AS "Q3_total_sleep_records",
PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY total_minute_asleep) AS "Q1_total_minute_asleep",
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY total_minute_asleep) AS "Q3_total_minute_asleep"
FROM Beat.Daily_Activities
JOIN Daily_Sleep_1 USING (Id)),
First_Third_Quartile AS(
SELECT 1 AS "S/N", 'Q1_total_steps' AS "Statistic", "Q1_total_steps" AS "Value"
FROM Summary_Stat
UNION 
SELECT 2,
'Q3_total_steps', "Q3_total_steps"
FROM Summary_Stat
UNION
SELECT 3, 'Q1_total_distance', "Q1_total_distance"
FROM Summary_Stat
UNION
SELECT 4, 'Q3_total_distance', "Q3_total_distance"
FROM Summary_Stat
UNION
SELECT 5, 'Q1_sedentary_minutes', "Q1_sedentary_minutes"
FROM Summary_Stat
UNION
SELECT 6, 'Q3_sedentary_minutes', "Q3_sedentary_minutes"
FROM Summary_Stat
UNION
SELECT 7, 'Q1_Calories', "Q1_Calories"
FROM Summary_Stat
UNION
SELECT 8, 'Q3_Calories', "Q3_Calories"
FROM Summary_Stat
UNION
SELECT 9, 'Q1_total_sleep_records', "Q1_total_sleep_records"
FROM Summary_Stat
UNION
SELECT 10, 'Q3_total_sleep_records', "Q3_total_sleep_records"
FROM Summary_Stat
UNION
SELECT 11, 'Q1_total_minute_asleep', "Q1_total_minute_asleep"
FROM Summary_Stat
UNION
SELECT 12, 'Q3_total_minute_asleep', "Q3_total_minute_asleep"
FROM Summary_Stat)
SELECT * FROM First_Third_Quartile
ORDER BY "S/N"

--- To analyze the summary statistic of Total_Steps
WITH RECURSIVE Summary_Stats AS(
  SELECT 
  ROUND(AVG(total_steps), 2) AS mean,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_steps) AS median,
  MIN(total_steps) AS min,
  MAX(total_steps) AS max,
  MAX(total_steps) - MIN(total_steps) AS range,
  ROUND(STDDEV(total_steps), 2) AS standard_deviation,
  ROUND(VARIANCE(total_steps), 2) AS variance
FROM Beat.Daily_Activities),
Compiling_Summary_Stats AS(
SELECT 1 AS "S/N", 'mean' AS "Statistic", mean AS "Value" 
FROM Summary_Stats
UNION
SELECT 2, 'median', median 
FROM Summary_Stats
UNION
SELECT 3, 'minimum', min 
FROM Summary_Stats
UNION
SELECT 4, 'maximum', max 
FROM Summary_Stats
UNION
SELECT 5, 'range', range 
FROM Summary_Stats
UNION
SELECT 6, 'standard deviation', standard_deviation 
FROM Summary_Stats
UNION
SELECT 7, 'variance', variance 
FROM Summary_Stats
UNION
SELECT 8, 'skewness', 
 ROUND(3 * (mean - median)::NUMERIC / standard_deviation, 2) AS skewness 
FROM Summary_Stats)
SELECT * 
FROM Compiling_Summary_Stats
ORDER BY "S/N";

--- To analyze the number of steps and percentage of number of steps taken daily by users
WITH Daily_Steps AS(
SELECT
CASE 
	WHEN EXTRACT(isodow FROM activity_date) = 1 THEN 'Sunday'
	WHEN EXTRACT(isodow FROM activity_date) = 2 THEN 'Monday'
	WHEN EXTRACT(isodow FROM activity_date) = 3 THEN 'Tuseday'
	WHEN EXTRACT(isodow FROM activity_date) = 4 THEN 'Wednesday'
	WHEN EXTRACT(isodow FROM activity_date) = 5 THEN 'Thurday'
	WHEN EXTRACT(isodow FROM activity_date) = 6 THEN 'Friday'
	ELSE 'Saturday'
END AS "Day_of_Week",
SUM(Total_steps) "No_of_Steps"
FROM Beat.Daily_Activities
GROUP BY 1
ORDER BY 2 DESC)
SELECT *, 
	CONCAT(ROUND("No_of_Steps" * 100.00/(select sum("No_of_Steps") from Daily_Steps), 2), '%') "Percentage"
FROM Daily_Steps

--- To analyze the number of steps taken per hour by users and it's percentage
WITH Steps_Analysis AS(
SELECT *,
SPLIT_PART(activity_hour::varchar, ' ', 2) AS Time
FROM Beat.Hourly_Steps),
Hourly_Analysis AS(
SELECT SUM(step_total) AS Hourly_Steps, time::time
FROM Steps_Analysis 
GROUP BY 2)
SELECT time,
	hourly_steps, 
	CONCAT(ROUND(hourly_steps * 100.00/(select sum(hourly_steps) from Hourly_Analysis), 2), '%') "Percentage_Hourly_Step"
FROM Hourly_Analysis
ORDER BY 1

--- To analyze how long users take to nap during the day using Minute_Sleep table
SELECT Id, sleep_start "Sleep_Date",
COUNT(log_id) "Number_of_Naps",
SUM(EXTRACT(HOUR FROM date::timestamp)) "Total_Sleep_Time"
FROM(select Id, Log_Id, date,
	min(date::date) AS sleep_start,
	max(date::date) AS sleep_end,
	EXTRACT(HOUR FROM (MAX(date)::timestamp - MIN(date)::timestamp)),
	MOD(EXTRACT(MINUTE FROM (MAX(date)::timestamp - MIN(date)::timestamp)), 60),
	MOD(MOD(EXTRACT(SECOND FROM (MAX(date)::timestamp - MIN(date)::timestamp)), 3600), 60) AS time_sleeping
	from Minute_Sleep_1
	WHERE value = 1
	group by 1, 2, 3) X
WHERE
sleep_start = sleep_end
GROUP BY 1, 2
ORDER BY 3 DESC

--- To analyze the total number of steps, Max, Min, Avg Steps and percentile taken by users based on the time of day and day of week
WITH Day_Week_Time_Analysis AS(
SELECT
Id,
EXTRACT(isodow FROM activity_hour) AS "DOW_Number",
to_char(activity_hour, 'Day') AS "Day_of_Week",
CASE
WHEN TRIM(to_char(activity_hour, 'Day')) IN ('Sunday', 'Saturday') THEN 'Weekend'	
WHEN TRIM(to_char(activity_hour, 'Day')) NOT IN ('Sunday', 'Saturday') THEN 'Weekday'
ELSE 'Nil'
END AS "Part_of_Week",
CASE
 WHEN EXTRACT(HOUR FROM activity_hour::timestamp) >= 06 AND EXTRACT(HOUR FROM activity_hour::timestamp) < 12 THEN 'Morning'
 WHEN EXTRACT(HOUR FROM activity_hour::timestamp) >= 12 AND EXTRACT(HOUR FROM activity_hour::timestamp) <= 16 THEN 'Afternoon'
 WHEN EXTRACT(HOUR FROM activity_hour::timestamp) > 16 AND EXTRACT(HOUR FROM activity_hour::timestamp) <= 20 THEN 'Evening'
ELSE 'Night'
END AS "Time_of_Day",
step_total AS "Total_Steps",
step_total AS "Average_Steps",
step_total AS "Max_Steps",
step_total AS "Min_Steps"
FROM Beat.Hourly_Steps),
Steps_Deciles AS(
SELECT
DISTINCT "Day_of_Week", "Part_of_Week", "Time_of_Day",
CAST(PERCENTILE_CONT(0.7) WITHIN GROUP(ORDER BY "Total_Steps") AS int) AS "Seventh_Deciles",
CAST(PERCENTILE_CONT(0.8) WITHIN GROUP(ORDER BY "Total_Steps") AS int) AS "Eight_Deciles",
CAST(PERCENTILE_CONT(0.9) WITHIN GROUP(ORDER BY "Total_Steps") AS int) AS "Ninth_Decile"
FROM Day_Week_Time_Analysis
GROUP BY 1, 2, 3),
Analytics_Summary AS(
SELECT
"Part_of_Week", "Day_of_Week", "Time_of_Day",
SUM("Total_Steps") AS "Total_Steps",
CAST(AVG("Average_Steps") AS int) AS "Average_Steps",
Max("Max_Steps") AS "Max_Steps",
MIN("Min_Steps") AS "Min_Steps"
FROM Day_Week_Time_Analysis
GROUP BY 1, 2, 3)
SELECT *
FROM Analytics_Summary 
LEFT JOIN Steps_Deciles
USING("Part_of_Week", "Day_of_Week", "Time_of_Day")
ORDER BY 1, 2

--- To analyze the relationship b/w total daily steps and calories burnt
WITH Calories_Burnt AS(
SELECT
CASE 
	WHEN EXTRACT(isodow FROM activity_date) = 1 THEN 'Sunday'
	WHEN EXTRACT(isodow FROM activity_date) = 2 THEN 'Monday'
	WHEN EXTRACT(isodow FROM activity_date) = 3 THEN 'Tuseday'
	WHEN EXTRACT(isodow FROM activity_date) = 4 THEN 'Wednesday'
	WHEN EXTRACT(isodow FROM activity_date) = 5 THEN 'Thursday'
	WHEN EXTRACT(isodow FROM activity_date) = 6 THEN 'Friday'
	ELSE 'Saturday'
END AS "Day_of_Week",
SUM(Total_steps) "No_of_Steps", SUM(calories) "Calories"
FROM Beat.Daily_Activities
GROUP BY 1
ORDER BY 2 DESC)
SELECT DISTINCT "No_of_Steps", "Calories",
	CONCAT(ROUND("Calories" * 100.00/(select sum("Calories") from Calories_Burnt), 2), '%') "Percentage_Calories"
FROM Calories_Burnt
ORDER BY 1 DESC

--- To analyze the relationship between total active minutes and calories burnt by users daily, and its percentage
WITH Active_Minutes AS(
SELECT 
	CASE 
	WHEN EXTRACT(isodow FROM activity_date) = 1 THEN 'Sunday'
	WHEN EXTRACT(isodow FROM activity_date) = 2 THEN 'Monday'
	WHEN EXTRACT(isodow FROM activity_date) = 3 THEN 'Tuseday'
	WHEN EXTRACT(isodow FROM activity_date) = 4 THEN 'Wednesday'
	WHEN EXTRACT(isodow FROM activity_date) = 5 THEN 'Thursday'
	WHEN EXTRACT(isodow FROM activity_date) = 6 THEN 'Friday'
	ELSE 'Saturday'
END AS "Day_of_Week",
(fairly_active_minutes + very_active_minutes + lightly_active_minutes) "Total_Active_Minutes",
calories
FROM Beat.Daily_Activities),
Calories_Percent AS(
SELECT "Day_of_Week", SUM("Total_Active_Minutes") "Total_Active_Minutes", SUM(calories) "Calories"
FROM Active_Minutes
GROUP BY 1)
SELECT *,
	CONCAT(ROUND("Calories" * 100.00/(select sum("Calories") from Calories_Percent), 2), '%') "Percentage_Calories"
FROM Calories_Percent

--- To analyze the relationship between daily Minutes asleep and time in bed by users
SELECT 
	CASE 
	WHEN EXTRACT(isodow FROM sleep_day) = 1 THEN 'Sunday'
	WHEN EXTRACT(isodow FROM sleep_day) = 2 THEN 'Monday'
	WHEN EXTRACT(isodow FROM sleep_day) = 3 THEN 'Tuseday'
	WHEN EXTRACT(isodow FROM sleep_day) = 4 THEN 'Wednesday'
	WHEN EXTRACT(isodow FROM sleep_day) = 5 THEN 'Thursday'
	WHEN EXTRACT(isodow FROM sleep_day) = 6 THEN 'Friday'
	ELSE 'Saturday'
	END AS "Week_Day",
	SUM(total_minute_asleep) "Minute_Asleep", SUM(tracker_time_in_bed) "Time_In_Bed"
FROM Daily_Sleep_1
GROUP BY 1

--- Relationship between hourly steps and calories burnt
WITH Calories_Analysis AS(
SELECT hs.step_total, hs.activity_hour, ds.calories,
	SPLIT_PART(activity_hour::varchar, ' ', 2) AS Time
FROM Beat.Daily_Activities ds
JOIN Beat.Hourly_Steps hs
USING(Id)),
Hourly_Analysis AS(
SELECT DISTINCT time::time, SUM(step_total) AS Hourly_Steps, SUM(calories) AS "Calories_Count"
FROM Calories_Analysis
GROUP BY 1)
SELECT *,
	CONCAT(ROUND("Calories_Count" * 100.00/(select sum("Calories_Count") from Hourly_Analysis), 2), '%') "Percentage_Calories_Count"
FROM Hourly_Analysis
