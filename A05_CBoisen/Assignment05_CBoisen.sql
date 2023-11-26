--*************************************************************************--
-- Title: Assignment05
-- Author: CBoisen
-- Desc: This file demonstrates how to use Joins and Subqueiers
-- Change Log: When,Who,What
-- 2023-11-06,CBoisen,Created File
--**************************************************************************--
Use Master;
go

If Exists(Select Name From SysDatabases Where Name = 'Assignment05DB_CBoisen')
 Begin 
  Alter Database [Assignment05DB_CBoisen] set Single_user With Rollback Immediate;
  Drop Database Assignment05DB_CBoisen;
 End
go

Create Database Assignment05DB_CBoisen;
go

Use Assignment05DB_CBoisen;
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
-- Question 1 (10 pts): How can you show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

/*
SELECT * FROM Categories; -- View both entire category and entire product tables
SELECT * FROM Products;

SELECT CategoryName FROM Categories; -- look at category names to be combined
SELECT ProductName, UnitPrice FROM Products; --- look at product name and unit price to be combined 
*/

SELECT C.CategoryName AS [Category Name], P.ProductName AS [Product Name], P.UnitPrice AS [Unit Price] -- choose columns to be included in join 
FROM Categories AS C -- use alias for tables
	INNER JOIN Products AS P -- inner join default join used unless specific otherwise 
		ON C.CategoryID = P.CategoryID -- join tables using CategoryID (linked)
ORDER BY [Category Name], [Product Name];


-- Question 2 (10 pts): How can you show a list of Product name 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Date, Product,  and Count!
/*
SELECT * FROM Inventories; -- want to reduce redundancy when many dates for each entry 
SELECT * FROM Products; -- tables connected through ProductID
*/

SELECT P.ProductName AS [Product Name], I.InventoryDate AS [Inventory Date], I.[Count] -- choose columns to be included in join
FROM Products AS P
	INNER JOIN Inventories AS I
		ON P.ProductID = I.ProductID -- join tables using CategoryID 
ORDER BY [Inventory Date], [Product Name], [Count];

-- Question 3 (10 pts): How can you show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!
 /*
SELECT * FROM Inventories;
SELECT * FROM Employees; -- Connected through employeeID key 
*/

SELECT DISTINCT I.InventoryDate AS [Inventory Date], E.EmployeeFirstName + ' ' + E.EmployeeLastName AS [Employee Name]
FROM Inventories AS I
	INNER JOIN Employees AS E
		ON I.EmployeeID = E.EmployeeID
ORDER BY [Inventory Date], [Employee Name];

-- Question 4 (10 pts): How can you show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

SELECT C.CategoryName AS [Category Name], P.ProductName AS [Product Name], I.InventoryDate AS [Inventory Date], I.[Count]  -- choose columns to be included in join 
FROM Categories AS C -- use alias for tables
	INNER JOIN Products AS P -- inner join default join used unless specific otherwise 
		ON C.CategoryID = P.CategoryID 
	INNER JOIN Inventories AS I
		ON P.ProductID = I.ProductID 
ORDER BY [Category Name], [Product Name], [Inventory Date], [Count];

-- Question 5 (20 pts): How can you show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

SELECT DISTINCT C.CategoryName AS [Category Name], P.ProductName AS [Product Name], I.InventoryDate AS [Inventory Date], I.[Count], E.EmployeeFirstName + ' ' + E.EmployeeLastName AS [Employee Name]  -- choose columns to be included in join 
FROM Categories AS C -- use alias for tables
	INNER JOIN Products AS P -- inner join default join used unless specific otherwise 
		ON C.CategoryID = P.CategoryID 
	INNER JOIN Inventories AS I 
		ON P.ProductID = I.ProductID 
	INNER JOIN Employees AS E
		ON I.EmployeeID = E.EmployeeID
ORDER BY [Inventory Date], [Category Name], [Product Name], [Employee Name];

-- Question 6 (20 pts): How can you show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
-- For Practice; Use a Subquery to get the ProductID based on the Product Names 
-- and order the results by the Inventory Date, Category, and Product!

SELECT DISTINCT C.CategoryName AS [Category Name], P.ProductName AS [Product Name], I.InventoryDate AS [Inventory Date], I.[Count], E.EmployeeFirstName + ' ' + E.EmployeeLastName AS [Employee Name]  -- choose columns to be included in join 
FROM Categories AS C -- use alias for tables
	INNER JOIN Products AS P -- inner join default join used unless specific otherwise 
		ON C.CategoryID = P.CategoryID 
	INNER JOIN Inventories AS I 
		ON P.ProductID = I.ProductID 
	INNER JOIN Employees AS E
		ON I.EmployeeID = E.EmployeeID
WHERE I.ProductID in (SELECT [ProductID] FROM Products WHERE [ProductName] IN ('Chai', 'Chang')) -- use subquery to identify ONLY chai and chang products 
ORDER BY [Inventory Date], [Category Name], [Product Name], [Employee Name];

-- Question 7 (20 pts): How can you show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- USE A SELF JOIN by duplicating the table and joining sepocific identifier rows to itself 

SELECT M.EmployeeFirstName + ' ' + M.EmployeeLastName AS [Manager], E.EmployeeFirstName + ' ' + E.EmployeeLastName AS [Employee]
FROM Employees AS E -- match the employeeid with the managerid to create and display column that lists manager name (from employee list)
	INNER JOIN Employees AS M 
		ON E.ManagerID = M.EmployeeID -- create and combine manager name column with employee name columns (from e table and m table)
ORDER BY [Manager], [Employee];


/***************************************************************************************/