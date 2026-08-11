create or alter procedure bronze.load_bronze as
begin
declare @start_time datetime, @end_time datetime
    begin try
	    set @start_time = getdate();
		truncate table bronze.crm_cust_info;
		bulk insert bronze.crm_cust_info
		from 'G:\data analysis\data engineering\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with(
		firstrow = 2 ,
		fieldterminator = ',',
		tablock
		)
		set @end_time = getdate();
		print 'duration load :' + cast(datediff(second ,@start_time,@end_time )as nvarchar)+ 'seconds'
		
		set @start_time = getdate();
		truncate table bronze.crm_prd_info;
		bulk insert bronze.crm_prd_info
		from 'G:\data analysis\data engineering\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with(
		firstrow = 2 ,
		fieldterminator = ',',
		tablock
		)
		set @end_time = getdate();
		print 'duration load :' + cast(datediff(second ,@start_time,@end_time )as nvarchar)+ 'seconds'

		set @start_time = getdate();
		truncate table bronze.crm_sales_details;
		bulk insert bronze.crm_sales_details
		from 'G:\data analysis\data engineering\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with(
		firstrow = 2 ,
		fieldterminator = ',',
		tablock
		)
		set @end_time = getdate();
		print 'duration load :' + cast(datediff(second ,@start_time,@end_time )as nvarchar)+ 'seconds'

		set @start_time = getdate();
		truncate table bronze.erp_cust_az12;
		bulk insert bronze.erp_cust_az12
		from 'G:\data analysis\data engineering\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		with(
		firstrow = 2 ,
		fieldterminator = ',',
		tablock
		)
		set @end_time = getdate();
		print 'duration load :' + cast(datediff(second ,@start_time,@end_time )as nvarchar)+ 'seconds'

		set @start_time = getdate();
		truncate table bronze.erp_loc_a101;
		bulk insert bronze.erp_loc_a101
		from 'G:\data analysis\data engineering\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		with(
		firstrow = 2 ,
		fieldterminator = ',',
		tablock)
		set @end_time = getdate();
		print 'duration load :' + cast(datediff(second ,@start_time,@end_time )as nvarchar)+ 'seconds'

		set @start_time = getdate();
		truncate table bronze.erp_px_cat_g1v2;
		bulk insert bronze.erp_px_cat_g1v2
		from 'G:\data analysis\data engineering\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		with(
		firstrow = 2 ,
		fieldterminator = ',',
		tablock)
		set @end_time = getdate();
		print 'duration load :' + cast(datediff(second ,@start_time,@end_time )as nvarchar)+ 'seconds'
	end try
	begin catch
	print'an error has occured'
	print 'error message: '+ERROR_MESSAGE();
	print 'error number:'+cast( ERROR_NUMBER() as nvarchar);
	print 'error message:'+cast( ERROR_STATE() as nvarchar);
	end catch;
end;

exec bronze.load_bronze;
