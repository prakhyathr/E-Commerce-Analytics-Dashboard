# E-Commerce Analytics - SQL Business Intelligence Report
Generated on: 2026-06-08 18:39:46

This report consolidates the results of the key analytical queries run against the `ecommerce_analytics` database.

---

## Query 1: ==================================================================== SECTION 1: REVENUE ANALYSIS ==================================================================== 1. Top 10 Revenue Categories Business Value: Identifies the main revenue-generating categories to allocate inventory budgets.

```sql
SELECT 
    product_category_name_english AS category,
    SUM(price) AS total_revenue,
    COUNT(order_id) AS units_sold,
    ROUND(SUM(price) / COUNT(order_id), 2) AS average_unit_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY product_category_name_english
ORDER BY total_revenue DESC
LIMIT 10
```

### Results
| category              |    total_revenue |   units_sold |   average_unit_price |
|:----------------------|-----------------:|-------------:|---------------------:|
| Health Beauty         |      1.25868e+06 |         9670 |               130.16 |
| Watches Gifts         |      1.20501e+06 |         5991 |               201.14 |
| Bed Bath Table        |      1.03699e+06 |        11115 |                93.3  |
| Sports Leisure        | 988049           |         8641 |               114.34 |
| Computers Accessories | 911954           |         7827 |               116.51 |
| Furniture Decor       | 729762           |         8334 |                87.56 |
| Cool Stuff            | 635291           |         3796 |               167.36 |
| Housewares            | 632249           |         6964 |                90.79 |
| Auto                  | 592720           |         4235 |               139.96 |
| Garden Tools          | 485256           |         4347 |               111.63 |

---

## Query 2: 2. Monthly Revenue Trend Business Value: Shows sales growth trajectories and highlights peak shopping seasons.

```sql
SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS year_month,
    SUM(order_total_value) AS monthly_revenue,
    COUNT(order_id) AS monthly_orders
FROM orders
WHERE order_status = 'delivered'
GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
ORDER BY year_month
```

### Results
| year_month   |   monthly_revenue |   monthly_orders |
|:-------------|------------------:|-----------------:|
| 2016-09      |     143.46        |                1 |
| 2016-10      |   46490.7         |              265 |
| 2016-12      |      19.62        |                1 |
| 2017-01      |  127482           |              750 |
| 2017-02      |  271239           |             1653 |
| 2017-03      |  414331           |             2546 |
| 2017-04      |  390812           |             2303 |
| 2017-05      |  566851           |             3546 |
| 2017-06      |  490050           |             3135 |
| 2017-07      |  566299           |             3872 |
| 2017-08      |  645832           |             4193 |
| 2017-09      |  701077           |             4150 |
| 2017-10      |  751117           |             4478 |
| 2017-11      |       1.15336e+06 |             7289 |
| 2017-12      |  843078           |             5513 |
| 2018-01      |       1.07789e+06 |             7069 |
| 2018-02      |  966168           |             6555 |
| 2018-03      |       1.1206e+06  |             7003 |
| 2018-04      |       1.13288e+06 |             6798 |
| 2018-05      |       1.12877e+06 |             6749 |
| 2018-06      |       1.01198e+06 |             6099 |
| 2018-07      |       1.02781e+06 |             6159 |
| 2018-08      |  985492           |             6351 |

---

## Query 3: 3. Quarterly Revenue Trend Business Value: Evaluates financial performance at a quarterly level, smoothing out monthly noise.

```sql
SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-Q') AS year_quarter,
    CONCAT('Q', QUARTER(order_purchase_timestamp)) AS quarter_num,
    SUM(order_total_value) AS quarterly_revenue,
    COUNT(order_id) AS quarterly_orders
FROM orders
WHERE order_status = 'delivered'
GROUP BY YEAR(order_purchase_timestamp), QUARTER(order_purchase_timestamp)
ORDER BY YEAR(order_purchase_timestamp), QUARTER(order_purchase_timestamp)
```

### Results
| year_quarter   | quarter_num   |   quarterly_revenue |   quarterly_orders |
|:---------------|:--------------|--------------------:|-------------------:|
| 2016-Q         | Q3            |       143.46        |                  1 |
| 2016-Q         | Q4            |     46510.3         |                266 |
| 2017-Q         | Q1            |    813053           |               4949 |
| 2017-Q         | Q2            |         1.44771e+06 |               8984 |
| 2017-Q         | Q3            |         1.91321e+06 |              12215 |
| 2017-Q         | Q4            |         2.74756e+06 |              17280 |
| 2018-Q         | Q1            |         3.16465e+06 |              20627 |
| 2018-Q         | Q2            |         3.27363e+06 |              19646 |
| 2018-Q         | Q3            |         2.0133e+06  |              12510 |

---

## Query 4: 4. Revenue Growth Analysis (Month-over-Month %) Business Value: Tracks mom growth rates to detect if growth is accelerating or cooling off.

```sql
WITH MonthlyRevenue AS (
    SELECT 
        DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS year_month,
        SUM(order_total_value) AS revenue
    FROM orders
    WHERE order_status = 'delivered'
    GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
)
SELECT 
    year_month,
    revenue,
    LAG(revenue, 1) OVER (ORDER BY year_month) AS prev_month_revenue,
    ROUND(((revenue - LAG(revenue, 1) OVER (ORDER BY year_month)) / LAG(revenue, 1) OVER (ORDER BY year_month)) * 100, 2) AS mom_growth_pct
FROM MonthlyRevenue
ORDER BY year_month
```

