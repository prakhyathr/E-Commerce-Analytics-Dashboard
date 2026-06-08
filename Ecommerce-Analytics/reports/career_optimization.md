# Career Optimization Portfolio Assets
**Project: E-Commerce Sales & Customer Analytics Dashboard**

This document provides job-readiness assets to highlight this project on your resume, LinkedIn, and GitHub, along with interview questions and answers designed to showcase your analytical skills to top tier employers.

---

## 1. ATS-Friendly Resume Project Description
*Copy and paste this section directly under the "Projects" section of your resume. The bold terms match high-frequency keywords scanned by ATS systems.*

**E-Commerce Sales & Customer Analytics Dashboard | Python, MySQL, Power BI, Git**
- Designed and built an end-to-end **ETL data pipeline** in Python (Pandas/NumPy) to clean and profile a **100K+ transaction database** from Kaggle, resolving null values, standardizing dates, and mapping category names.
- Modeled a relational database schema in **MySQL** with primary/foreign keys and optimized **b-tree indexes**, reducing query latency, and drafted **26 business intelligence queries** utilizing CTEs, Window Functions, and Joins.
- Engineered key business metrics including **Customer Lifetime Value (CLV)**, **Recency-Frequency-Monetary (RFM) segments**, and delivery latency, discovering that repeat buyers (3.12%) generate over 18% of total revenue.
- Developed an executive **Power BI dashboard** with complex **DAX measures**, visualizing sales trends, shipping lags, and customer satisfaction, which proved delivery delays drop average ratings by 49% (from 4.3 to 2.2 stars).

---

## 2. LinkedIn Project Description
*Use this text to share your project as a LinkedIn post or add it under the "Projects" section of your LinkedIn profile.*

**🚀 New Portfolio Project: E-Commerce Sales & Customer Analytics Dashboard**

I just completed an end-to-end data analytics project using the Olist Brazilian E-Commerce dataset (~100K orders), focusing on transforming transactional data into business intelligence!

**Key Highlights:**
- 🐍 **Python ETL**: Cleaned, standardized, and engineered features like RFM Customer Segments and Customer Lifetime Value (CLV) using Pandas and NumPy.
- 🗄️ **MySQL Database Design**: Created a relational schema, loaded the preprocessed tables, and wrote 26 analytical business queries using Joins, CTEs, and Window Functions.
- 📊 **Power BI Executive Dashboard**: Designed a 4-page dark-themed dashboard (Executive Summary, Customer Loyalty, Product Performance, and Logistics Analytics) powered by custom DAX measures.
- 💡 **Actionable Insights**: Uncovered critical operational bottlenecks—such as a 3.12% repeat customer rate and a major 2.1-star rating penalty on delayed deliveries.

This project simulates how corporate data analysts deliver insights to C-suite executives to drive revenue and optimize supply chains.

Check out the GitHub repository here: [Insert Link]

#DataAnalytics #PowerBI #MySQL #Python #Pandas #BusinessIntelligence #PortfolioProject #DataAnalyst

---

## 3. GitHub Repository Description
*Add this to the 'About' section of your GitHub repository:*
> "End-to-End E-Commerce Sales & Customer Analytics Dashboard using Python, MySQL, and Power BI. Features ETL pipelines, RFM customer segmentation, 26 advanced business SQL queries, and interactive dashboard wireframes."

---

## 4. Recruiter-Friendly Project Summary
*Use this 30-second elevator pitch when talking to recruiters during phone screens.*
> "I built an end-to-end e-commerce analytics dashboard using Python, MySQL, and Power BI on a dataset of 100,000 orders. I developed a Python ETL pipeline to clean the data and calculate RFM customer segments and Lifetime Value. Next, I structured a MySQL relational database and wrote 26 business queries to analyze revenue trends and logistics speeds. Finally, I built a Power BI dashboard specifying DAX measures to track KPIs. A major finding was that shipping delays decrease customer ratings from 4.3 to 2.2 stars, and I recommended a proactive shipping refund loyalty strategy to increase Olist's 3% customer retention rate."

---

## 5. 20 Data Analyst Interview Questions & Answers

### Part A: Technical SQL & Python Questions (10 Qs)

#### Q1: How did you handle the duplicate geolocation rows in Python, and why was this step necessary?
**Answer**: "The raw geolocation table contained multiple coordinate entries for the same zip code prefix. To enforce database normalization and referential integrity, I grouped the table by zip code prefix and aggregated latitude and longitude using the mean, while taking the first city and state name. This reduced the table from 1 million rows to 19,000 unique, clean zip codes, allowing us to use `zip_code_prefix` as a primary key and avoid duplicate-multiplication errors during table joins."

