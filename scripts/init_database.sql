/*
================================================
Create Database and Schemas
================================================
Script Purpose:
	This script creates a new database 'DataWarehouse' after checking whether it already exists or not.
	If it exists, the database is dropped and recreated.
	Additionally, the script sets up three schemas in the database: 'bronze', 'silver' and 'gold'.

WARNING:
	Running this script will completely drop the database 'DataWarehouse' if it exists. 
	All the data in the database will be permanently deleted.
	Ensure you have a proper backup of the database before executing this script.
*/

USE master;
GO

--Drop and recreate the database 'DataWarehouse'
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

--Create DataWarehouse
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
GO
