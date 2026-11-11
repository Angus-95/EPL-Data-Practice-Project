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
