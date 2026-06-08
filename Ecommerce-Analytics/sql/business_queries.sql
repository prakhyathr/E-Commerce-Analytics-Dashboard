-- E-Commerce Sales & Customer Analytics Dashboard
-- Business Queries File containing 26 Advanced SQL Queries
USE ecommerce_analytics;

-- ====================================================================
-- SECTION 1: REVENUE ANALYSIS
-- ====================================================================

-- 1. Top 10 Revenue Categories
-- Business Value: Identifies the main revenue-generating categories to allocate inventory budgets.
SELECT 
    product_category_name_english AS category,
    SUM(price) AS total_revenue,
    COUNT(order_id) AS units_sold,
    ROUND(SUM(price) / COUNT(order_id), 2) AS average_unit_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY product_category_name_english
ORDER BY total_revenue DESC
LIMIT 10;

-- 2. Monthly Revenue Trend
-- Business Value: Shows sales growth trajectories and highlights peak shopping seasons.
SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS purchase_month,
    SUM(order_total_value) AS monthly_revenue,
    COUNT(order_id) AS monthly_orders
FROM orders
WHERE order_status = 'delivered'
GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
ORDER BY purchase_month;

-- 3. Quarterly Revenue Trend
-- Business Value: Evaluates financial performance at a quarterly level, smoothing out monthly noise.
SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-Q') AS year_quarter,
    CONCAT('Q', QUARTER(order_purchase_timestamp)) AS quarter_num,
    SUM(order_total_value) AS quarterly_revenue,
    COUNT(order_id) AS quarterly_orders
FROM orders
WHERE order_status = 'delivered'
GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-Q'), CONCAT('Q', QUARTER(order_purchase_timestamp))
ORDER BY year_quarter;

-- 4. Revenue Growth Analysis (Month-over-Month %)
-- Business Value: Tracks mom growth rates to detect if growth is accelerating or cooling off.
WITH MonthlyRevenue AS (
    SELECT 
        DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS purchase_month,
        SUM(order_total_value) AS revenue
    FROM orders
    WHERE order_status = 'delivered'
    GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
)
SELECT 
    purchase_month,
    revenue,
    LAG(revenue, 1) OVER (ORDER BY purchase_month) AS prev_month_revenue,
    ROUND(((revenue - LAG(revenue, 1) OVER (ORDER BY purchase_month)) / LAG(revenue, 1) OVER (ORDER BY purchase_month)) * 100, 2) AS mom_growth_pct
FROM MonthlyRevenue
ORDER BY purchase_month;

-- 5. State-wise Revenue and Contribution
-- Business Value: Pinpoints high-value geographies to focus marketing campaigns and free shipping budgets.
SELECT 
    customer_state AS state,
    SUM(monetary) AS state_revenue,
    COUNT(customer_unique_id) AS total_customers,
    ROUND((SUM(monetary) / (SELECT SUM(monetary) FROM customers)) * 100, 2) AS revenue_contribution_pct
FROM customers
GROUP BY customer_state
ORDER BY state_revenue DESC;


-- ====================================================================
-- SECTION 2: CUSTOMER ANALYSIS
-- ====================================================================

-- 6. Top 10 Customers by Lifetime Value (CLV)
-- Business Value: Identifies the VIP customers who generate the highest revenue.
SELECT 
    customer_unique_id,
    customer_state,
    frequency AS total_orders,
    monetary AS clv,
    customer_segment
FROM customers
ORDER BY clv DESC
LIMIT 10;

-- 7. Repeat Customers Analysis
-- Business Value: Measures loyalty. Repeat buyers are far cheaper to acquire than new users.
SELECT 
    is_repeat_buyer,
    COUNT(customer_unique_id) AS customer_count,
    ROUND(COUNT(customer_unique_id) / (SELECT COUNT(*) FROM customers) * 100, 2) AS customer_share_pct,
    SUM(monetary) AS total_spend,
    ROUND(SUM(monetary) / (SELECT SUM(monetary) FROM customers) * 100, 2) AS spend_share_pct
FROM customers
GROUP BY is_repeat_buyer;

