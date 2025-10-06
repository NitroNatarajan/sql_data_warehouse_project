/*
=====================================================================================================================
Create Database and Schemas
=====================================================================================================================

Script Purpose:
  This script creates a new databse named 'DataWareHouse' after checking if it already exists. 
  If the database exists, it is dropped and recreated. Additionally, thescript sets up three schemas within the databse: 'bronze', 'silver' and 'gold'.

WARNING:
Running this script will drop the entire 'DataWareHouse' database if Exists. 
All data in the database will be permanently deleted. Proceed with caution and ensure you have backups before running this script. 

*/

USE master;
GO
-- Drop and recreate the 'DataWareHouse' atabase
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWareHouse')
BEGIN
  ALTER DATABASE DataWareHouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE DataWareHouse;
END;
GO

-- Create Database 'DataWarehouse'
CREATE DATABASE DataWareHouse;
GO

  
USE DataWareHouse;
GO

-- Creating Schema's such as Bronze , silver , gold. 
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
