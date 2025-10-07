/*
============================================================================================
Stored Proceedure: Load Broze Layer (Source -> Bronze)
============================================================================================
Script Purpose:
  This stored procedure load the data into the 'bronze' schema from external CSV files.
  It performes the following actions:
    - Truncates the bronze tables before loading the data.
    - Uses the 'Bulk Insert' command to load data from csv Files to the bronZe tables. 

Parameters: None (This stored procedure doesn't accept any parameter or return any values.)

Usae Example: EXEC bronze.load_bronze;

*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
	DECLARE @start_time DATETIME , @end_time DATETIME, @batch_start_time datetime , @batch_end_time datetime;
	BEGIN TRY
		set @batch_start_time = GETDATE();
		PRINT '=============================================';
		PRINT 'Loading Bronze Layer';
		PRINT '=============================================';

		PRINT '---------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '---------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncate Table: bronze.crm_cust_info';

		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT 'Loading data into table: bronze.crm_cust_info'
		BULK INSERT bronze.crm_cust_info
		FROM 'E:\Data_Career_Preparation\Projects\Data_WareHouse_SQL_Project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Loading Duration: ' + CAST(DATEDIFF(second, @start_time , @end_time) AS NVARCHAR) + ' seconds'


		PRINT '>> -----------------------------------------------' ;

		-- For crm_prd_info
		
		SET @start_time = GETDATE();
		PRINT '>> Truncate Table: bronze.crm_prd_info';

		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT 'Loading data into table:bronze.crm_prd_info';

		BULK INSERT bronze.crm_prd_info
		FROM 'E:\Data_Career_Preparation\Projects\Data_WareHouse_SQL_Project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT '>> Loading Duration: ' + CAST(DATEDIFF(second, @start_time , @end_time) AS NVARCHAR) + ' seconds'


		PRINT '>> -----------------------------------------------' ;


		-- For crm_sales_details
		SET @start_time = GETDATE();
		PRINT '>> Truncate Table: bronze.crm_sales_details';

		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT 'Loading data into table:bronze.crm_sales_details';

		BULK INSERT bronze.crm_sales_details
		FROM 'E:\Data_Career_Preparation\Projects\Data_WareHouse_SQL_Project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT '>> Loading Duration: ' + CAST(DATEDIFF(second, @start_time , @end_time) AS NVARCHAR) + ' seconds'
		PRINT '>> -----------------------------------------------' ;
	
		PRINT '---------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '---------------------------------------------';



		-- For erp_cust_az12
		SET @start_time = GETDATE();
		PRINT '>> Truncate Table: bronze.erp_cust_az12';

		TRUNCATE TABLE bronze.erp_cust_az12; 

		PRINT 'Loading data into table:bronze.erp_cust_az12';

		BULK INSERT bronze.erp_cust_az12
		FROM 'E:\Data_Career_Preparation\Projects\Data_WareHouse_SQL_Project\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Loading Duration: ' + CAST(DATEDIFF(second, @start_time , @end_time) AS NVARCHAR) + ' seconds'
		PRINT '>> -----------------------------------------------' ;

		-- For erp_loc_a101
		SET @start_time = GETDATE();
		PRINT '>> Truncate Table: bronze.erp_loc_a101';

		TRUNCATE TABLE bronze.erp_loc_a101; 

		PRINT 'Loading data into table:bronze.erp_loc_a101';

		BULK INSERT bronze.erp_loc_a101
		FROM 'E:\Data_Career_Preparation\Projects\Data_WareHouse_SQL_Project\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT '>> Loading Duration: ' + CAST(DATEDIFF(second, @start_time , @end_time) AS NVARCHAR) + ' seconds'
		PRINT '>> -----------------------------------------------' ;

		-- For erp_px_cat_g1v2
		SET @start_time = GETDATE();
		PRINT '>> Truncate Table: bronze.erp_px_cat_g1v2';

		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT 'Loading data into table:bronze.erp_px_cat_g1v2';

		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'E:\Data_Career_Preparation\Projects\Data_WareHouse_SQL_Project\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Loading Duration: ' + CAST(DATEDIFF(second, @start_time , @end_time) AS NVARCHAR) + ' seconds'
		PRINT '>> -----------------------------------------------' ;
		SET @batch_end_time = GETDATE();
		PRINT '==================================================================';
		PRINT 'Loading Bronze layer is completed';
		PRINT 'Total Load duration:' + CAST(DATEDIFF(SECOND, @batch_start_time , @batch_end_time) AS NVARCHAR);
		PRINT '==================================================================';
	END TRY
	BEGIN CATCH
		PRINT '===============================================' ;
		PRINT 'Error Occured while loading the Bronze Layer';
		print'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '===============================================' ;

	END CATCH 
END 
