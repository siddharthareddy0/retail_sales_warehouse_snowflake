use WAREHOUSE COMPUTE_WH ;

USE DATABASE SNOWFLAKE_LEARNING_DB ;
create or replace table SILVER.STORE_SALES_ENRICHED as 
select 
SS.SS_CUSTOMER_SK,
SS.SS_STORE_SK,
SS.SS_SALES_PRICE,
D.D_DATE AS TRANSACTION_DATE
FROM SILVER.STORE_SALES_CLEAN SS 
JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM D 
ON SS.SS_SOLD_DATE_SK = D.D_DATE_SK ;

---PROPER HISTORICAL --

SELECT
    f.transaction_date,
    d.state,
    SUM(f.ss_sales_price) AS total_sales
FROM SILVER.STORE_SALES_ENRICHED f
JOIN SILVER.CUSTOMER_DIM d
    ON f.ss_customer_sk = d.customer_id
    AND f.transaction_date >= d.start_date
    AND (f.transaction_date < d.end_date OR d.end_date IS NULL)
GROUP BY
    f.transaction_date,
    d.state
ORDER BY
    f.transaction_date;

-- simulate the incremental fact load

    CREATE OR REPLACE TABLE SILVER.FACT_STAGE (
    customer_id NUMBER,
    store_id NUMBER,
    sales_price NUMBER,
    transaction_date DATE
);

-- insert the increemntal data
INSERT INTO SILVER.FACT_STAGE VALUES
(101, 10, 500, '2024-01-10'),
(101, 10, 700, '2021-01-10');

-- Load the facts with surrogate keys

DROP TABLE IF EXISTS SILVER.CUSTOMER_DIM;

CREATE OR REPLACE TABLE SILVER.CUSTOMER_DIM (
    customer_sk NUMBER AUTOINCREMENT,
    customer_id NUMBER,
    state STRING,
    start_date DATE,
    end_date DATE,
    is_current STRING
);

INSERT INTO SILVER.CUSTOMER_DIM
(customer_id, state, start_date, end_date, is_current)
SELECT
    c.c_customer_sk,
    ca.ca_state,
    '1900-01-01',
    NULL,
    'Y'
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER c
JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER_ADDRESS ca
    ON c.c_current_addr_sk = ca.ca_address_sk;

   CREATE OR REPLACE TABLE SILVER.FACT_SALES AS
SELECT
    d.customer_sk,
    f.ss_store_sk AS store_id,
    f.ss_sales_price AS sales_price,
    f.transaction_date
FROM SILVER.STORE_SALES_ENRICHED f
JOIN SILVER.CUSTOMER_DIM d
    ON f.ss_customer_sk = d.customer_id
    AND f.transaction_date >= d.start_date
    AND (f.transaction_date < d.end_date OR d.end_date IS NULL);

    SELECT COUNT(*) FROM SILVER.FACT_SALES;