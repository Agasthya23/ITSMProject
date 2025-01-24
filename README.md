# DBT Ticketing Data Project

This project involves transforming raw ticket data into actionable insights by cleaning, aggregating, and summarizing the data. The project uses DBT to manage the data transformations and build models.

## Overview

The project is structured into multiple DBT models that transform raw ticketing data into several derived datasets for reporting. These models aim to provide insights such as:

- Average resolution time per category and priority.
- Closure rate per assignment group.
- Monthly ticket summary including total tickets, average resolution time, and closure rate.

## Assumptions in `processeddata.sql`:

### *Handling Missing `inc_cmdb_ci` Values:*
For incidents where the `inc_cmdb_ci` (Configuration Item) field is missing (`NULL`), the value is derived based on specific conditions. The approach involves:
1. If the `inc_business_service` is related to certain keywords (e.g., "nxgen tech. business services", "nxgen erp sfa") **and** the `inc_short_description` contains a colon or period, we assume that the `inc_cmdb_ci` value can be extracted from the short description.
2. If the incident's category is `Workstation`, the `inc_cmdb_ci` is populated with the `inc_assignment_group` value.
3. If the short description mentions keywords like `service-now` or `roger questionnaires`, predefined values such as `'ServiceNow'` and `'Roger Questionnaires'` are assigned to `inc_cmdb_ci`.
4. For other incidents with missing `inc_cmdb_ci`, it falls back to the existing `inc_cmdb_ci` if it's available, otherwise leaving it as `NULL`.

### *Handling Missing or Unformatted `inc_short_description`:*
For incidents with missing `inc_short_description`, we extract the first portion of the `inc_close_notes` before any colon (`:`) or period (`.`) and use that as the short description. This is especially useful for incidents where the short description wasn't captured correctly but a relevant piece of information is available in the close notes.

### *Filling `inc_resolved_at` for Unresolved Incidents:*
For incidents where the `inc_resolved_at` timestamp is missing (i.e., unresolved incidents), we assign a default future date (`'9999-12-31'`) to indicate that the resolution is pending and the incident has not yet been resolved.

These transformations ensure the data is clean and ready for further analysis, minimizing missing or NULL values.

## Models

The following DBT models are defined in this project:

### 1. `processeddata.sql`
This model processes raw ticket data and applies several transformations, including:
- Filling in missing `inc_cmdb_ci` values based on conditions related to the short description, category, or assignment group.
- Handling `inc_short_description` and `inc_close_notes` where values are missing or need formatting.
- Calculating `inc_resolved_at` when it's missing for unresolved incidents.

#### Output:
- A cleaned and processed dataset with ticket data ready for further analysis.

### 2. `extracted_createddate.sql`
This model extracts year, month, and day from the `createdate` to facilitate time-based aggregations. It is based on the `processeddata` model.

#### Output:
- A dataset with extracted date parts (year, month, day).

### 3. `avg_resolution_time.sql`
This model calculates the average resolution time (in hours) for tickets grouped by category and priority.

#### Output:
- A dataset containing `category`, `priority`, and their respective average resolution time.

### 4. `closure_rate.sql`
This model calculates the closure rate for each assignment group based on the proportion of closed tickets.

#### Output:
- A dataset containing `assignmentgroup` and the calculated closure rate.

### 5. `monthly_ticket_summary.sql`
This model aggregates monthly ticket data by joining the `extracted_createddate`, `avg_resolution_time`, and `closure_rate` models. It calculates:
- Total tickets for each month.
- Average resolution time per month.
- Average closure rate per month.

#### Output:
- A dataset summarizing monthly ticketing data.

## Assumptions

- The project assumes that the raw data is stored in a table called `raw_tickets`.
- The ticket data includes fields like `inc_business_service`, `inc_category`, `inc_number`, `inc_state`, `inc_priority`, `inc_assignment_group`, and others.
- All DBT models reference each other in a chain (i.e., `processeddata` → `extracted_createddate` → `avg_resolution_time` → `closure_rate` → `monthly_ticket_summary`).

## Instructions for Running Locally

### 1. Install DBT
You need to install DBT to run the models. You can install DBT using pip:

```bash
pip install dbt