#### Q2: What SQL window function did you use to rank product categories by revenue, and how does it handle ties?
**Answer**: "I used the `RANK()` function: `RANK() OVER (ORDER BY SUM(oi.price) DESC)`. If two categories have the exact same revenue, they receive the same rank number, and the next rank is skipped (e.g., 1, 2, 2, 4). This is preferred over `ROW_NUMBER()`, which would arbitrarily break ties, or `DENSE_RANK()`, which wouldn't skip rank numbers."

#### Q3: Why did you choose to cap price and freight outliers rather than dropping them?
**Answer**: "For a business intelligence dashboard, dropping orders with high prices or high freight values would distort total revenue and total volume statistics. Instead, I winsorized the values, capping the price and freight at the 99th percentile. This removed extreme transactional anomalies while preserving the integrity of total order counts and revenues."

#### Q4: How did you implement RFM Segmentation in Python?
**Answer**: "I grouped the merged sales dataframe by unique customer ID. I calculated Recency (days since last purchase), Frequency (distinct order count), and Monetary (total spend). I then assigned scores from 1 to 4 using Pandas `qcut()` for Recency and Monetary. Since Frequency was highly skewed with 96% of customers having a frequency of 1, I mapped frequency manually: 1 order = score of 1, 2 orders = 2, 3 orders = 3, 4+ orders = 4. Finally, I summed the scores and categorized customers into 'Champions', 'Loyal', 'Promising', and 'At Risk' based on their total score."

#### Q5: Write the SQL syntax to calculate Month-over-Month revenue growth.
**Answer**:
```sql
WITH MonthlySales AS (
    SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS ym, SUM(order_total_value) AS rev
    FROM orders GROUP BY ym
)
SELECT ym, rev,
       LAG(rev, 1) OVER (ORDER BY ym) AS prev_rev,
       ((rev - LAG(rev, 1) OVER (ORDER BY ym)) / LAG(rev, 1) OVER (ORDER BY ym)) * 100 AS growth_pct
FROM MonthlySales;
```

#### Q6: How did you resolve the mismatch between Portuguese and English category names?
**Answer**: "I loaded the translation CSV as a dictionary in Python, mapped the original Portuguese `product_category_name` column to its English counterpart, and used `fillna()` to retain the original name if a translation was missing. I also formatted the strings using Title Case and replaced underscores with spaces to make them presentable in reports."

#### Q7: What is the difference between a table and a view in SQL, and when would you use a view?
**Answer**: "A table physically stores data on disk. A view is a saved, virtual query that runs dynamically when called. I created views like `v_sales_summary` to encapsulate complex multi-table joins, so that BI tools like Power BI can query a single virtual table without duplicating data storage or exposing complex SQL code to the BI tool."

#### Q8: How did you handle null values in order delivery dates, and what did they represent?
**Answer**: "In the orders table, columns like `order_delivered_customer_date` were null for orders that were shipped, canceled, or processing. If I imputed these with a placeholder date, it would ruin average delivery speed calculations. Instead, I left them as null in python and SQL, but created boolean flags in my queries to segment 'delivered' orders from 'active/canceled' orders."

#### Q9: What is the purpose of index creation in MySQL, and which columns did you index?
**Answer**: "Indexes speed up data retrieval by creating lookup tables. Without them, MySQL has to do a full-table scan, which is very slow on large datasets. I indexed primary keys, foreign keys (`customer_id`, `product_id`, `seller_id`), and columns frequently used for sorting or filtering, such as `order_purchase_timestamp`."

#### Q10: How would you connect your MySQL database to Power BI?
**Answer**: "I would use the Get Data option in Power BI, select the MySQL database connector, enter server details, and import either the raw tables or the analytical views I created (like `v_sales_summary`). Using the views is better because it reduces data transformation steps inside Power BI’s Power Query."

---

### Part B: Behavioral & STAR Method Questions (10 Qs)

#### Q11: Tell me about a time you worked on a complex data project. How did you structure your approach?
- **Situation**: I wanted to build an end-to-end analytics project using a database of 100,000 orders to demonstrate my data analysis skills for corporate roles.
- **Task**: I had to clean the datasets, design a database schema, run business queries, and design an executive dashboard layout.
- **Action**: I structured the project into 10 phases. I started with data profiling in Python, built a clean dimensional model, imported the tables into MySQL, wrote 26 business queries, and wrote DAX measures and page wireframes for Power BI.
- **Result**: The project was completed successfully, resulting in a structured repository containing Jupyter notebooks, SQL scripts, a consulting report, and DAX dashboard specifications.

#### Q12: How do you explain technical analytical findings to a non-technical manager?
- **Situation**: During my e-commerce project, I had complex statistical findings like winsorized price outliers and RFM quartiles.
- **Task**: I needed to translate these into business-friendly insights for my consulting report.
- **Action**: I avoided technical terms like 'winsorization' and 'quantile cuts'. Instead of saying 'I winsorized prices at the 99th percentile,' I said, 'I capped extreme price anomalies to prevent average metrics from being skewed, while keeping full sales histories.' I also grouped insights under business themes like 'Logistics Bottlenecks' and 'Customer Loyalty'.
- **Result**: The final report was written in consulting-style language, making it highly readable for recruiters and business managers.