### Results
| year_month   |          revenue |   prev_month_revenue |   mom_growth_pct |
|:-------------|-----------------:|---------------------:|-----------------:|
| 2016-09      |    143.46        |                      |                  |
| 2016-10      |  46490.7         |        143.46        |         32306.7  |
| 2016-12      |     19.62        |      46490.7         |           -99.96 |
| 2017-01      | 127482           |         19.62        |        649657    |
| 2017-02      | 271239           |     127482           |           112.77 |
| 2017-03      | 414331           |     271239           |            52.75 |
| 2017-04      | 390812           |     414331           |            -5.68 |
| 2017-05      | 566851           |     390812           |            45.04 |
| 2017-06      | 490050           |     566851           |           -13.55 |
| 2017-07      | 566299           |     490050           |            15.56 |
| 2017-08      | 645832           |     566299           |            14.04 |
| 2017-09      | 701077           |     645832           |             8.55 |
| 2017-10      | 751117           |     701077           |             7.14 |
| 2017-11      |      1.15336e+06 |     751117           |            53.55 |
| 2017-12      | 843078           |          1.15336e+06 |           -26.9  |
| 2018-01      |      1.07789e+06 |     843078           |            27.85 |
| 2018-02      | 966168           |          1.07789e+06 |           -10.36 |
| 2018-03      |      1.1206e+06  |     966168           |            15.98 |
| 2018-04      |      1.13288e+06 |          1.1206e+06  |             1.1  |
| 2018-05      |      1.12877e+06 |          1.13288e+06 |            -0.36 |
| 2018-06      |      1.01198e+06 |          1.12877e+06 |           -10.35 |
| 2018-07      |      1.02781e+06 |          1.01198e+06 |             1.56 |
| 2018-08      | 985492           |          1.02781e+06 |            -4.12 |

---

## Query 5: 5. State-wise Revenue and Contribution Business Value: Pinpoints high-value geographies to focus marketing campaigns and free shipping budgets.

```sql
SELECT 
    customer_state AS state,
    SUM(monetary) AS state_revenue,
    COUNT(customer_unique_id) AS total_customers,
    ROUND((SUM(monetary) / (SELECT SUM(monetary) FROM customers)) * 100, 2) AS revenue_contribution_pct
FROM customers
GROUP BY customer_state
ORDER BY state_revenue DESC
```

### Results
| state   |    state_revenue |   total_customers |   revenue_contribution_pct |
|:--------|-----------------:|------------------:|---------------------------:|
| SP      |      6.37375e+06 |             41746 |                      37.56 |
| RJ      |      2.29516e+06 |             12852 |                      13.53 |
| MG      |      1.98003e+06 |             11635 |                      11.67 |
| RS      | 962333           |              5466 |                       5.67 |
| PR      | 850853           |              5045 |                       5.01 |
| SC      | 658053           |              3637 |                       3.88 |
| BA      | 650716           |              3380 |                       3.83 |
| DF      | 370072           |              2140 |                       2.18 |
| GO      | 368073           |              2020 |                       2.17 |
| ES      | 350233           |              2033 |                       2.06 |
| PE      | 348073           |              1652 |                       2.05 |
| CE      | 282878           |              1336 |                       1.67 |
| PA      | 225481           |               975 |                       1.33 |
| MT      | 195079           |               907 |                       1.15 |
| MA      | 160450           |               747 |                       0.95 |
| PB      | 149849           |               536 |                       0.88 |
| MS      | 142777           |               715 |                       0.84 |
| PI      | 113582           |               495 |                       0.67 |
| RN      | 105794           |               485 |                       0.62 |
| AL      | 103246           |               413 |                       0.61 |
| SE      |  76742           |               350 |                       0.45 |
| TO      |  63744.4         |               280 |                       0.38 |
| RO      |  62652.2         |               253 |                       0.37 |
| AM      |  30849.3         |               148 |                       0.18 |
| AC      |  21514           |                81 |                       0.13 |
| AP      |  16868.6         |                68 |                       0.1  |
| RR      |  10827.9         |                46 |                       0.06 |

---

## Query 6: ==================================================================== SECTION 2: CUSTOMER ANALYSIS ==================================================================== 6. Top 10 Customers by Lifetime Value (CLV) Business Value: Identifies the VIP customers who generate the highest revenue.

```sql
SELECT 
    customer_unique_id,
    customer_state,
    frequency AS total_orders,
    monetary AS clv,
    customer_segment
FROM customers
ORDER BY clv DESC
LIMIT 10
```

### Results
| customer_unique_id               | customer_state   |   total_orders |      clv | customer_segment   |
|:---------------------------------|:-----------------|---------------:|---------:|:-------------------|
| 0a0a92112bd4c708ca5fde585afaa872 | RJ               |              1 | 13664.1  | Promising/Recent   |
| da122df9eeddfedc1dc1f5349a1a690c | RJ               |              2 |  7571.63 | Promising/Recent   |
| da122df9eeddfedc1dc1f5349a1a690c | RJ               |              2 |  7571.63 | Promising/Recent   |
| 763c8b1c9c68a0229c42c9fc6f662b93 | ES               |              1 |  7274.88 | Loyal              |
| dc4802a71eae9be1dd28f5d788ceb526 | MS               |              1 |  6929.31 | Promising/Recent   |
| 459bef486812aa25204be022145caa62 | ES               |              1 |  6922.21 | Loyal              |
| ff4159b92c40ebe40454e3e6a7c35ed6 | SP               |              1 |  6726.66 | Promising/Recent   |
| 4007669dec559734d6f53e029e360987 | MG               |              1 |  6081.54 | Promising/Recent   |
| 5d0a2980b292d049061542014e8960bf | GO               |              1 |  4809.44 | Loyal              |
| eebb5dda148d3893cdaf5b5ca3040ccb | SP               |              1 |  4764.34 | Promising/Recent   |