-- 8. Customer Geographic Distribution (Top 10 Cities)
-- Business Value: Identifies urban centers with high demand to establish warehouse nodes.
SELECT 
    customer_city,
    customer_state,
    COUNT(customer_unique_id) AS customer_count,
    SUM(monetary) AS total_spend
FROM customers
GROUP BY customer_city, customer_state
ORDER BY customer_count DESC
LIMIT 10;

-- 9. Customer Purchase Frequency (Order Count Distribution)
-- Business Value: Quantifies how many orders users place, highlighting the single-purchase trap.
SELECT 
    frequency AS order_count,
    COUNT(customer_unique_id) AS customer_count,
    ROUND(COUNT(customer_unique_id) / (SELECT COUNT(*) FROM customers) * 100, 2) AS customer_share_pct
FROM customers
GROUP BY frequency
ORDER BY order_count;

-- 10. RFM Segment Revenue Contribution
-- Business Value: Profiles value segments. Shows if the small VIP tier drives disproportionate sales.
SELECT 
    customer_segment,
    COUNT(customer_unique_id) AS customer_count,
    ROUND(COUNT(customer_unique_id) / (SELECT COUNT(*) FROM customers) * 100, 2) AS customer_count_pct,
    SUM(monetary) AS total_sales,
    ROUND(SUM(monetary) / (SELECT SUM(monetary) FROM customers) * 100, 2) AS sales_pct
FROM customers
GROUP BY customer_segment
ORDER BY total_sales DESC;


-- ====================================================================
-- SECTION 3: PRODUCT ANALYSIS
-- ====================================================================

