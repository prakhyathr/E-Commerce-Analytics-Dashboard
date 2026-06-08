-- E-Commerce Sales & Customer Analytics Data Ingestion Script
-- This file provides two methods for loading the cleaned data:
-- METHOD A: Standard SQL LOAD DATA INFILE commands (Requires MySQL Server file privileges)
-- METHOD B: Python Bulk Ingestion Script (Easiest to run locally without security configurations)

USE ecommerce_analytics;

-- ====================================================================
-- METHOD A: SQL LOAD DATA INFILE
-- ====================================================================
-- Ensure that secure_file_priv is configured and local_infile is enabled.

/*
-- 1. Load Geolocation
LOAD DATA LOCAL INFILE '../data/cleaned/geolocation_cleaned.csv'
INTO TABLE geolocation
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state);

-- 2. Load Customers
LOAD DATA LOCAL INFILE '../data/cleaned/customers_master.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- 3. Load Sellers
LOAD DATA LOCAL INFILE '../data/cleaned/sellers_master.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- 4. Load Products
LOAD DATA LOCAL INFILE '../data/cleaned/products_cleaned.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- 5. Load Orders
LOAD DATA LOCAL INFILE '../data/cleaned/orders_master.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- 6. Load Order Items
LOAD DATA LOCAL INFILE '../data/cleaned/order_items_cleaned.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- 7. Load Order Payments
LOAD DATA LOCAL INFILE '../data/cleaned/order_payments_cleaned.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- 8. Load Order Reviews
LOAD DATA LOCAL INFILE '../data/cleaned/order_reviews_cleaned.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
*/


-- ====================================================================
-- METHOD B: PYTHON BULK INGESTION UTILITY
-- Save the code below as 'db_loader.py' and execute it: python db_loader.py
-- ====================================================================

/*
import os
import pandas as pd
import mysql.connector

# Database Connection Details
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'your_password_here',
    'database': 'ecommerce_analytics'
}

CLEANED_DIR = '../data/cleaned/'

def get_db_connection():
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except mysql.connector.Error as err:
        print(f"Error connecting: {err}")
        return None

def load_table_to_mysql(table_name, csv_filename, columns_map):
    filepath = os.path.join(CLEANED_DIR, csv_filename)
    if not os.path.exists(filepath):
        print(f"File not found: {filepath}")
        return
    
    print(f"Ingesting {csv_filename} into {table_name} table...")
    df = pd.read_csv(filepath)
    
    # Filter only relevant columns defined in schema
    df = df[list(columns_map.keys())].rename(columns=columns_map)
    # Replace NaN values with None for SQL NULL
    df = df.where(pd.notnull(df), None)
    
    conn = get_db_connection()
    if not conn:
        return
        
    cursor = conn.cursor()
    
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
        except mysql.connector.Error as err:
            print(f"Batch insert error: {err}")
            conn.rollback()
            break
            
    print(f"Successfully loaded {len(df)} rows into {table_name}.")
    cursor.close()
    conn.close()

if __name__ == '__main__':
    # 1. Geolocation
    load_table_to_mysql('geolocation', 'geolocation_cleaned.csv', {
        'geolocation_zip_code_prefix': 'geolocation_zip_code_prefix',
        'geolocation_lat': 'geolocation_lat',
        'geolocation_lng': 'geolocation_lng',
        'geolocation_city': 'geolocation_city',
        'geolocation_state': 'geolocation_state'
    })
    
    # 2. Customers
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
    })
    
    # 3. Sellers
    load_table_to_mysql('sellers', 'sellers_master.csv', {
        'seller_id': 'seller_id',
        'seller_zip_code_prefix': 'seller_zip_code_prefix',
        'seller_city': 'seller_city',
        'seller_state': 'seller_state',
        'seller_revenue': 'seller_revenue',
        'seller_avg_rating': 'seller_avg_rating',
        'seller_order_count': 'seller_order_count'
    })
    
    # 4. Products
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
    })
    
    # 5. Orders
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
    })
    
    # 6. Order Items
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
    })
    
    # 7. Order Payments
    load_table_to_mysql('order_payments', 'order_payments_cleaned.csv', {
        'order_id': 'order_id',
        'payment_sequential': 'payment_sequential',
        'payment_type': 'payment_type',
        'payment_installments': 'payment_installments',
        'payment_value': 'payment_value'
    })
    
    # 8. Order Reviews
    load_table_to_mysql('order_reviews', 'order_reviews_cleaned.csv', {
        'review_id': 'review_id',
        'order_id': 'order_id',
        'review_score': 'review_score',
        'review_comment_title': 'review_comment_title',
        'review_comment_message': 'review_comment_message',
        'review_creation_date': 'review_creation_date',
        'review_answer_timestamp': 'review_answer_timestamp'
    })
*/