---

## Query 7: 7. Repeat Customers Analysis Business Value: Measures loyalty. Repeat buyers are far cheaper to acquire than new users.

```sql
SELECT 
    is_repeat_buyer,
    COUNT(customer_unique_id) AS customer_count,
    ROUND(COUNT(customer_unique_id) / (SELECT COUNT(*) FROM customers) * 100, 2) AS customer_share_pct,
    SUM(monetary) AS total_spend,
    ROUND(SUM(monetary) / (SELECT SUM(monetary) FROM customers) * 100, 2) AS spend_share_pct
FROM customers
GROUP BY is_repeat_buyer
```

### Results
|   is_repeat_buyer |   customer_count |   customer_share_pct |   total_spend |   spend_share_pct |
|------------------:|-----------------:|---------------------:|--------------:|------------------:|
|                 0 |            93099 |                93.62 |   1.49215e+07 |             87.93 |
|                 1 |             6342 |                 6.38 |   2.04816e+06 |             12.07 |

---

## Query 8: 8. Customer Geographic Distribution (Top 10 Cities) Business Value: Identifies urban centers with high demand to establish warehouse nodes.

```sql
SELECT 
    customer_city,
    customer_state,
    COUNT(customer_unique_id) AS customer_count,
    SUM(monetary) AS total_spend
FROM customers
GROUP BY customer_city, customer_state
ORDER BY customer_count DESC
LIMIT 10
```

### Results
| customer_city         | customer_state   |   customer_count |      total_spend |
|:----------------------|:-----------------|-----------------:|-----------------:|
| sao paulo             | SP               |            15540 |      2.34801e+06 |
| rio de janeiro        | RJ               |             6882 |      1.24496e+06 |
| belo horizonte        | MG               |             2773 | 448862           |
| brasilia              | DF               |             2131 | 368653           |
| curitiba              | PR               |             1521 | 261640           |
| campinas              | SP               |             1444 | 229021           |
| porto alegre          | RS               |             1379 | 261689           |
| salvador              | BA               |             1245 | 227337           |
| guarulhos             | SP               |             1189 | 174410           |
| sao bernardo do campo | SP               |              938 | 126391           |

---

## Query 9: 9. Customer Purchase Frequency (Order Count Distribution) Business Value: Quantifies how many orders users place, highlighting the single-purchase trap.

```sql
SELECT 
    frequency AS order_count,
    COUNT(customer_unique_id) AS customer_count,
    ROUND(COUNT(customer_unique_id) / (SELECT COUNT(*) FROM customers) * 100, 2) AS customer_share_pct
FROM customers
GROUP BY frequency
ORDER BY order_count
```

### Results
|   order_count |   customer_count |   customer_share_pct |
|--------------:|-----------------:|---------------------:|
|             1 |            93099 |                93.62 |
|             2 |             5490 |                 5.52 |
|             3 |              609 |                 0.61 |
|             4 |              120 |                 0.12 |
|             5 |               40 |                 0.04 |
|             6 |               36 |                 0.04 |
|             7 |               21 |                 0.02 |
|             9 |                9 |                 0.01 |
|            17 |               17 |                 0.02 |

---

## Query 10: 10. RFM Segment Revenue Contribution Business Value: Profiles value segments. Shows if the small VIP tier drives disproportionate sales.

```sql
SELECT 
    customer_segment,
    COUNT(customer_unique_id) AS customer_count,
    ROUND(COUNT(customer_unique_id) / (SELECT COUNT(*) FROM customers) * 100, 2) AS customer_count_pct,
    SUM(monetary) AS total_sales,
    ROUND(SUM(monetary) / (SELECT SUM(monetary) FROM customers) * 100, 2) AS sales_pct
FROM customers
GROUP BY customer_segment
ORDER BY total_sales DESC
```

### Results
| customer_segment    |   customer_count |   customer_count_pct |      total_sales |   sales_pct |
|:--------------------|-----------------:|---------------------:|-----------------:|------------:|
| Promising/Recent    |            59561 |                59.9  |      9.12503e+06 |       53.77 |
| Loyal               |            20059 |                20.17 |      6.11862e+06 |       36.06 |
| At Risk/Hibernating |            18323 |                18.43 |      1.01277e+06 |        5.97 |
| Champions           |             1498 |                 1.51 | 713254           |        4.2  |

---

## Query 11: ==================================================================== SECTION 3: PRODUCT ANALYSIS ==================================================================== 11. Top 10 Selling Products Business Value: Highlights individual item bestsellers to maintain robust inventory levels.

```sql
SELECT 
    oi.product_id,
    p.product_category_name_english AS category,
    COUNT(oi.order_id) AS units_sold,
    SUM(oi.price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY oi.product_id, p.product_category_name_english
ORDER BY units_sold DESC, total_revenue DESC
LIMIT 10
```

### Results
| product_id                       | category              |   units_sold |   total_revenue |
|:---------------------------------|:----------------------|-------------:|----------------:|
| aca2eb7d00ea1a7b8ebd4e68314663af | Furniture Decor       |          527 |        37608.9  |
| 99a4788cb24856965c36a24e339b6058 | Bed Bath Table        |          488 |        43025.6  |
| 422879e10f46682990de24d770e7f83d | Garden Tools          |          484 |        26577.2  |
| 389d119b48cf3043d311335e499d9c6b | Garden Tools          |          392 |        21440.6  |
| 368c6c730842d78016ad823897a372db | Garden Tools          |          388 |        21056.8  |
| 53759a2ecddad2bb87a079a1f1519f73 | Garden Tools          |          373 |        20387.2  |
| d1c427060a0f73f6b889a5c7c61f2ac4 | Computers Accessories |          343 |        47214.5  |
| 53b36df67ebb7c41585e8d54d6772e08 | Watches Gifts         |          323 |        37683.4  |
| 154e7e31ebfa092203795c972e5804a6 | Health Beauty         |          281 |         6325.19 |
| 3dd2a17168ec895c781a9191c1e95ad7 | Computers Accessories |          274 |        41082.6  |

