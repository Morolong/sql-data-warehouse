-- =========================================================
-- Gold Layer - Data Quality Checks
-- =========================================================

-- =========================================================
-- 1. gold.dim_customers
-- =========================================================
PRINT '========================================='
PRINT 'QC: gold.dim_customers'
PRINT '========================================='

-- Uniqueness and completeness of the surrogate key
PRINT '>> Check: Duplicate or NULL customer_key'
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- No NULL customer_id (source PK must always be present)
PRINT '>> Check: NULL customer_id'
SELECT customer_key, customer_id
FROM gold.dim_customers
WHERE customer_id IS NULL;

-- No NULL customer_number
PRINT '>> Check: NULL customer_number'
SELECT customer_key, customer_id, customer_number
FROM gold.dim_customers
WHERE customer_number IS NULL;

-- Gender resolves correctly — no unexpected values
-- CRM is master; ERP fallback should yield Female/Male/N/A only
PRINT '>> Check: Invalid gender values'
SELECT DISTINCT gender
FROM gold.dim_customers
WHERE gender NOT IN ('Male', 'Female', 'N/A');

-- Gender consistency: CRM value used when available, not overridden by ERP
PRINT '>> Check: Gender mismatch — CRM value ignored when it should be master'
SELECT 
    dc.customer_id,
    dc.gender           AS gold_gender,
    ci.cst_gndr         AS crm_gender,
    ca.gen              AS erp_gender
FROM gold.dim_customers dc
JOIN silver.crm_cust_info ci  ON dc.customer_id  = ci.cst_id
LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key  = ca.cid
WHERE ci.cst_gndr != 'N/A'          -- CRM has a value
  AND dc.gender   != ci.cst_gndr;   -- but Gold doesn't reflect it

-- Marital status only contains expected values
PRINT '>> Check: Invalid marital_status values'
SELECT DISTINCT marital_status
FROM gold.dim_customers
WHERE marital_status NOT IN ('Single', 'Married', 'N/A');

-- No future birthdates
PRINT '>> Check: Future birthdate'
SELECT customer_key, customer_id, birthdate
FROM gold.dim_customers
WHERE birthdate > GETDATE();

-- No implausibly old birthdates
PRINT '>> Check: Implausibly old birthdate (before 1900)'
SELECT customer_key, customer_id, birthdate
FROM gold.dim_customers
WHERE birthdate < '1900-01-01';

-- Country should not contain raw abbreviations
PRINT '>> Check: Unmapped country abbreviations'
SELECT DISTINCT country
FROM gold.dim_customers
WHERE country IN ('DE', 'US', 'USA');

-- No NULL or blank country values
PRINT '>> Check: NULL or blank country'
SELECT customer_key, customer_id, country
FROM gold.dim_customers
WHERE country IS NULL OR TRIM(country) = '';

-- Row count for reference
PRINT '>> Info: gold.dim_customers row count'
SELECT COUNT(*) AS total_customers FROM gold.dim_customers;


-- =========================================================
-- 2. gold.dim_products
-- =========================================================
PRINT '========================================='
PRINT 'QC: gold.dim_products'
PRINT '========================================='

-- Uniqueness and completeness of the surrogate key
PRINT '>> Check: Duplicate or NULL product_key'
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- No NULL product_id or product_number
PRINT '>> Check: NULL product_id or product_number'
SELECT product_key, product_id, product_number
FROM gold.dim_products
WHERE product_id IS NULL OR product_number IS NULL;

-- Historical records must be fully excluded (prd_end_dt IS NULL filter)
PRINT '>> Check: Historical products leaked into view (prd_end_dt IS NOT NULL)'
SELECT 
    p.prd_id, 
    p.prd_key,
    p.prd_end_dt
FROM silver.crm_prd_info p
WHERE p.prd_end_dt IS NOT NULL
  AND p.prd_key IN (SELECT product_number FROM gold.dim_products);

-- No negative or NULL costs
PRINT '>> Check: NULL or negative cost'
SELECT product_key, product_id, product_name, cost
FROM gold.dim_products
WHERE cost IS NULL OR cost < 0;

