
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