---

## Query 12: 12. Worst Performing Products (Lowest sales, minimum 1 sale) Business Value: Identifies dead-stock candidates to liquidate or discount.

```sql
SELECT 
    oi.product_id,
    p.product_category_name_english AS category,
    COUNT(oi.order_id) AS units_sold,
    SUM(oi.price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY oi.product_id, p.product_category_name_english
ORDER BY total_revenue ASC, units_sold ASC
LIMIT 10
```

### Results
| product_id                       | category                        |   units_sold |   total_revenue |
|:---------------------------------|:--------------------------------|-------------:|----------------:|
| 46fce52cef5caa7cc225a5531c946c8b | Health Beauty                   |            1 |            2.2  |
| 310dc32058903b6416c71faff132df9e | Stationery                      |            1 |            2.29 |
| 8a3254bee785a526d548a81a9bc3c9be | Construction Tools Construction |            3 |            2.55 |
| 680cc8535be7cc69544238c1d6a83fe8 | Pet Shop                        |            1 |            2.9  |
| 2e8316b31db34314f393806fd7b6e185 | Stationery                      |            1 |            2.99 |
| 5304ff3fa35856a156e1170a6022d34d | Art                             |            1 |            3.5  |
| 0eeeb45e2f5911fd44282e5bb0c624ff | Music                           |            1 |            3.85 |
| 836c4b48c2b383bb38bb5788f828c596 | Fashion Underwear Beach         |            1 |            3.9  |
| c2fb26742f8484dbfe9a8d70bdc54025 | Computers Accessories           |            1 |            3.9  |
| eee2fb3dceb9ffd8a99dd4bc4b7e860a | Computers Accessories           |            1 |            3.9  |

---

## Query 13: 13. Category Contribution Pareto (80/20 Rule) Business Value: Demonstrates if 80% of revenue is driven by a small fraction of categories.

```sql
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
ORDER BY revenue DESC
```

### Results
| category                                      |          revenue |   cumulative_revenue_pct |
|:----------------------------------------------|-----------------:|-------------------------:|
| Health Beauty                                 |      1.25868e+06 |                     9.26 |
| Watches Gifts                                 |      1.20501e+06 |                    18.13 |
| Bed Bath Table                                |      1.03699e+06 |                    25.76 |
| Sports Leisure                                | 988049           |                    33.03 |
| Computers Accessories                         | 911954           |                    39.74 |
| Furniture Decor                               | 729762           |                    45.1  |
| Cool Stuff                                    | 635291           |                    49.78 |
| Housewares                                    | 632249           |                    54.43 |
| Auto                                          | 592720           |                    58.79 |
| Garden Tools                                  | 485256           |                    62.36 |
| Toys                                          | 483947           |                    65.92 |
| Baby                                          | 411765           |                    68.95 |
| Perfumery                                     | 399125           |                    71.89 |
| Telephony                                     | 323668           |                    74.27 |
| Office Furniture                              | 273961           |                    76.29 |
| Stationery                                    | 230943           |                    77.98 |
| Computers                                     | 222963           |                    79.62 |
| Pet Shop                                      | 214315           |                    81.2  |
| Musical Instruments                           | 191499           |                    82.61 |
| Small Appliances                              | 190649           |                    84.01 |
| Unknown                                       | 179535           |                    85.33 |
| Electronics                                   | 160247           |                    86.51 |
| Consoles Games                                | 157465           |                    87.67 |
| Fashion Bags Accessories                      | 152824           |                    88.8  |
| Construction Tools Construction               | 144678           |                    89.86 |
| Luggage Accessories                           | 140430           |                    90.89 |
| Home Appliances 2                             | 113318           |                    91.73 |
| Home Construction                             |  83088.1         |                    92.34 |
| Home Appliances                               |  80171.5         |                    92.93 |
| Agro Industry And Commerce                    |  72530.5         |                    93.46 |
| Furniture Living Room                         |  68916.6         |                    93.97 |
| Fixed Telephony                               |  59583           |                    94.41 |
| Home Confort                                  |  58572           |                    94.84 |
| Air Conditioning                              |  55025           |                    95.24 |
| Audio                                         |  50688.5         |                    95.62 |
| Small Appliances Home Oven And Coffee         |  47445.7         |                    95.97 |
| Books General Interest                        |  46856.9         |                    96.31 |
| Kitchen Dining Laundry Garden Furniture       |  46328.4         |                    96.65 |
| Construction Tools Lights                     |  41080           |                    96.95 |
| Construction Tools Safety                     |  40544.5         |                    97.25 |
| Industry Commerce And Business                |  39669.6         |                    97.54 |
| Food                                          |  29393.4         |                    97.76 |
| Market Place                                  |  28378.5         |                    97.97 |
| Costruction Tools Garden                      |  25715.9         |                    98.16 |
| Art                                           |  24202.6         |                    98.34 |
| Fashion Shoes                                 |  23562.8         |                    98.51 |
| Drinks                                        |  22428.7         |                    98.67 |
| Signaling And Security                        |  21509.2         |                    98.83 |
| Furniture Bedroom                             |  20028.8         |                    98.98 |
| Books Technical                               |  19096.1         |                    99.12 |
| Costruction Tools Tools                       |  15904           |                    99.24 |
| Food Drink                                    |  15179.5         |                    99.35 |
| Fashion Male Clothing                         |  10797.8         |                    99.43 |
| Fashion Underwear Beach                       |   9541.55        |                    99.5  |
| Christmas Supplies                            |   8800.82        |                    99.56 |
| Tablets Printing Image                        |   7528.41        |                    99.62 |
| Cine Photo                                    |   6933.46        |                    99.67 |
| Music                                         |   6034.35        |                    99.71 |
| Dvds Blu Ray                                  |   5999.39        |                    99.76 |
| Books Imported                                |   4639.85        |                    99.79 |
| Party Supplies                                |   4485.18        |                    99.83 |
| Furniture Mattress And Upholstery             |   4368.08        |                    99.86 |
| Portateis Cozinha E Preparadores De Alimentos |   3968.53        |                    99.89 |
| Fashio Female Clothing                        |   2803.64        |                    99.91 |
| Fashion Sport                                 |   2119.51        |                    99.92 |
| La Cuisine                                    |   2054.99        |                    99.94 |
| Arts And Craftmanship                         |   1814.01        |                    99.95 |
| Diapers And Hygiene                           |   1567.59        |                    99.96 |
| Pc Gamer                                      |   1545.95        |                    99.97 |
| Flowers                                       |   1110.04        |                    99.98 |
| Home Comfort 2                                |    760.27        |                    99.99 |
| Cds Dvds Musicals                             |    730           |                    99.99 |
| Fashion Childrens Clothes                     |    569.85        |                   100    |
| Security And Services                         |    283.29        |                   100    |

