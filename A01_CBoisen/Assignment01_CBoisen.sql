----------------------------------------------------------------------
-- Title: Assignment01
-- Desc: Creating a normalized database from sample data
-- Author: Christa Boisen 
-- ChangeLog: (When,Who,What)
-- 9/21/2021,RRoot,Created Script
-- TODO: <12/13>,<Christa Boisen>,Completed Script
----------------------------------------------------------------------

--[ Create the Database ]--
--********************************************************************--
Use Master;
go
If exists (Select * From sysdatabases Where name='Assignment01DB_CBoisen') -- See if the database already exists
  Begin
  	Use [master];
	  Alter Database Assignment01DB_CBoisen Set Single_User With Rollback Immediate; -- If so, remove everyone from the DB
		Drop Database Assignment01DB_CBoisen; -- then drop the database.
  End
go
Create Database Assignment01DB_CBoisen; -- Now, make or remake the database
go
Use Assignment01DB_CBoisen; -- and start using it.
go

----Create Product Table 


 CREATE TABLE dbo.Products(
  [Product ID] int PRIMARY KEY, --- Primary key (Identification column) needed at beginning of each table to differentiate each row from the next
  [Product Name] varchar(50), --- Character 
  [Product Price] money --- Character ($)
);
Go

INSERT INTO dbo.Products ---Insert values 
VALUES
(100, 'Apples','$0.89'),
(101, 'Milk', '$1.59'),
(102, 'Bread', '$2.28');
Go

----Create Customer Table 

 CREATE TABLE dbo.Customer(
  [Customer ID] int PRIMARY KEY,
  [Customer Name First] varchar(50), 
  [Customer Name Last] varchar(50),--- Character 
  [Customer Address Number] int, --- integer
  [Customer Address Street] varchar(50), --- Character
  [Customer Address City] varchar(50), --- Character
  [Customer Address State] varchar(50) --- Character  
);
Go

INSERT INTO dbo.Customer 
  VALUES(10, 'Bob', 'Smith', 123, 'Main', 'Bellevue', 'Wa');
Go

----Create Sale Table 


 CREATE TABLE dbo.Sales(
  [Sales ID] int,
  [Customer ID] int,
  Primary Key([Sales ID], [Customer ID])
);
Go

INSERT INTO dbo.Sales
VALUES(1001, 10);
Go

----Create Sale Line Items Table  

 CREATE TABLE dbo.SaleLineItems(
  [Sales ID] int,
  [Line Item ID] int,
  [Product ID] int,
  [Quantity] int,
  Primary Key([Sales ID], [Line Item ID])
);
Go

INSERT INTO dbo.SaleLineItems 
	VALUES(1001, 1, 100, 12),(1001, 2, 101, 2),(1001, 3, 102, 1);
Go



SELECT * FROM Products; --- Show resulting Product Table 
SELECT * FROM Customer; --- Show Resulting Customer Table
SELECT * FROM Sales; --- Show Resulting Sales Table 
SELECT * FROM SaleLineItems; --- Show Resulting SaleLineItems Table 

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

