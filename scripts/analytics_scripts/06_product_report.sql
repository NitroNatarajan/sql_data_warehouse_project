/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - Consolidates key product-level performance metrics and behaviors.

Highlights:
    1. Gathers essential product attributes: name, category, subcategory, and cost.
    2. Segments products by revenue into:
         - High-Performers
         - Mid-Range
         - Low-Performers
    3. Aggregates KPIs such as:
         - Total Orders
         - Total Sales
         - Total Quantity Sold
         - Total Unique Customers
         - Lifespan (in months)
    4. Calculates additional performance measures:
         - Recency (months since last sale)
         - Average Order Revenue (AOR)
         - Average Monthly Revenue (AMR)
         - Average Selling Price (ASP)
===============================================================================
*/

-- =============================================================================
-- Step 1: Drop existing view if it already exists
-- =============================================================================
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

-- =============================================================================
-- Step 2: Create the Product Report View
-- =============================================================================
CREATE VIEW gold.report_products AS

WITH base_query AS (
    /*---------------------------------------------------------------------------
    1) Base Query: Retrieve core transactional and product details
    ---------------------------------------------------------------------------*/
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
),

product_aggregations AS (
    /*---------------------------------------------------------------------------
    2) Product Aggregations: Summarize data at the product level
    ---------------------------------------------------------------------------*/
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        MAX(order_date) AS last_sale_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 2) AS avg_selling_price
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)

SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,

    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,

    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,

    -- Average Order Revenue (AOR)
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,

    -- Average Monthly Revenue (AMR)
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue

FROM product_aggregations;
GO
