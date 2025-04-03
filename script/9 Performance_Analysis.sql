-- =================== Performance Analysis ===================

/*Analyze the yearly performance of products by comparing each product's sales to 
both its average sales performance and the previous year's sales.*/


WITH yearly_products_sales AS (
SELECT
YEAR(order_date) AS order_year,
p.product_name,
SUM(s.sales_amount) AS total_sales
FROM gold.dim_products AS p
LEFT JOIN gold.fact_sales AS s
ON p.product_key = s.product_key
WHERE YEAR(order_date) IS NOT NULL
GROUP BY YEAR(order_date), product_name
)

SELECT
order_year,
product_name,
total_sales,
AVG(total_sales) OVER (PARTITION BY product_name) as avg_sales,
total_sales - AVG(total_sales) OVER (PARTITION BY product_name) as avg_sales,
CASE 
	WHEN total_sales - AVG(total_sales) OVER (PARTITION BY product_name)> 0 THEN 'Above Avg'
	WHEN total_sales - AVG(total_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
	ELSE 'Avg'
END avg_change,
LAG(total_sales) OVER(PARTITION BY PRODUCT_NAME ORDER BY order_year) py_sales,
total_sales - LAG(total_sales) OVER(PARTITION BY PRODUCT_NAME ORDER BY order_year) diff_py,
CASE 
	WHEN total_sales - LAG(total_sales) OVER(PARTITION BY PRODUCT_NAME ORDER BY order_year) > 0 THEN 'Increase'
	WHEN total_sales - LAG(total_sales) OVER(PARTITION BY PRODUCT_NAME ORDER BY order_year) < 0 THEN 'Dicrease'
	ELSE 'Flate'
END py_change
FROM yearly_products_sales 
ORDER BY product_name, order_year ASC
;

