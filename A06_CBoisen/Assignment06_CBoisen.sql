--*************************************************************************--
-- Title: Assignment06
-- Author: CBoisen
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2023-11-20,CBoisen,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_CBoisen')
	 Begin 
	  Alter Database [Assignment06DB_CBoisen] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_CBoisen;
	 End
	Create Database Assignment06DB_CBoisen;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_CBoisen;

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
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 

'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BASIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

GO 
-- Create basic view for Categories 
CREATE -- DROP
VIEW vCategories
WITH SCHEMABINDING -- prevent orphaned view if table deleted 
	AS
 	 SELECT
 	 [CategoryID],
 	 [CategoryName]
	FROM dbo.Categories; -- have to use dbo. with schemabinding
GO

-- Create Basic View for Products
CREATE -- DROP
VIEW vProducts
WITH SCHEMABINDING
	AS
 	 SELECT 
 	 [ProductID],
 	 [ProductName],
 	 [CategoryID],
 	 [UnitPrice] 
 	FROM dbo.Products;
GO

-- Create basic view for employees
CREATE -- DROP
VIEW vEmployees
WITH SCHEMABINDING
	AS
 	 SELECT 
 	 [EmployeeID],
 	 [EmployeeFirstName],
 	 [EmployeeLastName],
 	 [ManagerID] 
 	FROM dbo.Employees;
GO

-- Create Basic View for Inventories
CREATE -- DROP
VIEW vInventories
WITH SCHEMABINDING
	AS
 	 SELECT 
 	 [InventoryID],
 	 [InventoryDate],
 	 [EmployeeID],
 	 [ProductID],
 	 [Count]
	FROM dbo.Inventories;
GO

-- Display the data in the view tables
SELECT * FROM vCategories;
SELECT * FROM vProducts;
SELECT * FROM vEmployees;
SELECT * FROM vInventories;

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
Use Assignment06DB_CBoisen;
-- Deny public group access to tables
DENY SELECT ON Categories to PUBLIC;
DENY SELECT ON Products to PUBLIC;
DENY SELECT ON Employees to PUBLIC;
DENY SELECT ON Inventories to PUBLIC;

-- Allow public group access to views
GRANT SELECT ON vCategories to PUBLIC;
GRANT SELECT ON vProducts to PUBLIC;
GRANT SELECT ON vEmployees to PUBLIC;
GRANT SELECT ON vInventories to PUBLIC;

GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

CREATE VIEW vProductsByCategories
AS
	SELECT TOP 100000 -- must use select top # to use order by in views 
		C.CategoryName AS [Category Name], P.ProductName AS [Product Name], P.UnitPrice AS [Unit Price] -- choose columns to be included in join 
			FROM vCategories AS C -- use alias for views, use basic views for join (NOT TABLES)
			INNER JOIN vProducts AS P -- inner join default join used unless specific otherwise 
			ON C.CategoryID = P.CategoryID -- join tables using CategoryID (linked)
	ORDER BY [Category Name], [Product Name];
GO

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
CREATE VIEW vInventoriesByProductsByDates
AS
	SELECT TOP 100000
		P.ProductName AS [Product Name], I.InventoryDate AS [Inventory Date], I.[Count] -- choose columns to be included in join
			FROM vProducts AS P
			INNER JOIN vInventories AS I
				ON P.ProductID = I.ProductID -- join tables using CategoryID 
	ORDER BY [Product Name], [Inventory Date], [Count];
GO


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

CREATE VIEW vInventoriesByEmployeesByDates
AS
	SELECT DISTINCT TOP 100000 
		I.InventoryDate AS [Inventory Date], E.EmployeeFirstName + ' ' + E.EmployeeLastName AS [Employee Name]
			FROM vInventories AS I
			INNER JOIN vEmployees AS E
				ON I.EmployeeID = E.EmployeeID
	ORDER BY [Inventory Date], [Employee Name];
GO

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

CREATE VIEW vInventoriesByProductsByCategories
AS
	SELECT TOP 100000
		C.CategoryName AS [Category Name], P.ProductName AS [Product Name], I.InventoryDate AS [Inventory Date], I.[Count]  -- choose columns to be included in join 
			FROM vCategories AS C -- use alias for tables
			INNER JOIN vProducts AS P -- inner join default join used unless specific otherwise 
				ON C.CategoryID = P.CategoryID 
			INNER JOIN vInventories AS I
				ON P.ProductID = I.ProductID 
	ORDER BY [Category Name], [Product Name], [Inventory Date], [Count];
