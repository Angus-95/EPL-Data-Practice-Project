-- Query 1: An initial query to find the top 10 highhest attendances.

SELECT Season, Year, Month, Day, HomeTeam, AwayTeam, Attendance, HomeStadium
FROM epl_match_data
ORDER BY Attendance DESC
LIMIT 10;

-- The matches listed by this query raised some issues.
