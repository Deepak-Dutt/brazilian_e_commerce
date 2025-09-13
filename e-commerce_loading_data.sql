create database if not exists brazilian_e_commerce;

show databases;

use brazilian_e_commerce;

show tables;

------------------------------------------------------------------------------------------------
create table if not exists customers (
customer_id char(50),
customer_unique_id char(50), 
customer_zip_code varchar(10),
customer_city varchar(50),
customer_state varchar(5)
);
load data infile "D:/brazilian_e_commerce/data/clean_data/customers.csv"
into table customers
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select customer_id, count(*) as count from customers
group by customer_id
having count(*)>1;

alter table customers
add primary key (customer_id);

select * from customers;

describe customers;
------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
create table if not exists order_items (
order_id char(50),
order_item_id varchar(10),
product_id char(50),
seller_id char(50),
shipping_limit_date date not null,
price decimal (10,2),
freight_value decimal (10,2)
);
load data infile "D:/brazilian_e_commerce/data/clean_data/order_items.csv"
into table order_items
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select order_id, count(*) as count from order_items
group by order_id
having count(*)>1;

select * from order_items as o1
where exists (
select 1 from order_items as o2
where o1.order_id = o2.order_id and
o1.order_item_id = o2.order_item_id and
o1.product_id = o2.product_id and
o1.seller_id = o2.seller_id and
o1.shipping_limit_date = o2.shipping_limit_date and
o1.price = o2.price and
o1.freight_value = o2.freight_value
);

select * from order_items;
------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
create table if not exists order_payments (
order_id char(50),
payment_sequential int,
payment_type char(20),
payment_installments int,
payment_value decimal(10, 2)
);
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_payments_dataset.csv"
into table order_payments
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select * from order_payments;
------------------------------------------------------------------------------------------------
xxxxx
------------------------------------------------------------------------------------------------
create table if not exists order_reviews (
review_id char(50),
order_id char(50),
review_score int,
review_comment_title varchar(100),
review_comment_message text,
review_creation_date varchar(100),
review_answer_timestamp varchar(100)
);
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_reviews_dataset.csv"
into table order_reviews
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select * from order_reviews;
------------------------------------------------------------------------------------------------
xxxxx
------------------------------------------------------------------------------------------------
create table if not exists orders (
order_id char(50),
customer_id char(50),
order_status char (10),
order_purchase_timestamp date,
order_approved_at date,
order_delivered_carrier_date date,
order_delivered_customer_date date,
order_estimated_delivery_date date
);
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_orders_dataset.csv"
into table orders
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select * from orders;
------------------------------------------------------------------------------------------------
xxxxx
------------------------------------------------------------------------------------------------
create table if not exists products (
product_id char(50),
product_category_name char(50),
product_name_lenght int,
product_description_lenght int,
product_photos_qty int,
product_weight_g int,
product_length_cm int,
product_height_cm int,
product_width_cm int
);
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_products_dataset.csv"
into table products
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select * from products;
------------------------------------------------------------------------------------------------
xxxxxx
------------------------------------------------------------------------------------------------
create table if not exists sellers (
seller_id char(50),
seller_zip_code_prefix char(10),
seller_city char(20),
seller_state char(5)
);
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_sellers_dataset.csv"
into table sellers
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select * from sellers;
------------------------------------------------------------------------------------------------
xxxxxx
------------------------------------------------------------------------------------------------
create table if not exists category_name (
product_category_name char(50),
product_category_name_english char(50) 
);
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_category_name_dataset.csv"
into table category_name
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select * from category_name;
------------------------------------------------------------------------------------------------
xxxxxx
------------------------------------------------------------------------------------------------