--*************************************************************************--
-- Title: Assignment02 
-- Desc: This script demonstrates the creation of a typical database with:
--       1) Tables
--       2) Constraints
--       3) Views
-- Dev: RRoot
-- Change Log: When,Who,What
-- 9/21/2021,RRoot,Created File
-- TODO: <10.21.2023>,<Christa Boisen>,Completed File
--**************************************************************************--

--[ Create the Database ]--
--********************************************************************--
Use Master;
go
If exists (Select * From sysdatabases Where name='Assignment02DB_CBoisen')
  Begin
  	Use [master];
	  Alter Database Assignment02DB_CBoisen Set Single_User With Rollback Immediate; -- Kick everyone out of the DB
		Drop Database Assignment02DB_CBoisen;
  End
go
Create Database Assignment02DB_CBoisen;
go
Use Assignment02DB_CBoisen;
go

--[ Create the Tables ]--
--********************************************************************--
-- NOTE: Include identity "default" when creating your tables

-- TODO: Create table for Categories
CREATE TABLE dbo.Categories(
[Category ID] int IDENTITY NOT NULL, --- primary key enforces unique values for each row which identity does not guarantee
[Category Name] nvarchar(100) NOT NULL);
GO

-- TODO: Add Constraints for Categories (Primary Key, Unique)
ALTER TABLE dbo.Categories
  ADD CONSTRAINT PK_cat PRIMARY KEY CLUSTERED ([Category ID]), --- Primary key can never be null
      CONSTRAINT uniq_cat_name UNIQUE NONCLUSTERED ([Category Name]);
GO



-- TODO: Create table for Products
 CREATE TABLE dbo.Products(
  [Product ID] int IDENTITY NOT NULL, --- Identity (not a constraint) automatically adds values to column, (1,1) = First row is 1 and each row increases by an increment of 1
  [Product Name] nvarchar(100) NOT NULL, --- Character 
  [Product Current Price] money NULL, 
  [Category ID] int NOT NULL);
GO

-- TODO: Add Constraints for Products (Primary Key, Unique, Check, Foreign Key, )
ALTER TABLE dbo.Products
  ADD CONSTRAINT PK_prod PRIMARY KEY CLUSTERED ([Product ID]),
      CONSTRAINT uniq_prod_name UNIQUE([Product Name]),
      CONSTRAINT chk_prod_currprice CHECK([Product Current Price] > 0),
      CONSTRAINT FK_prod_catID FOREIGN KEY([Category ID]) REFERENCES Categories([Category ID]); --- References matching Category ID in the Category table 
      
GO

-- TODO: Create table for Inventories
 CREATE TABLE dbo.Inventories(
  [Inventory ID] int IDENTITY(1,1) NOT NULL, 
  [Inventory Date] date NOT NULL, 
  [Inventory Count] int NULL,
  [Product ID] int NOT NULL);
GO

-- TODO: Add Constraints for Inventories (Primary Key, Check, Default, Foreign Key)
ALTER TABLE dbo.Inventories
  ADD CONSTRAINT PK_inv PRIMARY KEY CLUSTERED ([Inventory ID]), 
      CONSTRAINT chk_inv_count CHECK([Inventory Count] >= 0), 
	    CONSTRAINT DF_inv_count DEFAULT(0) FOR [Inventory Count],
      CONSTRAINT FK_inv_prodID FOREIGN KEY([Product ID]) REFERENCES Products([Product ID]); --- References matching Product ID in the Product table 
GO
       

--[ Create the Views ]--
--********************************************************************--
-- TODO: Create Views for Categories
CREATE VIEW dbo.vCategories
AS
  SELECT 
  [Category ID],
  [Category Name]
  FROM dbo.Categories;
GO


-- TODO: Create Views for Products
CREATE VIEW dbo.vProducts
AS
  SELECT 
  [Product ID],
  [Product Name],
  [Product Current Price],
  [Category ID]
  FROM dbo.Products;
GO


-- TODO: Create Views for Inventories
CREATE VIEW dbo.vInventories
AS
  SELECT 
  [Inventory ID],
  [Inventory Date],
  [Inventory Count],
  [Product ID]
  FROM dbo.Inventories;
GO

SELECT * FROM vCategories;
SELECT * FROM vProducts;
SELECT * FROM vInventories;


--[ Insert the Values ]--
--********************************************************************--
-- TODO: Insert Values for Categories 
INSERT INTO dbo.Categories([Category Name])
VALUES
('CatA'),
('CatB');
GO

-- TODO: Insert Values for Products

INSERT INTO dbo.Products([Product Name], [Product Current Price], [Category ID])
VALUES
('Prod1','$9.99', 1),
('Prod2','$19.99', 1),
('Prod3','$14.99', 2);
GO

-- TODO: Insert Values for Inventories

INSERT INTO dbo.Inventories([Inventory Date], [Inventory Count], [Product ID])
VALUES
('2020-01-01', 100, 1),
('2020-01-01', 50, 2),
('2020-01-01', 34, 3),
('2020-02-01', 100, 1),
('2020-02-01', 50, 2),
('2020-02-01', 34, 3);
GO


