# Power BI Dashboard Specification & DAX Measures
## E-Commerce Sales & Customer Analytics Dashboard

This guide details the wireframe design, page layouts, visual hierarchy, and exact DAX measures required to build a professional, executive-level dashboard in Power BI.

---

## 1. Design System & Aesthetics

To maintain a professional corporate style, implement a unified dark/modern aesthetic:
- **Background Color**: Dark Slate (`#0B0F19` or `rgb(11, 15, 25)`)
- **Card Background (Visual Containers)**: Dark Navy (`#161D30` or `rgb(22, 29, 48)`)
- **Primary Text Color**: Pure White (`#FFFFFF`)
- **Secondary Text (Labels)**: Soft Gray (`#94A3B8`)
- **Accent Primary (Positive/Revenue)**: Teal (`#0D9488`)
- **Accent Secondary (Logistics/Warning)**: Coral/Amber (`#F43F5E` / `#D97706`)
- **Neutral Accent**: Sky Blue (`#38BDF8`)
- **Typography**: `Segoe UI` or `Inter` (10pt for labels, 20-24pt bold for KPI numbers, 12pt for headers)
- **Container Formatting**: Border radius of `8px`, subtle shadow, default margins `10px`.

---

## 2. DAX Measures Dictionary

Create a table `_Measures` and write the following DAX calculations:

### Core Financial & Order Measures
```dax
// 1. Total Gross Sales (GMV)
Total Revenue = SUM(orders_master[order_total_value])

// 2. Total Orders
Total Orders = DISTINCTCOUNT(orders_master[order_id])

// 3. Average Order Value (AOV)
Average Order Value = DIVIDE([Total Revenue], [Total Orders], 0)

// 4. Units Sold
Units Sold = COUNT(order_items_cleaned[product_id])
```

### Customer Loyalty Measures
```dax
// 5. Total Customers (Unique)
Total Customers = DISTINCTCOUNT(customers_master[customer_unique_id])

// 6. Repeat Buyers Count
Repeat Buyers Count = CALCULATE([Total Customers], customers_master[is_repeat_buyer] = 1)

// 7. Repeat Buyer Rate (%)
Repeat Purchase Rate = DIVIDE([Repeat Buyers Count], [Total Customers], 0)

// 8. Customer Lifetime Value (CLV - Average)
Average CLV = AVERAGE(customers_master[clv])
```

### Logistics & Customer Satisfaction Measures
```dax
// 9. Average Delivery Time (Days)
Average Delivery Time = AVERAGE(orders_master[delivery_time_days])

// 10. Late Orders Count
Late Orders Count = CALCULATE([Total Orders], orders_master[is_late_delivery] = 1)

// 11. Late Delivery Rate (%)
Late Delivery Rate = DIVIDE([Late Orders Count], [Total Orders], 0)

// 12. Average Review Score
Average Review Score = AVERAGE(order_reviews_cleaned[review_score])

// 13. Late Delivery Rating Penalty
Avg Rating for Late Deliveries = CALCULATE([Average Review Score], orders_master[is_late_delivery] = 1)
```

---

## 3. Page-by-Page Dashboard Layout & Wireframes

### PAGE 1 - EXECUTIVE SUMMARY
*Focus: C-Suite overview of overall sales performance.*

```
+----------------------------------------------------------------------------------+
| TITLE: Executive Sales Overview                                   DATE FILTER    |
+----------------------------------------------------------------------------------+
| [ KPI Card ]       [ KPI Card ]       [ KPI Card ]       [ KPI Card ]            |
| Total Revenue      Total Orders       Average Order Val  Avg Review Score        |
| 15.8M BRL          99.4K              159.6 BRL          4.08 / 5.0              |
+------------------------------------+---------------------------------------------+
| VISUAL 1: Monthly Sales Trend      | VISUAL 2: Top Product Categories by Revenue |
| (Line Chart - Teal Accent)         | (Horizontal Bar Chart)                      |
|                                    |                                             |
|                                    |                                             |
+------------------------------------+---------------------------------------------+
| VISUAL 3: Revenue by State         | VISUAL 4: Sales Contribution Segment        |
| (Filled Map / Ranked Bar Chart)    | (Donut Chart - RFM Segments)                |
| SP (7M BRL), RJ (2M BRL)...        | Champions, Loyal, At Risk...                |
+------------------------------------+---------------------------------------------+
```

*Visual Configuration:*
- **Visual 1**: Line chart. X-axis: `order_purchase_timestamp` (Year-Month), Y-axis: `[Total Revenue]`. Enable tooltips showing `[Total Orders]`.
- **Visual 2**: Clustered horizontal bar chart. Y-axis: `product_category_name_english`, X-axis: `[Total Revenue]`. Top N filter set to `10`.
- **Visual 3**: Clustered column chart or filled map. X-axis: `customer_state`, Y-axis: `[Total Revenue]`.
- **Visual 4**: Donut chart. Legend: `customer_segment`, Values: `[Total Revenue]`.

---

