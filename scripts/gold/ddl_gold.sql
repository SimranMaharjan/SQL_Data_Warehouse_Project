/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

--=============================================================================
--Create Dimension: gold.dim_customers
--=============================================================================

IF OBJECT_ID('gold.dim_customers','V') IS NOT NULL
	DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
	C.cst_id AS customer_id,
	C.cst_key AS customer_number,
	C.cst_firstname AS first_name,
	C.cst_lastname AS last_name,
	L.cntry AS country,
	C.cst_marital_status AS marital_status,
	CASE WHEN C.cst_gndr != 'N/A' THEN C.cst_gndr
		 ELSE COALESCE(E.gen, 'N/A')
	END AS gender,
	E.bdate AS birth_date,
	C.cst_create_date AS create_date
FROM silver.crm_cust_info C
LEFT JOIN silver.erp_cust_az12 E ON C.cst_key = E.cid
LEFT JOIN silver.erp_loc_a101 L ON C.cst_key = L.cid;


--=============================================================================
--Create Dimension: gold.dim_products
--=============================================================================

IF OBJECT_ID('gold.dim_products','V') IS NOT NULL
	DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY P.prd_start_dt, P.prd_key) AS product_key,
	P.prd_id AS product_id,
	P.prd_key AS product_number,
	P.prd_nm AS product_name,
	P.cat_id AS category_id,
	C.cat AS category,
	C.subcat AS sub_category,
	C.maintenance AS maintenance,
	P.prd_cost AS product_cost,
	P.prd_line AS product_line,
	P.prd_start_dt AS start_date
FROM silver.crm_prd_info P
LEFT JOIN silver.erp_px_cat_g1v2 C ON P.cat_id = C.id 
WHERE P.prd_end_dt IS NULL;	--Filter only current data


--=============================================================================
--Create Dimension: gold.fact_sales
--=============================================================================

IF OBJECT_ID('gold.fact_sales','V') IS NOT NULL
	DROP VIEW gold.fact_sales;
GO
CREATE VIEW gold.fact_sales AS
SELECT 
	S.sls_ord_num AS order_number,
	P.product_key,
	C.customer_key,
	S.sls_order_dt AS order_date,
	S.sls_ship_dt AS shipping_date,
	S.sls_due_dt AS due_date,
	S.sls_sales AS sales_amount,
	S.sls_quantity AS quantity,
	S.sls_price AS price
FROM silver.crm_sales_details S
LEFT JOIN gold.dim_products P ON S.sls_prd_key = P.product_number
LEFT JOIN gold.dim_customers C ON S.sls_cust_id = C.customer_id;
