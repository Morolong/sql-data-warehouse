--WARNING: this script will drop the entire "DataWarehouse" database if it exists. All data in this database will be permanently deleted. 
--Script Purpose: Create a new Database called "DataWarehouse" after checking if it already exists. If this database exists, it will be deleted and recreated with three schemas within this database: "bronze", "silver", "gold". 

USE master; 
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN 
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE; 
    DROP DATABASE DataWarehouse; 
END;
GO 

--Create "DataWarehouse" database
CREATE DATABASE DataWarehouse; 
GO

USE DataWarehouse; 

GO

--Create Schemas 
CREATE SCHEMA bronze; 
GO

CREATE SCHEMA silver; 
GO 

CREATE SCHEMA gold; 
Go
