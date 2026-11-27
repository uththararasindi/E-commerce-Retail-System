/*
===============================================================================
 OLIST DWBI PROJECT - STAGING DATABASE TABLE CREATION
 File: Olist_Staging_Create.sql

 Purpose:
   Creates the final staging-table structures used by Staging.dtsx.
   The staging layer stores extracted source data before dimensional
   transformations are performed in Package.dtsx.

 Important:
   This script assumes that the database Olist_Staging already exists.
===============================================================================
*/

USE Olist_Staging;


/* ---------------------------------------------------------------------------
   1. CUSTOMER STAGING TABLE
   Source: Customers operational data
   Final data types reflect the metadata used by the working SSIS package.
--------------------------------------------------------------------------- */
CREATE TABLE dbo.stg_Customers
(
    customer_id              NVARCHAR(50),
    customer_unique_id       NVARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city            NVARCHAR(150),
    customer_state           NVARCHAR(20)
);


/* ---------------------------------------------------------------------------
   2. ORDER STAGING TABLE
   Source: Orders operational data
--------------------------------------------------------------------------- */
CREATE TABLE dbo.stg_Orders
(
    order_id                      NVARCHAR(50),
    customer_id                   NVARCHAR(50),
    order_status                  NVARCHAR(50),
    order_purchase_timestamp      DATETIME,
    order_approved_at             DATETIME NULL,
    order_delivered_carrier_date  DATETIME NULL,
    order_delivered_customer_date DATETIME NULL,
    order_estimated_delivery_date DATETIME NULL
);


/* ---------------------------------------------------------------------------
   3. ORDER ITEM STAGING TABLE
   Source: Order items operational data
--------------------------------------------------------------------------- */
CREATE TABLE dbo.stg_OrderItems
(
    order_id            NVARCHAR(50),
    order_item_id       INT,
    product_id          NVARCHAR(50),
    seller_id           NVARCHAR(50),
    shipping_limit_date DATETIME,
    price               DECIMAL(18,2),
    freight_value       DECIMAL(18,2)
);


/* ---------------------------------------------------------------------------
   4. ORDER PAYMENT STAGING TABLE
   Source: Order payments operational data
--------------------------------------------------------------------------- */
CREATE TABLE dbo.stg_OrderPayments
(
    order_id             NVARCHAR(50),
    payment_sequential   INT,
    payment_type         NVARCHAR(50),
    payment_installments INT,
    payment_value        DECIMAL(18,2)
);


/* ---------------------------------------------------------------------------
   5. PRODUCT STAGING TABLE
   Source: Products CSV

   Product measurement fields are intentionally stored as VARCHAR(100).
   The source contains blank/text values, and the warehouse package performs
   cleansing and safe numeric conversion before loading Dim_Product.
--------------------------------------------------------------------------- */
CREATE TABLE dbo.stg_Products
(
    product_id                 VARCHAR(50),
    product_category_name      VARCHAR(100) NULL,
    product_name_lenght        VARCHAR(100) NULL,
    product_description_lenght VARCHAR(100) NULL,
    product_photos_qty         VARCHAR(100) NULL,
    product_weight_g           VARCHAR(100) NULL,
    product_length_cm          VARCHAR(100) NULL,
    product_height_cm          VARCHAR(100) NULL,
    product_width_cm           VARCHAR(100) NULL
);


/* ---------------------------------------------------------------------------
   6. PRODUCT CATEGORY TRANSLATION STAGING TABLE
   Source: Product category translation CSV
--------------------------------------------------------------------------- */
CREATE TABLE dbo.stg_ProductCategoryTranslation
(
    product_category_name         NVARCHAR(100),
    product_category_name_english NVARCHAR(100)
);
GO

/* ---------------------------------------------------------------------------
   7. SELLER STAGING TABLE
   Source: Sellers JSON
--------------------------------------------------------------------------- */
CREATE TABLE dbo.stg_Sellers
(
    seller_id              VARCHAR(50),
    seller_zip_code_prefix INT,
    seller_city            VARCHAR(100),
    seller_state           VARCHAR(10)
);



