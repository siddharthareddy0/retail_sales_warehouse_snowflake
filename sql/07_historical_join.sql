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
(101, 10, 700, '2021-01-10'),
(102, 10, 450, '2024-01-15'),
(103, 11, 650, '2023-06-20'),
(104, 12, 800, '2022-03-05'),
(105, 10, 300, '2024-02-14'),
(106, 13, 950, '2021-11-30'),
(107, 11, 550, '2023-09-12'),
(108, 12, 720, '2022-07-18'),
(109, 10, 420, '2024-01-22'),
(110, 14, 880, '2021-05-08'),
(111, 11, 610, '2023-04-25'),
(112, 12, 750, '2022-10-11'),
(113, 10, 480, '2024-03-03'),
(114, 13, 920, '2021-12-15'),
(115, 11, 590, '2023-08-07'),
(116, 12, 680, '2022-02-28'),
(117, 10, 540, '2024-02-19'),
(118, 14, 810, '2021-06-22'),
(119, 11, 670, '2023-11-09'),
(120, 12, 730, '2022-05-14');

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