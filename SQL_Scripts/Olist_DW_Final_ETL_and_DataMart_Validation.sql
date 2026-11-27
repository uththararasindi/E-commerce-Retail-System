/*
===============================================================================
 OLIST DWBI PROJECT - ETL AND DATA MART VALIDATION
 File: Olist_DW_Final_ETL_and_DataMart_Validation.sql

 Purpose:
   Validates the staging layer, dimensions, fact table, and Data Mart views
   after the SSIS ETL process has completed successfully.
===============================================================================
*/

/* ===========================================================================
   A. STAGING LAYER VALIDATION
=========================================================================== */

USE Olist_Staging;


/* Confirm row counts loaded by Staging.dtsx. */
SELECT COUNT(*) AS CustomerStagingCount
FROM dbo.stg_Customers;

SELECT COUNT(*) AS OrderStagingCount
FROM dbo.stg_Orders;

SELECT COUNT(*) AS OrderItemStagingCount
FROM dbo.stg_OrderItems;

SELECT COUNT(*) AS PaymentStagingCount
FROM dbo.stg_OrderPayments;

SELECT COUNT(*) AS ProductStagingCount
FROM dbo.stg_Products;

SELECT COUNT(*) AS CategoryTranslationStagingCount
FROM dbo.stg_ProductCategoryTranslation;

SELECT COUNT(*) AS SellerStagingCount
FROM dbo.stg_Sellers;


/* Inspect seller staging metadata used during SSIS lookup troubleshooting. */
EXEC sp_help 'dbo.stg_Sellers';


/* ===========================================================================
   B. DIMENSION VALIDATION
=========================================================================== */

USE Olist_DW_Final;


/* 1. Customer dimension */
SELECT COUNT(*) AS CustomerCount
FROM dbo.Dim_Customer;

SELECT TOP 10 *
FROM dbo.Dim_Customer;

/* 2. Product dimension */
SELECT COUNT(*) AS ProductCount
FROM dbo.Dim_Product;

SELECT COUNT(*) AS UnknownCategoryCount
FROM dbo.Dim_Product
WHERE CategoryNameEnglish = 'Unknown';

SELECT TOP 10 *
FROM dbo.Dim_Product;

/* 3. Seller dimension */
SELECT COUNT(*) AS SellerCount
FROM dbo.Dim_Seller;

/* 4. Location dimension */
SELECT COUNT(*) AS LocationCount
FROM dbo.Dim_Location;

SELECT TOP 10 *
FROM dbo.Dim_Location;

/* 5. Date dimension */
SELECT COUNT(*) AS DateCount
FROM dbo.Dim_Date;

SELECT
    MIN(FullDate) AS MinDate,
    MAX(FullDate) AS MaxDate
FROM dbo.Dim_Date;



/* ===========================================================================
   C. FACT TABLE VALIDATION
=========================================================================== */

/* Validate fact row count and unique order count. */
SELECT COUNT(*) AS FactCount
FROM dbo.Fact_Orders;

SELECT COUNT(DISTINCT OrderBK) AS UniqueOrders
FROM dbo.Fact_Orders;

/* Reconcile the main monetary measures. */
SELECT
    SUM(Price) AS TotalProductSales,
    SUM(FreightValue) AS TotalFreight,
    SUM(TotalOrderValue) AS TotalOrderValue
FROM dbo.Fact_Orders;
GO


/* ===========================================================================
   D. DATA MART VALIDATION
=========================================================================== */

/* Validate the number of rows exposed by each department-specific view. */
SELECT COUNT(*) AS ExecutiveRows
FROM Executive.MonthlySummary;

SELECT COUNT(*) AS SalesRows
FROM Sales.ProductPerformance;

SELECT COUNT(*) AS MarketingRows
FROM Marketing.CustomerInsights;

SELECT COUNT(*) AS LogisticsRows
FROM Logistics.ShippingPerformance;


/* Inspect the Executive mart structure and a sample row. */
SELECT TOP 1 *
FROM Executive.MonthlySummary;


/* Reconcile Executive mart totals with Fact_Orders. */
SELECT
    SUM(TotalRevenue) AS ExecutiveRevenue,
    SUM(TotalFreightCosts) AS ExecutiveFreight,
    SUM(TotalOrders) AS ExecutiveOrders
FROM Executive.MonthlySummary;


/* ===========================================================================
   Expected validated results from the completed project:
     Dim_Customer                     = 99,441
     Dim_Product                      = 32,951
     Unknown product categories       = 623
     Dim_Seller                       = 3,095
     Dim_Location                     = 15,249
     Dim_Date                         = 1,097
     Fact_Orders                      = 112,650
     Unique orders                    = 98,666
     Total product sales              = 13,591,285.70
     Total freight                    = 2,251,405.52
     Total order value                = 15,842,691.22
     Executive.MonthlySummary rows    = 24
     Sales.ProductPerformance rows    = 112,650
     Marketing.CustomerInsights rows  = 98,666
     Logistics.ShippingPerformance    = 112,650
=========================================================================== */