---

## Query 14: 14. Average Price and Freight per Category Business Value: Identifies high shipping-overhead categories to adjust shipping algorithms.

```sql
SELECT 
    p.product_category_name_english AS category,
    ROUND(AVG(oi.price), 2) AS avg_price,
    ROUND(AVG(oi.freight_value), 2) AS avg_freight,
    ROUND(AVG(oi.freight_value) / AVG(oi.price) * 100, 2) AS freight_to_price_ratio_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name_english
ORDER BY avg_freight DESC
LIMIT 10
```

### Results
| category                                |   avg_price |   avg_freight |   freight_to_price_ratio_pct |
|:----------------------------------------|------------:|--------------:|-----------------------------:|
| Computers                               |     1098.34 |         48.45 |                         4.41 |
| Home Appliances 2                       |      476.12 |         44.54 |                         9.35 |
| Furniture Mattress And Upholstery       |      114.95 |         42.91 |                        37.33 |
| Kitchen Dining Laundry Garden Furniture |      164.87 |         42.7  |                        25.9  |
| Furniture Bedroom                       |      183.75 |         42.5  |                        23.13 |
| Office Furniture                        |      162.01 |         40.55 |                        25.03 |
| Small Appliances Home Oven And Coffee   |      624.29 |         36.16 |                         5.79 |
| Furniture Living Room                   |      137.01 |         35.72 |                        26.07 |
| Signaling And Security                  |      108.09 |         32.7  |                        30.26 |
| Industry Commerce And Business          |      148.02 |         29.42 |                        19.88 |

---

## Query 15: ==================================================================== SECTION 4: SELLER ANALYSIS ==================================================================== 15. Top 10 Sellers by Revenue Business Value: Identifies major sellers to invite to merchant loyalty or premium account tiers.

```sql
SELECT 
    s.seller_id,
    s.seller_state AS state,
    s.seller_revenue,
    s.seller_order_count AS orders_fulfilled,
    s.seller_avg_rating
FROM sellers s
ORDER BY s.seller_revenue DESC
LIMIT 10
```

### Results
| seller_id                        | state   |   seller_revenue |   orders_fulfilled |   seller_avg_rating |
|:---------------------------------|:--------|-----------------:|-------------------:|--------------------:|
| 4869f7a5dfa277a7dca6462dcf3b52b2 | SP      |           228071 |               1124 |                4.12 |
| 53243585a1d6dc2643021fd1853d8905 | BA      |           220740 |                356 |                4.08 |
| 4a3ca9315b744ce9f8e9374361493884 | SP      |           200561 |               1785 |                3.8  |
| fa1c13f2614d7b5c4749cbc52fecda94 | SP      |           192774 |                581 |                4.34 |
| 7c67e1448b00f6e969d365cea6b010ab | SP      |           188018 |                976 |                3.35 |
| 7e93a43ef30c4f03f38b393420bc753a | SP      |           176202 |                335 |                4.21 |
| da8622b14eb17ae2831f4ac5b9dab84a | SP      |           161994 |               1308 |                4.07 |
| 7a67c85e85bb2ce8582c35f2203ad736 | SP      |           141131 |               1151 |                4.23 |
| 1025f0e2d44d7041d6cf58b6550e0bfa | SP      |           139484 |                907 |                3.85 |
| 955fee9216a65b617aa5c0531780ce60 | SP      |           133949 |               1277 |                4.05 |

---

## Query 16: 16. Seller Rankings by State Business Value: Finds local merchant leaders, supporting regional seller acquisition strategies.

```sql
SELECT 
    seller_id,
    seller_state,
    seller_revenue,
    DENSE_RANK() OVER (PARTITION BY seller_state ORDER BY seller_revenue DESC) AS state_rank
FROM sellers
WHERE seller_revenue > 0
ORDER BY seller_state, state_rank
LIMIT 15
```

