WITH date_parts AS (
    SELECT * 
    FROM {{ ref('extracted_createddate') }}  -- Reference to extract year, month, and day for aggregation later
)

SELECT
    category,
    priority,
    ROUND(AVG((resolveddate - createdate) * 24), 2) AS avg_resolution_time_hours
FROM date_parts
WHERE resolveddate IS NOT NULL
GROUP BY category, priority

