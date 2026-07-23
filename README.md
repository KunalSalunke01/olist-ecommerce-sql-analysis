# Olist Brazilian E-Commerce — SQL Analysis

End-to-end SQL analysis of the Olist Brazilian e-commerce dataset: schema design, data quality auditing, cleaning, and 51 business-question queries covering revenue, customers, sellers, products, and delivery performance.

## KPI Snapshot

| KPI | Value |
|---|---|
| Total Orders | 99,441 |
| Total Revenue | R$13,221,498.11 |
| Avg Order Value | R$137.75 |
| Delivered Rate | 97% |
| Avg Review Score | 4.09 / 5 |
| Late Delivery Rate | 8.11% |
| Top Payment Method | Credit Card (74%) |
| Total Sellers / Products | 3,095 / 32,951 |

## Dataset

Public Kaggle dataset from Olist, a Brazilian e-commerce marketplace. Covers ~99,000 orders placed between **2016-09-04 and 2018-10-17** across 9 relational tables:

| Table | Rows | Description |
|---|---|---|
| customers | 99,441 | Customer ID and location |
| orders | 99,441 | Order status and timestamps |
| order_items | 112,650 | Line items per order |
| products | 32,951 | Product attributes |
| sellers | 3,095 | Seller location |
| order_payments | 103,886 (103,877 after cleaning) | Payment method and value |
| order_reviews | 99,224 | Customer review scores |
| geolocation | 1,000,163 | Zip-code coordinates |
| product_category_translation | 71 | Category name → English |

## Tools

PostgreSQL

## Entity-Relationship Diagram

`erd.png` — *(add diagram here)*

## Project Structure

```
sql/
├── 01_schema.sql              -- table creation, PKs, FKs, indexes
├── 02_data_exploration.sql    -- null checks, duplicate checks, anomaly detection
├── 03_data_cleaning.sql       -- invalid record removal, deduplication
└── 04_business_questions.sql  -- 47 business questions across 5 sections
└── 05_business_dashboards.sql  -- 3 executive business dashboards
```

## Data Quality & Cleaning

- **Removed 9 invalid payment records** where `payment_value = 0` or `payment_type = 'not_defined'`.
- **~611 products (~2%)** have a NULL category — retained, since `product_id` is still valid; likely incomplete/delisted listings.
- **Deduplicated geolocation** on exact matches across zip, lat, lng, city, and state, since the raw table has no primary key and multiple customers can legitimately share a zip/coordinate.
- **Dropped `review_comment_title` / `review_comment_message`** — free-text fields not needed for SQL analysis (kept `review_answer_timestamp` for potential response-time analysis).
- **Anomaly investigation:** 1,359 orders (~1.4%) show `order_delivered_carrier_date` earlier than `order_approved_at`. Cross-checked against `order_delivered_customer_date < order_purchase_timestamp` (0 rows) — confirmed no deliveries are physically impossible. Most likely a logging lag on `order_approved_at` rather than a real sequencing error. Not excluded from delivery-time calculations, since those use purchase/carrier/customer dates, not `approved_at`.

## Key Findings

**Customers & Orders**
- São Paulo (SP) accounts for the largest share of customers (41,746) — more than 3x the next-highest state (RJ, 12,852).
- 96,478 of 99,441 orders (97%) were successfully delivered; 625 canceled, 609 unavailable.
- Average order value: R$137.75.

**Payments**
- Credit card is the dominant payment method (76,795 of ~103,900 payments, ~74%), followed by boleto (19,784).
- Paraíba (PB) has the highest average payment value per order (R$264.08) despite not being a top-volume state — a smaller but higher-value market.

**Revenue**
- Top revenue category is Health & Beauty (R$1.26M), followed by Watches & Gifts (R$1.21M) and Bed, Bath & Table (R$1.04M).
- Top seller by revenue generated R$228,071 across 1,124 orders and 1,148 items sold, spanning 95 unique products, with a 4.12 average review score.

**Delivery Performance**
- Late delivery rates vary sharply by state: Alagoas (AL) has the highest at 23.0%, while Rondônia (RO) has the lowest at 2.77% — an 8x spread.
- Freight cost and delivery time show only a weak positive correlation (r = 0.215) — higher freight is not a strong predictor of slower delivery.

**Reviews**
- Highest-rated category is CDs & DVDs (4.6 avg), followed by children's fashion (4.5).
- Most top-rated categories cluster in the 4.3–4.4 range, suggesting review scores are generally high and compressed toward the top end.

**Customer Loyalty**
- Most loyal customer by order count placed 17 orders across 15 months (May 2017 – Aug 2018), totaling R$927.63 — favoring credit card.
- High-frequency repeat customers consistently favor credit card or boleto as their payment method.

## Business Questions Covered

**1–10 Basic Insights** — customers by state/city, orders by month, order status mix, avg order value, payment method mix, top sellers, top categories, purchase date range, avg payment by state

**11–20 Sales & Revenue** — seller revenue, top categories/products by revenue, avg order value by state, freight cost analysis, monthly revenue trend, payment type revenue contribution

**21–30 Customer Analysis** — repeat customers, multi-seller customers, above-average spenders, top spenders, spending by state, one-time customers, customer spending rank, multi-category buyers, multi-year repeat customers

**31–40 Product & Seller Analysis** — unsold products/inactive sellers, seller revenue ranking, top sellers by state, product ranking within category, multi-category sellers, avg price by category, seller revenue contribution

**41–51 Advanced Case Studies** — delivery time by seller, late delivery % by state, review scores by product/seller/category, freight-vs-delivery-time correlation, customer dashboard, seller dashboard, executive sales dashboard with running revenue total

## Dashboard Query Results

Screenshots of the 3 dashboard queries from `04_business_questions.sql` (query results run in your SQL client):

**Customer Dashboard** — total orders, total spend, avg order value, first/last order date, favorite payment method per customer
`dashboards/customer_dashboard.png`

**Seller Dashboard** — total revenue, orders, products sold, avg freight cost, avg review score, revenue rank per seller
`dashboards/seller_dashboard.png`

**Executive Sales Dashboard** — monthly orders, revenue, avg order value, top category, top seller, payment mode, avg review, late delivery %, running revenue total
`dashboards/executive_dashboard.png`

## Known Data Limitations

- Reviews are recorded at the **order level**, not per product — an order with multiple products shares one review score across all of them, which dilutes product/seller-level review accuracy.
- Delivery-related timestamp fields are naturally NULL for canceled, unavailable, or in-progress orders; delivery analyses use only completed deliveries.
- Revenue queries are **not filtered by order status** — canceled/unavailable orders' items are included unless a query explicitly filters them out.

## Future Work

- Power BI dashboard on top of these queries
- Full end-to-end pipeline: SQL → Pandas → Power BI