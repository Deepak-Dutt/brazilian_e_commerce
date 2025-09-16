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


-- check duplicates order_id in 'orders' table--
select order_id, count(*) from orders
group by order_id
having count(*) > 1;

-- check duplicate order_id and order_item_id in 'order_items' table --
select order_id, order_item_id, count(*) from items
group by order_id, order_item_id
having count(*) > 1;

-- Check duplicate order_id and payment_sequentail in 'payments' table --
select order_id, payment_sequential, count(*) from payments
group by order_id, payment_sequential
having count(*) > 1;


-- ##############################################
-- Matrix 1: Revenue and Growth
-- ##############################################
-- **********************************************
-- KPI 1: Monthly Revenue Trend --
-- **********************************************
-- ----------------------------------------------
-- It check the null and negative values
-- ----------------------------------------------
select count(*) as total, sum(price is null or price<0) as bad_prices, sum(o.order_approved_at is null) as missing_date
from orders as o
join items as oi using(order_id);

with order_totals as (
	-- ----------------------------------------------
	-- It calculates the prices of order
	-- ----------------------------------------------
    select o.order_id, sum(oi.price) as order_revenue
	from orders as o
    join items as oi
    on o.order_id = oi.order_id
    group by o.order_id
    )
-- ----------------------------------------------
-- It displays the monthly revenue
-- ----------------------------------------------
select date_format(co.order_approved_at, '%Y-%m') as month, round(sum(t.order_revenue), 2) as total_revenue
from orders as co
join order_totals as t using (order_id)
group by month
order by month;

-- **********************************************
-- KPI 2: Year-Over-Year Growth --
-- **********************************************
with revenue as (
			-- ----------------------------------------------
			-- It gives the total revenue per year
			-- ----------------------------------------------
            select extract(year from o.order_approved_at) as yr,
			round(sum(oi.price), 2) as total_revenue
			from orders as o
			join items as oi
			on o.order_id = oi.order_id
			where o.order_approved_at is not null
			group by yr
			order by yr
			)
-- ----------------------------------------------
-- It generate growth percentage
-- ----------------------------------------------
select yr as Year, total_revenue,
			round(100 * (total_revenue - LAG(total_revenue) over (order by yr)) / nullif(lag(total_revenue) over (order by yr), 0), 2) as yoy_growth
from revenue
order by yr;


with jan_sept_revenue as (
						-- ----------------------------------------------
						-- It shows total revenue from Jan-2017 to Sept-2018
						-- ----------------------------------------------
						select extract(year from o.order_approved_at) as yr,
						round(sum(oi.price), 2) as total_revenue
						from orders as o
						join items as oi
						on o.order_id = oi.order_id
						where o.order_approved_at is not null and
                        extract(month from o.order_approved_at) between 1 and 9 and
                        extract(year from o.order_approved_at) in (2017, 2018)
						group by yr
						)
-- ----------------------------------------------
-- It calculates revenue growth from Jan-2017 to Sept-2018
-- ----------------------------------------------
select yr as Year, total_revenue, round(100 * (total_revenue - lag(total_revenue) over (order by yr)) / nullif(lag(total_revenue) over (order by yr), 0), 2) as yoy_growth
from jan_sept_revenue
order by yr;

-- ***********************************************
-- KPI 3: Average Order Value Trend
-- ***********************************************
with order_totals as (
					-- ----------------------------------------------
					-- It sums order price by order_id
					-- ----------------------------------------------
					select o.order_id,
					date_format(o.order_approved_at, '%m') as months,
					SUM(oi.price) as revenue
					from orders o
					join items oi on o.order_id = oi.order_id
					where o.order_approved_at is not null
					group by months, o.order_id
)
-- ----------------------------------------------
-- It computes average order value per month
-- ----------------------------------------------
select months,
       round(avg(revenue), 2) as avg_order_value
from order_totals
group by months
order by months;


-- ##############################################
-- Matrix 2: Product & Category Performance
-- ##############################################
-- **********************************************
-- KPI 1: Top Categories by Revenue and Units Sold
-- **********************************************
-- ----------------------------------------------
-- It displays category, total_revenue and item_sold per category
-- ----------------------------------------------
select p.product_category_name as category,
       round(sum(oi.price), 2) as total_revenue,
       count(*) as units_sold
from items oi
join products as p
on oi.product_id = p.product_id
group by category
order by total_revenue desc
limit 10;

