/*
===============================================================================
 OLIST DWBI PROJECT - FINAL DATA WAREHOUSE CREATION
 File: Olist_DW_Final_Create.sql

 Purpose:
   Creates the final dimensional warehouse database structure.
   No source data is copied by this script. Data is loaded by SSIS.

 Dimensional model:
   Dimensions: Dim_Customer, Dim_Product, Dim_Seller, Dim_Location, Dim_Date
   Fact table: Fact_Orders
   Fact grain: one row per order item
===============================================================================
*/

USE master;


/* ---------------------------------------------------------------------------
   1. CREATE FINAL WAREHOUSE DATABASE
--------------------------------------------------------------------------- */
IF DB_ID('Olist_DW_Final') IS NULL
BEGIN
    CREATE DATABASE Olist_DW_Final;
END;


USE Olist_DW_Final;
GO

/* ---------------------------------------------------------------------------
   2. CREATE DATA MART SCHEMAS
   The views themselves are created in Data_Marts.sql.
--------------------------------------------------------------------------- */
CREATE SCHEMA Executive;
GO
CREATE SCHEMA Logistics;
GO
CREATE SCHEMA Marketing;
GO
CREATE SCHEMA Sales;
GO


/* ---------------------------------------------------------------------------
   3. DIMENSION: LOCATION
   Shared role-playing dimension used for both customer and seller locations.
--------------------------------------------------------------------------- */
CREATE TABLE dbo.Dim_Location
(
    LocationKey   INT IDENTITY(1,1) NOT NULL,
    ZipCodePrefix NVARCHAR(20) NOT NULL,
    City          NVARCHAR(100) NOT NULL,
    State         NVARCHAR(10) NOT NULL,

    CONSTRAINT PK_Dim_Location
        PRIMARY KEY CLUSTERED (LocationKey)
);


/* ---------------------------------------------------------------------------
   4. DIMENSION: DATE
   Calendar dimension used for historical and trend analysis.
--------------------------------------------------------------------------- */
CREATE TABLE dbo.Dim_Date
(
    DateKey       INT NOT NULL,
    FullDate      DATE NOT NULL,
    Year          INT NOT NULL,
    Quarter       INT NOT NULL,
    Month         INT NOT NULL,
    MonthName     NVARCHAR(20) NOT NULL,
    Day           INT NOT NULL,
    DayOfWeekName NVARCHAR(20) NOT NULL,

    CONSTRAINT PK_Dim_Date
        PRIMARY KEY CLUSTERED (DateKey)
);


/* ---------------------------------------------------------------------------
   5. DIMENSION: PRODUCT
   Stores translated category names and cleaned product measurements.
--------------------------------------------------------------------------- */
CREATE TABLE dbo.Dim_Product
(
    ProductSK           INT IDENTITY(1,1) NOT NULL,
    ProductBK           NVARCHAR(50) NOT NULL,
    CategoryNameEnglish NVARCHAR(100) NULL,
    ProductWeightGrams  FLOAT NULL,
    ProductLengthCm     FLOAT NULL,
    ProductHeightCm     FLOAT NULL,
    ProductWidthCm      FLOAT NULL,

    CONSTRAINT PK_Dim_Product
        PRIMARY KEY CLUSTERED (ProductSK)
);


/* ---------------------------------------------------------------------------
   6. DIMENSION: CUSTOMER
--------------------------------------------------------------------------- */
CREATE TABLE dbo.Dim_Customer
(
    CustomerSK       INT IDENTITY(1,1) NOT NULL,
    CustomerBK       NVARCHAR(50) NOT NULL,
    CustomerUniqueId NVARCHAR(50) NULL,

    CONSTRAINT PK_Dim_Customer
        PRIMARY KEY CLUSTERED (CustomerSK)
);


/* ---------------------------------------------------------------------------
   7. DIMENSION: SELLER
   Seller geography is handled separately through Dim_Location.
--------------------------------------------------------------------------- */
CREATE TABLE dbo.Dim_Seller
(
    SellerSK INT IDENTITY(1,1) NOT NULL,
    SellerBK NVARCHAR(50) NOT NULL,

    CONSTRAINT PK_Dim_Seller
        PRIMARY KEY CLUSTERED (SellerSK)
);


/* ---------------------------------------------------------------------------
   8. FACT TABLE: ORDERS
   Grain: one row per order item.
--------------------------------------------------------------------------- */
CREATE TABLE dbo.Fact_Orders
(
    OrderSK         INT IDENTITY(1,1) NOT NULL,
    OrderBK         NVARCHAR(50) NOT NULL,
    OrderItemNumber INT NOT NULL,

    DateKey    INT NULL,
    CustomerSK INT NULL,
    ProductSK  INT NULL,
    SellerSK   INT NULL,

    Price            DECIMAL(10,2) NULL,
    FreightValue     DECIMAL(10,2) NULL,
    TotalOrderValue  DECIMAL(10,2) NULL,
    DeliveryTimeDays INT NULL,

    CustomerLocationKey INT NULL,
    SellerLocationKey   INT NULL,

    CONSTRAINT PK_Fact_Orders
        PRIMARY KEY CLUSTERED (OrderSK)
);


/* ---------------------------------------------------------------------------
   9. FOREIGN KEY RELATIONSHIPS
--------------------------------------------------------------------------- */
ALTER TABLE dbo.Fact_Orders
ADD CONSTRAINT FK_FactOrders_Customer
FOREIGN KEY (CustomerSK)
REFERENCES dbo.Dim_Customer(CustomerSK);


ALTER TABLE dbo.Fact_Orders
ADD CONSTRAINT FK_FactOrders_Date
FOREIGN KEY (DateKey)
REFERENCES dbo.Dim_Date(DateKey);


ALTER TABLE dbo.Fact_Orders
ADD CONSTRAINT FK_FactOrders_Product
FOREIGN KEY (ProductSK)
REFERENCES dbo.Dim_Product(ProductSK);
GO

ALTER TABLE dbo.Fact_Orders
ADD CONSTRAINT FK_FactOrders_Seller
FOREIGN KEY (SellerSK)
REFERENCES dbo.Dim_Seller(SellerSK);


ALTER TABLE dbo.Fact_Orders
ADD CONSTRAINT FK_FactOrders_CustomerLocation
FOREIGN KEY (CustomerLocationKey)
REFERENCES dbo.Dim_Location(LocationKey);


ALTER TABLE dbo.Fact_Orders
ADD CONSTRAINT FK_FactOrders_SellerLocation
FOREIGN KEY (SellerLocationKey)
REFERENCES dbo.Dim_Location(LocationKey);


