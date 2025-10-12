/*
==================================================================================
DDL Scripts: Create the Gold Layer
----------------------------------------------------------------------------------
Purpose:
  This script creates the Gold Layer views based on the transformed Silver Layer.
  It ensures the data model follows dimensional modeling principles with 
  dimensions (Customers, Products) and a fact table (Sales) (STAR Schema).

  Each view performs transformations and combines data from the silver layer 
  to product the a clean, enriched and business ready dataset.

Usage: 
    - These views can be queried directly for the analytics and reporting. 
==================================================================================
*/

-- =====================================================================
-- View: gold.dim_customers
-- =====================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE OR ALTER VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
    cst_id AS customer_id,
    cst_key AS customer_number,
    cst_firstname AS first_name,
    cst_lastname AS last_name,
    la.cntry AS country,
    cst_marital_status AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,
    ca.bdate AS birthdate,
    cst_create_date AS create_date,
    GETDATE() AS dwh_create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
    ON la.cid = ci.cst_key;
GO


-- =====================================================================
-- View: gold.dim_products
-- =====================================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE OR ALTER VIEW gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER(ORDER BY pn.prd_start_date, pn.prd_key) AS product_key,
    pn.prd_id AS product_id,
    pn.prd_key AS product_number,
    pn.prd_nm AS product_name,
    pn.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance,
    pn.prd_cost AS cost,
    pn.prd_line AS product_line,
    pn.prd_start_date AS start_date,
    GETDATE() AS dwh_create_date
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
    ON pn.cat_id = pc.id
WHERE pn.prd_end_date IS NULL;
GO


-- =====================================================================
-- View: gold.fact_sales
-- =====================================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE OR ALTER VIEW gold.fact_sales AS
SELECT 
    sd.sls_ord_num AS order_number,
    pr.product_key,
    cu.customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price,
    GETDATE() AS dwh_create_date
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers AS cu
    ON sd.sls_cust_id = cu.customer_id;
GO
