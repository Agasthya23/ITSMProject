WITH base_data AS (
    SELECT DISTINCT * 
    FROM raw_tickets
),

processed_data AS (
    SELECT 
        *,

        -- Consolidated Logic for inc_cmdb_ci
        CASE
            WHEN inc_cmdb_ci IS NULL 
                 AND (LOWER(inc_business_service) LIKE 'nxgen tech. business services%' 
                      OR LOWER(inc_business_service) LIKE 'nxgen erp sfa%')
                 AND (inc_short_description LIKE '%:%' OR inc_short_description LIKE '%.%')
            THEN 
                CASE
                    WHEN POSITION(':' IN inc_short_description) > 0 THEN 
                        SUBSTRING(inc_short_description FROM 1 FOR POSITION(':' IN inc_short_description) - 1)
                    WHEN POSITION('.' IN inc_short_description) > 0 THEN 
                        SUBSTRING(inc_short_description FROM 1 FOR POSITION('.' IN inc_short_description) - 1)
                END
            
            WHEN inc_cmdb_ci IS NULL 
                 AND inc_category = 'Workstation'
            THEN inc_assignment_group

            WHEN inc_cmdb_ci IS NULL
                 AND LOWER(inc_short_description) LIKE '%service-now%' 
                 AND LOWER(inc_short_description) LIKE '%access%'
            THEN 'ServiceNow'
            
            WHEN inc_cmdb_ci IS NULL
                 AND LOWER(inc_short_description) LIKE '%roger questionnaires%'
            THEN 'Roger Questionnaires'
            
            WHEN inc_cmdb_ci IS NULL
                 AND LOWER(inc_short_description) LIKE 'other%'
            THEN inc_assignment_group

            ELSE inc_cmdb_ci
        END AS updated_inc_cmdb_ci,

        -- Handle NULL in Short Description
        CASE
            WHEN inc_short_description IS NULL
            THEN TRIM(SUBSTRING(inc_close_notes, 1, POSITION(':' IN inc_close_notes) - 1))
            ELSE inc_short_description
        END AS updated_inc_short_description,

        -- Handle Close Notes and Close Code with ELSE
        CASE
            WHEN inc_resolved_at IS NOT NULL AND (inc_close_notes IS NULL OR TRIM(inc_close_notes) = '') AND inc_state = 'Closed'
            THEN 'Issue resolved'
            WHEN inc_close_notes IS NULL AND inc_state = 'Canceled'
            THEN 'Incident Canceled'
            WHEN inc_close_notes IS NULL AND inc_state IN ('In Progress', 'New', 'On Hold')
            THEN 'Not Applicable'
            ELSE inc_close_notes -- Add ELSE to retain original value
        END AS updated_inc_close_notes,

        CASE
            WHEN inc_resolved_at IS NOT NULL AND (inc_close_code IS NULL OR TRIM(inc_close_code) = '') AND inc_state = 'Closed'
            THEN 'Other not on list'
            WHEN inc_close_code IS NULL AND inc_state = 'Canceled'
            THEN 'Incident Canceled'
            WHEN inc_close_code IS NULL AND inc_state IN ('In Progress', 'New', 'On Hold')
            THEN 'Not Applicable'
            ELSE inc_close_code -- Add ELSE to retain original value
        END AS updated_inc_close_code,

        -- Handle unresolved incidents
        CASE
            WHEN inc_resolved_at IS NULL AND inc_state != 'Closed'
            THEN '9999-12-31'
        END AS updated_inc_resolved_at
        
    FROM base_data
)
	SELECT
    id, 
    inc_business_service AS businessservice, 
    inc_category AS category, 
    inc_number AS incnumber,
    inc_priority AS priority,
    inc_sys_created_on::DATE AS createdate,
    inc_resolved_at::DATE AS resolveddate,
    inc_assigned_to AS assignedto,
    inc_state AS state,
    updated_inc_cmdb_ci AS cmdbci,
    inc_caller_id AS callerid,
    updated_inc_short_description AS shortdescription,
	inc_assignment_group AS assignmentgroup,
    updated_inc_close_code AS closecode,
    updated_inc_close_notes AS closenotes
FROM processed_data 
ORDER BY createdate