### PAGE 2 - CUSTOMER ANALYTICS
*Focus: Customer demographics, loyalty profiles, and RFM structures.*

```
+----------------------------------------------------------------------------------+
| TITLE: Customer Insights & Loyalty                                DATE FILTER    |
+----------------------------------------------------------------------------------+
| [ KPI Card ]               [ KPI Card ]               [ KPI Card ]               |
| Total Customers            Repeat Purchase Rate       Average Lifetime Value     |
| 96.1K                      3.12%                      165.2 BRL                  |
+-------------------------------------------+--------------------------------------+
| VISUAL 1: RFM Customer Segments Count     | VISUAL 2: Purchase Frequency Dist    |
| (Stacked Bar Chart or Treemap)            | (Column Chart - orders per customer) |
|                                           |                                      |
|                                           |                                      |
+-------------------------------------------+--------------------------------------+
| VISUAL 3: Top 20 Customers by CLV                                                |
| (Table: Customer Unique ID, Segment, State, Total Orders, Lifetime Value)         |
|                                                                                  |
+----------------------------------------------------------------------------------+
```

*Visual Configuration:*
- **Visual 1**: Treemap. Category: `customer_segment`, Values: `[Total Customers]`.
- **Visual 2**: Column chart. X-axis: `frequency` (grouped: 1, 2, 3, 4+), Y-axis: `[Total Customers]`.
- **Visual 3**: Table visual. Columns: `customer_unique_id`, `customer_segment`, `customer_state`, `[Total Orders]` (frequency), `[Total Revenue]` (clv). Sort descending by CLV.

---

### PAGE 3 - PRODUCT ANALYTICS
*Focus: Inventory management, category sales contributions, and price points.*

```
+----------------------------------------------------------------------------------+
| TITLE: Product & Category Performance                              DATE FILTER    |
+----------------------------------------------------------------------------------+
| [ KPI Card ]               [ KPI Card ]               [ KPI Card ]               |
| Best Selling Category      Total Unique Products      Average Item Price         |
| Health & Beauty            32.9K                      120.6 BRL                  |
+-------------------------------------------+--------------------------------------+
| VISUAL 1: Product Contribution (Pareto)   | VISUAL 2: Price vs Freight Ratio     |
| (Line & Column Chart: Cum % vs Revenue)   | (Scatter Plot: Price vs Freight)     |
|                                           |                                      |
|                                           |                                      |
+-------------------------------------------+--------------------------------------+
| VISUAL 3: Top Product Items Table                                                 |
| (Table: Product ID, Category, Units Sold, Avg Price, Revenue, Revenue Rank)       |
|                                                                                  |
+----------------------------------------------------------------------------------+
```

*Visual Configuration:*
- **Visual 1**: Line and stacked column chart. Shared Axis: `product_category_name_english`, Column Values: `[Total Revenue]`, Line Values: Running Total % of Revenue (using a quick measure).
- **Visual 2**: Scatter plot. X-axis: `price`, Y-axis: `freight_value`, Details: `product_id`. Helps detect low-price items with high shipping costs.
- **Visual 3**: Table visual. Columns: `product_id`, `product_category_name_english`, `[Units Sold]`, `[Average Order Value]`, `[Total Revenue]`, ranked descending by Revenue.

---

### PAGE 4 - DELIVERY & REVIEW ANALYTICS
*Focus: Supply chain performance, delivery bottlenecks, and customer satisfaction.*

```
+----------------------------------------------------------------------------------+
| TITLE: Delivery Performance & Customer Satisfaction                DATE FILTER    |
+----------------------------------------------------------------------------------+
| [ KPI Card ]               [ KPI Card ]               [ KPI Card ]               |
| Average Delivery Time      Late Delivery Rate         Average Satisfaction Score |
| 12.1 Days                  7.84%                      4.08 / 5.0                 |
+-------------------------------------------+--------------------------------------+
| VISUAL 1: Delivery Delay vs Rating        | VISUAL 2: Late Delivery Rate by State|
| (Column Chart: Avg Rating by Late Flag)   | (Geographic Map or Ranked Bar)       |
| On-Time (4.3) vs Late (2.2)               |                                      |
+-------------------------------------------+--------------------------------------+
| VISUAL 3: Delivery Days Trend MoM                                                 |
| (Line Chart: Avg Delivery Days vs Estimated Promise Days MoM)                    |
|                                                                                  |
+----------------------------------------------------------------------------------+
```

*Visual Configuration:*
- **Visual 1**: Clustered column chart. X-axis: `is_late_delivery` (On-Time vs Late), Y-axis: `[Average Review Score]`.
- **Visual 2**: Clustered column chart. X-axis: `customer_state`, Y-axis: `[Late Delivery Rate]`. Color format bars to turn red when exceeding 10%.
- **Visual 3**: Line chart. X-axis: `order_purchase_timestamp` (Year-Month), Y-axis 1: `[Average Delivery Time]`, Y-axis 2: Average Estimated Delivery Time. Highlights if shipping speeds are worsening over time.
