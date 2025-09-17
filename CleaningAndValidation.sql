show databases;
use brazilian_e_commerce;
show tables;

select 'customers' as table_name, count(*) as row_count from brazilian_e_commerce.customers
union all
select 'name_translation', count(*) from brazilian_e_commerce.names
union all
select 'order_items', count(*) from brazilian_e_commerce.items
union all
select 'orders', count(*) from brazilian_e_commerce.orders
union all
select 'payments', count(*) from brazilian_e_commerce.payments
union all
select 'products', count(*) from brazilian_e_commerce.products
union all
select 'reviews', count(*) from brazilian_e_commerce.reviews
union all
select 'sellers', count(*) from brazilian_e_commerce.sellers
union all
select 'geolocations', count(*) from brazilian_e_commerce.geolocations;


-- 'customers' Table
-- ================================================
-- CHECK FOR MISSING DATA
-- This query shows which columns in the 'customers' table have missing (NULL) values
-- ================================================
select 
    sum(case when customer_id is null then 1 else 0 end) as null_customer_id,
    sum(case when customer_unique_id is null then 1 else 0 end) as null_customer_unique_id,
    sum(case when customer_zip_code is null then 1 else 0 end) as null_zip_code,
    sum(case when customer_city is null then 1 else 0 end) as null_city,
    sum(case when customer_state is null then 1 else 0 end) as null_state
from customers;


-- ================================================
-- REMOVE EXACT DUPLICATES
-- Using row_number() to assign a temporary number to duplicate rows and keeping only the first
-- ================================================
drop table if exists customers_dedup;

create table customers_temp as
select *
from (
    select *,
           row_number() over (
               partition by customer_id,
                        customer_unique_id,
                        customer_zip_code,
                        customer_city,
                        customer_state
               order by customer_id
           ) as rn
    from customers
) t
where rn = 1;

-- Replace the original table with the deduplicated table
drop table customers;
rename table customers_temp to customers;


-- ================================================
-- STANDARDIZE customer_state
-- Make all state codes uppercase and remove invalid values
-- ================================================
update customers
set customer_state = upper(trim(customer_state));

delete from customers
where customer_state is null
  or length(customer_state) not between 2 and 5;


-- ================================================
-- CLEAN customer_city
-- Trim spaces and capitalize the first letter
-- ================================================
update customers
set customer_city = trim(customer_city)
where customer_city is not null;

update customers
set customer_city = concat(upper(left(customer_city,1)), lower(substring(customer_city,2)))
where customer_city <> '';


-- ================================================
-- VALIDATE customer_zip_code
-- Remove invalid zip codes and pad short codes to 8 characters
-- ================================================
delete from customers
where customer_zip_code is null
  or customer_zip_code not regexp '^[0-9\\-]+$';

update customers
set customer_zip_code = lpad(customer_zip_code, 8, '0')
where length(customer_zip_code) < 8;


-- 'geolocations' Table 
-- ================================================
-- CHECK FOR MISSING DATA
-- This query shows which columns in the 'geolocations' table have missing (NULL) values
-- ================================================
select 
    sum(case when geolocation_zip_code_prefix is null then 1 else 0 end) as null_zip_code_prefix,
    sum(case when geolocation_lat is null then 1 else 0 end) as null_lat,
    sum(case when geolocation_lng is null then 1 else 0 end) as null_lng,
    sum(case when geolocation_city is null then 1 else 0 end) as null_city,
    sum(case when geolocation_state is null then 1 else 0 end) as null_state
from geolocations;


-- ================================================
-- REMOVE EXACT DUPLICATES
-- Using row_number() to assign a temporary number to duplicate rows and keeping only the first
-- ================================================
drop table if exists geolocations_dedup;

create table geolocations_dedup as
select *
from (
    select *,
           row_number() over (
               partition by geolocation_zip_code_prefix,
                        geolocation_lat,
                        geolocation_lng,
                        geolocation_city,
                        geolocation_state
               order by geolocation_zip_code_prefix
           ) as rn
    from geolocations
) t
where rn = 1;

