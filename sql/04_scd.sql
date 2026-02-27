desc table snowflake_sample_data.tpcds_sf100tcl.customer;

desc table snowflake_sample_data.tpcds_sf100tcl.customer_address;

use warehouse compute_wh;

use database snowflake_learning_db;

create or replace table silver.customer_dim (
    customer_sk Number AUTOINCREMENT,
    customer_id NUMBER,
    state STRING,
    start_date DATE,
    end_date DATE,
    is_current STRING
);

--initial load
insert into silver.customer_dim
(customer_id , state , start_date , end_date ,is_current)
select 
    c.c_customer_sk,
    ca.ca_state,
    current_date,
    null,
    'Y'
    from snowflake_sample_data.tpcds_sf100tcl.customer c
    join snowflake_sample_data.tpcds_sf100tcl.customer_address ca
       on c.c_current_addr_sk = ca.ca_address_sk;

select count(*) from silver.customer_dim;

select * from silver.customer_dim;


--create a small stage

create or replace table silver.customer_stage as
select customer_id , state from silver.customer_dim 
where is_current = 'Y';

update silver.customer_stage
set state ='TX'
where customer_id = 31623753;

--manual update one row
select * from silver.customer_stage where customer_id = 31623753;

--implement stage 2 using merge

merge into silver.customer_dim target
using silver.customer_stage source
on target.customer_id = source.customer_id  and target.is_current ='Y' when matched 
and target.state <> source.state then
update set 
    target.end_date=current_date,
    target.is_current = 'N'

when not matched then
insert (customer_id , state , start_date ,end_date ,is_current)
values(source.customer_id , source.state , current_date,null , 'Y');

--validate SCD behaviour

select * from silver.customer_dim where customer_id =31623753 order by start_date; 
