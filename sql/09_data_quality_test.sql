--------------------------------------------------------
-- =====================================================
-- 09_data_quality_tests.sql
-- Data Quality & Validation Framework
-- =====================================================

USE WAREHOUSE COMPUTE_WH;
USE DATABASE SNOWFLAKE_LEARNING_DB;

-- -----------------------------------------------------
-- Row Count Validation (Bronze vs Source)
-- -----------------------------------------------------

SELECT 
    (SELECT COUNT(*) FROM BRONZE.STORE_SALES_RAW) AS bronze_count,
    (SELECT COUNT(*) 
     FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE_SALES LIMIT 50000000) AS source_count;


-- -----------------------------------------------------
--  Null Checks (Critical Columns)
-- -----------------------------------------------------

SELECT COUNT(*) AS null_sales_price
FROM SILVER.FACT_SALES
WHERE sales_price IS NULL;

SELECT COUNT(*) AS null_customer_sk
FROM SILVER.FACT_SALES
WHERE customer_sk IS NULL;


-- -----------------------------------------------------
--  Duplicate Check (Fact Grain Validation)
-- -----------------------------------------------------

SELECT 
    customer_sk,
    store_id,
    transaction_date,
    COUNT(*) AS duplicate_count
FROM SILVER.FACT_SALES
GROUP BY customer_sk, store_id, transaction_date
HAVING COUNT(*) > 1;


-- -----------------------------------------------------
--  Referential Integrity Check
-- -----------------------------------------------------

SELECT COUNT(*) AS orphan_records
FROM SILVER.FACT_SALES f
LEFT JOIN SILVER.CUSTOMER_DIM d
    ON f.customer_sk = d.customer_sk
WHERE d.customer_sk IS NULL;


-- -----------------------------------------------------
--  SCD Integrity Check (Only One Current Record)
-- -----------------------------------------------------

SELECT customer_id
FROM SILVER.CUSTOMER_DIM
WHERE is_current = 'Y'
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- -----------------------------------------------------
--  Historical Date Range Overlap Check
-- -----------------------------------------------------

SELECT t1.customer_id
FROM SILVER.CUSTOMER_DIM t1
JOIN SILVER.CUSTOMER_DIM t2
  ON t1.customer_id = t2.customer_id
 AND t1.customer_sk <> t2.customer_sk
 AND t1.start_date < COALESCE(t2.end_date, CURRENT_DATE)
 AND COALESCE(t1.end_date, CURRENT_DATE) > t2.start_date;


-- -----------------------------------------------------
--  Gold vs Silver Aggregation Check
-- -----------------------------------------------------

SELECT 


    (SELECT SUM(sales_price) FROM SILVER.FACT_SALES) AS silver_total,
    (SELECT SUM(total_sales) FROM GOLD.SALES_BY_YEAR) AS gold_total;