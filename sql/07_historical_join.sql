
-- Historical Join
use warehouse compute_wh;
use database snowflake_learning_db;

create or replace table silver.store_sales_enriched as
select 
    ss.ss_customer_sk,
    ss.ss_store_sk,
    ss.ss_sales_price,
    d.d_date as transaction_date
from silver.store_sales_clean ss
join snowflake_sample_data.tpcds_sf100tcl.date_dim d
    on ss.ss_sold_date_sk = d.d_date_sk;

-- ACtual historical join

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