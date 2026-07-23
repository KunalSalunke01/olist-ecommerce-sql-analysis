/*=========================================================
  OLIST E-COMMERCE DATASET
  Purpose : Creating Database and Relations (Tables)
=========================================================*/


----------------------------------------------------------
-- CUSTOMERS
----------------------------------------------------------

DROP TABLE IF EXISTS customers CASCADE;
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50) NOT NULL,
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);

----------------------------------------------------------
-- PRODUCTS
----------------------------------------------------------

DROP TABLE IF EXISTS products CASCADE;
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_gm INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

----------------------------------------------------------
-- SELLERS
----------------------------------------------------------

DROP TABLE IF EXISTS sellers CASCADE;
CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state CHAR(2)
);

----------------------------------------------------------
-- ORDERS
----------------------------------------------------------

DROP TABLE IF EXISTS orders CASCADE;
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    order_status VARCHAR(30),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

----------------------------------------------------------
-- ORDERS PAYMENTS
----------------------------------------------------------

DROP TABLE IF EXISTS order_payments CASCADE;
CREATE TABLE order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value NUMERIC(10,2),

    PRIMARY KEY (order_id, payment_sequential),

    CONSTRAINT fk_payment_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);

----------------------------------------------------------
-- ORDER ITEMS
----------------------------------------------------------

DROP TABLE IF EXISTS order_items CASCADE;
CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2),

    PRIMARY KEY (order_id, order_item_id),

    CONSTRAINT fk_item_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_item_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id),

    CONSTRAINT fk_item_seller
        FOREIGN KEY (seller_id)
        REFERENCES sellers(seller_id)
);

----------------------------------------------------------
-- ORDER REVIEWS
----------------------------------------------------------

DROP TABLE IF EXISTS order_reviews CASCADE;
CREATE TABLE order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT CHECK (review_score BETWEEN 1 AND 5),
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,

    PRIMARY KEY (review_id, order_id),

    FOREIGN KEY (order_id)
    REFERENCES orders(order_id)
);

----------------------------------------------------------
-- GEOLOCATION
----------------------------------------------------------

DROP TABLE IF EXISTS geolocation CASCADE;
CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat NUMERIC(10,7),
    geolocation_lng NUMERIC(10,7),
    geolocation_city VARCHAR(100),
    geolocation_state CHAR(2)
);

----------------------------------------------------------
-- PRODUCT CATEGORY TRANSLATION
----------------------------------------------------------

DROP TABLE IF EXISTS product_category_translation CASCADE;
CREATE TABLE product_category_translation (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);


-- ADDITIONAL FK: products -> product_category_translation
-- (added last since product_category_translation is created last)

ALTER TABLE products
ADD CONSTRAINT fk_products_category
FOREIGN KEY (product_category_name)
REFERENCES product_category_translation(product_category_name);