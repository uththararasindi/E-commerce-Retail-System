/*
===============================================================================
 OLIST DWBI PROJECT - DATA MART VIEWS
 File: Data_Marts.sql

 Purpose:
   Creates four department-oriented analytical views on Olist_DW_Final.

 Data Marts:
   1. Executive.MonthlySummary
   2. Sales.ProductPerformance
   3. Marketing.CustomerInsights
   4. Logistics.ShippingPerformance
===============================================================================
*/

USE Olist_DW_Final;
GO


/* ---------------------------------------------------------------------------
   1. LOGISTICS DATA MART
   Target users: logistics / operations users
   Purpose: analyse freight, delivery time, and customer/seller geography.
--------------------------------------------------------------------------- */
CREATE VIEW Logistics.ShippingPerformance
AS
SELECT
    f.OrderBK AS OrderID,
    d.FullDate AS OrderDate,

    cl.City  AS CustomerCity,
    cl.State AS CustomerState,

    sl.City  AS SellerCity,
    sl.State AS SellerState,

    f.DeliveryTimeDays,
    f.FreightValue,
    f.TotalOrderValue

FROM dbo.Fact_Orders f
INNER JOIN dbo.Dim_Date d
    ON f.DateKey = d.DateKey
INNER JOIN dbo.Dim_Location cl
    ON f.CustomerLocationKey = cl.LocationKey
INNER JOIN dbo.Dim_Location sl
    ON f.SellerLocationKey = sl.LocationKey;


/* ---------------------------------------------------------------------------
   2. SALES DATA MART
   Target users: sales / product teams
   Purpose: analyse item-level product and category performance over time.
--------------------------------------------------------------------------- */
GO
CREATE VIEW Sales.ProductPerformance
AS
SELECT
    p.CategoryNameEnglish,
    p.ProductBK AS ProductID,
    d.FullDate AS SaleDate,
    f.Price,
    f.TotalOrderValue

FROM dbo.Fact_Orders f
INNER JOIN dbo.Dim_Product p
    ON f.ProductSK = p.ProductSK
INNER JOIN dbo.Dim_Date d
    ON f.DateKey = d.DateKey;


/* ---------------------------------------------------------------------------
   3. MARKETING DATA MART
   Target users: marketing / customer analysis users
   Purpose: analyse customer purchasing behaviour and geographical patterns.
--------------------------------------------------------------------------- */
GO
CREATE VIEW Marketing.CustomerInsights
AS
SELECT
    c.CustomerBK AS CustomerID,
    c.CustomerUniqueId,

    l.City  AS CustomerCity,
    l.State AS CustomerState,

    COUNT(DISTINCT f.OrderBK) AS TotalOrders,
    SUM(f.TotalOrderValue) AS TotalSpent,
    AVG(f.TotalOrderValue) AS AverageOrderValue

FROM dbo.Fact_Orders f
INNER JOIN dbo.Dim_Customer c
    ON f.CustomerSK = c.CustomerSK
INNER JOIN dbo.Dim_Location l
    ON f.CustomerLocationKey = l.LocationKey

GROUP BY
    c.CustomerBK,
    c.CustomerUniqueId,
    l.City,
    l.State;


/* ---------------------------------------------------------------------------
   4. EXECUTIVE DATA MART
   Target users: executives / senior management
   Purpose: monthly summary of orders, revenue and freight expenditure.
--------------------------------------------------------------------------- */
GO
CREATE VIEW Executive.MonthlySummary
AS
SELECT
    d.Year,
    d.Month,
    d.MonthName,

    COUNT(DISTINCT f.OrderBK) AS TotalOrders,
    SUM(f.TotalOrderValue) AS TotalRevenue,
    SUM(f.FreightValue) AS TotalFreightCosts

FROM dbo.Fact_Orders f
INNER JOIN dbo.Dim_Date d
    ON f.DateKey = d.DateKey

GROUP BY
    d.Year,
    d.Month,
    d.MonthName;