-- Replace the original table with the deduplicated table
drop table geolocations;
rename table geolocations_dedup to geolocations;


-- ================================================
-- STANDARDIZE geolocation_state
-- Make all state codes uppercase and remove invalid values
-- ================================================
update geolocations
set geolocation_state = upper(trim(geolocation_state));

delete from geolocations
where geolocation_state is null
  or length(geolocation_state) not between 2 and 5;


-- ================================================
-- CLEAN geolocation_city
-- Trim spaces and capitalize the first letter
-- ================================================
update geolocations
set geolocation_city = trim(geolocation_city)
where geolocation_city is not null;

update geolocations
set geolocation_city = concat(upper(left(geolocation_city,1)), lower(substring(geolocation_city,2)))
where geolocation_city <> '';


-- ================================================
-- VALIDATE geolocation_zip_code_prefix
-- Remove invalid zip codes (non-numeric) and pad short codes to 8 characters
-- ================================================
delete from geolocations
where geolocation_zip_code_prefix is null
  or geolocation_zip_code_prefix not regexp '^[0-9]+$';

update geolocations
set geolocation_zip_code_prefix = lpad(geolocation_zip_code_prefix, 8, '0')
where length(geolocation_zip_code_prefix) < 8;


-- ================================================
-- VALIDATE latitude and longitude
-- Ensure latitude and longitude are within valid ranges
-- ================================================
delete from geolocations
where geolocation_lat not between -90 and 90
   or geolocation_lng not between -180 and 180;
   

-- 'Items' Table
-- ================================================
-- CHECK FOR MISSING DATA
-- This query shows which columns in the 'order_items' table have missing (NULL) values
-- ================================================
select 
    sum(case when order_id is null then 1 else 0 end) as null_order_id,
    sum(case when order_item_id is null then 1 else 0 end) as null_order_item_id,
    sum(case when product_id is null then 1 else 0 end) as null_product_id,
    sum(case when seller_id is null then 1 else 0 end) as null_seller_id,
    sum(case when shipping_limit_date is null then 1 else 0 end) as null_shipping_limit_date,
    sum(case when price is null then 1 else 0 end) as null_price,
    sum(case when freight_value is null then 1 else 0 end) as null_freight_value
from order_items;


-- ================================================
-- REMOVE EXACT DUPLICATES
-- Using row_number() to assign a temporary number to duplicate rows and keeping only the first
-- ================================================
drop table if exists order_items_dedup;

create table order_items_dedup as
select *
from (
    select *,
           row_number() over (
               partition by order_id,
                        order_item_id,
                        product_id,
                        seller_id,
                        shipping_limit_date,
                        price,
                        freight_value
               order by order_id
           ) as rn
    from order_items
) t
where rn = 1;

-- Replace the original table with the deduplicated table
drop table order_items;
rename table order_items_dedup to order_items;


-- ================================================
-- VALIDATE NUMERIC FIELDS
-- Ensure price and freight_value are non-negative
-- ================================================
delete from order_items
where price < 0
   or freight_value < 0;


-- ================================================
-- VALIDATE DATES
-- Ensure shipping_limit_date is valid (not null, reasonable range)
-- ================================================
delete from order_items
where shipping_limit_date is null
   or shipping_limit_date < '2000-01-01'  -- adjust based on dataset
   or shipping_limit_date > curdate() + interval 2 year;  -- future cutoff



-- 'names' Table
-- ================================================
-- CHECK FOR MISSING DATA
-- This query shows which columns have missing (NULL) values
-- ================================================
select 
    sum(case when product_category_name is null then 1 else 0 end) as null_category_name,
    sum(case when product_category_name_english is null then 1 else 0 end) as null_category_name_english
from product_category_name;


-- ================================================
-- REMOVE EXACT DUPLICATES
-- Using row_number() to assign a temporary number to duplicate rows and keeping only the first
-- ================================================
drop table if exists product_category_dedup;