-- 11. Top 10 Selling Products
-- Business Value: Highlights individual item bestsellers to maintain robust inventory levels.
SELECT 
    oi.product_id,
    p.product_category_name_english AS category,
    COUNT(oi.order_id) AS units_sold,
    SUM(oi.price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY oi.product_id, p.product_category_name_english
ORDER BY units_sold DESC, total_revenue DESC
LIMIT 10;

-- 12. Worst Performing Products (Lowest sales, minimum 1 sale)
-- Business Value: Identifies dead-stock candidates to liquidate or discount.
SELECT 
    oi.product_id,
    p.product_category_name_english AS category,
    COUNT(oi.order_id) AS units_sold,
    SUM(oi.price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY oi.product_id, p.product_category_name_english
ORDER BY total_revenue ASC, units_sold ASC
LIMIT 10;

-- 13. Category Contribution Pareto (80/20 Rule)
-- Business Value: Demonstrates if 80% of revenue is driven by a small fraction of categories.
WITH CategoryRevenue AS (
    SELECT 
        p.product_category_name_english AS category,
        SUM(oi.price) AS revenue
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.product_category_name_english
),
CumulativeRevenue AS (
    SELECT 
        category,
        revenue,
        SUM(revenue) OVER (ORDER BY revenue DESC) AS running_revenue,
        SUM(revenue) OVER () AS total_revenue
    FROM CategoryRevenue
)
SELECT 
    category,
    revenue,
    ROUND((running_revenue / total_revenue) * 100, 2) AS cumulative_revenue_pct
FROM CumulativeRevenue
ORDER BY revenue DESC;

-- 14. Average Price and Freight per Category
-- Business Value: Identifies high shipping-overhead categories to adjust shipping algorithms.
SELECT 
    p.product_category_name_english AS category,
    ROUND(AVG(oi.price), 2) AS avg_price,
    ROUND(AVG(oi.freight_value), 2) AS avg_freight,
    ROUND(AVG(oi.freight_value) / AVG(oi.price) * 100, 2) AS freight_to_price_ratio_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name_english
ORDER BY avg_freight DESC
LIMIT 10;


-- ====================================================================
-- SECTION 4: SELLER ANALYSIS
-- ====================================================================

-- 15. Top 10 Sellers by Revenue
-- Business Value: Identifies major sellers to invite to merchant loyalty or premium account tiers.
SELECT 
    s.seller_id,
    s.seller_state AS state,
    s.seller_revenue,
    s.seller_order_count AS orders_fulfilled,
    s.seller_avg_rating
FROM sellers s
ORDER BY s.seller_revenue DESC
LIMIT 10;

-- 16. Seller Rankings by State
-- Business Value: Finds local merchant leaders, supporting regional seller acquisition strategies.
SELECT 
    seller_id,
    seller_state,
    seller_revenue,
    DENSE_RANK() OVER (PARTITION BY seller_state ORDER BY seller_revenue DESC) AS state_rank
FROM sellers
WHERE seller_revenue > 0
ORDER BY seller_state, state_rank
LIMIT 15;

-- 17. Seller Revenue Concentration (Pareto)
-- Business Value: Shows if a tiny minority of sellers holds monopolistic volume on the platform.
WITH SellerRev AS (
    SELECT 
        seller_id,
        seller_revenue
    FROM sellers
),
CumSellerRev AS (
    SELECT 
        seller_id,
        seller_revenue,
        SUM(seller_revenue) OVER (ORDER BY seller_revenue DESC) AS running_rev,
        SUM(seller_revenue) OVER () AS total_rev
    FROM SellerRev
)
SELECT 
    seller_id,
    seller_revenue,
    ROUND((running_rev / total_rev) * 100, 2) AS cumulative_revenue_pct
FROM CumSellerRev
ORDER BY seller_revenue DESC
LIMIT 15;

-- 18. Seller Rating Performance
-- Business Value: Pinpoints top-rated vs poor sellers. Sellers with high sales and low scores need support.
SELECT 
    seller_id,
    seller_order_count,
    seller_revenue,
    seller_avg_rating,
    CASE 
        WHEN seller_avg_rating >= 4.5 THEN 'Elite (4.5+)'
        WHEN seller_avg_rating >= 4.0 THEN 'Good (4.0 - 4.5)'
        WHEN seller_avg_rating >= 3.0 THEN 'Average (3.0 - 4.0)'
        ELSE 'Underperforming (<3.0)'
    END AS seller_rating_class
FROM sellers
WHERE seller_order_count >= 10
ORDER BY seller_revenue DESC
LIMIT 15;


-- ====================================================================
-- SECTION 5: DELIVERY ANALYSIS
-- ====================================================================

-- 19. Average Delivery Time by State
-- Business Value: Pinpoints states suffering from shipping delays to negotiate with local carriers.
SELECT 
    customer_state AS state,
    ROUND(AVG(delivery_time_days), 1) AS avg_delivery_time_days,
    ROUND(AVG(shipping_duration_days), 1) AS avg_carrier_transit_days,
    ROUND(AVG(estimated_vs_actual_days), 1) AS avg_days_ahead_of_estimate
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY customer_state
ORDER BY avg_delivery_time_days DESC;

-- 20. Late Deliveries Percentage by State
-- Business Value: Pinpoints where late deliveries are highest, highlighting customer dissatisfaction risks.
SELECT 
    c.customer_state AS state,
    COUNT(o.order_id) AS total_orders,
    SUM(o.is_late_delivery) AS late_orders,
    ROUND((SUM(o.is_late_delivery) / COUNT(o.order_id)) * 100, 2) AS late_delivery_rate_pct
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY late_delivery_rate_pct DESC;

-- 21. Fastest and Slowest Delivery Regions (Top 5 & Bottom 5 Cities)
-- Business Value: Provides local insights to direct regional logistics partnerships.
(
    SELECT 
        c.customer_city,
        c.customer_state,
        COUNT(o.order_id) AS orders_count,
        ROUND(AVG(o.delivery_time_days), 1) AS avg_delivery_days,
        'FASTEST' AS delivery_speed
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_city, c.customer_state
    HAVING orders_count >= 50
    ORDER BY avg_delivery_days ASC
    LIMIT 5
)
UNION ALL
(
    SELECT 
        c.customer_city,
        c.customer_state,
        COUNT(o.order_id) AS orders_count,
        ROUND(AVG(o.delivery_time_days), 1) AS avg_delivery_days,
        'SLOWEST' AS delivery_speed
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_city, c.customer_state
    HAVING orders_count >= 50
    ORDER BY avg_delivery_days DESC
    LIMIT 5
);

-- 22. Logistics Performance by Seller
-- Business Value: Shows which sellers take too long to ship packages, leading to late orders.
SELECT 
    oi.seller_id,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, o.order_approved_at, o.order_delivered_carrier_date) / 24), 1) AS avg_seller_dispatch_lag_days,
    ROUND(AVG(o.delivery_time_days), 1) AS avg_total_delivery_days
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN sellers s ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered' AND o.order_approved_at IS NOT NULL
GROUP BY oi.seller_id, s.seller_state
HAVING total_orders >= 50
ORDER BY avg_seller_dispatch_lag_days DESC
LIMIT 10;


