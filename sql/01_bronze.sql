use database snowflake_sample_data;

Desc table tpcds_sf100tcl.store_sales;


select count(*) from tpcds_sf100tcl.store_sales;


----------------------------------BRONZE(Data Validation)---------------------------------------------------------------------------------

--phase-2
use warehouse compute_wh;

use database snowflake_learning_db;

create schema if not exists bronze;


create or replace table bronze.store_sales_raw AS 
select * from snowflake_sample_data.tpcds_sf100tcl.store_sales
limit 50000000;

--phase-3 :Data Validation (Completeness)

select count(*) from bronze.store_sales_raw; 

select count(*) from snowflake_sample_data.tpcds_sf100tcl.store_sales;

desc table bronze.store_sales_raw;

select count(*) as total_rows,count(ss_sales_price) as non_null_sales_price from bronze.store_sales_raw;

--OPTIONAL 
SELECT min(ss_sold_date_sk),max(ss_sold_date_sk) from bronze.store_sales_raw;


select ss_sold_date_sk from bronze.store_sales_raw limit ;

-----------------------------------------------------------------------------------------------------------------------