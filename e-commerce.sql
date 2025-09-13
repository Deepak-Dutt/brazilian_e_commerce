show databases;
use brazilian_e_commerce;
show tables;

select 'customers' as table_name, count(*) as row_count from brazilian_e_commerce.customers
union all
select 'name_translation', count(*) from brazilian_e_commerce.name_translation
union all
select 'order_items', count(*) from brazilian_e_commerce.order_items
union all
select 'orders', count(*) from brazilian_e_commerce.orders
union all
select 'payments', count(*) from brazilian_e_commerce.payments
union all
select 'products', count(*) from brazilian_e_commerce.products
union all
select 'reviews', count(*) from brazilian_e_commerce.reviews
union all
select 'sellers', count(*) from brazilian_e_commerce.sellers;


-- check duplicates order_id in 'orders' table--
select order_id, count(*) from orders
group by order_id
having count(*) > 1;

-- check duplicate order_id and order_item_id in 'order_items' table --
select order_id, order_item_id, count(*) from order_items
group by order_id, order_item_id
having count(*) > 1;

-- Check duplicate order_id and payment_sequentail in 'payments' table --
select order_id, payment_sequential, count(*) from payments
group by order_id, payment_sequential
having count(*) > 1;
