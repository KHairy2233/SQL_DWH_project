----create dimension customers view

create view Gold.dim_customers as
select 
ROW_NUMBER() over(order by cst_id) as customer_key,
ci.cst_id as customer_id,
ci.cst_key as customer_number,
ci.cst_firstname as first_name,
ci.cst_lastname as last_name,
ci.cst_marital_status as martial_status,
case when ci.cst_gndr != 'n/a' then ci.cst_gndr
else coalesce(ca.gen,'n/a')
end as gender,
ca.BDATE as birthdate,
la.CNTRY as country,
ci.cst_create_date as create_date
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on ci.cst_key = ca.CID
left join silver.erp_loc_a101 la
on ci.cst_key= la.CID



-----------------------------------------------------------------
---- create dimension products view
select * from silver.crm_prd_info
select * from silver.erp_px_cat_g1v2
create view  gold.dim_products as
select 
ROW_NUMBER() over(order by prd_start_dt,prd_key) as product_key,
si.prd_id as product_id,
si.cat_id as category_id,
si.prd_key as product_number ,
si.prd_nm as product_name,
pc.CAT as category,
pc.SUBCAT as sub_category,
pc.MAINTENANCE as maintenance,
si.prd_cost as cost,
si.prd_line as product_line,
si.prd_start_dt as start_date
from silver.crm_prd_info si
left join silver.erp_px_cat_g1v2 pc
on si.cat_id= pc.ID
where prd_end_dt is not null



------------------------------------------------
---- create fact sales view
select * from silver.crm_sales_details
create view gold.fact_sales as
select
sd.sls_ord_num as order_number,
dp.product_number,
dc.customer_id,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as ship_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales,
sd.sls_quantity as quantity,
sd.sls_price as price
from silver.crm_sales_details sd
left join gold.dim_customers dc
on sd.sls_cust_id = dc.customer_id
left join gold.dim_products dp
on sd.sls_prd_key = dp.product_number
