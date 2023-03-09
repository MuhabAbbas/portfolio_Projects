# Summer Olympics
[Dataset_link](https://www.dropbox.com/s/3sxwx52o3x8ozj7/olympic_games.bak?dl=0)

## SQL Codes

SELECT [ID]
      ,[Name] as [Compititor Name]
      ,case when sex = 'M' then 'Male' 
	    when sex = 'F' then 'Female' end as Gender
      ,[Age]
      ,case when age < 18 then 'Under 18'
	    when age between 18 and 25 then '18-25'
	    when AGE BETWEEN 25 AND 30 THEN '25-30'
	    when AGE > 30 THEN 'Over 30' end as [Age Grouping]
      ,[Height]
      ,[Weight]
      ,[NOC] as 'Nation Code'
      ,LEFT(games,4) as Year
      ,[Sport]
      ,[Event]
      ,case when medal = 'NA' then 'Not registered' else medal end as Medal
 FROM [olympic_games].[dbo].[athletes_event_results]
 where right(games, CHARINDEX(' ', reverse(games))-1) = 'Summer'
