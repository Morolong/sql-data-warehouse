-- =========================================================
-- Silver Layer - Data Quality Checks
-- =========================================================

-- =========================================================
-- 1. silver.crm_cust_info
-- =========================================================
PRINT '========================================='
PRINT 'QC: silver.crm_cust_info'
PRINT '========================================='

-- No duplicate or NULL customer IDs
PRINT '>> Check: Duplicate / NULL cst_id'
SELECT 
    cst_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_cust_info
WHERE cst_id IS NOT NULL
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- No unwanted leading/trailing spaces in name fields
PRINT '>> Check: Whitespace in cst_firstname / cst_lastname'
SELECT cst_id, cst_firstname, cst_lastname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
   OR cst_lastname  != TRIM(cst_lastname);

-- Marital status only contains expected values
PRINT '>> Check: Invalid cst_marital_status values'
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info
WHERE cst_marital_status NOT IN ('Single', 'Married', 'N/A');

-- Gender only contains expected values
PRINT '>> Check: Invalid cst_gndr values'
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr NOT IN ('Male', 'Female', 'N/A');

-- =========================================================
-- 2. silver.crm_prd_info
-- =========================================================
PRINT '========================================='
PRINT 'QC: silver.crm_prd_info'
PRINT '========================================='

-- No NULL product IDs
PRINT '>> Check: NULL prd_id'
SELECT prd_id
FROM silver.crm_prd_info
WHERE prd_id IS NULL;

-- No negative or NULL product costs
PRINT '>> Check: NULL or negative prd_cost'
SELECT prd_id, prd_nm, prd_cost
FROM silver.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0;

-- Product line only contains expected values
PRINT '>> Check: Invalid prd_line values'
SELECT DISTINCT prd_line
FROM silver.crm_prd_info
WHERE prd_line NOT IN ('Mountain', 'Road', 'Other Sales', 'Touring', 'n/a');

-- End date must not be before start date
PRINT '>> Check: prd_end_dt before prd_start_dt'
SELECT prd_id, prd_nm, prd_start_dt, prd_end_dt
FROM silver.crm_prd_info
WHERE prd_end_dt IS NOT NULL
  AND prd_end_dt < prd_start_dt;

-- =========================================================
-- 3. silver.crm_sales_details
-- =========================================================
PRINT '========================================='
PRINT 'QC: silver.crm_sales_details'
PRINT '========================================='

-- No invalid date ordering (order -> ship -> due)
PRINT '>> Check: sls_order_dt after sls_ship_dt or sls_due_dt'
SELECT sls_ord_num, sls_order_dt, sls_ship_dt, sls_due_dt
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;

-- Sales must equal quantity * price
PRINT '>> Check: sls_sales != sls_quantity * sls_price'
SELECT 
    sls_ord_num, 
    sls_sales, 
    sls_quantity, 
    sls_price,
    sls_quantity * sls_price AS expected_sales
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_sales <= 0;

-- No NULL or zero quantities
PRINT '>> Check: NULL or zero sls_quantity'
SELECT sls_ord_num, sls_quantity
FROM silver.crm_sales_details
WHERE sls_quantity IS NULL OR sls_quantity <= 0;

-- No NULL or negative prices
PRINT '>> Check: NULL or negative sls_price'
SELECT sls_ord_num, sls_price
FROM silver.crm_sales_details
WHERE sls_price IS NULL OR sls_price <= 0;

-- =========================================================
-- 4. silver.erp_cust_az12
-- =========================================================
PRINT '========================================='
PRINT 'QC: silver.erp_cust_az12'
PRINT '========================================='

-- No 'NAS' prefix remaining in cid
PRINT '>> Check: Residual NAS prefix in cid'
SELECT cid
FROM silver.erp_cust_az12
WHERE cid LIKE 'NAS%';

-- No future birthdates
PRINT '>> Check: Future bdate'
SELECT cid, bdate
FROM silver.erp_cust_az12
WHERE bdate > GETDATE();

-- No unreasonably old birthdates (sanity check, e.g. before 1900)
PRINT '>> Check: Implausibly old bdate'
SELECT cid, bdate
FROM silver.erp_cust_az12
WHERE bdate < '1900-01-01';

-- Gender only contains expected values
PRINT '>> Check: Invalid gen values'
SELECT DISTINCT gen
FROM silver.erp_cust_az12
WHERE gen NOT IN ('Female', 'MALE', 'N/A');

-- =========================================================
-- 5. silver.erp_loc_a101
-- =========================================================
PRINT '========================================='
PRINT 'QC: silver.erp_loc_a101'
PRINT '========================================='

-- No dashes remaining in cid
PRINT '>> Check: Residual dashes in cid'
SELECT cid
FROM silver.erp_loc_a101
WHERE cid LIKE '%-%';

-- No NULL or empty country values
PRINT '>> Check: NULL or blank cntry'
SELECT cid, cntry
FROM silver.erp_loc_a101
WHERE cntry IS NULL OR TRIM(cntry) = '';

-- Spot-check: no raw abbreviations remain (DE, US, USA)
PRINT '>> Check: Unmapped cntry abbreviations'
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
WHERE cntry IN ('DE', 'US', 'USA');

-- =========================================================
-- 6. silver.erp_px_cat_g1v2
-- =========================================================
PRINT '========================================='
PRINT 'QC: silver.erp_px_cat_g1v2'
PRINT '========================================='

-- No NULL IDs
PRINT '>> Check: NULL id'
SELECT id
FROM silver.erp_px_cat_g1v2
WHERE id IS NULL;

-- No NULL categories or subcategories
PRINT '>> Check: NULL cat or subcat'
SELECT id, cat, subcat
FROM silver.erp_px_cat_g1v2
WHERE cat IS NULL OR subcat IS NULL;

-- Distribution of maintenance values (for manual review)
PRINT '>> Check: Distinct maintenance values'
SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2;

-- =========================================================
-- 7. Cross-Table Referential Integrity Checks
-- =========================================================
PRINT '========================================='
PRINT 'QC: Referential Integrity'
PRINT '========================================='

-- Sales customer IDs must exist in CRM customer table
PRINT '>> Check: sls_cust_id not in crm_cust_info'
SELECT DISTINCT sls_cust_id
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN (
    SELECT cst_id FROM silver.crm_cust_info
);

-- Sales product keys must exist in CRM product table
PRINT '>> Check: sls_prd_key not in crm_prd_info'
SELECT DISTINCT sls_prd_key
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN (
    SELECT prd_key FROM silver.crm_prd_info
);

-- ERP customer IDs must exist in CRM customer table
PRINT '>> Check: erp_cust_az12.cid not in crm_cust_info'
SELECT cid
FROM silver.erp_cust_az12
WHERE cid NOT IN (
    SELECT cst_key FROM silver.crm_cust_info
);
