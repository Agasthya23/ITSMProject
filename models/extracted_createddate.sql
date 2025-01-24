WITH cleaned_data AS (
    SELECT * 
    FROM {{ ref('processed_data') }}  -- Reference the first model properly
)
SELECT
    businessservice,
    incnumber,
    category,
	state,
    priority,
    assignmentgroup,
    createdate,
    EXTRACT(YEAR FROM createdate) AS createdyear,
    EXTRACT(MONTH FROM createdate) AS createdmonth,
    EXTRACT(DAY FROM createdate) AS createdday,
    resolveddate
FROM cleaned_data
