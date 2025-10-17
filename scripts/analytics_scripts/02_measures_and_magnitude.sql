/*
===============================================================================
Script Name   : 02_Data_Exploration_Measures_And_Magnitude.sql
Layer         : Gold
Purpose       : To explore key business metrics, temporal ranges, and data 
                magnitudes across customer, product, and sales dimensions.
Author        : Natarajan Thanaraj
===============================================================================
Description:
    This script performs data exploration and summary analytics on the gold layer.
    It helps identify the range of historical data, measure key KPIs such as total 
    sales and orders, and analyze magnitude distributions across customers, products, 
    and geographies.

Sections Included:
    1. Date Range Exploration
    2. Measures Exploration (Key Metrics)
    3. Magnitude Analysis (Group-wise Aggregations)

SQL Functions Used:
    - Aggregate Functions: MIN(), MAX(), DATEDIFF(), COUNT(), SUM(), AVG()
    - GROUP BY, ORDER BY
===============================================================================
*/


-- ============================================================================
-- SECTION 1: Date Range Exploration
-- ============================================================================
-- Determine the first and last order dates and total duration in months
SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;

-- Identify the youngest and oldest customers based on birthdate
SELECT
    MIN(birthdate) AS oldest_birthdate,
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,
    MAX(birthdate) AS youngest_birthdate,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers;



-- ============================================================================
-- SECTION 2: Measures Exploration (Key Metrics)
-- ============================================================================
-- Find the total sales
SELECT SUM(sales_amount) AS total_sales 
FROM gold.fact_sales;

-- Find total quantity sold
SELECT SUM(quantity) AS total_quantity 
FROM gold.fact_sales;

-- Find the average selling price
SELECT AVG(price) AS avg_price 
FROM gold.fact_sales;

-- Find the total number of orders (with and without DISTINCT check)
SELECT COUNT(order_number) AS total_orders 
FROM gold.fact_sales;

SELECT COUNT(DISTINCT order_number) AS total_distinct_orders 
FROM gold.fact_sales;

-- Find the total number of products
SELECT COUNT(product_name) AS total_products 
FROM gold.dim_products;

-- Find the total number of customers
SELECT COUNT(customer_key) AS total_customers 
FROM gold.dim_customers;

-- Find the total number of customers who have placed an order
SELECT COUNT(DISTINCT customer_key) AS active_customers 
FROM gold.fact_sales;

-- Generate a single summary report of all key measures
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_name) FROM gold.dim_products
UNION ALL
SELECT 'Total Customers', COUNT(customer_key) FROM gold.dim_customers;



-- ============================================================================
-- SECTION 3: Magnitude Analysis (Group-wise Aggregations)
-- ============================================================================
-- Find total customers by country
SELECT
    country,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- Find total customers by gender
SELECT
    gender,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Find total products by category
SELECT
    category,
    COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- Find average product cost per category
SELECT
    category,
    AVG(cost) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC;

-- Find total revenue generated per category
SELECT
    p.category,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Find total revenue generated per customer
SELECT
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

-- Find distribution of sold items across countries
SELECT
    c.country,
    SUM(f.quantity) AS total_sold_items
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC;

-- Find average order value by country
SELECT
    c.country,
    AVG(f.sales_amount) AS avg_order_value
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY avg_order_value DESC;

