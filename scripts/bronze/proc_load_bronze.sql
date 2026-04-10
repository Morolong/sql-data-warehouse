--This script is a stored procedure that loads data into the 'bronze' schema from external CSV files. 
--It Truncates the bronze tables beofre loading data 
--Uses the "Bulk INSERT' command to load data from csv Files to bronze tables. 
-- This stored procedure does not accept any parameters or retun any values. 
--Usage: e.g EXEC bronze.load_bronze; 

USE DataWarehouse;
GO
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN 
	DECLARE @start_time DATETIME, @end_time DATETIME,@batch_start_time DATETIME, @batch_end_time DATETIME; 
	BEGIN TRY
		SET @batch_start_time = GETDATE(); 
		PRINT '=========================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '=========================================================';
		 
		Print '---------------------------------------------';
		Print 'Loading CRM Tables';
		Print '---------------------------------------------';
		
		SET @start_time = GETDATE(); 
		PRINT '>> Truncating Table: bronze.crm_cust_info'; 
		TRUNCATE TABLE bronze.crm_cust_info; 
		PRINT '>> Inserting Data Into: bronze.crm_cust_info'; 
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\mgsot\OneDrive\Documents\My Learning\PostgreSQL\Datawarehouse\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',', 
			TABLOCK
		);
		SET @end_time = GETDATE(); 
		PRINT '>>> Cust_Info Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'; 
		PRINT '<<<-------------------------------------------->>>'

		SET @start_time = GETDATE(); 
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;
		PRINT '>> Inserting Data Into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\mgsot\OneDrive\Documents\My Learning\PostgreSQL\Datawarehouse\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',', 
			TABLOCK
		);
		SET @end_time = GETDATE(); 
		PRINT '>>> CRM_PRD_INFO Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'; 
		PRINT '<<<-------------------------------------------->>>'

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details; 
		PRINT '>> Inserting Data Into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\mgsot\OneDrive\Documents\My Learning\PostgreSQL\Datawarehouse\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',', 
			TABLOCK
		);
		SET @end_time = GETDATE(); 
		PRINT '>>> SALES_DETAILS Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'; 
		PRINT '<<<-------------------------------------------->>>'


		Print '---------------------------------------------';
		Print 'Loading ERP Tables';
		Print '---------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12; 
		PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\mgsot\OneDrive\Documents\My Learning\PostgreSQL\Datawarehouse\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		WITH (
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',', 
			TABLOCK
		);
		SET @end_time = GETDATE(); 
		PRINT '>>> CUST_AZ12 Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'; 
		PRINT '<<<-------------------------------------------->>>'

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101; 
		PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\mgsot\OneDrive\Documents\My Learning\PostgreSQL\Datawarehouse\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH (
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',', 
			TABLOCK
		);
		SET @end_time = GETDATE(); 
		PRINT '>>> ERP_LOC_A101 Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'; 
		PRINT '<<<-------------------------------------------->>>'

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2; 
		PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\mgsot\OneDrive\Documents\My Learning\PostgreSQL\Datawarehouse\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',', 
			TABLOCK
		);
		SET @end_time = GETDATE(); 
		PRINT '>>> PX_CAT_G1V2 Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'; 
		PRINT '<<<-------------------------------------------->>>'

		SET @batch_end_time = GETDATE(); 
		PRINT '=========================================================';
		PRINT 'Loading Bronze Layer is Completed';
		PRINT '- Total Load Duration: ' +  CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds';
		PRINT '=========================================================';
	END TRY
	BEGIN CATCH 
		PRINT '=========================================================';
		PRINT 'ERROR OCCURED DURING LOADING OF BRONZE LAYER';
		PRINT '=========================================================';
		PRINT 'Error Message:  ' + ERROR_MESSAGE();
		PRINT 'Error Number:   ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
		PRINT 'Error State:    ' + CAST(ERROR_STATE() AS NVARCHAR(10));
		PRINT 'Error Line:     ' + CAST(ERROR_LINE() AS NVARCHAR(10));
		PRINT '=========================================================';
	END CATCH 
END