-- Product line only expected values
PRINT '>> Check: Invalid product_line values'
SELECT DISTINCT product_line
FROM gold.dim_products
WHERE product_line NOT IN ('Mountain', 'Road', 'Other Sales', 'Touring', 'n/a');

-- Category join success — NULLs indicate unmatched category_id
PRINT '>> Check: Products with no matching category (category IS NULL)'
SELECT 
    product_key,
    product_id,
    product_number,
    category_id,
    category
FROM gold.dim_products
WHERE category IS NULL;

-- No NULL product names
PRINT '>> Check: NULL product_name'
SELECT product_key, product_id
FROM gold.dim_products
WHERE product_name IS NULL;

-- Row count for reference
PRINT '>> Info: gold.dim_products row count'
SELECT COUNT(*) AS total_products FROM gold.dim_products;


-- =========================================================
-- 3. gold.fact_sales
-- =========================================================
PRINT '========================================='
PRINT 'QC: gold.fact_sales'
PRINT '========================================='

-- Surrogate key linkage — NULLs mean the JOIN to dim_products failed
PRINT '>> Check: NULL product_key (unresolved product)'
SELECT 
    order_number,
    product_key,
    sd.sls_prd_key AS source_product_number
FROM gold.fact_sales fs
JOIN silver.crm_sales_details sd ON fs.order_number = sd.sls_ord_num
WHERE fs.product_key IS NULL;

-- Surrogate key linkage — NULLs mean the JOIN to dim_customers failed
PRINT '>> Check: NULL customer_key (unresolved customer)'
SELECT 
    order_number,
    customer_key,
    sd.sls_cust_id AS source_customer_id
FROM gold.fact_sales fs
JOIN silver.crm_sales_details sd ON fs.order_number = sd.sls_ord_num
WHERE fs.customer_key IS NULL;

-- Date ordering: order_date must not be after shipping_date or due_date
PRINT '>> Check: order_date after shipping_date or due_date'
SELECT 
    order_number,
    order_date,
    shipping_date,
    due_date
FROM gold.fact_sales
WHERE order_date > shipping_date
   OR order_date > due_date;

-- Sales amount must equal quantity * price
PRINT '>> Check: sales_amount != quantity * price'
SELECT 
    order_number,
    sales_amount,
    quantity,
    price,
    quantity * price AS expected_sales_amount
FROM gold.fact_sales
WHERE sales_amount != quantity * price
   OR sales_amount IS NULL
   OR sales_amount <= 0;

-- No NULL or zero quantities
PRINT '>> Check: NULL or zero quantity'
SELECT order_number, quantity
FROM gold.fact_sales
WHERE quantity IS NULL OR quantity <= 0;

-- No NULL or negative prices
PRINT '>> Check: NULL or negative price'
SELECT order_number, price
FROM gold.fact_sales
WHERE price IS NULL OR price <= 0;

-- Every fact row must trace back to a valid dim_customers record
PRINT '>> Check: customer_key in fact not present in dim_customers'
SELECT DISTINCT customer_key
FROM gold.fact_sales
WHERE customer_key NOT IN (
    SELECT customer_key FROM gold.dim_customers
);

-- Every fact row must trace back to a valid dim_products record
PRINT '>> Check: product_key in fact not present in dim_products'
SELECT DISTINCT product_key
FROM gold.fact_sales
WHERE product_key NOT IN (
    SELECT product_key FROM gold.dim_products
);

-- Row count and key aggregates for manual review
PRINT '>> Info: gold.fact_sales summary'
SELECT 
    COUNT(*)                        AS total_rows,
    COUNT(DISTINCT order_number)    AS distinct_orders,
    COUNT(DISTINCT customer_key)    AS distinct_customers,
    COUNT(DISTINCT product_key)     AS distinct_products,
    SUM(sales_amount)               AS total_sales,
    MIN(order_date)                 AS earliest_order,
    MAX(order_date)                 AS latest_order
FROM gold.fact_sales;
