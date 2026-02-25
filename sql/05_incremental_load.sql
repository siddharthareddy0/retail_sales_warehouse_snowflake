-- =====================================================
-- 05_incremental_load.sql
-- Incremental Load with SCD Type 2 + Historical Join
-- =====================================================

-- -----------------------------------------------------
-- Session Setup
-- -----------------------------------------------------

USE WAREHOUSE COMPUTE_WH;
USE DATABASE SNOWFLAKE_LEARNING_DB;

-- -----------------------------------------------------
-- STEP 1: Simulate Incoming Customer Changes
-- -----------------------------------------------------

CREATE OR REPLACE TABLE SILVER.CUSTOMER_STAGE AS
SELECT customer_id, state
FROM SILVER.CUSTOMER_DIM
WHERE is_current = 'Y';

-- Simulate change for one customer
UPDATE SILVER.CUSTOMER_STAGE
SET state = 'TX'
WHERE customer_id = (
    SELECT customer_id FROM SILVER.CUSTOMER_STAGE LIMIT 1
);

-- -----------------------------------------------------
-- STEP 2: Apply SCD Type 2 Logic
-- -----------------------------------------------------

MERGE INTO SILVER.CUSTOMER_DIM target
USING SILVER.CUSTOMER_STAGE source
ON target.customer_id = source.customer_id
AND target.is_current = 'Y'

WHEN MATCHED AND target.state <> source.state THEN
UPDATE SET
    target.end_date = CURRENT_DATE,
    target.is_current = 'N'

WHEN NOT MATCHED THEN
INSERT (customer_id, state, start_date, end_date, is_current)
VALUES (source.customer_id, source.state, CURRENT_DATE, NULL, 'Y');

-- -----------------------------------------------------
-- STEP 3: Simulate Incremental Fact Load
-- -----------------------------------------------------

CREATE OR REPLACE TABLE SILVER.FACT_STAGE (
    customer_id NUMBER,
    store_id NUMBER,
    sales_price NUMBER,
    transaction_date DATE
);

INSERT INTO SILVER.FACT_STAGE VALUES
(101, 10, 500, '2024-01-10'),
(101, 10, 700, '2021-01-10');

-- -----------------------------------------------------
-- STEP 4: Load Fact with Historical Join
-- -----------------------------------------------------

CREATE OR REPLACE TABLE SILVER.FACT_SALES AS
SELECT
    d.customer_sk,
    f.store_id,
    f.sales_price,
    f.transaction_date
FROM SILVER.FACT_STAGE f
JOIN SILVER.CUSTOMER_DIM d
    ON f.customer_id = d.customer_id
    AND f.transaction_date >= d.start_date
    AND (f.transaction_date < d.end_date OR d.end_date IS NULL);

-- -----------------------------------------------------
-- STEP 5: Validation
-- -----------------------------------------------------

SELECT * FROM SILVER.CUSTOMER_DIM
ORDER BY customer_id, start_date;

SELECT * FROM SILVER.FACT_SALES;