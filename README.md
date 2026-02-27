
# Retail Sales Intelligence Warehouse (Snowflake)

## Overview
End-to-end SQL Data Warehouse project using Snowflake and TPCDS dataset.

## Architecture
Bronze → Silver → Gold layered design

## Features
- SCD Type 2 implementation
- Incremental loading
- Fact pre-aggregation
- Query optimization using partition pruning
- Query profiling

## Tech Stack
- Snowflake
- SQL
- Mermaid (Architecture diagrams)
- Git & GitHub

## Project Structure
See `/sql` for implementation scripts.


## CI/CD Workflow

Branch Strategy:
- dev → Development
- main → Production-ready

Deployment Process:
1. Develop changes in dev branch.
2. Run data quality tests (09_data_quality_tests.sql).
3. Validate results.
4. Create Pull Request.
5. Merge to main after review.

All changes must pass validation checks before merge.


## 🎨 Dashboard Design & UX Workflow

The dashboard layout and visual hierarchy were first prototyped in Figma before implementation in Metabase.

Design ideation was assisted using structured AI prompts to:
- Generate layout concepts
- Optimize visual hierarchy
- Define KPI placement
- Improve readability and executive storytelling

The final implementation was recreated in Metabase based on the approved Figma wireframe.


## 🧠 Design Process

1. Defined business KPIs from Gold layer.
2. Created wireframe layout in Figma.
3. Used prompt engineering to generate:
   - Executive-focused layouts
   - Clean modern data visualization styles
   - Minimalist BI dashboard themes
4. Selected final design and implemented in Metabase.


   See `/docs/dashboard_design/` for wireframes and final dashboard screenshots.