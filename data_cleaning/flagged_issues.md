## Incorrect attendance

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
From the 100 matchday attendances checked, 90 were found to match the new fbref data, while 10 matched the original dataset. All 10 of these matches took place prior to 2007, and the attendances differed by less than 1000 in every case. I could also find records with contrasting information matching both the original and FBref figures for these matches. As such, the disparity was put down to differences in data recording methods at the time.
