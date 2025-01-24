-- models/closure_rate_per_group.sql

WITH date_parts AS (
    SELECT * 
    FROM {{ ref('extracted_createddate') }}  -- Referencing the previous model
)
SELECT 
    assignmentgroup,
    ROUND(
        CASE 
            WHEN COUNT(*) = 0 THEN 0 
            ELSE (COUNT(CASE WHEN state = 'Closed' THEN 1 END) / COUNT(*)::float)::numeric 
        END, 
        2
    ) AS closure_rate
FROM date_parts
GROUP BY assignmentgroup
