/*
===============================================================================
Script Name   : 01_dimension_exploration.sql
Layer         : Gold
Purpose       : To explore and validate the structure and content of the gold 
                layer dimension and fact tables for analytical readiness.
Author        : Natarajan Thanaraj
===============================================================================
Description:
    This script performs schema and data exploration across the gold layer. 
    It helps analysts and engineers verify table availability, column metadata, 
    and data distribution patterns for customers, products, and sales facts.

Sections Included:
    1. Schema Metadata Exploration
    2. Customer Dimension Exploration
    3. Product Dimension Exploration
    4. Sales Fact Exploration

SQL Functions Used:
    - DISTINCT
    - ORDER BY
    - INFORMATION_SCHEMA views
===============================================================================
*/

-- ============================================================================
-- SECTION 1: Schema Metadata Exploration
-- ============================================================================
-- Retrieve all tables available in the gold schema
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'gold'
ORDER BY TABLE_NAME;

-- Retrieve detailed column information for each table in the gold schema
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold'
ORDER BY TABLE_NAME, ORDINAL_POSITION;


-- ============================================================================
-- SECTION 2: Customer Dimension Exploration
-- ============================================================================
-- Retrieving the top 5 records to understand data structure of the customer dimension
SELECT TOP 5 * 
FROM gold.dim_customers;

-- Retrieve a list of unique countries from which customers originate
SELECT DISTINCT 
    country
FROM gold.dim_customers
ORDER BY country;

-- Retrieve a list of unique genders for data quality and segmentation insights
SELECT DISTINCT 
    gender
FROM gold.dim_customers
ORDER BY gender;

-- Quick record count for volume validation
SELECT 
    COUNT(*) AS total_customers
FROM gold.dim_customers;


-- ============================================================================
-- SECTION 3: Product Dimension Exploration
-- ============================================================================
-- Retrieving the top 5 records to understand data structure of the product dimension
SELECT TOP 5 * 
FROM gold.dim_products;

-- Retrieve a list of unique product categories, subcategories, and product names
SELECT DISTINCT 
    category, 
    subcategory, 
    product_name
FROM gold.dim_products
ORDER BY category, subcategory, product_name;

-- Retrieve a list of unique maintenance types for reference
SELECT DISTINCT 
    maintenance
FROM gold.dim_products
ORDER BY maintenance;

-- Quick record count for volume validation
SELECT 
    COUNT(*) AS total_products
FROM gold.dim_products;


-- ============================================================================
-- SECTION 4: Sales Fact Exploration
-- ============================================================================
-- Retrieving the top 5 records to understand data structure of the sales fact table
SELECT TOP 5 *
FROM gold.fact_sales;

-- Retrieve a list of unique order dates for time-series validation
SELECT DISTINCT 
    order_date
FROM gold.fact_sales
ORDER BY order_date;

-- Retrieve a list of unique price points for sanity check
SELECT DISTINCT 
    price
FROM gold.fact_sales
ORDER BY price;

-- Retrieve unique combinations of customer, product, and order for granularity check
SELECT DISTINCT 
    order_number, 
    customer_key, 
    product_key
FROM gold.fact_sales
ORDER BY order_number, customer_key, product_key;

-- Quick record count for validation
SELECT 
    COUNT(*) AS total_sales_records
FROM gold.fact_sales;
