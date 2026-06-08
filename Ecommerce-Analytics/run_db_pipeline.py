import os
import re
import pandas as pd
import mysql.connector
from mysql.connector import Error

# Configuration
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '',  # To be filled in from input
    'database': 'ecommerce_analytics'
}

CLEANED_DIR = 'data/cleaned/'
SQL_DIR = 'sql/'
REPORT_FILE = 'reports/business_queries_output.md'

def get_db_connection(with_db=True, password=''):
    config = DB_CONFIG.copy()
    config['password'] = password
    if not with_db:
        config.pop('database', None)
    return mysql.connector.connect(**config)

def execute_sql_file(filename, conn):
    cursor = conn.cursor()
    print(f"Executing SQL file: {filename}...")
    with open(filename, 'r', encoding='utf-8') as f:
        sql_content = f.read()

    # Remove SQL comments
    sql_content = re.sub(r'--.*$', '', sql_content, flags=re.MULTILINE)
    sql_content = re.sub(r'/\*.*?\*/', '', sql_content, flags=re.DOTALL)
    
    # Split queries by semicolon (ensuring we don't split on semicolons inside strings)
    # A simple split by semicolon is usually sufficient if SQL is clean
    queries = sql_content.split(';')
    
    for query in queries:
        query = query.strip()
        if not query:
            continue
        try:
            # Skip USE statement if it might conflict
            cursor.execute(query)
        except Error as err:
            # Ignore duplicate index errors or database already exists warnings
            if "Duplicate key name" in str(err) or "already exists" in str(err):
                continue
            print(f"Warning/Error on query: {query[:100]}...\nError: {err}")
            
    conn.commit()
    cursor.close()
    print(f"Finished executing {filename}.")

def load_table_to_mysql(table_name, csv_filename, columns_map, password):
    filepath = os.path.join(CLEANED_DIR, csv_filename)
    if not os.path.exists(filepath):
        print(f"Error: Cleaned data file not found: {filepath}")
        return
    
    print(f"Loading {csv_filename} into database table '{table_name}'...")
    df = pd.read_csv(filepath)
    
    # Filter only relevant columns defined in schema
    df = df[list(columns_map.keys())].rename(columns=columns_map)
    # Replace NaN values with None for SQL NULL
    df = df.where(pd.notnull(df), None)
    
    conn = get_db_connection(with_db=True, password=password)
    cursor = conn.cursor()
    
    # Temporarily disable foreign key checks for bulk data loading
    cursor.execute("SET FOREIGN_KEY_CHECKS = 0;")
    
    # Generate INSERT statement
    placeholders = ", ".join(["%s"] * len(df.columns))
    cols = ", ".join(df.columns)
    sql = f"INSERT INTO {table_name} ({cols}) VALUES ({placeholders}) ON DUPLICATE KEY UPDATE "
    sql += ", ".join([f"{col}=VALUES({col})" for col in df.columns if col != df.columns[0]])
    
    # Bulk insert in batches of 5000 rows
    data_list = [tuple(x) for x in df.values]
    batch_size = 5000
    
    for i in range(0, len(data_list), batch_size):
        batch = data_list[i:i+batch_size]
        try:
            cursor.executemany(sql, batch)
            conn.commit()
        except Error as err:
            print(f"Batch insert error in {table_name}: {err}")
            conn.rollback()
            break
            
    # Re-enable foreign key checks
    cursor.execute("SET FOREIGN_KEY_CHECKS = 1;")
    conn.commit()
    
    print(f"Successfully loaded {len(df)} rows into {table_name}.")
    cursor.close()
    conn.close()

