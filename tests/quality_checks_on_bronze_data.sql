/*
==================================================================================
Data Quality Checks: Bronze Layer
----------------------------------------------------------------------------------
Purpose:
  Identify data quality issues in the bronze layer before transforming to silver.
  These checks will help detect duplicates, missing values, invalid formats, and
  referential inconsistencies in the raw source data.
==================================================================================
*/

-- =====================================================================
-- 1. CRM Customer Info Data Quality Checks
-- =====================================================================

-- 1.1 Null or Missing Customer IDs
SELECT *
FROM bronze.crm_cust_info
WHERE cst_id IS NULL;

-- 1.2 Duplicate Customer IDs
SELECT cst_id, COUNT(*) AS dup_count
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- 1.3 Missing or Invalid Names
SELECT *
FROM bronze.crm_cust_info
WHERE cst_firstname IS NULL OR LTRIM(RTRIM(cst_firstname)) = ''
   OR cst_lastname IS NULL OR LTRIM(RTRIM(cst_lastname)) = '';

-- 1.4 Invalid Gender Codes
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr NOT IN ('M', 'F', 'Male', 'Female', 'Other');

-- 1.5 Invalid Marital Status Values
SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info
WHERE cst_marital_status NOT IN ('Single', 'Married', 'Divorced', 'Widowed');

-- 1.6 Future Customer Creation Dates
SELECT *
FROM bronze.crm_cust_info
WHERE cst_create_date > GETDATE();

-- =====================================================================
-- 2. CRM Product Info Data Quality Checks
-- =====================================================================

-- 2.1 Null or Duplicate Product IDs
SELECT prd_id, COUNT(*) AS dup_count
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1;

SELECT *
FROM bronze.crm_prd_info
WHERE prd_id IS NULL OR prd_key IS NULL;

-- 2.2 Invalid Cost Values
SELECT *
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- 2.3 Invalid Product Dates (End < Start)
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_date < prd_start_date;

-- 2.4 Missing Product Names
SELECT *
FROM bronze.crm_prd_info
WHERE prd_nm IS NULL OR LTRIM(RTRIM(prd_nm)) = '';

-- =====================================================================
-- 3. CRM Sales Details Data Quality Checks
-- =====================================================================

-- 3.1 Null or Missing Keys
SELECT *
FROM bronze.crm_sales_details
WHERE sls_ord_num IS NULL OR sls_prd_key IS NULL OR sls_cust_id IS NULL;

-- 3.2 Duplicate Sales Orders
SELECT sls_ord_num, COUNT(*) AS dup_count
FROM bronze.crm_sales_details
GROUP BY sls_ord_num
HAVING COUNT(*) > 1;

-- 3.3 Invalid or Negative Values
SELECT *
FROM bronze.crm_sales_details
WHERE sls_quantity <= 0 OR sls_price <= 0 OR sls_sales <= 0;

-- 3.4 Date Logic Errors
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_ship_dt > sls_due_dt;

-- 3.5 Sales Consistency Check
SELECT *
FROM bronze.crm_sales_details
WHERE sls_sales <> sls_quantity * sls_price;

-- =====================================================================
-- 4. ERP Customer Table Data Quality Checks
-- =====================================================================

-- 4.1 Null or Duplicate CIDs
SELECT cid, COUNT(*) AS dup_count
FROM bronze.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1;

SELECT *
FROM bronze.erp_cust_az12
WHERE cid IS NULL;

-- 4.2 Invalid Birth Dates
SELECT *
FROM bronze.erp_cust_az12
WHERE bdate IS NULL
   OR bdate > GETDATE()
   OR bdate < '1900-01-01';

-- 4.3 Invalid Gender
SELECT DISTINCT gen
FROM bronze.erp_cust_az12
WHERE gen NOT IN ('M', 'F', 'Male', 'Female', 'Other');

-- =====================================================================
-- 5. ERP Location Table Data Quality Checks
-- =====================================================================

-- 5.1 Missing CIDs or Country Names
SELECT *
FROM bronze.erp_loc_a101
WHERE cid IS NULL OR cntry IS NULL OR LTRIM(RTRIM(cntry)) = '';

-- 5.2 Duplicate CIDs in Location Table
SELECT cid, COUNT(*) AS dup_count
FROM bronze.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1;

-- =====================================================================
-- 6. ERP Product Category Table Data Quality Checks
-- =====================================================================

-- 6.1 Missing or Duplicate IDs
SELECT id, COUNT(*) AS dup_count
FROM bronze.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1;

SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE id IS NULL OR cat IS NULL;

-- 6.2 Invalid Maintenance Values
SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2
WHERE maintenance NOT IN ('Low', 'Medium', 'High');

-- =====================================================================
-- 7. Cross-Table Referential Checks
-- =====================================================================

-- 7.1 Product Key in Sales not in Product Info
SELECT DISTINCT s.sls_prd_key
FROM bronze.crm_sales_details s
LEFT JOIN bronze.crm_prd_info p
  ON s.sls_prd_key = p.prd_key
WHERE p.prd_key IS NULL;

-- 7.2 Customer ID in Sales not in Customer Info
SELECT DISTINCT s.sls_cust_id
FROM bronze.crm_sales_details s
LEFT JOIN bronze.crm_cust_info c
  ON s.sls_cust_id = c.cst_id
WHERE c.cst_id IS NULL;

-- 7.3 Customer IDs in ERP not mapped in CRM
SELECT e.cid
FROM bronze.erp_cust_az12 e
LEFT JOIN bronze.crm_cust_info c
  ON e.cid = c.cst_id
WHERE c.cst_id IS NULL;