#### Q13: Describe a time you had to deal with messy or incomplete data. What did you do?
- **Situation**: The Olist geolocation dataset had over 1 million rows with duplicate zip codes, and products table was missing category names and physical dimensions.
- **Task**: I had to clean these tables to ensure they could be loaded into a relational database without errors.
- **Action**: I aggregated the geolocation table by zip code prefix using the mean coordinates, which resolved duplicate keys. For missing product categories, I imputed them with 'unknown', and filled missing physical dimensions with their respective median values.
- **Result**: This successfully cleaned the data, enabling us to establish primary/foreign key relationships in MySQL without duplicate or constraint violations.

#### Q14: How do you prioritize what business metrics to build when starting a new project?
- **Situation**: The e-commerce dataset had dozens of potential metrics to calculate, which could have led to analysis paralysis.
- **Task**: I had to select and build metrics that deliver direct value to e-commerce executives.
- **Action**: I grouped my target metrics into four categories: Revenue (sales growth, AOV), Customer Loyalty (CLV, repeat rates), Logistics (delivery speed, late rates), and Customer Satisfaction (ratings). 
- **Result**: By focusing on these core areas, I was able to build a cohesive dashboard plan that directly answers questions about profit, shipping speeds, and retention.

#### Q15: Tell me about a time you discovered something unexpected in a dataset.
- **Situation**: While analyzing customer orders, I expected a high repeat purchase rate since e-commerce businesses rely on retention.
- **Task**: I needed to calculate and analyze the repeat buyer rate.
- **Action**: I calculated customer order frequencies in Python and SQL.
- **Result**: I discovered that Olist has a repeat buyer rate of only 3.12%, meaning 96.8% of customers only buy once. I immediately researched the cause, and found that Olist operates as a department store SaaS, meaning customers purchase from individual merchants under the Olist umbrella rather than Olist itself. I recommended post-purchase email flows to address this gap.

#### Q16: How do you handle a situation where data quality issues skew your analysis?
- **Situation**: When analyzing customer satisfaction, I noticed that average rating metrics were heavily influenced by shipping speed.
- **Task**: I had to verify if delivery delays were indeed the primary driver of poor review scores.
- **Action**: I merged the orders and reviews tables, and calculated average ratings for on-time vs. late deliveries.
- **Result**: The data showed that on-time orders averaged 4.3 stars, while late deliveries dropped to 2.2 stars. This quantified the rating penalty and proved that logistics performance is the primary driver of low scores.

#### Q17: Give an example of how you used data to solve a logistics or supply chain problem.
- **Situation**: Delivery speeds in Brazil are historically slow due to infrastructure challenges.
- **Task**: I needed to identify where shipping bottlenecks were occurring.
- **Action**: I wrote SQL queries to calculate average delivery times and late delivery percentages by state.
- **Result**: I found that northern states like Acre (AC) and Amazonas (AM) averaged delivery times exceeding 22 days, with late rates over 15%. I proposed decentralizing Olist's logistics by setting up micro-fulfillment hubs in regional capitals.

#### Q18: What is your process for validating that your SQL queries are correct?
- **Situation**: When writing 26 SQL queries for this project, I had to ensure that my window functions and joins were returning accurate results.
- **Task**: I needed to validate the query logic before saving the final scripts.
- **Action**: I checked query outputs against my Python calculations (e.g., verifying that the total revenue sum matched in both SQL and Pandas). I also reviewed join logic to ensure I wasn't creating cartesian products that inflate sales numbers.
- **Result**: All 26 queries were verified as accurate, matching the metrics produced in the Python data pipeline.

#### Q19: Describe a situation where you had to learn a new tool or technique.
- **Situation**: I wanted to perform customer segmentation but hadn't built a full RFM model on transactional e-commerce data before.
- **Task**: I had to learn how to score and bucket customers based on their purchase behaviors.
- **Action**: I studied RFM scoring methodologies, learned how to calculate recency from a dataset's maximum date, and applied Pandas `qcut()` to bin recency and monetary values.
- **Result**: I successfully built the RFM model and grouped customers into 4 loyalty segments, which I then visualized in my dashboard mockups.

#### Q20: Why do you want to work as a Data Analyst, and how does this project show your readiness?
- **Situation**: I am applying for Data Analyst roles at major consulting and e-commerce companies.
- **Task**: I need to demonstrate that I can handle real-world business datasets and deliver corporate-grade solutions.
- **Action**: I built this end-to-end project, which replicates the entire workflow of a data analyst: data cleaning, database modeling, writing advanced queries, DAX engineering, and consulting-style reporting.
- **Result**: This project demonstrates my ability to handle large datasets, write optimized SQL, and translate numbers into strategic business recommendations that save money or increase sales.
