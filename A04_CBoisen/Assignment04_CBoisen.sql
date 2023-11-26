--*************************************************************************--
-- Title: Assignment04
-- Desc: This file demonstrates how to process data in a database
-- Change Log: When,Who,What
-- 2023-01-01,RRoot,Created File
-- 2023-11-06,CBoisen,Added transaction code
--**************************************************************************--
Use Master;
go

If Exists(Select Name from SysDatabases Where Name = 'Assignment04DB_CBoisen')
 Begin 
  Alter Database [Assignment04DB_CBoisen] set Single_user With Rollback Immediate;
  Drop Database Assignment04DB_CBoisen;
 End
go

Create Database Assignment04DB_CBoisen;
go

Use Assignment04DB_CBoisen;
go

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Alter Table Categories 
 Add Constraint pkCategories 
  Primary Key (CategoryId);
go

Alter Table Categories 
 Add Constraint ukCategories 
  Unique (CategoryName);
go

Alter Table Products 
 Add Constraint pkProducts 
  Primary Key (ProductId);
go

Alter Table Products 
 Add Constraint ukProducts 
  Unique (ProductName);
go

Alter Table Products 
 Add Constraint fkProductsToCategories 
  Foreign Key (CategoryId) References Categories(CategoryId);
go

Alter Table Products 
 Add Constraint ckProductUnitPriceZeroOrHigher 
  Check (UnitPrice >= 0);
go

Alter Table Inventories 
 Add Constraint pkInventories 
  Primary Key (InventoryId);
go

Alter Table Inventories
 Add Constraint dfInventoryDate
  Default GetDate() For InventoryDate;
go

Alter Table Inventories
 Add Constraint fkInventoriesToProducts
  Foreign Key (ProductId) References Products(ProductId);
go

Alter Table Inventories 
 Add Constraint ckInventoryCountZeroOrHigher 
  Check ([Count] >= 0);
go


-- Show the Current data in the Categories, Products, and Inventories Tables
Select * from Categories;
go
Select * from Products;
go
Select * from Inventories;
go

/********************************* TASKS *********************************/

-- Add the following data to this database.
-- All answers must include the Begin Tran, Commit Tran, and Rollback Tran transaction statements. 
-- All answers must include the Try/Catch blocks around your transaction processing code.
-- Display the Error message if the catch block is invoked.

/* Add the following data to this database:
Beverages	Chai	18.00	2017-01-01	61
Beverages	Chang	19.00	2017-01-01	87
Condiments	Aniseed Syrup	10.00	2017-01-01	19
Condiments	Chef Anton's Cajun Seasoning	22.00	2017-01-01	81
Beverages	Chai	18.00	2017-02-01	13
Beverages	Chang	19.00	2017-02-01	2
Condiments	Aniseed Syrup	10.00	2017-02-01	1
Condiments	Chef Anton's Cajun Seasoning	22.00	2017-02-01	79
Beverages	Chai	18.00	2017-03-02	18
Beverages	Chang	19.00	2017-03-02	12
Condiments	Aniseed Syrup	10.00	2017-03-02	84
Condiments	Chef Anton's Cajun Seasoning	22.00	2017-03-02	72
*/

-- Task 1 (20 pts): Add data to the Categories table
-- TODO: Add Insert Code
BEGIN TRY -- use a try/catch block to handle errors during transactions 
    BEGIN TRAN; --- Transaction/TRAN is happening whenever INSERT, UPDATE, DELETE and should be used to formally define the statements
        INSERT INTO Categories -- can't insert into identity clause 
            ([CategoryName]) --- skip identity (autonumber) column - automatically generates numbers for CategoryID
        VALUES 
            ('Beverages'), ('Condiments');
    COMMIT TRAN; --- not completed, data not INSERT/UPDATE/DELETE until COMMIT
END TRY
BEGIN CATCH --- used to catch the error and rollback TRAN if fails 
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; --- if trans did not work and cant be comitted, rollback so statement is closed 
    PRINT 'There was an ERROR! Refer back to ERROR message'
    PRINT Error_Message();
END CATCH          
GO

SELECT @@TRANCOUNT; -- check to see if transaction is still open and needs to be closed (ROLLBACK or COMMIT) 
GO

SELECT @@IDENTITY AS [Last ID from current connection], --- can see what the identityID is for new/curent rows that are added
        IDENT_CURRENT('Categories') AS [Last ID for any connection]

SELECT * FROM Categories;
GO

