-- Recreate bronze layer
USE WAREHOUSE COMPUTE_WH;
USE DATABASE SNOWFLAKE_LEARNING_DB;

CREATE OR REPLACE TABLE BRONZE.STORE_SALES_RAW AS
SELECT ss.*
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE_SALES ss
JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d
    ON ss.ss_sold_date_sk = d.d_date_sk
WHERE d.d_year BETWEEN 1998AND 2010;

-- validate it 
SELECT MIN(d.d_year), MAX(d.d_year)
FROM BRONZE.STORE_SALES_RAW ss
JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d
    ON ss.ss_sold_date_sk = d.d_date_sk;

-- rebuild silver
CREATE OR REPLACE TABLE SILVER.STORE_SALES_CLEAN AS
SELECT 
    ss_sold_date_sk,
    ss_store_sk,
    ss_customer_sk,
    ss_quantity,
    ss_sales_price
FROM BRONZE.STORE_SALES_RAW
WHERE ss_sales_price IS NOT NULL
AND ss_quantity > 0;


-- rebuild enrich fact
CREATE OR REPLACE TABLE SILVER.STORE_SALES_ENRICHED AS
SELECT
    ss.ss_customer_sk,
    ss.ss_store_sk,
    ss.ss_sales_price,
    d.d_date AS transaction_date
FROM SILVER.STORE_SALES_CLEAN ss
JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.DATE_DIM d
    ON ss.ss_sold_date_sk = d.d_date_sk;

- rebuild fact sales with historical join
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

-- rebuild gold layer

CREATE OR REPLACE TABLE GOLD.SALES_BY_YEAR AS
SELECT
    YEAR(transaction_date) AS sales_year,
    SUM(sales_price) AS total_sales
FROM SILVER.FACT_SALES
GROUP BY sales_year;

CREATE OR REPLACE TABLE GOLD.MONTHLY_SALES AS
SELECT
    DATE_TRUNC('month', transaction_date) AS sales_month,
    SUM(sales_price) AS total_sales
FROM SILVER.FACT_SALES
GROUP BY sales_month;

CREATE OR REPLACE TABLE GOLD.SALES_BY_STATE AS
SELECT
    d.state,
    SUM(f.sales_price) AS total_sales
FROM SILVER.FACT_SALES f
JOIN SILVER.CUSTOMER_DIM d
    ON f.customer_sk = d.customer_sk
GROUP BY d.state;



-- use database snowflake_sample_data;

-- Desc table tpcds_sf100tcl.store_sales;


-- select count(*) from tpcds_sf100tcl.store_sales;


-- ----------------------------------BRONZE(Data Validation)---------------------------------------------------------------------------------

-- --phase-2
-- use warehouse compute_wh;

-- use database snowflake_learning_db;

-- create schema if not exists bronze;


-- create or replace table bronze.store_sales_raw AS 
-- select * from snowflake_sample_data.tpcds_sf100tcl.store_sales;

-- --phase-3 :Data Validation (Completeness)

-- select count(*) from bronze.store_sales_raw; 

-- select count(*) from snowflake_sample_data.tpcds_sf100tcl.store_sales;

-- desc table bronze.store_sales_raw;

-- select count(*) as total_rows,count(ss_sales_price) as non_null_sales_price from bronze.store_sales_raw;

-- --OPTIONAL 
-- SELECT min(ss_sold_date_sk),max(ss_sold_date_sk) from bronze.store_sales_raw;


-- select ss_sold_date_sk from bronze.store_sales_raw limit ;

-- -----------------------------------------------------------------------------------------------------------------------
