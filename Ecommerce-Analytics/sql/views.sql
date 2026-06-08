-- E-Commerce Sales & Customer Analytics Views
USE ecommerce_analytics;

-- 1. Complete Sales Line-Item Details View
-- Joins transactions, products, customers, and sellers for granular and aggregated sales analysis.
CREATE OR REPLACE VIEW v_sales_summary AS
SELECT 
    oi.order_id,
    oi.order_item_id,
    o.order_purchase_timestamp,
    o.order_status,
    c.customer_unique_id,
    c.customer_state AS customer_state,
    c.customer_city AS customer_city,
    s.seller_id,
    s.seller_state AS seller_state,
    s.seller_city AS seller_city,
    p.product_id,
    p.product_category_name_english AS product_category,
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS total_item_value,
    oi.price_capped,
    oi.freight_capped,
    (oi.price_capped + oi.freight_capped) AS total_item_value_capped,
    o.delivery_time_days,
    o.is_late_delivery
FROM order_items oi
INNER JOIN orders o ON oi.order_id = o.order_id
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN sellers s ON oi.seller_id = s.seller_id
INNER JOIN products p ON oi.product_id = p.product_id;

-- 2. Customer Profiles and Segmentation View
-- Simplifies user demographic and loyalty segmentation reporting.
CREATE OR REPLACE VIEW v_customer_profiles AS
SELECT 
    customer_unique_id,
    customer_city,
    customer_state,
    recency,
    frequency,
    monetary AS clv,
    is_repeat_buyer,
    customer_segment,
    R_score,
    F_score,
    M_score
FROM customers
WHERE customer_unique_id IS NOT NULL;

-- 3. Seller Performance Dashboard View
-- Consolidates seller-specific metrics like revenue, orders, ratings, and locations.
CREATE OR REPLACE VIEW v_seller_performance AS
SELECT 
    seller_id,
    seller_city,
    seller_state,
    seller_revenue,
    seller_order_count,
    seller_avg_rating
FROM sellers;

-- 4. Delivery and Logistics Performance View
-- Tracks carrier efficiency, estimated vs actual delivery differences, and customer reviews.
CREATE OR REPLACE VIEW v_delivery_analysis AS
SELECT 
    o.order_id,
    o.order_purchase_timestamp,
    o.order_status,
    o.delivery_time_days,
    o.shipping_duration_days,
    o.estimated_vs_actual_days,
    o.is_late_delivery,
    r.review_score
FROM orders o
LEFT JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered';

-- 5. Product Category Summary View
-- Computes sales volume, gross revenue, and rankings per product category.
CREATE OR REPLACE VIEW v_category_performance AS
SELECT 
    p.product_category_name_english AS category_name,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(oi.product_id) AS units_sold,
    SUM(oi.price) AS gross_revenue,
    AVG(oi.price) AS average_price,
    RANK() OVER (ORDER BY SUM(oi.price) DESC) AS revenue_rank
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name_english;
