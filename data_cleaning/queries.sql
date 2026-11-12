-- Query 1: An initial query to find the top 10 highhest attendances.

SELECT Season, Year, Month, Day, HomeTeam, AwayTeam, Attendance, HomeStadium
FROM epl_match_data
ORDER BY Attendance DESC
LIMIT 10;

-- The matches listed by this query raised some issues.

-- Query 2: Create Unique ID for each match
-- As I'm going to be adding a new table with fresh attendance data to the dataset, I will need a better method of generation than the simple incrementing digits
-- I originally created when uploading the data. As teams play each other only once at home per season, a [Season] [Home Team] [AwayTeam] code is guaranteed to be
-- unique. to avoid using full team names a separate dataset was uploaded containing the standardized three letter abbreviations (tri codes) for each team - e.g.
-- Manchester United = MUN. The season is then concatenated with these tri codes to generate the match IDs.
-- Example code: Charlton vs Manchester City in the 2000/2001 season becomes "00/01CHAMCI".

SELECT m.season,
m.hometeam,
m.awayteam,
CONCAT(
    m.season,
    h.tri_code,
    a.tri_code
) AS MatchID_2

FROM epl_match_data AS m

LEFT JOIN teams AS h            -- First left join adds the home tri code
ON m.HomeTeam = h.team_name
LEFT JOIN teams AS a            -- And the second adds the away team.
ON m.AwayTeam = a.team_name;

-- Query 3: Check that all Match IDs are unique before updating table - no rows returned means no duplicate IDs

SELECT MatchID_2, count(*) AS IDcount
FROM (
    SELECT
        CONCAT(
            m.season,
            h.tri_code,
            a.tri_code
        ) AS MatchID_2
    FROM epl_match_data AS m
    LEFT JOIN teams AS h
    ON m.HomeTeam = h.team_name
    LEFT JOIN teams AS a
    ON m.AwayTeam = a.team_name
)
GROUP BY MatchID_2
HAVING IDcount > 1;

-- Query 4: Update dataset to add the new codes.

UPDATE epl_match_data AS m
LEFT JOIN teams AS h
ON m.hometeam = h.team_name
LEFT JOIN teams AS a
ON m.awayteam = a.team_name
SET m.MatchID = CONCAT(
    m.season,
    h.tri_code,
    a.tri_code
);                        -- This process was repeated on the other tables in the dataset.

-- Query 5: Compare both attendance recoords to identify discrepancies
-- Out of 9880 entries, 3776 discrepancies were found.

SELECT COUNT(*)
FROM epl_match_data AS e
JOIN true_attendance AS ta
ON e.MatchID = ta.MatchID
WHERE e.attendance != ta.attendance; 

-- 440 of these discrepancies were found to be during the 19/20 and 20/21 seasons, where matches were played without fans due to the COVID-19 pandemic.

SELECT COUNT(*)
FROM true_attendance
WHERE (attendance IS NULL AND season = "19/20")
OR (attendance IS NULL AND season = "20/21");