GO

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

CREATE VIEW vInventoriesByProductsByEmployees
AS
	SELECT DISTINCT TOP 100000
		C.CategoryName AS [Category Name], P.ProductName AS [Product Name], I.InventoryDate AS [Inventory Date], I.[Count], E.EmployeeFirstName + ' ' + E.EmployeeLastName AS [Employee Name]  -- choose columns to be included in join 
			FROM vCategories AS C 
			INNER JOIN vProducts AS P 
				ON C.CategoryID = P.CategoryID 
			INNER JOIN vInventories AS I 
				ON P.ProductID = I.ProductID 
			INNER JOIN vEmployees AS E
				ON I.EmployeeID = E.EmployeeID
	ORDER BY [Inventory Date], [Category Name], [Product Name], [Employee Name];
GO

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
CREATE VIEW vInventoriesForChaiAndChangByEmployees
AS
	SELECT DISTINCT TOP 100000
		C.CategoryName AS [Category Name], P.ProductName AS [Product Name], I.InventoryDate AS [Inventory Date], I.[Count], E.EmployeeFirstName + ' ' + E.EmployeeLastName AS [Employee Name] 
			FROM vCategories AS C 
			INNER JOIN vProducts AS P 
				ON C.CategoryID = P.CategoryID 
			INNER JOIN vInventories AS I 
				ON P.ProductID = I.ProductID 
			INNER JOIN vEmployees AS E
				ON I.EmployeeID = E.EmployeeID
		WHERE I.ProductID in (SELECT [ProductID] FROM Products WHERE [ProductName] IN ('Chai', 'Chang')) -- use subquery to identify ONLY chai and chang products 
	ORDER BY [Inventory Date], [Category Name], [Product Name], [Employee Name];
GO

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

CREATE VIEW vEmployeesByManager
AS
	SELECT TOP 100000
		M.EmployeeFirstName + ' ' + M.EmployeeLastName AS [Manager], E.EmployeeFirstName + ' ' + E.EmployeeLastName AS [Employee]
			FROM vEmployees AS E -- match the employeeid with the managerid to create and display column that lists manager name (from employee list)
			INNER JOIN vEmployees AS M 
				ON E.ManagerID = M.EmployeeID -- create and combine manager name column with employee name columns (from e table and m table)
	ORDER BY [Manager], [Employee];
GO

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

CREATE VIEW vInventoriesByProductsByCategoriesByEmployees -- views are saved (as code) in database in a system table  
AS 
	SELECT TOP 100000 -- need to list out every column from tables but only keys once in primary tables 
		C.CategoryID AS [Category ID], C.CategoryName AS [Category Name], -- category table (two columns)
		P.ProductID AS [Product ID], P.ProductName AS [Product Name], P.UnitPrice AS [Unit Price], -- product table (three columns)
		I.InventoryID AS [Inventory ID], I.InventoryDate AS [Inventory Date], I.[Count], -- inventory table (3 columns)
		E.EmployeeID AS [Employee ID], M.EmployeeFirstName + ' ' + M.EmployeeLastName AS [Manager], E.EmployeeFirstName + ' ' + E.EmployeeLastName AS [Employee]
			FROM vCategories as C -- start with earlier identified columns from categories view 
			INNER JOIN vProducts AS P 
			ON P.CategoryID = C.CategoryID -- join vcategories to vproduct by category ID
			INNER JOIN vInventories AS I 
				ON P.ProductID = I.ProductID -- join vproducts to vinventory by product ID
			INNER JOIN vEmployees AS E
				ON I.EmployeeID = E.EmployeeID -- join vinventory to vemployee by employee id
			INNER JOIN vEmployees AS M 
				ON E.ManagerID = M.EmployeeID -- self join vemployee to vemployee by employee id to add manager 
	ORDER BY [Category ID], [Product ID], [Inventory ID], [Employee ID];
GO

Sp_helpText vInventoriesByProductsByCategoriesByEmployees

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]



/***************************************************************************************/