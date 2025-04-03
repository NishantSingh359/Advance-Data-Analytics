-- =================== Cumilative Analysis ===================

-- Total running sales by years
SELECT 
years,
total_sales,
SUM(total_sales) OVER( ORDER BY years, months) AS running_total_sales
FROM (
SELECT 
YEAR(order_date) years, 
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)  , MONTH(order_date) 
) AS t

-- Total running sales and quantity with Each Months by Year
SELECT 
years,
months,
total_sales,
SUM(total_sales) OVER(PARTITION BY years ORDER BY years, months) AS running_total_sales,
avg_price,
AVG(avg_price) OVER(PARTITION BY years ORDER BY years, months) AS running_avg_price
FROM (
SELECT 
YEAR(order_date) years,
MONTH(order_date) months, 
SUM(sales_amount) AS total_sales,
AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)  , MONTH(order_date) 
) AS t

