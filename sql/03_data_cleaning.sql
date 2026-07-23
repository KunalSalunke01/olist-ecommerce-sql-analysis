/*=========================================================
  OLIST E-COMMERCE DATASET
  Purpose : Data cleaning and preprocessing
=========================================================*/

----------------------------------------------------------
-- ORDER PAYMENTS
----------------------------------------------------------

-- Remove invalid payment records

DELETE
FROM order_payments
WHERE payment_value = 0
   OR payment_type = 'not_defined';

----------------------------------------------------------
-- ORDER REVIEWS
----------------------------------------------------------

-- Drop unused text columns
-- These columns are not required for SQL analysis.
-- They are mainly useful for NLP / Sentiment Analysis.

ALTER TABLE order_reviews
DROP COLUMN review_comment_title,
DROP COLUMN review_comment_message;

----------------------------------------------------------
-- GEOLOCATION 
----------------------------------------------------------

-- Remove Duplicate rows

DELETE FROM geolocation g1
USING geolocation g2
WHERE g1.ctid < g2.ctid
  AND g1.geolocation_zip_code_prefix = g2.geolocation_zip_code_prefix
  AND g1.geolocation_lat = g2.geolocation_lat
  AND g1.geolocation_lng = g2.geolocation_lng
  AND g1.geolocation_city = g2.geolocation_city
  AND g1.geolocation_state = g2.geolocation_state;


----------------------------------------------------------
-- DATA CLEANING NOTES
----------------------------------------------------------

/*

Orders
------
Missing delivery-related timestamps are expected
for cancelled, processing, invoiced, created,
approved and unavailable orders.

Products
--------
611 products (~2%) have NULL values in
category or product description fields.
Retained because Product_ID remains valid.

Order Reviews
-------------
review_comment_title dropped
review_comment_message dropped

review_answer_timestamp retained because it
may be useful for response-time analysis.

Payments
--------
Removed 9 invalid payment records where

payment_value = 0
OR
payment_type = 'not_defined'

Geolocation
-----------
Duplicate coordinate rows retained because
multiple customers can share the same ZIP code
and coordinates.

*/