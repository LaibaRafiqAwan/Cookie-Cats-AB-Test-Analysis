CREATE DATABASE cookie_cats_ab_test;

USE cookie_cats_ab_test;
SELECT COUNT(*) AS total_users
FROM cookie_cats;
SELECT *
FROM cookie_cats
LIMIT 10;
SELECT 
    version,
    COUNT(*) AS users
FROM cookie_cats
GROUP BY version;
SELECT
    userid,
    version,
    sum_gamerounds,
    retention_1,
    retention_7
FROM cookie_cats
ORDER BY sum_gamerounds DESC
LIMIT 10;
SELECT
    userid,
    version,
    sum_gamerounds,
    RANK() OVER (
        ORDER BY sum_gamerounds DESC
    ) AS engagement_rank
FROM cookie_cats
LIMIT 10;
SELECT
    ROUND(AVG(sum_gamerounds), 2) AS avg_with_outlier
FROM cookie_cats;
SELECT
    ROUND(AVG(sum_gamerounds), 2) AS avg_without_outlier
FROM cookie_cats
WHERE sum_gamerounds < 49854;
SELECT
    version,
    COUNT(*) AS users,

    ROUND(
        100.0 * SUM(CASE WHEN retention_1 = 'TRUE' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS day1_retention_pct,

    ROUND(
        100.0 * SUM(CASE WHEN retention_7 = 'TRUE' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS day7_retention_pct,

    ROUND(AVG(
        CASE 
            WHEN sum_gamerounds < 49854 
            THEN sum_gamerounds
        END
    ), 2) AS avg_game_rounds

FROM cookie_cats
GROUP BY version;
WITH engagement_segments AS (
    SELECT
        userid,
        version,
        sum_gamerounds,
        retention_7,

        NTILE(4) OVER (
            ORDER BY sum_gamerounds
        ) AS engagement_quartile

    FROM cookie_cats
    WHERE sum_gamerounds < 49854
)

SELECT
    engagement_quartile,
    COUNT(*) AS users,
    ROUND(AVG(sum_gamerounds), 2) AS avg_rounds,

    ROUND(
        100.0 * SUM(
            CASE WHEN retention_7 = 'TRUE' THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
    ) AS day7_retention_pct

FROM engagement_segments
GROUP BY engagement_quartile
ORDER BY engagement_quartile;