def run_business_queries_and_report(password):
    print("Executing business queries and generating report...")
    conn = get_db_connection(with_db=True, password=password)
    cursor = conn.cursor()
    
    # Temporarily remove ONLY_FULL_GROUP_BY for the session to run aggregate queries
    try:
        cursor.execute("SET SESSION sql_mode = (SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));")
    except Error as err:
        print(f"Warning: Could not adjust sql_mode: {err}")
    
    with open(os.path.join(SQL_DIR, 'business_queries.sql'), 'r', encoding='utf-8') as f:
        sql_content = f.read()
    
    # Extract comments and query texts using regex
    # Split queries by double-hyphen lines or sections
    raw_queries = sql_content.split(';')
    
    report_lines = [
        "# E-Commerce Analytics - SQL Business Intelligence Report",
        f"Generated on: {pd.Timestamp.now().strftime('%Y-%m-%d %H:%M:%S')}",
        "",
        "This report consolidates the results of the key analytical queries run against the `ecommerce_analytics` database.",
        "",
        "---",
        ""
    ]
    
    query_count = 0
    for idx, raw_q in enumerate(raw_queries):
        raw_q = raw_q.strip()
        if not raw_q:
            continue
            
        # Parse description and SQL query
        lines = raw_q.splitlines()
        description_lines = []
        sql_lines = []
        
        for line in lines:
            if line.strip().startswith('--'):
                description_lines.append(line.replace('--', '').strip())
            else:
                sql_lines.append(line)
        
        sql_query = "\n".join(sql_lines).strip()
        description = " ".join(description_lines).strip()
        
        if not sql_query or "USE " in sql_query:
            continue
            
        # Run the query
        query_count += 1
        title = f"Query {query_count}: " + (description if description else f"Analytical Query {query_count}")
        print(f"Running {title}...")
        
        report_lines.append(f"## {title}")
        report_lines.append("")
        report_lines.append("```sql")
        report_lines.append(sql_query)
        report_lines.append("```")
        report_lines.append("")
        
        # Quote reserved keyword 'year_month' for MySQL syntax compatibility
        sql_query_escaped = re.sub(r'\byear_month\b', '`year_month`', sql_query)
        
        try:
            cursor.execute(sql_query_escaped)
            # Fetch results
            headers = [col[0] for col in cursor.description]
            rows = cursor.fetchall()
            
            if rows:
                df_res = pd.DataFrame(rows, columns=headers)
                # Format markdown table
                markdown_table = df_res.to_markdown(index=False)
                report_lines.append("### Results")
                report_lines.append(markdown_table)
            else:
                report_lines.append("*Query completed successfully with no rows returned.*")
        except Error as err:
            report_lines.append(f"**Error executing query:** {err}")
            print(f"Error running query {query_count}: {err}")
            
        report_lines.append("")
        report_lines.append("---")
        report_lines.append("")
        
    cursor.close()
    conn.close()
    
    # Save the report
    os.makedirs(os.path.dirname(REPORT_FILE), exist_ok=True)
    with open(REPORT_FILE, 'w', encoding='utf-8') as f:
        f.write("\n".join(report_lines))
    print(f"Successfully generated database queries report at: {REPORT_FILE}")

