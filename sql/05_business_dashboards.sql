--------------------------------------------------------------
-- Executive Business Dashboards
--------------------------------------------------------------

--------------------------------------------------------------
-- 1. Build a customer dashboard showing:
--------------------------------------------------------------
	-- Customer ID
	-- Total Orders
	-- Total Spend
	-- Average Order Value
	-- First Order Date
	-- Last Order Date
	-- Favorite Payment Method
WITH payments AS(
SELECT 
	order_id , 
	SUM(payment_value) AS payment_value ,
	MODE() WITHIN GROUP (ORDER BY payment_type) AS payment_type
FROM order_payments
GROUP BY order_id
)
SELECT 
	customer_unique_id ,
	COUNT(o.order_id) AS total_orders, 
	SUM(payment_value) AS total_spend,
	ROUND(AVG(payment_value),2) AS avg_order,
	MIN(order_purchase_timestamp) AS first_order,
	MAX(order_purchase_timestamp) AS last_order,
	MODE() WITHIN GROUP (ORDER BY payment_type) AS fav_pay_mode
FROM customers c
INNER JOIN orders o
ON o.customer_id = c.customer_id
INNER JOIN payments p
ON p.order_id = o.order_id
GROUP BY 1
ORDER BY 2 DESC ,3 DESC;

--------------------------------------------------------------
-- 2. Build a seller dashboard showing:
--------------------------------------------------------------
	-- Seller ID
	-- Total Revenue
	-- Total Orders
	-- Total Products Sold
	-- Average Freight Cost
	-- Average Review Score
	-- Revenue Rank
SELECT 
	seller_id ,
	SUM(price) AS total_revenue,
	COUNT(DISTINCT i.order_id) AS total_orders,
	COUNT(product_id) AS total_products,
	COUNT(DISTINCT product_id) AS unique_products,
	ROUND(AVG(freight_value),2) AS avg_freight_cost,
	ROUND(AVG(review_score),2)AS avg_review,
	RANK() OVER(ORDER BY SUM(price) DESC) AS revenue_rank
FROM order_items i
INNER JOIN order_reviews r
ON i.order_id = r.order_id
GROUP BY seller_id
ORDER BY 2 DESC,3 DESC;
	
--------------------------------------------------------------
-- 3. Build an executive sales dashboard showing:
--------------------------------------------------------------
	-- Month
	-- Total Orders
	-- Total Revenue
	-- Average Order Value
	-- Top Category
	-- Top Seller
	-- Most Used Payment Type
	-- Average Review Score
	-- Late Delivery Percentage
	-- Running Revenue Total
	
WITH late_orders AS(
SELECT 
	order_id ,
	CASE 
		WHEN (order_delivered_customer_date > order_estimated_delivery_date) THEN 1 
		ELSE 0 
	END AS late_delivery
FROM orders 
), 
order_payment AS(
SELECT 
	order_id ,
	MODE() WITHIN GROUP (ORDER BY payment_type) AS payment_type
FROM order_payments
GROUP BY 1
),
order_price AS (
SELECT 
	i.order_id ,
	SUM(price) as price
FROM order_items i
GROUP BY i.order_id
),
seller_rank AS(
SELECT
	TO_CHAR(order_delivered_customer_date,'YYYY-MM') AS year_month,
	seller_id,
	ROW_NUMBER() OVER(PARTITION BY TO_CHAR(order_delivered_customer_date,'YYYY-MM') ORDER BY SUM(price) DESC ) AS sell_rank
FROM orders o
INNER JOIN order_items i
ON o.order_id=i.order_id
GROUP BY 1,2
),
category_rank AS(
SELECT
	TO_CHAR(order_delivered_customer_date,'YYYY-MM') AS year_month,
	product_category_name,
	ROW_NUMBER() OVER(PARTITION BY TO_CHAR(order_delivered_customer_date,'YYYY-MM') ORDER BY SUM(price) DESC ) AS cate_rank
FROM orders o
INNER JOIN order_items i
ON o.order_id=i.order_id
INNER JOIN products p
ON i.product_id=p.product_id
GROUP BY 1,2
)
SELECT 
	dt.year_month,
	dt.total_orders,
	dt.total_revenue,
	dt.avg_order,
	dt.most_used_pay_mode,
	dt.avg_review,
	cr.product_category_name AS top_category,
	sr.seller_id AS top_seller,
	dt.late_delivery_percent,
	SUM(total_revenue) OVER(ORDER BY dt.year_month) AS running_revenue
FROM 
(
SELECT 
	TO_CHAR(order_delivered_customer_date,'YYYY-MM') AS year_month,
	COUNT(DISTINCT o.order_id) AS total_orders,
	SUM(price) AS total_revenue,
	ROUND(AVG(price),2) AS avg_order,
	MODE() WITHIN GROUP (ORDER BY payment_type) AS most_used_pay_mode,
	ROUND(AVG(review_score),2) AS avg_review,
	ROUND( 100.0 * SUM(late_delivery) / COUNT(late_delivery),2) AS late_delivery_percent
FROM orders o
INNER JOIN order_price p
ON o.order_id = p.order_id
INNER JOIN late_orders l
ON l.order_id = o.order_id
LEFT JOIN order_reviews r
ON o.order_id = r.order_id
INNER JOIN order_payment op
ON op.order_id = o.order_id
WHERE 
	order_delivered_customer_date IS NOT NULL
GROUP BY 1
) dt
INNER JOIN category_rank cr
ON cr.year_month = dt.year_month
INNER JOIN seller_rank sr
ON sr.year_month = dt.year_month
WHERE  
	sell_rank = 1 
	AND cate_rank = 1 ;
	