create table product_category_dedup as
select *
from (
    select *,
           row_number() over (
               partition by product_category_name,
                        product_category_name_english
               order by product_category_name
           ) as rn
    from product_category_name
) t
where rn = 1;

-- Replace the original table with the deduplicated table
drop table product_category_name;
rename table product_category_dedup to product_category_name;


-- ================================================
-- CLEAN TEXT COLUMNS
-- Trim spaces and standardize capitalization
-- ================================================
update product_category_name
set product_category_name = trim(product_category_name)
where product_category_name is not null;

update product_category_name
set product_category_name_english = trim(product_category_name_english)
where product_category_name_english is not null;

-- Optional: capitalize first letter of each word in English column
update product_category_name
set product_category_name_english = concat(upper(left(product_category_name_english,1)), lower(substring(product_category_name_english,2)))
where product_category_name_english <> '';


-- 'orders' Table
-- ================================================
-- CHECK FOR MISSING DATA
-- This query shows which columns have missing (NULL) values
-- ================================================
select 
    sum(case when order_id is null then 1 else 0 end) as null_order_id,
    sum(case when customer_id is null then 1 else 0 end) as null_customer_id,
    sum(case when order_status is null then 1 else 0 end) as null_order_status,
    sum(case when order_purchase_timestamp is null then 1 else 0 end) as null_purchase_timestamp,
    sum(case when order_approved_at is null then 1 else 0 end) as null_approved_at,
    sum(case when order_delivered_carrier_date is null then 1 else 0 end) as null_delivered_carrier_date,
    sum(case when order_delivered_customer_date is null then 1 else 0 end) as null_delivered_customer_date,
    sum(case when order_estimated_delivery_date is null then 1 else 0 end) as null_estimated_delivery_date
from orders;


-- ================================================
-- REMOVE EXACT DUPLICATES
-- Using row_number() to assign a temporary number to duplicate rows and keeping only the first
-- ================================================
drop table if exists orders_dedup;

create table orders_dedup as
select *
from (
    select *,
           row_number() over (
               partition by order_id,
                        customer_id,
                        order_status,
                        order_purchase_timestamp,
                        order_approved_at,
                        order_delivered_carrier_date,
                        order_delivered_customer_date,
                        order_estimated_delivery_date
               order by order_id
           ) as rn
    from orders
) t
where rn = 1;

-- Replace the original table with the deduplicated table
drop table orders;
rename table orders_dedup to orders;


-- ================================================
-- CLEAN order_status
-- Trim spaces and standardize to uppercase
-- ================================================
update orders
set order_status = upper(trim(order_status))
where order_status is not null;


-- ================================================
-- VALIDATE DATES
-- Ensure all dates are reasonable and consistent
-- ================================================
-- remove orders with purchase date missing or unrealistic
delete from orders
where order_purchase_timestamp is null
   or order_purchase_timestamp < '2000-01-01'
   or order_purchase_timestamp > curdate() + interval 1 year;

-- remove orders where approved date is before purchase date
delete from orders
where order_approved_at is not null
  and order_approved_at < order_purchase_timestamp;

-- remove orders where delivered dates are before purchase or approved date
delete from orders
where (order_delivered_carrier_date is not null and order_delivered_carrier_date < order_purchase_timestamp)
   or (order_delivered_customer_date is not null and order_delivered_customer_date < order_purchase_timestamp)
   or (order_delivered_customer_date is not null and order_approved_at is not null and order_delivered_customer_date < order_approved_at);

-- remove orders where estimated delivery is before purchase
delete from orders
where order_estimated_delivery_date is not null
  and order_estimated_delivery_date < order_purchase_timestamp;
  


-- 'payments' Table
-- ================================================
-- CHECK FOR MISSING DATA
-- This query shows which columns have missing (NULL) values
-- ================================================
select 
    sum(case when order_id is null then 1 else 0 end) as null_order_id,
    sum(case when payment_sequential is null then 1 else 0 end) as null_payment_sequential,
    sum(case when payment_type is null then 1 else 0 end) as null_payment_type,
    sum(case when payment_installments is null then 1 else 0 end) as null_payment_installments,
    sum(case when payment_value is null then 1 else 0 end) as null_payment_value