### Results
| seller_id                        | seller_state   |   seller_revenue |   state_rank |
|:---------------------------------|:---------------|-----------------:|-------------:|
| 4be2e7f96b4fd749d52dff41f80e39dd | AC             |           267    |            1 |
| 327b89b872c14d1c0be7235ef4871685 | AM             |          1177    |            1 |
| 53243585a1d6dc2643021fd1853d8905 | BA             |        220740    |            1 |
| c72de06d72748d1a0dfb2125be43ba63 | BA             |         17522    |            2 |
| 75d34ebb1bd0bd7dde40dd507b8169c3 | BA             |         15048.3  |            3 |
| d03698c2efd04a549382afa6623e27fb | BA             |          8865.47 |            4 |
| 4aba391bc3b88717ce08eb11e44937b2 | BA             |          7595.87 |            5 |
| a3dd39f583bc80bd8c5901c95878921e | BA             |          4659.81 |            6 |
| 1444c08e64d55fb3c25f0f09c07ffcf2 | BA             |          2749    |            7 |
| 659e8466eb3ff1b0e8740d74fb7bbedd | BA             |          1486.8  |            8 |
| d2e753bb80b7d4faa77483ed00edc8ca | BA             |          1389.7  |            9 |
| 4fb41dff7c50136976d1a5cf004a42e2 | BA             |          1230    |           10 |
| 4221a7df464f1fe2955934e30ff3a5a1 | BA             |           849.5  |           11 |
| fc59392d66ef99377e50356ee4f3b4e1 | BA             |           519.99 |           12 |
| 2b402d5dc42554061f8ea98d1916f148 | BA             |           299.89 |           13 |

---

## Query 17: 17. Seller Revenue Concentration (Pareto) Business Value: Shows if a tiny minority of sellers holds monopolistic volume on the platform.

```sql
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
LIMIT 15
```

### Results
| seller_id                        |   seller_revenue |   cumulative_revenue_pct |
|:---------------------------------|-----------------:|-------------------------:|
| 4869f7a5dfa277a7dca6462dcf3b52b2 |           228071 |                     1.69 |
| 53243585a1d6dc2643021fd1853d8905 |           220740 |                     3.32 |
| 4a3ca9315b744ce9f8e9374361493884 |           200561 |                     4.8  |
| fa1c13f2614d7b5c4749cbc52fecda94 |           192774 |                     6.23 |
| 7c67e1448b00f6e969d365cea6b010ab |           188018 |                     7.62 |
| 7e93a43ef30c4f03f38b393420bc753a |           176202 |                     8.92 |
| da8622b14eb17ae2831f4ac5b9dab84a |           161994 |                    10.12 |
| 7a67c85e85bb2ce8582c35f2203ad736 |           141131 |                    11.16 |
| 1025f0e2d44d7041d6cf58b6550e0bfa |           139484 |                    12.19 |
| 955fee9216a65b617aa5c0531780ce60 |           133949 |                    13.18 |
| 46dc3b2cc0980fb8ec44634e21d2718e |           126166 |                    14.11 |
| 6560211a19b47992c3666cc44a7e94c0 |           122485 |                    15.02 |
| 620c87c171fb2a6dd6e8bb4dec959fc6 |           114015 |                    15.86 |
| 7d13fca15225358621be4086e1eb0964 |           113091 |                    16.7  |
| 5dceca129747e92ff8ef7a997dc4f8ca |           110489 |                    17.51 |

---

## Query 18: 18. Seller Rating Performance Business Value: Pinpoints top-rated vs poor sellers. Sellers with high sales and low scores need support.

```sql
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
LIMIT 15
```

### Results
| seller_id                        |   seller_order_count |   seller_revenue |   seller_avg_rating | seller_rating_class   |
|:---------------------------------|---------------------:|-----------------:|--------------------:|:----------------------|
| 4869f7a5dfa277a7dca6462dcf3b52b2 |                 1124 |           228071 |                4.12 | Good (4.0 - 4.5)      |
| 53243585a1d6dc2643021fd1853d8905 |                  356 |           220740 |                4.08 | Good (4.0 - 4.5)      |
| 4a3ca9315b744ce9f8e9374361493884 |                 1785 |           200561 |                3.8  | Average (3.0 - 4.0)   |
| fa1c13f2614d7b5c4749cbc52fecda94 |                  581 |           192774 |                4.34 | Good (4.0 - 4.5)      |
| 7c67e1448b00f6e969d365cea6b010ab |                  976 |           188018 |                3.35 | Average (3.0 - 4.0)   |
| 7e93a43ef30c4f03f38b393420bc753a |                  335 |           176202 |                4.21 | Good (4.0 - 4.5)      |
| da8622b14eb17ae2831f4ac5b9dab84a |                 1308 |           161994 |                4.07 | Good (4.0 - 4.5)      |
| 7a67c85e85bb2ce8582c35f2203ad736 |                 1151 |           141131 |                4.23 | Good (4.0 - 4.5)      |
| 1025f0e2d44d7041d6cf58b6550e0bfa |                  907 |           139484 |                3.85 | Average (3.0 - 4.0)   |
| 955fee9216a65b617aa5c0531780ce60 |                 1277 |           133949 |                4.05 | Good (4.0 - 4.5)      |
| 46dc3b2cc0980fb8ec44634e21d2718e |                  515 |           126166 |                4.18 | Good (4.0 - 4.5)      |
| 6560211a19b47992c3666cc44a7e94c0 |                 1838 |           122485 |                3.91 | Average (3.0 - 4.0)   |
| 620c87c171fb2a6dd6e8bb4dec959fc6 |                  733 |           114015 |                4.22 | Good (4.0 - 4.5)      |
| 7d13fca15225358621be4086e1eb0964 |                  561 |           113091 |                4    | Good (4.0 - 4.5)      |
| 5dceca129747e92ff8ef7a997dc4f8ca |                  321 |           110489 |                3.99 | Average (3.0 - 4.0)   |

