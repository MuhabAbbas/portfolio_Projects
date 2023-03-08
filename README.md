# Bellabeat
[Dataset_link](https://www.kaggle.com/datasets/kyle007hendricks/bellabeat-dataset)

## SQL Code
-- Checking NULL values:
SELECT * 
	FROM [dbo].dailyActivity_merged$
	WHERE id is null
		or ActivityDate is null
		or TotalSteps is null
		or TotalDistance is null
		or LoggedActivitiesDistance is null
		or VeryActiveDistance is null
		or ModeratelyActiveDistance is null
		or LightActiveDistance is null
		or SedentaryActiveDistance is null
		or VeryActiveMinutes is null
		or FairlyActiveMinutes is null 
		or LightlyActiveMinutes is null
		or [SedentaryMinutes] is null
		or [Calories] is null;

--Average steps, distance and Calories burned per day:

WITH avg_table AS (
	SELECT
      DISTINCT Id,
      CAST(AVG(TotalSteps) AS INT) AS daily_avg_steps,
      AVG(TotalDistance) AS daily_avg_distance,
      CAST(AVG(Calories) AS INT) AS daily_avg_calories
	FROM [dbo].[dailyActivity_merged$]
      
	GROUP BY Id)

	SELECT 
      CAST(AVG(daily_avg_steps) AS INT) AS avg_steps,
      ROUND(AVG(daily_avg_distance), 2) AS avg_distance,
      CAST(AVG(daily_avg_calories) AS INT) AS avg_calories
	FROM avg_table;

-- Steps
-- average steps per days of the week

WITH avg_steps AS(
	SELECT  *, datepart(DW, ActivityDay) as day_of_week
	FROM [dbo].[dailySteps_merged$])
	,avg_steps1 AS(
	SELECT case when day_of_week = 1 then 'Sunday'
            when day_of_week = 2 then 'Monday'
			when day_of_week = 3 then 'Tuesday'
			when day_of_week = 4 then 'Wednesday'
			when day_of_week = 5 then 'Thursday'
			when day_of_week = 6 then 'Friday'
			Else 'Saturday' 
			end as Week_day, [StepTotal],day_of_week
	FROM avg_steps)
	SELECT Week_day, ROUND(avg([StepTotal]),2) as avg_daily_steps
	FROM avg_steps1
	GROUP BY Week_day
	ORDER BY avg_daily_steps DESC

-- are the users active or somewhat active?

WITH user_status AS(
	SELECT id, round(avg(steptotal),2) avg_steps
	FROM [dbo].[dailySteps_merged$]
	GROUP BY id)
	SELECT id, avg_steps, CASE WHEN avg_steps < 7500 THEN 'Inactive'
							   WHEN avg_steps <= 9999 THEN 'Somewhat active'
							   ELSE 'Acvtive' end as statement
	FROM user_status

-- how many inactive users?

SELECT count(statement) AS No_of_inactive
FROM status_table
WHERE statement= 'Inactive';

-- hourly steps

select cast(avg(StepTotal) as int) as avg_steps,datepart(HH, ActivityHour) as hour
from [dbo].[hourlySteps_merged$]
group by datepart(HH, ActivityHour)
order by 1 desc

-- Sleep
-- The most and least day of the week

with sleep1 as(
	select *,datepart(DW,[SleepDay]) as day_of_week
	from [dbo].[sleepDay_merged$]),
sleep2 as(
	select *,case when day_of_week = 1 then 'Sunday'
				  when day_of_week = 2 then 'Monday'
				  when day_of_week = 3 then 'Tuesday'
				  when day_of_week = 4 then 'Wednesday'
				  when day_of_week = 5 then 'Thursday'
				  when day_of_week = 6 then 'Friday'
				  Else 'Saturday' 
				  end as Week_day
	from sleep1
)
select week_day, round(avg([TotalMinutesAsleep]),0) as avg_sleep_per_day
from sleep2
group by week_day
order by 2 desc

--Calories
-- number of users

select count(distinct id) as number_of_users
from [dbo].[hourlyCalories_merged$]

-- number of days

with table1 as (
	select *, datepart(DAY,ActivityHour) as day
	from [dbo].[hourlyCalories_merged$])
select count(distinct day) days
from table1

-- Average Calories burned per hour

with table1 as(
	select *,datepart(HH,ActivityHour) as time_hour
	from [dbo].[hourlyCalories_merged$])
select time_hour, round(avg(calories),2) as Avg_calories
from table1
group by time_hour
order by 2 desc

-- average calories per hour

select round(avg(Calories),2) as avg_calories
from [dbo].[hourlyCalories_merged$]

-- average calories per day

select round(avg(calories),2) as avg_calories
from [dbo].[dailyCalories_merged$]

-- Per Day of the week

with calo1 as(
	select *,datepart(DW, ActivityDay) as day_of_week
	from [dbo].[dailyCalories_merged$]), calo2 as(
	select *, case when day_of_week = 1 then 'Sunday'
				   when day_of_week = 2 then 'Monday'
				   when day_of_week = 3 then 'Tuesday'
				   when day_of_week = 4 then 'Wednesday'
				   when day_of_week = 5 then 'Thursday'
				   when day_of_week = 6 then 'Friday'
				   Else 'Saturday' end as Week_day
	from calo1)
select round(avg(calories),2) as avg_calories, Week_day
from calo2
group by Week_day
order by 1 desc

--Activity

with activity1 as(
	SELECT Id, ActivityDate, SUM(VeryActiveMinutes + FairlyActiveMinutes) AS active_zone_minutes
	FROM [dbo].[dailyActivity_merged$]
	GROUP BY Id, ActivityDate),activity2 as(
	SELECT DISTINCT Id, ROUND(SUM(active_zone_minutes)/COUNT(ActivityDate), 2) AS avg_act_per_user
	FROM activity1
	GROUP BY Id),activity3 as(
	SELECT *, CASE WHEN avg_act_per_user >= 22 THEN 'Goal Completed'
               ELSE 'Goal Incomplete' END AS goal_status
	from activity2)
SELECT COUNT(goal_status) as goal_completed
from activity3
where goal_status = 'Goal Completed'

-- Engagement of user

with act1 as(
	SELECT DISTINCT Id, COUNT(ActivityDate) AS active_days, SUM(VeryActiveMinutes + FairlyActiveMinutes +  LightlyActiveMinutes + SedentaryMinutes)/60 as total_hr_usage
	FROM [dbo].[dailyActivity_merged$]
	GROUP BY Id), act2 as(
	select *, CASE WHEN active_days >= 25 AND total_hr_usage >= 595 THEN 'Highly Engaged User'
				   WHEN active_days >= 16 AND total_hr_usage >= 380 THEN 'Moderately Engaged User'
                   WHEN active_days >= 1 AND total_hr_usage >= 24 THEN 'Low Engaged User'
                   END AS type_of_user
	from act1)
select type_of_user, count(*) as No_of_users
from act2
group by type_of_user
order by No_of_users desc

-- Users who have an Average Healthy sleep, complete their Daily steps goal and Daily active minutes

with actsleep1 as(
	SELECT DISTINCT s.Id, ActivityDate, TotalSteps, SUM(VeryActiveMinutes + FairlyActiveMinutes) AS active_min,
	TotalMinutesAsleep
	FROM [dbo].[dailyActivity_merged$] a
	INNER JOIN [dbo].[sleepDay_merged$] s
	ON a.Id = s.Id
	AND a.ActivityDate = s.SleepDay
	GROUP BY s.Id, ActivityDate, TotalSteps, TotalMinutesAsleep),actsleep2 as(
	SELECT DISTINCT Id, ROUND(AVG(TotalSteps), 0) AS avg_steps,
       ROUND(AVG(active_min), 2) AS avg_act_min,
	   ROUND(AVG(TotalMinutesAsleep), 2) AS sleep_min
	from Actsleep1
	group by Id), actsleep3 as(
	select *, case WHEN avg_steps >= 7500 AND avg_act_min >= 22 AND sleep_min BETWEEN 420 AND 540 THEN 'All 3'
				   WHEN avg_steps >= 7500 AND avg_act_min >= 22 AND sleep_min NOT BETWEEN 420 AND 540 THEN 'Only 2'
                   WHEN avg_steps < 7500 AND avg_act_min >= 22  AND sleep_min  BETWEEN 420 AND 540 THEN 'Only 2'
                   WHEN avg_steps >= 7500 AND avg_act_min < 22  AND sleep_min  BETWEEN 420 AND 540 THEN 'Only 2'
				   WHEN avg_steps >= 7500 AND avg_act_min < 22 AND sleep_min NOT BETWEEN 420 AND 540 THEN 'Only 1'
				   WHEN avg_steps < 7500 AND avg_act_min >= 22 AND sleep_min NOT BETWEEN 420 AND 540 THEN 'Only 1'
				   WHEN avg_steps < 7500 AND avg_act_min < 22 AND sleep_min BETWEEN 420 AND 540 THEN 'Only 1'
				   ELSE 'None' END AS goal_completed
	from actsleep2)
select goal_completed, count(*) as No_of_users
from actsleep3
group by goal_completed

--Average Height, Weight(kg) and BMI

with summary as(    
	SELECT Id, ROUND(SQRT(AVG(WeightKg)/AVG(BMI))*100, 2) AS height_in_cm,
			   ROUND(AVG(BMI), 2) AS bmi,
			   ROUND(AVG(WeightKg), 2) AS weight_kg
	FROM [dbo].[weightLogInfo_merged$]
	GROUP BY Id)
SELECT ROUND(AVG(height_in_cm), 2) AS avg_height_in_cm,
       ROUND(AVG(bmi), 2) AS avg_bmi,
       ROUND(AVG(weight_kg), 2) AS avg_weight_kg,
       MAX(height_in_cm) AS max_height_in_cm,
       MIN(height_in_cm) AS min_height_in_cm,
       MAX(bmi) AS max_bmi,
       MIN(bmi) AS min_bmi,
       MAX(weight_kg) AS max_weight_kg,
       MIN(weight_kg) AS min_weight_kg
FROM summary
