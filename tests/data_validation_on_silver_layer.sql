/*
==================================================================================
Data Quality Validation: Silver Layer
----------------------------------------------------------------------------------
Purpose:
  Validate that Silver Layer data conforms to expected quality rules after 
  transformation from Bronze.

  This script ensures:
    - No duplicates or null keys
    - Standardized values (e.g., gender, marital status)
    - Valid date logic
    - Referential consistency across Silver tables
    - Numeric consistency and positive metrics

Run After:
  EXEC silver.load_silver;

==================================================================================
*/

-- =====================================================================
-- 1. CRM Customer Info Validations
-- =====================================================================

-- 1.1 Ensure all Customer IDs are unique and non-null
SELECT COUNT(*) AS null_cst_id_count
FROM silver.crm_cust_info
WHERE cst_id IS NULL;

SELECT cst_id, COUNT(*) AS dup_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- 1.2 Ensure gender values are standardized
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr NOT IN ('Male', 'Female', 'n/a');

-- 1.3 Ensure marital status values are standardized
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info
WHERE cst_marital_status NOT IN ('Single', 'Married', 'n/a');

-- 1.4 Ensure customer creation dates are not in the future
SELECT *
FROM silver.crm_cust_info
WHERE cst_create_date > GETDATE();

-- =====================================================================
-- 2. CRM Product Info Validations
-- =====================================================================

-- 2.1 Check for duplicate or null product IDs
SELECT COUNT(*) AS null_prd_id_count
FROM silver.crm_prd_info
WHERE prd_id IS NULL;

SELECT prd_id, COUNT(*) AS dup_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1;

-- 2.2 Ensure product line values are standardized
SELECT DISTINCT prd_line
FROM silver.crm_prd_info
WHERE prd_line NOT IN ('Mountain', 'Road', 'Touring', 'Other Sales', 'n/a');

-- 2.3 Check invalid cost (negative or null)
SELECT *
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- 2.4 Ensure date sequence validity (start < end)
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_date IS NOT NULL AND prd_end_date < prd_start_date;

-- =====================================================================
-- 3. CRM Sales Details Validations
-- =====================================================================

-- 3.1 Check null or invalid references
SELECT *
FROM silver.crm_sales_details
WHERE sls_ord_num IS NULL
   OR sls_prd_key IS NULL
   OR sls_cust_id IS NULL;

-- 3.2 Ensure positive quantities, prices, and sales
SELECT *
FROM silver.crm_sales_details
WHERE sls_quantity <= 0 OR sls_price <= 0 OR sls_sales <= 0;

-- 3.3 Ensure sales = price * quantity
SELECT *
FROM silver.crm_sales_details
WHERE sls_sales <> sls_price * sls_quantity;

-- 3.4 Validate date logic
SELECT *
FROM silver.crm_sales_details
WHERE (sls_order_dt > sls_ship_dt)
   OR (sls_ship_dt > sls_due_dt);

-- =====================================================================
-- 4. ERP Customer Table Validations
-- =====================================================================

-- 4.1 Null or duplicate customer IDs
SELECT COUNT(*) AS null_cid_count
FROM silver.erp_cust_az12
WHERE cid IS NULL;

SELECT cid, COUNT(*) AS dup_count
FROM silver.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1;

-- 4.2 Validate birthdate logic
SELECT *
FROM silver.erp_cust_az12
WHERE bdate IS NOT NULL AND (bdate > GETDATE() OR bdate < '1900-01-01');

-- 4.3 Ensure gender is standardized
SELECT DISTINCT gen
FROM silver.erp_cust_az12
WHERE gen NOT IN ('Male', 'Female', 'n/a');

-- =====================================================================
-- 5. ERP Location Table Validations
-- =====================================================================

-- 5.1 Missing or invalid values
SELECT *
FROM silver.erp_loc_a101
WHERE cid IS NULL OR cntry IS NULL OR LTRIM(RTRIM(cntry)) = '';

-- 5.2 Ensure country names are standardized
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
WHERE cntry IN ('DE', 'US', 'USA');

-- =====================================================================
-- 6. ERP Product Category Table Validations
-- =====================================================================

-- 6.1 Duplicate or null IDs
SELECT id, COUNT(*) AS dup_count
FROM silver.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1;

SELECT COUNT(*) AS null_id_count
FROM silver.erp_px_cat_g1v2
WHERE id IS NULL;

-- 6.2 Maintenance category validation
SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2
WHERE maintenance NOT IN ('Low', 'Medium', 'High', 'n/a');

-- =====================================================================
-- 7. Cross-Table Referential Integrity Checks
-- =====================================================================

-- 7.1 Customer ID in Sales exists in CRM Customer Info
SELECT DISTINCT s.sls_cust_id
FROM silver.crm_sales_details s
LEFT JOIN silver.crm_cust_info c
  ON s.sls_cust_id = c.cst_id
WHERE c.cst_id IS NULL;

-- 7.2 Product Key in Sales exists in CRM Product Info
SELECT DISTINCT s.sls_prd_key
FROM silver.crm_sales_details s
LEFT JOIN silver.crm_prd_info p
  ON s.sls_prd_key = p.prd_key
WHERE p.prd_key IS NULL;

-- 7.3 ERP Customer IDs must exist in ERP Location
SELECT DISTINCT e.cid
FROM silver.erp_cust_az12 e
LEFT JOIN silver.erp_loc_a101 l
  ON e.cid = l.cid
WHERE l.cid IS NULL;

-- =====================================================================
-- 8. Row Count Consistency Checks (Bronze vs Silver)
-- =====================================================================

-- These ensure data volumes align (accounting for expected filtering)

SELECT
    'crm_cust_info' AS table_name,
    (SELECT COUNT(*) FROM bronze.crm_cust_info) AS bronze_count,
    (SELECT COUNT(*) FROM silver.crm_cust_info) AS silver_count;

SELECT
    'crm_prd_info' AS table_name,
    (SELECT COUNT(*) FROM bronze.crm_prd_info) AS bronze_count,
    (SELECT COUNT(*) FROM silver.crm_prd_info) AS silver_count;

SELECT
    'crm_sales_details' AS table_name,
    (SELECT COUNT(*) FROM bronze.crm_sales_details) AS bronze_count,
    (SELECT COUNT(*) FROM silver.crm_sales_details) AS silver_count;

SELECT
    'erp_cust_az12' AS table_name,
    (SELECT COUNT(*) FROM bronze.erp_cust_az12) AS bronze_count,
    (SELECT COUNT(*) FROM silver.erp_cust_az12) AS silver_count;

SELECT
    'erp_loc_a101' AS table_name,
    (SELECT COUNT(*) FROM bronze.erp_loc_a101) AS bronze_count,
    (SELECT COUNT(*) FROM silver.erp_loc_a101) AS silver_count;

SELECT
    'erp_px_cat_g1v2' AS table_name,
    (SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2) AS bronze_count,
    (SELECT COUNT(*) FROM silver.erp_px_cat_g1v2) AS silver_count;
