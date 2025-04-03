-- =================== Data Segmentation ===================

-- Segment products into cost ranges and cont how many products fall into each segment

WITH segmentation AS (
SELECT 
	product_key,
	product_name,
	cost,
	CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	 WHEN cost BETWEEN 1000 AND 1500 THEN '1000-1500'
	 WHEN cost BETWEEN 1500 AND 200 THEN '1500-2000'
	 ELSE 'Above 2000'
	END cost_category
FROM gold.dim_products
)
SELECT
	cost_category,
	COUNT(product_key) AS product_count
FROM segmentation
GROUP BY cost_category
ORDER BY product_count DESC;


-- Group customer into three segments based on their spending behavior:
   -- VIP: Customer with at least 12 months of history and spending more than ₹5,000.
   -- Regular: Customers with at least 12 months of history but speding ₹5000 or less.
   -- New: Customer with a lifespan less than 12 months.
-- And find total number of customer by each group

WITH cust_spending AS (
	SELECT 
		c.customer_key,
		MIN(order_date) AS first_order_date,
		DATEDIFF(month , MIN(order_date), MAX(order_date))  AS month_history,
		SUM(sales_amount) AS spending
	FROM gold.dim_customer AS c
	LEFT JOIN gold.fact_sales AS s
	ON s.customer_key = c.customer_key
	GROUP BY c.customer_key 
),
cust_group AS (
	SELECT 
		customer_key,
		first_order_date,
		month_history,
		spending,
		CASE 
		     WHEN month_history>= 12 AND spending > 5000 THEN 'VIP'
			 WHEN month_history>= 12 AND spending < 5000 THEN 'Regular'
			 ELSE 'New'
		END AS  cust_segment
	FROM cust_spending
)
SELECT 
	cust_segment,
	COUNT(customer_key) AS total_customer
FROM cust_group
GROUP BY cust_segment
ORDER BY total_customer DESC;
