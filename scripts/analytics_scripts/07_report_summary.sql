/*
===============================================================================
Retail Business Summary Report
===============================================================================
Purpose:
    - To consolidate high-level KPIs from both customers and products.
    - Designed for executive dashboards and trend monitoring.
    - Provides a snapshot of key business metrics for data-driven decisions.

Highlights:
    1. Combines metrics from gold.customer_report and gold.product_report.
    2. Calculates essential business KPIs:
         - Total Revenue
         - Total Orders
         - Total Customers
         - Total Products
         - Average Order Value (AOV)
         - Average Monthly Revenue (AMR)
         - Active Customers (last 3 months)
    3. Identifies top-performing categories and customer segments.
===============================================================================
*/
-- =============================================================================
-- Step 1: Drop existing view if it exists
-- =============================================================================
IF OBJECT_ID('gold.summary_report', 'V') IS NOT NULL
    DROP VIEW gold.summary_report;
GO

-- =============================================================================
-- Step 2: Create Summary View
-- =============================================================================
CREATE VIEW gold.summary_report AS

WITH
/*---------------------------------------------------------------------------
1) Customer Metrics
---------------------------------------------------------------------------*/
customer_metrics AS (
    SELECT
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(total_sales) AS total_customer_sales,
        SUM(total_orders) AS total_customer_orders,
        AVG(AOV) AS avg_customer_order_value,
        AVG(AVG_MONTH_SPEND) AS avg_customer_monthly_spend,
        SUM(CASE WHEN recency <= 3 THEN 1 ELSE 0 END) AS active_customers_3m
    FROM gold.customer_report
),

/*---------------------------------------------------------------------------
2) Product Metrics
---------------------------------------------------------------------------*/
product_metrics AS (
    SELECT
        COUNT(DISTINCT product_key) AS total_products,
        SUM(total_sales) AS total_product_sales,
        SUM(total_orders) AS total_product_orders,
        AVG(avg_order_revenue) AS avg_product_order_revenue,
        AVG(avg_monthly_revenue) AS avg_product_monthly_revenue
    FROM gold.product_report
),

/*---------------------------------------------------------------------------
3) Category Performance (Top 3 Categories by Total Sales)
---------------------------------------------------------------------------*/
top_categories AS (
    SELECT TOP 3
        category,
        SUM(total_sales) AS category_sales
    FROM gold.product_report
    GROUP BY category
    ORDER BY category_sales DESC
),

/*---------------------------------------------------------------------------
4) Customer Segmentation Summary
---------------------------------------------------------------------------*/
customer_segments AS (
    SELECT
        customer_status,
        COUNT(customer_key) AS total_customers
    FROM gold.customer_report
    GROUP BY customer_status
)

/*---------------------------------------------------------------------------
5) Final Aggregation: Combine Everything
---------------------------------------------------------------------------*/
SELECT
    -- Core KPIs
    cm.total_customers,
    cm.active_customers_3m,
    pm.total_products,

    -- Revenue & Orders
    pm.total_product_sales AS total_sales,
    cm.total_customer_orders + pm.total_product_orders AS total_orders,

    -- Averages
    ROUND(cm.avg_customer_order_value, 2) AS avg_order_value,
    ROUND(pm.avg_product_monthly_revenue, 2) AS avg_monthly_revenue,

    -- Top Category Insights
    (
        SELECT STRING_AGG(CONCAT(category, ' (', category_sales, ')'), ', ')
        FROM top_categories
    ) AS top_3_categories,

    -- Customer Segment Distribution
    (
        SELECT STRING_AGG(CONCAT(customer_status, ': ', total_customers), ', ')
        FROM customer_segments
    ) AS customer_segment_distribution,

    -- KPI Ratios
    ROUND(
        CAST(cm.active_customers_3m AS FLOAT) / NULLIF(cm.total_customers, 0) * 100, 2
    ) AS pct_active_customers,

    ROUND(
        CAST(pm.total_product_sales AS FLOAT) / NULLIF(pm.total_products, 0), 2
    ) AS avg_sales_per_product

FROM customer_metrics cm
CROSS JOIN product_metrics pm;
GO
