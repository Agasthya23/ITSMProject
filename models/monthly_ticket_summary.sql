-- models/monthly_ticket_summary.sql
WITH closure_rate AS (
    SELECT * 
    FROM {{ ref('closure_rate') }}  
),
avg_resolution AS (
    SELECT * 
    FROM {{ ref('avg_resolution_time') }} 
),
date_parts AS (
    SELECT * 
    FROM {{ ref('extracted_createddate') }} 
)
SELECT
    date_parts.createdyear,
    date_parts.createdmonth,
    COUNT(*) AS total_tickets,
    ROUND(AVG(avg_resolution.avg_resolution_time_hours), 2) AS avg_resolution_time,
    ROUND(AVG(closure_rate.closure_rate), 2) AS avg_closure_rate
FROM date_parts
JOIN avg_resolution ON date_parts.category = avg_resolution.category
                   AND date_parts.priority = avg_resolution.priority
JOIN closure_rate ON date_parts.assignmentgroup = closure_rate.assignmentgroup
GROUP BY date_parts.createdyear, date_parts.createdmonth
