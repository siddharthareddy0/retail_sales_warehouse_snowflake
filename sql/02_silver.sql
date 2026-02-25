use warehouse compute_wh;

use database snowflake_learning_db;

create schema if not exists Silver;


create or replace table silver.store_sales_clean as 
select 
    ss.ss_sold_date_sk,
    ss.ss_store_sk,
    ss.ss_customer_sk,
    ss.ss_quantity,
    ss.ss_sales_price 
from bronze.store_sales_raw ss 
join snowflake_sample_data.tpcds_sf100tcl.date_dim d
on ss.ss_sold_date_sk = d.d_date_sk
where d.d_year between 1998 and 1999
and ss.ss_sales_price is not null
and ss.ss_quantity >0 ;


select count(*) from silver.store_sales_clean;

select min(ss_sales_price) , max(ss_sales_price) from silver.store_sales_clean;

select count(*) from bronze.store_sales_raw;

select count(*) from silver.store_sales_clean;


select count(*) from silver.store_sales_clean where ss_sales_price is null;

select count(*) from silver.store_sales_clean where ss_quantity <=0;