from order_payments;


-- ================================================
-- REMOVE EXACT DUPLICATES
-- Using row_number() to assign a temporary number to duplicate rows and keeping only the first
-- ================================================
drop table if exists order_payments_dedup;

create table order_payments_dedup as
select *
from (
    select *,
           row_number() over (
               partition by order_id,
                        payment_sequential,
                        payment_type,
                        payment_installments,
                        payment_value
               order by order_id
           ) as rn
    from order_payments
) t
where rn = 1;

-- Replace the original table with the deduplicated table
drop table order_payments;
rename table order_payments_dedup to order_payments;


-- ================================================
-- CLEAN payment_type
-- Trim spaces and standardize to uppercase
-- ================================================
update order_payments
set payment_type = upper(trim(payment_type))
where payment_type is not null;


-- ================================================
-- VALIDATE NUMERIC FIELDS
-- Ensure installments and payment_value are non-negative
-- ================================================
delete from order_payments
where payment_installments < 1
   or payment_value < 0;


-- 'products' Table
-- ================================================
-- CHECK FOR MISSING DATA
-- This query shows which columns have missing (NULL) values
-- ================================================
select 
    sum(case when product_id is null then 1 else 0 end) as null_product_id,
    sum(case when product_category_name is null then 1 else 0 end) as null_category_name,
    sum(case when product_name_lenght is null then 1 else 0 end) as null_name_length,
    sum(case when product_description_lenght is null then 1 else 0 end) as null_description_length,
    sum(case when product_photos_qty is null then 1 else 0 end) as null_photos_qty,
    sum(case when product_weight_g is null then 1 else 0 end) as null_weight_g,
    sum(case when product_length_cm is null then 1 else 0 end) as null_length_cm,
    sum(case when product_height_cm is null then 1 else 0 end) as null_height_cm,
    sum(case when product_width_cm is null then 1 else 0 end) as null_width_cm
from products;


-- ================================================
-- REMOVE EXACT DUPLICATES
-- Using row_number() to assign a temporary number to duplicate rows and keeping only the first
-- ================================================
drop table if exists products_dedup;

create table products_dedup as
select *
from (
    select *,
           row_number() over (
               partition by product_id,
                        product_category_name,
                        product_name_lenght,
                        product_description_lenght,
                        product_photos_qty,
                        product_weight_g,
                        product_length_cm,
                        product_height_cm,
                        product_width_cm
               order by product_id
           ) as rn
    from products
) t
where rn = 1;

-- Replace the original table with the deduplicated table
drop table products;
rename table products_dedup to products;


-- ================================================
-- CLEAN TEXT FIELDS
-- Trim spaces and standardize text
-- ================================================
update products
set product_category_name = trim(product_category_name)
where product_category_name is not null;


-- ================================================
-- VALIDATE NUMERIC FIELDS
-- Ensure integer/numeric fields are non-negative
-- ================================================
delete from products
where product_name_lenght < 0
   or product_description_lenght < 0
   or product_photos_qty < 0
   or product_weight_g < 0
   or product_length_cm < 0
   or product_height_cm < 0
   or product_width_cm < 0;



-- 'rewiews' Table
-- ================================================
-- CHECK FOR MISSING DATA
-- This query shows which columns have missing (NULL) values
-- ================================================
select 
    sum(case when review_id is null then 1 else 0 end) as null_review_id,
    sum(case when order_id is null then 1 else 0 end) as null_order_id,
    sum(case when review_score is null then 1 else 0 end) as null_review_score,
    sum(case when review_comment_title is null then 1 else 0 end) as null_comment_title,
    sum(case when review_comment_message is null then 1 else 0 end) as null_comment_message,
    sum(case when review_creation_date is null then 1 else 0 end) as null_creation_date,
    sum(case when review_answer_timestamp is null then 1 else 0 end) as null_answer_timestamp
from order_reviews;


