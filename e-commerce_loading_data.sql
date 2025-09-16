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
------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
create table if not exists items (
order_id char(50),
order_item_id varchar(10),
product_id char(50),
seller_id char(50),
shipping_limit_date date not null,
price decimal (10,2),
freight_value decimal (10,2)
);
load data infile "D:/brazilian_e_commerce/data/clean_data/items.csv"
into table items
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select order_id, count(*) as count from items
group by order_id
having count(*)>1;

select * from items as o1
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
------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
create table if not exists payments (
order_id char(50),
payment_sequential int,
payment_type char(20),
payment_installments int,
payment_value decimal(10, 2)
);
load data infile "D:/brazilian_e_commerce/data/clean_data/payments.csv"
into table payments
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;
------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
create table if not exists reviews (
review_id char(50),
order_id char(50),
review_score int,
review_comment_title varchar(100),
review_comment_message text,
review_creation_date varchar(100),
review_answer_timestamp varchar(100)
);
load data infile "D:/brazilian_e_commerce/data/clean_data/reviews.csv"
into table reviews
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;
------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
create table if not exists orders (
order_id char(50),
customer_id char(50),
order_status varchar (20),
order_purchase_timestamp date,
order_approved_at date,
order_delivered_carrier_date date,
order_delivered_customer_date date,
order_estimated_delivery_date date
);
load data infile "D:/brazilian_e_commerce/data/clean_data/orders.csv"
into table orders
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;
------------------------------------------------------------------------------------------------

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
load data infile "D:/brazilian_e_commerce/data/clean_data/products.csv"
into table products
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;
------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
create table if not exists sellers (
seller_id char(50),
seller_zip_code_prefix char(10),
seller_city varchar(50),
seller_state char(5)
);
load data infile "D:/brazilian_e_commerce/data/clean_data/sellers.csv"
into table sellers
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;
------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
create table if not exists names (
product_category_name char(50),
product_category_name_english char(50) 
);
load data infile "D:/brazilian_e_commerce/data/clean_data/names.csv"
into table names
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;
------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
create table if not exists geolocations (
    geolocation_zip_code_prefix varchar(10),
    geolocation_lat decimal (20, 16),
    geolocation_lng decimal (20, 16),
    geolocation_city varchar(40),
    geolocation_state varchar(5)
);
load data infile "D:/brazilian_e_commerce/data/clean_data/geolocations.csv"
into table geolocations
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;