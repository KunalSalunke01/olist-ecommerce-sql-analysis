/*=========================================================
  OLIST E-COMMERCE DATASET
  Purpose : Explore dataset quality before cleaning
=========================================================*/

----------------------------------------------------------
-- Dataset Row Counts
----------------------------------------------------------

SELECT COUNT(*) FROM customers;	
-- 99441 rows
SELECT COUNT(*) FROM orders;
-- 99441 rows
SELECT COUNT(*) FROM order_items;
-- 112650 rows
SELECT COUNT(*) FROM products;
-- 32951 rows
SELECT COUNT(*) FROM sellers;
-- 3095 rows
SELECT COUNT(*) FROM order_payments;
-- 103886 rows
SELECT COUNT(*) FROM order_reviews;
-- 99224 rows
SELECT COUNT(*) FROM geolocation;
-- 1000163 rows
SELECT COUNT(*) FROM product_category_translation;
-- 71 rows

----------------------------------------------------------
-- CUSTOMERS
----------------------------------------------------------

SELECT * FROM customers LIMIT 10;

-- NULL values
SELECT * FROM customers
WHERE customer_id IS NULL
   OR customer_unique_id IS NULL
   OR customer_zip_code_prefix IS NULL
   OR customer_city IS NULL
   OR customer_state IS NULL;

-- Duplicate Customer IDs
SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

----------------------------------------------------------
-- ORDERS
----------------------------------------------------------

SELECT * FROM orders LIMIT 10;

-- NULL values
SELECT * FROM orders
WHERE order_id IS NULL
   OR customer_id IS NULL
   OR order_status IS NULL
   OR order_purchase_timestamp IS NULL
   OR order_approved_at IS NULL
   OR order_delivered_carrier_date IS NULL
   OR order_delivered_customer_date IS NULL
   OR order_estimated_delivery_date IS NULL;

-- Missing delivery dates by order status
SELECT
    order_status,
    COUNT(*) FILTER (WHERE order_approved_at IS NULL) AS approved_at_missing,
    COUNT(*) FILTER (WHERE order_delivered_carrier_date IS NULL) AS carrier_missing,
    COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL) AS customer_missing
FROM orders
GROUP BY order_status
ORDER BY order_status;

-- Duplicate Order IDs
SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Logical timestamp inconsistency
SELECT * FROM orders
WHERE order_delivered_customer_date < order_purchase_timestamp
   OR order_delivered_carrier_date < order_approved_at;

----------------------------------------------------------
-- ORDER ITEMS
----------------------------------------------------------

SELECT * FROM order_items LIMIT 10;

-- NULL values
SELECT *
FROM order_items
WHERE order_id IS NULL
   OR order_item_id IS NULL
   OR product_id IS NULL
   OR seller_id IS NULL
   OR shipping_limit_date IS NULL
   OR price IS NULL
   OR freight_value IS NULL;

-- Price statistics
SELECT MIN(price),MAX(price),AVG(price)
FROM order_items;

-- Duplicate Order Items
SELECT order_id, order_item_id, COUNT(*)
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

----------------------------------------------------------
-- PRODUCTS
----------------------------------------------------------

SELECT * FROM products LIMIT 10;

-- NULL values
SELECT * FROM products
WHERE product_id IS NULL
   OR product_category_name IS NULL
   OR product_name_length IS NULL
   OR product_description_length IS NULL
   OR product_photos_qty IS NULL
   OR product_weight_gm IS NULL
   OR product_length_cm IS NULL
   OR product_height_cm IS NULL
   OR product_width_cm IS NULL;

-- Duplicate Product IDs
SELECT product_id, COUNT(*)
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

----------------------------------------------------------
-- SELLERS
----------------------------------------------------------

SELECT * FROM sellers LIMIT 10;

-- NULL values
SELECT * FROM sellers
WHERE seller_id IS NULL
   OR seller_zip_code_prefix IS NULL
   OR seller_city IS NULL
   OR seller_state IS NULL;

-- Duplicate Seller IDs
SELECT seller_id, COUNT(*)
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

----------------------------------------------------------
-- PAYMENTS
----------------------------------------------------------

SELECT * FROM order_payments LIMIT 10;

-- NULL values
SELECT * FROM order_payments
WHERE order_id IS NULL
   OR payment_sequential IS NULL
   OR payment_type IS NULL
   OR payment_installments IS NULL
   OR payment_value IS NULL;

-- Payment statistics
SELECT
    MIN(payment_value),
    MAX(payment_value),
    AVG(payment_value)
FROM order_payments;

SELECT
    MIN(payment_installments),
    MAX(payment_installments),
    AVG(payment_installments)
FROM order_payments;

-- Duplicate payments
SELECT order_id, payment_sequential, COUNT(*)
FROM order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;

-- Invalid payment records
SELECT * FROM order_payments
WHERE payment_value = 0
   OR payment_type = 'not_defined';

----------------------------------------------------------
-- REVIEWS
----------------------------------------------------------

SELECT * FROM order_reviews LIMIT 10;

-- NULL values
SELECT * FROM order_reviews
WHERE review_id IS NULL
   OR order_id IS NULL
   OR review_score IS NULL
   OR review_comment_title IS NULL
   OR review_comment_message IS NULL
   OR review_creation_date IS NULL
   OR review_answer_timestamp IS NULL;

-- Review score statistics
SELECT
    MIN(review_score),
    MAX(review_score),
    AVG(review_score)
FROM order_reviews;

-- Duplicate Reviews
SELECT review_id, order_id, COUNT(*)
FROM order_reviews
GROUP BY review_id, order_id
HAVING COUNT(*) > 1;

----------------------------------------------------------
-- GEOLOCATION
----------------------------------------------------------

SELECT * FROM geolocation LIMIT 10;

-- NULL values
SELECT * FROM geolocation
WHERE geolocation_zip_code_prefix IS NULL
   OR geolocation_lat IS NULL
   OR geolocation_lng IS NULL
   OR geolocation_city IS NULL
   OR geolocation_state IS NULL;

-- Duplicate locations
SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    COUNT(*)
FROM geolocation
GROUP BY
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng
HAVING COUNT(*) > 1;

----------------------------------------------------------
-- PRODUCT CATEGORY TRANSLATION
----------------------------------------------------------

SELECT * FROM product_category_translation LIMIT 10;

-- NULL values
SELECT * FROM product_category_translation
WHERE product_category_name IS NULL
   OR product_category_name_english IS NULL;

-- Duplicate Categories
SELECT product_category_name, COUNT(*)
FROM product_category_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1;