---

## Query 19: ==================================================================== SECTION 5: DELIVERY ANALYSIS ==================================================================== 19. Average Delivery Time by State Business Value: Pinpoints states suffering from shipping delays to negotiate with local carriers.

```sql
SELECT 
    customer_state AS state,
    ROUND(AVG(delivery_time_days), 1) AS avg_delivery_time_days,
    ROUND(AVG(shipping_duration_days), 1) AS avg_carrier_transit_days,
    ROUND(AVG(estimated_vs_actual_days), 1) AS avg_days_ahead_of_estimate
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY customer_state
ORDER BY avg_delivery_time_days DESC
```

### Results
| state   |   avg_delivery_time_days |   avg_carrier_transit_days |   avg_days_ahead_of_estimate |
|:--------|-------------------------:|---------------------------:|-----------------------------:|
| RR      |                     29.4 |                        3.3 |                         16.6 |
| AP      |                     27.2 |                        2.9 |                         19.1 |
| AM      |                     26.4 |                        2.5 |                         18.9 |
| AL      |                     24.5 |                        3   |                          8   |
| PA      |                     23.8 |                        3   |                         13.4 |
| MA      |                     21.6 |                        3   |                          8.9 |
| SE      |                     21.5 |                        3.2 |                          9.3 |
| CE      |                     21.3 |                        2.9 |                         10.1 |
| AC      |                     21   |                        2.8 |                         20.1 |
| PB      |                     20.4 |                        2.9 |                         12.6 |
| PI      |                     19.5 |                        2.8 |                         10.6 |
| RO      |                     19.4 |                        2.3 |                         19.4 |
| BA      |                     19.3 |                        2.8 |                         10.1 |
| RN      |                     19.3 |                        3.1 |                         13   |
| PE      |                     18.4 |                        2.8 |                         12.6 |
| MT      |                     18.1 |                        2.6 |                         13.7 |
| TO      |                     17.7 |                        2.9 |                         11.4 |
| ES      |                     15.8 |                        2.9 |                          9.8 |
| GO      |                     15.6 |                        2.6 |                         11.5 |
| MS      |                     15.6 |                        2.7 |                         10.4 |
| RJ      |                     15.3 |                        2.9 |                         11.1 |
| RS      |                     15.3 |                        2.7 |                         13.2 |
| SC      |                     15   |                        2.9 |                         10.8 |
| DF      |                     13   |                        2.7 |                         11.3 |
| MG      |                     12   |                        2.8 |                         12.5 |
| PR      |                     12   |                        2.8 |                         12.6 |
| SP      |                      8.8 |                        2.8 |                         10.4 |

---

## Query 20: 20. Late Deliveries Percentage by State Business Value: Pinpoints where late deliveries are highest, highlighting customer dissatisfaction risks.

```sql
SELECT 
    c.customer_state AS state,
    COUNT(o.order_id) AS total_orders,
    SUM(o.is_late_delivery) AS late_orders,
    ROUND((SUM(o.is_late_delivery) / COUNT(o.order_id)) * 100, 2) AS late_delivery_rate_pct
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY late_delivery_rate_pct DESC
```

### Results
| state   |   total_orders |   late_orders |   late_delivery_rate_pct |
|:--------|---------------:|--------------:|-------------------------:|
| AL      |            397 |            95 |                    23.93 |
| MA      |            717 |           141 |                    19.67 |
| PI      |            476 |            76 |                    15.97 |
| CE      |           1279 |           196 |                    15.32 |
| SE      |            335 |            51 |                    15.22 |
| BA      |           3256 |           457 |                    14.04 |
| RJ      |          12350 |          1664 |                    13.47 |
| TO      |            274 |            35 |                    12.77 |
| PA      |            946 |           117 |                    12.37 |
| ES      |           1995 |           244 |                    12.23 |
| RR      |             41 |             5 |                    12.2  |
| MS      |            701 |            81 |                    11.55 |
| PB      |            517 |            57 |                    11.03 |
| PE      |           1593 |           172 |                    10.8  |
| RN      |            474 |            51 |                    10.76 |
| SC      |           3546 |           346 |                     9.76 |
| GO      |           1957 |           160 |                     8.18 |
| RS      |           5345 |           382 |                     7.15 |
| DF      |           2080 |           147 |                     7.07 |
| MT      |            886 |            60 |                     6.77 |
| SP      |          40501 |          2387 |                     5.89 |
| MG      |          11354 |           637 |                     5.61 |
| PR      |           4923 |           246 |                     5    |
| AP      |             67 |             3 |                     4.48 |
| AM      |            145 |             6 |                     4.14 |
| AC      |             80 |             3 |                     3.75 |
| RO      |            243 |             7 |                     2.88 |

---

## Query 21: 21. Fastest and Slowest Delivery Regions (Top 5 & Bottom 5 Cities) Business Value: Provides local insights to direct regional logistics partnerships.

```sql
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
)
```

### Results
| customer_city       | customer_state   |   orders_count | avg_delivery_days   | delivery_speed   |
|:--------------------|:-----------------|---------------:|:--------------------|:-----------------|
| aruja               | SP               |             68 |                     | FASTEST          |
| poa                 | SP               |             85 |                     | FASTEST          |
| taboao da serra     | SP               |            284 |                     | FASTEST          |
| cotia               | SP               |            242 |                     | FASTEST          |
| santana de parnaiba | SP               |            178 |                     | FASTEST          |
| macapa              | AP               |             53 |                     | SLOWEST          |
| manaus              | AM               |            137 |                     | SLOWEST          |
| maceio              | AL               |            236 |                     | SLOWEST          |
| ananindeua          | PA               |             85 |                     | SLOWEST          |
| belem               | PA               |            428 |                     | SLOWEST          |

