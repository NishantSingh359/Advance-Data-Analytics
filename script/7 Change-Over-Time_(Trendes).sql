
-- =================== Changes Over Time Analysis ===================
   
-- Total Sales, Customer, Quantity by Year
SELECT 
   YEAR(order_date) AS years,
   SUM(sales_amount) AS total_sales,
   COUNT( DISTINCT customer_key) AS total_customer,
   SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY years ASC;

-- Total Sales, Customer, Quantity for each Year and Month
SELECT 
   YEAR(order_date) AS years,
   MONTH(order_date) months,
   SUM(sales_amount) AS total_sales,
   COUNT( DISTINCT customer_key) AS total_customer,
   SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY years ASC;

-- Total Sales, Customer, Quantity by Month
SELECT 
   MONTH(order_date) months, 
   SUM(sales_amount) AS total_sales,
   COUNT( DISTINCT customer_key) AS total_customer,
   SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY  MONTH(order_date)
ORDER BY months ASC;
