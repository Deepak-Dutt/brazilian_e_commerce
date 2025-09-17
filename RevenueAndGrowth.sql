-- ##############################################
-- Matrix 1: Revenue and Growth
-- ##############################################
-- **********************************************
-- KPI 1: Monthly Revenue Trend --
-- **********************************************
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