-- **********************************************
-- KPI 2: Fast growing categories of Jan to Sept 2017 vs 2018
-- **********************************************
with jan_sept_rev as (
					-- ----------------------------------------------
					-- Revenue generated by category from 2017-2018
					-- ----------------------------------------------
					select p.product_category_name as categories,
						   sum(oi.price) as revenue,
						   extract(year from o.order_approved_at) as years
					from items oi
					join products as p on p.product_id = oi.product_id
					join orders as o on o.order_id = oi.order_id
					where o.order_approved_at is not null and
						  extract(month from o.order_approved_at) between 1 and 9 and
						  extract(year from o.order_approved_at) in (2017, 2018)
					group by categories, years
					order by years
),
pivot_rev as (
			-- ----------------------------------------------
			-- pivot year into two columns
			-- ----------------------------------------------
			select categories,
				   max(case when years = 2017 then revenue end) as rev_2017,
				   max(case when years = 2018 then revenue end) as rev_2018
			from jan_sept_rev
			group by categories
)
-- ----------------------------------------------
-- It calculates the growth
-- ----------------------------------------------
select categories, rev_2017, rev_2018, ROUND(100.0 * (rev_2018 - rev_2017) / NULLIF(rev_2017,0), 2) AS yoy_growth
from pivot_rev
where rev_2017 is not null and rev_2018 is not null
order by yoy_growth desc
limit 10;

-- ***********************************************
-- KPI 3: High average order value / low volume categories
-- ***********************************************
with cat_sold as (
				-- ----------------------------------------------
				-- It compute revenue & units per category
				-- ----------------------------------------------
				select p.product_category_name as categories,
					   sum(oi.price) as revenue,
					   count(*) as units_sold
				from items oi
				join products p on oi.product_id = p.product_id
				group by categories
),
avg_price as (
			-- ----------------------------------------------
			-- It computes average price of items
			-- ----------------------------------------------
			select categories, revenue, units_sold,
				   round(revenue * 1.0 / units_sold, 2) AS avg_price_of_item
			from cat_sold
), 
row_count as (
    select count(*) as total_rows
    from avg_price
)
-- ----------------------------------------------
-- It computes average price of items
-- ----------------------------------------------
select *
from avg_price
where units_sold < (select percentile_cont(0.50) within group (order by units_sold) from avg_price) and
      avg_price_of_item > (select percentile_cont(0.50) within group (order by avg_price_of_item) from avg_price)
order by avg_price_of_item desc
limit 10;

-- ##############################################
-- Matrix 3: Geographical Analysis
-- ##############################################
-- **********************************************
-- KPI 1: Revenue by city
-- **********************************************
with order_totals as ( 
						-- ----------------------------------------------
						-- It generated order revenue by city
						-- ----------------------------------------------
						select o.order_id,
							  g.geolocation_city as city,
							  sum(oi.price) as order_revenue
						from orders o
						join items oi on o.order_id = oi.order_id
						join customers c on o.customer_id = c.customer_id
						join geolocations g on c.customer_zip_code = g.geolocation_zip_code_prefix
						group by o.order_id, city
)
-- ----------------------------------------------
-- It aggregate revenue per city
-- ----------------------------------------------
select city,
       round(sum(order_revenue), 2) as total_revenue
from order_totals
group by city
order by total_revenue desc
limit 10;

-- **********************************************
-- KPI 2: Average delivery days by city
-- **********************************************
-- ----------------------------------------------
-- It calculates avg delivery days duration per city
-- ----------------------------------------------
select g.geolocation_city as city,
       round(avg(datediff(o.order_approved_at, o.order_delivered_customer_date)), 2) as avg_delivery_days
from orders o
join customers c on o.customer_id = c.customer_id
join geolocations g on c.customer_zip_code = g.geolocation_zip_code_prefix
where o.order_delivered_customer_date is not null
group by city
order by avg_delivery_days desc
limit 10;

-- **********************************************
-- KPI 3 · Order vs Revenue Share by City
-- **********************************************
with city_stats as (
					-- ----------------------------------------------
					-- It counts order and revenue per city,
					-- ----------------------------------------------
					select g.geolocation_city as city,
						   count(distinct o.order_id) as orders,
						   sum(oi.price) as revenue
					from orders o
                    join items oi on o.order_id = oi.order_id
                    join customers c on o.customer_id = c.customer_id
                    join geolocations g on c.customer_zip_code = g.geolocation_zip_code_prefix
                    group by city
),
totals as (
			-- ----------------------------------------------
			-- It counts order and revenue per city,
			-- ----------------------------------------------
			select sum(orders) as nat_orders, 
				   sum(revenue) as nat_revenue
			from city_stats
)
-- ----------------------------------------------
-- It counts order and revenue per city,
-- ----------------------------------------------
select s.city, round(100.0 * s.orders  / t.nat_orders, 2) as order_share_pct, 
       round(100.0 * s.revenue / t.nat_revenue, 2) as revenue_share_pct
from city_stats s
cross join totals t
order by revenue_share_pct desc;