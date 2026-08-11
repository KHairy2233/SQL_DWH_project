create or alter procedure load_silver as
begin
    begin try
        truncate table silver.crm_cust_info;
        insert into silver.crm_cust_info (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
        )
        select
        cst_id,
        cst_key,
        trim(cst_firstname) as cst_firstname ,
        trim(cst_lastname) as cst_lastname,
        case 
        when upper(trim(cst_marital_status)) = 'S' then 'Single'
        when upper(trim(cst_marital_status)) = 'M' then 'Married'
        else 'n/a'
        end cst_marital_status,
        case 
        when upper(trim(cst_gndr)) = 'M' then 'Male'
        when upper(trim(cst_gndr)) = 'F' then 'Female'
        else 'n/a'
        end cst_gndr,
        cst_create_date
        from(
	        select 
	        * ,
	        ROW_NUMBER() over(partition by cst_id order by cst_create_date desc)as flag_last
	        from bronze.crm_cust_info
	        where cst_id is not null
        )t
        where flag_last = 1 
        ----------------------------------------------
        select * from bronze.crm_prd_info
        ----------------------------------------




        truncate table silver.crm_prd_info;
        insert into silver.crm_prd_info(
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
        )
        SELECT 
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
            prd_nm,
            ISNULL(prd_cost, 0) AS prd_cost,

            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line,

            prd_start_dt ,

            DATEADD(
                DAY,
                -1,
                LEAD(prd_start_dt) OVER (
                    PARTITION BY prd_key 
                    ORDER BY prd_start_dt
                )
            ) AS prd_end_dt

        FROM bronze.crm_prd_info;


        ----------------------------------------

        truncate table silver.crm_sales_details;
        insert into silver.crm_sales_details(
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
        )
        select 
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            case when sls_order_dt = 0 or len(sls_order_dt)!=8 then null
                else cast(cast(sls_order_dt as varchar)as date)
            end as sls_order_dt,
            case when sls_ship_dt = 0 or len(sls_ship_dt)!=8 then null
                 else cast(cast(sls_ship_dt as varchar)as date)
            end as sls_ship_dt,
            case when sls_due_dt = 0 or len(sls_due_dt)!=8 then null
                 else cast(cast(sls_due_dt as varchar)as date)
            end as sls_due_dt,
            case when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity * abs(sls_sales)
                then sls_quantity * abs(sls_sales)
                else sls_sales
                end as sls_sales,
            sls_quantity,
            case when sls_price is null or sls_price<=0 then sls_sales/nullif(sls_quantity , 0)
                 else sls_price
                 end as sls_price
        from bronze.crm_sales_details
     

        -----------------------------------------------------------------------------------------------------

        truncate table silver.erp_cust_az12
        insert into silver.erp_cust_az12(
        CID,
        BDATE,
        GEN
        )
        select
        case when cid like 'NAS%' then SUBSTRING(cid,4, len(cid))
            else cid
            end as cid,
        case when BDATE > GETDATE() then null
            else BDATE
            end as bdate,
        case when upper(trim(gen)) in ('M','MALE') then 'Male'
            when upper(trim(gen)) in ('F','FEMALE') then 'Female'
            else 'n/a'
            end as gen
        from bronze.erp_cust_az12




        ----------------------------------------------------------------------
        truncate table silver.erp_loc_a101;
        insert into silver.erp_loc_a101(
        CID,
        CNTRY
        )
        select 
        replace(cid , '-' ,'') as cid,
        case when trim(CNTRY) = 'DE' then 'Germany'
             when trim(CNTRY) in ('US','USA') then 'United States'
             when trim(CNTRY) = '' or trim(CNTRY) is null then 'n/a'
             else trim(CNTRY)
             end as cntry
        from bronze.erp_loc_a101



        -----------------------------------------------------------------
        truncate table silver.erp_px_cat_g1v2;
        insert into silver.erp_px_cat_g1v2(
        id,
        CAT,
        SUBCAT,
        MAINTENANCE
        )
        select
        id,
        CAT,
        SUBCAT,
        MAINTENANCE
        from bronze.erp_px_cat_g1v2
    end try
    begin catch
	print'an error has occured'
	print 'error message: '+ERROR_MESSAGE();
	print 'error number:'+cast( ERROR_NUMBER() as nvarchar);
	print 'error message:'+cast( ERROR_STATE() as nvarchar);
	end catch;
end

exec load_silver
