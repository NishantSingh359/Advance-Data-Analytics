/*
===================================
Product Report
==================================
Purpose :
    - This report consolidates key product metrics and behaviors.

Highlights:
	1. Gathers essential fields such as product name, category, subcategory, and cost.
	2. Aggregates product-level metrics:
		- total orders
		- total sales
		- total quantity sold
		- total customers (unique)
		- lifespan (in months)
	3. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
	4. Calculates valuable KPIs:
		- recency (months since last sale)
		- average order revenue (AOR)
		- average monthly revenue
*/
WITH base_query AS (
	SELECT 
		p.product_key,
		p.product_number,
		p.product_name,
		p.category,
		p.subcategory,
		p.cost,
		s.order_number,
		s.order_date,
		s.customer_key,
		s.sales_amount,
		s.quantity
	FROM gold.fact_sales AS s
	LEFT JOIN gold.dim_products AS p
	ON s.product_key = p.product_key
),
-- 2) Product Aggregations: Summarizes Key metrics at the customer level
aggregation AS (
SELECT
	product_key,
	product_number,
	product_name,
	category,
	subcategory,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT customer_key) AS total_customers,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY 
	product_key,
	product_number,
	product_name,
	category,
	subcategory
)
-- 3,4) Products Segmentation &  Calculates valuable KPIs:
SELECT
	product_key,
	product_number,
	product_name,
	category,
	subcategory,
	last_order_date,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	lifespan,
	CASE 
	    WHEN total_sales <10000 THEN 'Low Performance'
		WHEN total_sales BETWEEN 10000 AND 1000000 THEN 'Mid Range'
		WHEN total_sales >100000 THEN 'Heigh Performance'
	END AS prd_category,

	-- recency (months since last sale)

	DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,

	-- average order value (AVO)

	CASE 
	     WHEN total_orders = 0 THEN 0
	     WHEN total_orders > 0 THEN total_sales/ total_orders
	END AS avg_orders_value,

	-- average monthly spend

	CASE 
	     WHEN lifespan = 0 THEN total_sales
	     ELSE total_sales/lifespan
	END AS avg_monthly_spend

FROM aggregation;