-- ================================================
-- REMOVE EXACT DUPLICATES
-- Using row_number() to assign a temporary number to duplicate rows and keeping only the first
-- ================================================
drop table if exists order_reviews_dedup;

create table order_reviews_dedup as
select *
from (
    select *,
           row_number() over (
               partition by review_id,
                        order_id,
                        review_score,
                        review_comment_title,
                        review_comment_message,
                        review_creation_date,
                        review_answer_timestamp
               order by review_id
           ) as rn
    from order_reviews
) t
where rn = 1;

-- Replace the original table with the deduplicated table
drop table order_reviews;
rename table order_reviews_dedup to order_reviews;


-- ================================================
-- CLEAN TEXT FIELDS
-- Trim spaces and standardize text columns
-- ================================================
update order_reviews
set review_comment_title = trim(review_comment_title)
where review_comment_title is not null;

update order_reviews
set review_comment_message = trim(review_comment_message)
where review_comment_message is not null;


-- ================================================
-- VALIDATE review_score
-- Ensure review_score is within a valid range (assuming 1-5)
-- ================================================
delete from order_reviews
where review_score < 1
   or review_score > 5;


-- ================================================
-- CONVERT DATE STRINGS TO DATE
-- Convert varchar dates to proper DATE or DATETIME if needed
-- ================================================
-- MySQL expects yyyy-mm-dd or yyyy-mm-dd hh:mm:ss
-- Example conversion for review_creation_date:
alter table order_reviews add column review_creation_datetime datetime;

update order_reviews
set review_creation_datetime = str_to_date(review_creation_date, '%Y-%m-%d %H:%i:%s')
where review_creation_date is not null;

-- Similarly for review_answer_timestamp:
alter table order_reviews add column review_answer_datetime datetime;

update order_reviews
set review_answer_datetime = str_to_date(review_answer_timestamp, '%Y-%m-%d %H:%i:%s')
where review_answer_timestamp is not null;



-- 'sellers' Table
-- ================================================
-- CHECK FOR MISSING DATA
-- This query shows which columns in the 'sellers' table have missing (NULL) values
-- ================================================
select 
    sum(case when seller_id is null then 1 else 0 end) as null_seller_id,
    sum(case when seller_zip_code_prefix is null then 1 else 0 end) as null_zip_code_prefix,
    sum(case when seller_city is null then 1 else 0 end) as null_city,
    sum(case when seller_state is null then 1 else 0 end) as null_state
from sellers;


-- ================================================
-- REMOVE EXACT DUPLICATES
-- Using row_number() to assign a temporary number to duplicate rows and keeping only the first
-- ================================================
drop table if exists sellers_dedup;

create table sellers_dedup as
select *
from (
    select *,
           row_number() over (
               partition by seller_id,
                        seller_zip_code_prefix,
                        seller_city,
                        seller_state
               order by seller_id
           ) as rn
    from sellers
) t
where rn = 1;

-- Replace the original table with the deduplicated table
drop table sellers;
rename table sellers_dedup to sellers;


-- ================================================
-- STANDARDIZE seller_state
-- Make all state codes uppercase and remove invalid values
-- ================================================
update sellers
set seller_state = upper(trim(seller_state));

delete from sellers
where seller_state is null
  or length(seller_state) not between 2 and 5;


-- ================================================
-- CLEAN seller_city
-- Trim spaces and capitalize the first letter
-- ================================================
update sellers
set seller_city = trim(seller_city)
where seller_city is not null;

update sellers
set seller_city = concat(upper(left(seller_city,1)), lower(substring(seller_city,2)))
where seller_city <> '';


-- ================================================
-- VALIDATE seller_zip_code_prefix
-- Remove invalid zip codes (non-numeric) and pad short codes to 8 characters
-- ================================================
delete from sellers
where seller_zip_code_prefix is null
  or seller_zip_code_prefix not regexp '^[0-9]+$';

update sellers
set seller_zip_code_prefix = lpad(seller_zip_code_prefix, 8, '0')
where length(seller_zip_code_prefix) < 8;