---

## Query 22: 22. Logistics Performance by Seller Business Value: Shows which sellers take too long to ship packages, leading to late orders.

```sql
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
LIMIT 10
```

### Results
| seller_id                        | seller_state   |   total_orders |   avg_seller_dispatch_lag_days |   avg_total_delivery_days |
|:---------------------------------|:---------------|---------------:|-------------------------------:|--------------------------:|
| 54965bbe3e4f07ae045b90b0b8541f52 | PR             |             73 |                           15.7 |                      26.7 |
| 5058e8c1e82653974541e83690655b4a | SP             |             62 |                           15.3 |                      26.4 |
| 6fd52c528dcb38be2eea044946b811f8 | SP             |             67 |                           13.8 |                      21.2 |
| 17f51e7198701186712e53a39c564617 | SP             |             56 |                           11.7 |                      22.8 |
| 7c67e1448b00f6e969d365cea6b010ab | SP             |            973 |                           11.6 |                      22.4 |
| 8444e55c1f13cd5c179851e5ca5ebd00 | MG             |             92 |                           10.9 |                      21.3 |
| 2eb70248d66e0e3ef83659f71b244378 | SP             |            187 |                           10.6 |                      18   |
| a7f13822ceb966b076af67121f87b063 | SP             |             73 |                           10.4 |                      22.2 |
| 88460e8ebdecbfecb5f9601833981930 | PR             |            246 |                            7.9 |                      18.3 |
| 213b25e6f54661939f11710a6fddb871 | SP             |            152 |                            7.3 |                      15.2 |

---

## Query 23: ==================================================================== SECTION 6: REVIEW ANALYSIS ==================================================================== 23. Best and Worst Rated Categories (Min 100 reviews) Business Value: Highlights high-quality categories vs problematic categories with poor scores.

```sql
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
)
```

### Results
| category               |   review_count |   avg_rating | rating_class   |
|:-----------------------|---------------:|-------------:|:---------------|
| Books General Interest |            549 |         4.02 | BEST RATED     |
| Books Technical        |            266 |         4.02 | BEST RATED     |
| Luggage Accessories    |           1088 |         4.02 | BEST RATED     |
| Food Drink             |            279 |         4.02 | BEST RATED     |
| Fashion Shoes          |            261 |         4.02 | BEST RATED     |
| Office Furniture       |           1687 |         4.02 | WORST RATED    |
| Fashion Male Clothing  |            131 |         4.02 | WORST RATED    |
| Fixed Telephony        |            262 |         4.02 | WORST RATED    |
| Audio                  |            361 |         4.02 | WORST RATED    |
| Home Confort           |            435 |         4.02 | WORST RATED    |

---

## Query 24: 24. Impact of Delivery Performance on Review Score Business Value: Quantifies the rating penalty for delayed deliveries, reinforcing delivery SLAs.

```sql
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
ORDER BY average_review_score DESC
```

### Results
| delivery_performance        |   total_orders |   average_review_score |   negative_review_pct |
|:----------------------------|---------------:|-----------------------:|----------------------:|
| Super Fast (0-5 days)       |          13327 |                   4.45 |                  7.14 |
| Normal (5-10 days)          |          32712 |                   4.37 |                  8.11 |
| Slow but On-Time (10+ days) |          42622 |                   4.19 |                 10.76 |
| Late Delivery               |           7700 |                   2.57 |                 54.03 |

---

## Query 25: 25. Seller Review Score Distribution Business Value: Shows how sellers cluster in rating brackets to identify coaching groups.

```sql
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
ORDER BY seller_count DESC
```

### Results
| seller_rating_bracket   |   seller_count |   seller_share_pct |
|:------------------------|---------------:|-------------------:|
| Good (4.0 - 4.5)        |           1010 |              32.63 |
| Elite (4.5 - 5.0)       |            984 |              31.79 |
| Average (3.0 - 4.0)     |            754 |              24.36 |
| Underperforming (< 3.0) |            347 |              11.21 |

---

## Query 26: 26. Review Score Trend by Quarter Business Value: Tracks customer sentiment trends across the platform over time.

```sql
SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-Q') AS year_quarter,
    CONCAT('Q', QUARTER(o.order_purchase_timestamp)) AS quarter_num,
    COUNT(r.review_id) AS review_count,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM order_reviews r
JOIN orders o ON r.order_id = o.order_id
GROUP BY YEAR(o.order_purchase_timestamp), QUARTER(o.order_purchase_timestamp)
ORDER BY YEAR(o.order_purchase_timestamp), QUARTER(o.order_purchase_timestamp)
```

### Results
| year_quarter   | quarter_num   |   review_count |   avg_review_score |
|:---------------|:--------------|---------------:|-------------------:|
| 2016-Q         | Q3            |              4 |               1    |
| 2016-Q         | Q4            |            322 |               3.57 |
| 2017-Q         | Q1            |           5249 |               4.05 |
| 2017-Q         | Q2            |           9347 |               4.12 |
| 2017-Q         | Q3            |          12650 |               4.2  |
| 2017-Q         | Q4            |          17798 |               4    |
| 2018-Q         | Q1            |          21190 |               3.88 |
| 2018-Q         | Q2            |          19889 |               4.21 |
| 2018-Q         | Q3            |          12771 |               4.26 |
| 2018-Q         | Q4            |              4 |               2.25 |

---
