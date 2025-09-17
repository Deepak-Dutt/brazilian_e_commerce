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