-- Task 2 (20 pts): Add data to the Products table
-- TODO: Add Insert Code
BEGIN TRY
    BEGIN TRAN;
        INSERT INTO Products
            ([ProductName], [CategoryID], [UnitPrice]) --- column names for insert 
            VALUES 
                ('Chai', 1, 18.00), --- add values by rows not columns
                ('Chang', 1, 19.00), 
                ('Aniseed Syrup', 2, 10.00), 
                ('Chef Antons Cajun Seasoning', 2, 22.00);
    COMMIT TRAN;
END TRY
BEGIN CATCH  
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'There was an ERROR! Refer back to ERROR message'
    PRINT Error_Message();
END CATCH          
GO

SELECT @@TRANCOUNT;
GO

SELECT * FROM Products;
GO

-- Task 3 (20 pts): Add data to the Inventories table
-- TODO: Add Insert Code
BEGIN TRY
    BEGIN TRAN;
        INSERT INTO Inventories --- INSERT INTO, VALUES 
            ([InventoryDate], [ProductID], [Count]) --- PRODID- 1 beverage, 2 condiment
            VALUES 
                ('20170101', 1, 61), ---chai(1) , date must be formatted 'yearmonthday' 
                ('20170101', 2, 87), ---chang(2)
                ('20170101', 3, 19), --anise(3)
                ('20170101', 4, 81), ---cajun(4)

                ('20170201', 1, 13), ---chai
                ('20170201', 2, 2), ---chang
                ('20170201', 3, 1), ---anise
                ('20170201', 4, 79), ---cajun

                ('20170302', 1, 18), ---chai
                ('20170302', 2, 12), ---chang
                ('20170302', 3, 84), ---anise
                ('20170302', 4, 72) ---cajun        
    COMMIT TRAN;
END TRY
BEGIN CATCH  
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'There was an ERROR! Refer back to ERROR message'
    PRINT Error_Message();
END CATCH          
GO

SELECT @@TRANCOUNT;
GO

SELECT * FROM Inventories;
GO

-- Task 4 (10 pts): Write code to update the Category "Beverages" to "Drinks"
-- TODO: Add Update Code
BEGIN TRY
    BEGIN TRAN
        UPDATE Categories -- update table UPDATE, SET, WHERE
        SET [CategoryName] = 'Drinks' -- update particular column or multiple at once 
        WHERE [CategoryID] = 1; --- ALWAYS need to specify row using WHERE or all rows will be updated
    IF (@@ROWCOUNT >1) RAISERROR('Try again but only change the rows you want!', 15, 1); --- to protect from accident of updating more than you want, how mamy rows affected and raise custom error message
    COMMIT TRAN; 
END TRY
BEGIN CATCH  --- if raiserror happens then automatically sends to catch block without comitting 
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT Error_Message()
END CATCH          
GO

SELECT * FROM Categories ORDER BY 1,2;
GO


-- Task 5 (30 pts): Write code to delete all Condiments data from the database (in all three tables!)  
-- TODO: Add Delete Code

-- DELETE in the right order because of parent/child foerign key contraints- delete inventories row 3 & 4 (condiments) first 

BEGIN TRY 
    BEGIN TRAN;
        DELETE FROM Inventories -- delete data, DELETE FROM, WHERE
        WHERE [ProductID] IN (3,4); -- delete specific row value, can't delete parent value if it will orphan the child values - need to delete in specific order
    COMMIT TRAN;
END TRY
BEGIN CATCH  
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'There was an ERROR! Refer back to ERROR message!'
    PRINT Error_Message()
END CATCH          
GO

BEGIN TRY
    BEGIN TRAN;
        DELETE FROM Products -- delete data, DELETE FROM, WHERE
        WHERE [CategoryID] = (2); -- delete specific rows with ID value for condiments 
    COMMIT TRAN;
END TRY
BEGIN CATCH  
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'There was an ERROR! Refer back to ERROR message!'
    PRINT Error_Message()
END CATCH          
GO

BEGIN TRY
    BEGIN TRAN;
        DELETE FROM Categories -- delete data, DELETE FROM, WHERE
        WHERE [CategoryID] = (2); -- delete specific rows with ID value for condiments
    COMMIT TRAN;
END TRY
BEGIN CATCH  
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'There was an ERROR! Refer back to ERROR message!'
    PRINT Error_Message()
END CATCH          
GO

Select * From Inventories;
Select * From Products;
Select * From Categories ORDER BY 1,2;
go

/***************************************************************************************/