def main():
    password = input("Enter MySQL root password: ").strip()
    
    # Test connection
    try:
        conn = get_db_connection(with_db=False, password=password)
        conn.close()
        print("Connected to MySQL server successfully!")
    except Error as err:
        print(f"Connection failed: {err}")
        return
    
    # 1. Create database and schema
    try:
        conn = get_db_connection(with_db=False, password=password)
        execute_sql_file(os.path.join(SQL_DIR, 'schema.sql'), conn)
        conn.close()
    except Error as err:
        print(f"Failed to create database schema: {err}")
        return

    # 2. Ingest datasets
    print("Ingesting datasets into MySQL tables...")
    
    # Geolocation
    load_table_to_mysql('geolocation', 'geolocation_cleaned.csv', {
        'geolocation_zip_code_prefix': 'geolocation_zip_code_prefix',
        'geolocation_lat': 'geolocation_lat',
        'geolocation_lng': 'geolocation_lng',
        'geolocation_city': 'geolocation_city',
        'geolocation_state': 'geolocation_state'
    }, password)
    
    # Customers
    load_table_to_mysql('customers', 'customers_master.csv', {
        'customer_id': 'customer_id',
        'customer_unique_id': 'customer_unique_id',
        'customer_zip_code_prefix': 'customer_zip_code_prefix',
        'customer_city': 'customer_city',
        'customer_state': 'customer_state',
        'recency': 'recency',
        'frequency': 'frequency',
        'monetary': 'monetary',
        'is_repeat_buyer': 'is_repeat_buyer',
        'clv': 'clv',
        'R_score': 'R_score',
        'F_score': 'F_score',
        'M_score': 'M_score',
        'customer_segment': 'customer_segment'
    }, password)
    
    # Sellers
    load_table_to_mysql('sellers', 'sellers_master.csv', {
        'seller_id': 'seller_id',
        'seller_zip_code_prefix': 'seller_zip_code_prefix',
        'seller_city': 'seller_city',
        'seller_state': 'seller_state',
        'seller_revenue': 'seller_revenue',
        'seller_avg_rating': 'seller_avg_rating',
        'seller_order_count': 'seller_order_count'
    }, password)
    
    # Products
    load_table_to_mysql('products', 'products_cleaned.csv', {
        'product_id': 'product_id',
        'product_category_name': 'product_category_name',
        'product_name_lenght': 'product_name_lenght',
        'product_description_lenght': 'product_description_lenght',
        'product_photos_qty': 'product_photos_qty',
        'product_weight_g': 'product_weight_g',
        'product_length_cm': 'product_length_cm',
        'product_height_cm': 'product_height_cm',
        'product_width_cm': 'product_width_cm',
        'product_category_name_english': 'product_category_name_english'
    }, password)
    
    # Orders
    load_table_to_mysql('orders', 'orders_master.csv', {
        'order_id': 'order_id',
        'customer_id': 'customer_id',
        'order_status': 'order_status',
        'order_purchase_timestamp': 'order_purchase_timestamp',
        'order_approved_at': 'order_approved_at',
        'order_delivered_carrier_date': 'order_delivered_carrier_date',
        'order_delivered_customer_date': 'order_delivered_customer_date',
        'order_estimated_delivery_date': 'order_estimated_delivery_date',
        'delivery_time_days': 'delivery_time_days',
        'shipping_duration_days': 'shipping_duration_days',
        'estimated_vs_actual_days': 'estimated_vs_actual_days',
        'is_late_delivery': 'is_late_delivery',
        'order_price': 'order_price',
        'order_freight': 'order_freight',
        'order_price_capped': 'order_price_capped',
        'order_freight_capped': 'order_freight_capped',
        'order_item_count': 'order_item_count',
        'order_total_value': 'order_total_value',
        'order_total_value_capped': 'order_total_value_capped'
    }, password)
    
    # Order Items
    load_table_to_mysql('order_items', 'order_items_cleaned.csv', {
        'order_id': 'order_id',
        'order_item_id': 'order_item_id',
        'product_id': 'product_id',
        'seller_id': 'seller_id',
        'shipping_limit_date': 'shipping_limit_date',
        'price': 'price',
        'freight_value': 'freight_value',
        'price_capped': 'price_capped',
        'freight_capped': 'freight_capped'
    }, password)
    
    # Order Payments
    load_table_to_mysql('order_payments', 'order_payments_cleaned.csv', {
        'order_id': 'order_id',
        'payment_sequential': 'payment_sequential',
        'payment_type': 'payment_type',
        'payment_installments': 'payment_installments',
        'payment_value': 'payment_value'
    }, password)
    
    # Order Reviews
    load_table_to_mysql('order_reviews', 'order_reviews_cleaned.csv', {
        'review_id': 'review_id',
        'order_id': 'order_id',
        'review_score': 'review_score',
        'review_comment_title': 'review_comment_title',
        'review_comment_message': 'review_comment_message',
        'review_creation_date': 'review_creation_date',
        'review_answer_timestamp': 'review_answer_timestamp'
    }, password)

    # 3. Create views
    try:
        conn = get_db_connection(with_db=True, password=password)
        execute_sql_file(os.path.join(SQL_DIR, 'views.sql'), conn)
        conn.close()
    except Error as err:
        print(f"Failed to create views: {err}")
        return

    # 4. Run business queries and generate report
    try:
        run_business_queries_and_report(password)
        print("Database pipeline completed successfully!")
    except Error as err:
        print(f"Failed during queries execution: {err}")

if __name__ == '__main__':
    main()
