# Incorrect attendance

An initial query looking at the top 10 highest attendances in the dataset showed incorrect attendances.

```
SELECT Season, Year, Month, Day, HomeTeam, AwayTeam, Attendance, HomeStadium
FROM epl_match_data
ORDER BY Attendance DESC
LIMIT 10;
```

|Season|Year|Month|Day|HomeTeam |AwayTeam  |Attendance|HomeStadium              |
|------|----|-----|---|---------|----------|----------|-------------------------|
|17/18 |2018|2    |10 |Tottenham|Arsenal   |83014     |Wembley Stadium          |
|17/18 |2018|1    |31 |Tottenham|Man United|81771     |Wembley Stadium          |
|18/19 |2019|3    |2  |Tottenham|Arsenal   |81332     |Tottenham Hotspur Stadium|
|16/17 |2016|10   |2  |Tottenham|Man City  |80553     |White Hart Lane          |
|18/19 |2018|9    |15 |Tottenham|Liverpool |80188     |Wembley Stadium          |
|18/19 |2019|1    |13 |Tottenham|Man United|80062     |Tottenham Hotspur Stadium|
|17/18 |2017|10   |22 |Tottenham|Liverpool |80000     |Wembley Stadium          |
|17/18 |2018|1    |4  |Tottenham|West Ham  |76313     |Wembley Stadium          |
|16/17 |2016|10   |29 |Tottenham|Leicester |76268     |White Hart Lane          |
|16/17 |2016|11   |19 |Tottenham|West Ham  |76263     |White Hart Lane          |

As the maximum capacity of White Hart Lane was only 36,284, I knew these values had to be incorrect.
[An online match report](https://www.espn.com/soccer/match/_/gameId/450943/manchester-city-tottenham-hotspur) for the Tottenham - Man City match on October 2nd 2016 confirmed my suspicions. The correct value should be 31,793.

In order to ensure data validity a new attendance data table was created using data from [FBRef](https://fbref.com/en/comps/9/history/Premier-League-Seasons) for cross-referencing.
When comparing the two tables the problem became more clear, with some matches off by over 50,000 attendees.

```
SELECT
    e.season,
    ta.date,
    e.hometeam,
    e.awayteam,
    e.attendance AS original_attendance,
    ta.attendance AS new_attendance,
    ABS(e.attendance - ta.attendance) AS attendance_diff
FROM epl_match_data AS e
JOIN true_attendance AS ta
ON e.matchid = ta.matchid
ORDER BY attendance_diff DESC
LIMIT 10;
```
|season|date|hometeam|awayteam|original_attendance|new_attendance|attendance_diff|
|------|----|--------|--------|-------------------|--------------|---------------|
|21/22 |2022-03-12|Man United|Tottenham|2000               |73458         |71458          |
|21/22 |2022-02-26|Man United|Watford |2000               |73152         |71152          |
|21/22 |2022-02-12|Man United|Southampton|2000               |73084         |71084          |
|23/24 |2023-12-26|Man United|Aston Villa|6500               |73574         |67074          |
|23/24 |2024-01-14|Man United|Tottenham|10000              |73489         |63489          |
|19/20 |2019-12-26|Man United|Newcastle|10669              |73206         |62537          |
|25/26 |2025-12-06|Bournemouth|Chelsea |73677              |11240         |62437          |
|23/24 |2023-12-31|Tottenham|Bournemouth|2000               |61780         |59780          |
|23/24 |2023-12-23|West Ham|Man United|4988               |64472         |59484          |
|21/22 |2022-02-27|West Ham|Wolves  |2000               |59946         |57946          |

To ensure validity of the new data, a random sample of 100 matches was generated and checked manually against the attendances listed at [ESPN](www.espn.com).
From the 100 matchday attendances checked, 90 were found to match the new fbref data, while 10 matched the original dataset. All 10 of these matches took place prior to 2007, and the attendances differed by less than 1000 in every case. I could also find records with contrasting information matching both the original and FBref figures for these matches. As such, the disparity was put down to differences in data recording methods at the time. This analysis will proceed using the FBRef-sourced attendance data.

## FBref null values

During data validation, a total of 959 entries in the new attendance data were found to be blank. They were separated by season to troubleshoot.

```
SELECT
    COALESCE(e.season, "Total") AS season,
    COUNT(e.season) AS null_count
FROM epl_match_data AS e
JOIN true_attendance AS ta
ON e.matchid = ta.matchid
WHERE ta.attendance IS NULL
GROUP BY ROLLUP(e.season)
ORDER BY GROUPING(e.season) ASC, e.season ASC;
```
|season|null_count|
|------|----------|
|07/08 |370       |
|08/09 |141       |
|09/10 |7         |
|10/11 |1         |
|19/20 |92        |
|20/21 |348       |
|Total |959       |

- **2007/2008**
- **2008/2009**
- **2009/2010**
- **2010/2011**

  The single missing record was also missing on ESPN, so was instead identified on [11v11]([https://www.espn.co.uk/football/match/_/gameId/293170/aston-villa-west-ham-united](https://www.11v11.com/matches/west-ham-united-v-aston-villa-16-april-2011-294390/)) and updated accordingly.
  ```
  UPDATE true_attendance
  SET attendance = 34672
  WHERE matchid = "10/11WHUAVL";
  ```
  
- **2019/2020**
  
  The 92 missing values reflect the 92 games played with no fans due to the COVID-19 pandemic, as confirmed in [this Guardian article](https://www.theguardian.com/football/2020/apr/29/premier-leagues-project-restart-what-is-it-and-is-it-feasible). NULL values amended to 0 to reflect this.
  ```
  UPDATE true_attendance
  SET attendance = 0
  WHERE attendance IS NULL
  AND season = "19/20";
  ```
  
- **2020/2021**
  
  The entirety of the 2020/2021 season was played behind closed doors due to the COVID-19 pandemic, with the exception of 15 matches during December 2020, and 20 matches during May 2021, as confirmed on [ESPN.com](https://www.espn.com/soccer/schedule/_/date/20210518/league/eng.1). Following the logic from the previous season, this should leave 345 NULL values, while 348 were recorded. Checking which non-null values were recorded in December 2020 returned only 12 results instead of 15. A manual check on ESPN found three matches on December 20th 2020 were incorrectly recorded as null, when 2000 fans were present.
  ```
  SELECT ta.season, ta.date, ta.home, ta.away, ta.attendance, e.month
  FROM true_attendance AS ta
  JOIN epl_match_data AS e
  ON ta.matchid = e.matchid
  WHERE ta.attendance IS NOT NULL
  AND ta.season = "20/21"
  AND e.month = 12;
  ```
  The three missing matches were identified and corrected to the correct value of 2,000. all 345 other values were amended to 0.
  ```
  UPDATE true_attendance
  SET attendance = 2000
  WHERE matchID IN ("20/21SOUMCI", "20/21EVEARS", "20/21BHASHU");
  
  UPDATE true_attendance
  SET attendance = 0
  WHERE season = "20/21"
  AND attendance IS NULL;
  ```
  
  

