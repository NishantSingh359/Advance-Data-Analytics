/* 
=================================
Customer Reporting
=================================
Prupose:
    - This consolidates key customer metric and behaviors

Highlights:
   1. Gathers essential fields such as names, ages, and transaction details.
   2. Aggregates customer-level metrics:
      - total orders
	  - total sales
	  - total quantity purchased
	  - total products
	  - lifespan (in months)
   3. Segments customers into categories (VIP, Regular, New) and age groups.
   4. Calculates valuable KPIs:
      - recency (months since last order)
	  - average order value
	  - average monthly spend
*/


CREATE VIEW gold.customer_report AS 
WITH base_query AS (
    -- 1) Base Query: Retrieves core from tables
	Select
		s.order_number,
		s.product_key,
		s.order_date,
		s.sales_amount,
		s.quantity,
		c.customer_key,
		c.customer_number,
		CONCAT(first_name,' ',last_name) AS cust_name,
		c.birthdate,
		DATEDIFF(YEAR,birthdate, GETDATE()) AS age
	FROM gold.fact_sales AS s
	LEFT JOIN gold.dim_customer AS c
	    ON s.customer_key = c.customer_key
),
-- 2) Customer Aggregations: Summarizes Key metrics at the customer level
customer_aggregation AS (
	SELECT 
		customer_key,
		customer_number,
		cust_name,
		birthdate,
		age,
		COUNT(DISTINCT order_number) AS total_orders,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		COUNT(DISTINCT product_key) AS total_product,
		MAX(order_date) AS last_order_date,
		DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
	FROM base_query
	GROUP BY 
		customer_key,
		customer_number,
		cust_name,
		birthdate,
		age
)
-- 3,4) Customers Segmentation &  Calculates valuable KPIs:
SELECT
	customer_key,
	customer_number,
	cust_name,
	birthdate,
	age,

	CASE
		WHEN age < 18 THEN 'Under 18'
		WHEN age BETWEEN 18 AND 24 THEN 'Young Adults'
		WHEN age BETWEEN 25 AND 34 THEN 'Millennials'
		WHEN age BETWEEN 35 AND 44 THEN 'Middle-Aged Adults'
		WHEN age BETWEEN 45 AND 54 THEN 'Mature Adults'
		WHEN age BETWEEN 55 AND 64 THEN 'Older Adults'
		WHEN age >= 65 THEN 'Seniors'
	END AS age_group,

	CASE
		WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_sales < 5000 THEN 'Regular'
		ELSE 'New'
	END AS cust_category,

	last_order_date,
	total_orders,
	total_sales,
	total_quantity,
	total_product,
	lifespan,

  -- recency (Months since last order)
	DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,

	-- average order value (AVO)
	CASE 
	     WHEN total_orders = 0 THEN 0
	     WHEN total_orders > 0 THEN total_sales/ total_orders
	END AS avg_orders_value,

	-- Compuate average monthly spend
	CASE 
	     WHEN lifespan = 0 THEN total_sales
	     ELSE total_sales/lifespan
	END AS avg_monthly_spend
FROM customer_aggregation;