SELECT* FROM Categories
SELECT* FROM Products 
SELECT* FROM Inventories

EXEC sp_help Categories
EXEC sp_help Products
EXEC sp_help Inventories

--[ Review the design ]--
--********************************************************************--
-- Note: This is advanced code and it is NOT expected that you should be able to read it yet. 
-- However, you will be able to by the end of the course! :-)
-- Meta Data Query:
With 
TablesAndColumns As (
Select  
  [SourceObjectName] = TABLE_CATALOG + '.' + TABLE_SCHEMA + '.' + TABLE_NAME + '.' + COLUMN_NAME
, [IS_NULLABLE]=[IS_NULLABLE]
, [DATA_TYPE] = Case [DATA_TYPE]
                When 'varchar' Then  [DATA_TYPE] + '(' + IIf(DATA_TYPE = 'int','', IsNull(Cast(CHARACTER_MAXIMUM_LENGTH as varchar(10)), '')) + ')'
                When 'nvarchar' Then [DATA_TYPE] + '(' + IIf(DATA_TYPE = 'int','', IsNull(Cast(CHARACTER_MAXIMUM_LENGTH as varchar(10)), '')) + ')'
                When 'money' Then [DATA_TYPE] + '(' + Cast(NUMERIC_PRECISION as varchar(10)) + ',' + Cast(NUMERIC_SCALE as varchar(10)) + ')'
                When 'decimal' Then [DATA_TYPE] + '(' + Cast(NUMERIC_PRECISION as varchar(10)) + ',' + Cast(NUMERIC_SCALE as varchar(10)) + ')'
                When 'float' Then [DATA_TYPE] + '(' + Cast(NUMERIC_PRECISION as varchar(10)) + ',' + Cast(NUMERIC_SCALE as varchar(10)) + ')'
                Else [DATA_TYPE]
                End                          
, [TABLE_NAME]
, [COLUMN_NAME]
, [ORDINAL_POSITION]
, [COLUMN_DEFAULT]
From Information_Schema.columns 
),
Constraints As (
Select 
 [SourceObjectName] = TABLE_CATALOG + '.' + TABLE_SCHEMA + '.' + TABLE_NAME + '.' + COLUMN_NAME
,[CONSTRAINT_NAME]
From [INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE]
), 
IdentityColumns As (
Select 
 [ObjectName] = object_name(c.[object_id]) 
,[ColumnName] = c.[name]
,[IsIdentity] = IIF(is_identity = 1, 'Identity', Null)
From sys.columns as c Join Sys.tables as t on c.object_id = t.object_id
) 
Select 
  TablesAndColumns.[SourceObjectName]
, [IsNullable] = [Is_Nullable]
, [DataType] = [Data_Type] 
, [ConstraintName] = IsNull([CONSTRAINT_NAME], 'NA')
, [COLUMN_DEFAULT] = IsNull(IIF([IsIdentity] Is Not Null, 'Identity', [COLUMN_DEFAULT]), 'NA')
--, [ORDINAL_POSITION]
From TablesAndColumns 
Full Join Constraints On TablesAndColumns.[SourceObjectName]= Constraints.[SourceObjectName]
Full Join IdentityColumns On TablesAndColumns.COLUMN_NAME = IdentityColumns.[ColumnName]
                          And TablesAndColumns.Table_NAME = IdentityColumns.[ObjectName]
Where [TABLE_NAME] Not In (Select [TABLE_NAME] From [INFORMATION_SCHEMA].[VIEWS])
Order By [TABLE_NAME],[ORDINAL_POSITION]


-- Important: The correct design should match this output when my metadata query runs
/*
SourceObjectName	                                    IsNullable	    DataType	     ConstraintName	                          COLUMN_DEFAULT
Assignment02DB_RRoot.dbo.Categories.CategoryID	        NO	            int	             pkCategories	                          Identity
Assignment02DB_RRoot.dbo.Categories.CategoryName	    NO	            nvarchar(100) 	 uCategoryName	                          NA
Assignment02DB_RRoot.dbo.Inventories.InventoryID	    NO	            int	             pkInventories	                          Identity
Assignment02DB_RRoot.dbo.Inventories.InventoryDate	    NO	            date	         NA	                                      NA
Assignment02DB_RRoot.dbo.Inventories.InventoryCount	    NO	            int	             ckInventoriesInventoryCountZeroOrMore	  ((0))
Assignment02DB_RRoot.dbo.Inventories.ProductID	        NO	            int	             fkInventoriesProducts	                  NA
Assignment02DB_RRoot.dbo.Products.ProductID	            NO	            int	             pkProducts	                              Identity
Assignment02DB_RRoot.dbo.Products.ProductName	        NO	            nvarchar(100) 	 uProductName	                          NA
Assignment02DB_RRoot.dbo.Products.ProductCurrentPrice	YES	            money(19,4)	     pkProductsUnitPriceMoreThanZero	      NA
Assignment02DB_RRoot.dbo.Products.CategoryID	        NO	            int	             fkProductsCategories	                  NA
*/