-- ====================================================================
-- SECTION 6: REVIEW ANALYSIS
-- ====================================================================

-- 23. Best and Worst Rated Categories (Min 100 reviews)
-- Business Value: Highlights high-quality categories vs problematic categories with poor scores.
(
    SELECT 
        p.product_category_name_english AS category,
        COUNT(r.review_id) AS review_count,
        ROUND(AVG(r.review_score), 2) AS avg_rating,
        'BEST RATED' AS rating_class
    FROM order_reviews r
    JOIN order_items oi ON r.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.product_category_name_english
    HAVING review_count >= 100
    ORDER BY avg_rating DESC
    LIMIT 5
)
UNION ALL
(
    SELECT 
        p.product_category_name_english AS category,
        COUNT(r.review_id) AS review_count,
        ROUND(AVG(r.review_score), 2) AS avg_rating,
        'WORST RATED' AS rating_class
    FROM order_reviews r
    JOIN order_items oi ON r.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.product_category_name_english
    HAVING review_count >= 100
    ORDER BY avg_rating ASC
    LIMIT 5
);

-- 24. Impact of Delivery Performance on Review Score
-- Business Value: Quantifies the rating penalty for delayed deliveries, reinforcing delivery SLAs.
SELECT 
    CASE 
        WHEN o.is_late_delivery = 1 THEN 'Late Delivery'
        WHEN o.delivery_time_days <= 5 THEN 'Super Fast (0-5 days)'
        WHEN o.delivery_time_days <= 10 THEN 'Normal (5-10 days)'
        ELSE 'Slow but On-Time (10+ days)'
    END AS delivery_performance,
    COUNT(o.order_id) AS total_orders,
    ROUND(AVG(r.review_score), 2) AS average_review_score,
    ROUND(SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / COUNT(o.order_id) * 100, 2) AS negative_review_pct
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY 
    CASE 
        WHEN o.is_late_delivery = 1 THEN 'Late Delivery'
        WHEN o.delivery_time_days <= 5 THEN 'Super Fast (0-5 days)'
        WHEN o.delivery_time_days <= 10 THEN 'Normal (5-10 days)'
        ELSE 'Slow but On-Time (10+ days)'
    END
ORDER BY average_review_score DESC;

-- 25. Seller Review Score Distribution
-- Business Value: Shows how sellers cluster in rating brackets to identify coaching groups.
SELECT 
    CASE 
        WHEN seller_avg_rating >= 4.5 THEN 'Elite (4.5 - 5.0)'
        WHEN seller_avg_rating >= 4.0 THEN 'Good (4.0 - 4.5)'
        WHEN seller_avg_rating >= 3.0 THEN 'Average (3.0 - 4.0)'
        ELSE 'Underperforming (< 3.0)'
    END AS seller_rating_bracket,
    COUNT(seller_id) AS seller_count,
    ROUND(COUNT(seller_id) / (SELECT COUNT(*) FROM sellers) * 100, 2) AS seller_share_pct
FROM sellers
GROUP BY 
    CASE 
        WHEN seller_avg_rating >= 4.5 THEN 'Elite (4.5 - 5.0)'
        WHEN seller_avg_rating >= 4.0 THEN 'Good (4.0 - 4.5)'
        WHEN seller_avg_rating >= 3.0 THEN 'Average (3.0 - 4.0)'
        ELSE 'Underperforming (< 3.0)'
    END
ORDER BY seller_count DESC;

-- 26. Review Score Trend by Quarter
-- Business Value: Tracks customer sentiment trends across the platform over time.
SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-Q') AS year_quarter,
    CONCAT('Q', QUARTER(o.order_purchase_timestamp)) AS quarter_num,
    COUNT(r.review_id) AS review_count,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM order_reviews r
JOIN orders o ON r.order_id = o.order_id
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-Q'), CONCAT('Q', QUARTER(o.order_purchase_timestamp))
ORDER BY year_quarter;
