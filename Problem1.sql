-- CREATE SCHEMA dannys_diner;
-- SET search_path = dannys_diner;

USE dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);
  
CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
-- Ans 1

SELECT 
	customer_id, 
	SUM(price) as sales FROM sales 
	LEFT JOIN menu 
    on sales.product_id = menu.product_id
    GROUP BY customer_id;
    
-- Ans 2

SELECT 
	customer_id, 
    COUNT(DISTINCT order_date) as no_days FROM sales
    GROUP BY customer_id;

-- Ans 3

SELECT 
	customer_id, 
    product_id 
FROM (
    SELECT 
		*, 
        row_number() OVER (partition by customer_id order by order_date) as product_rank FROM sales) AS ranks
WHERE product_rank = 1;

-- Ans 4: Most purchased item on the menu and the number of times it was purchased by all customers

select 
	product_id,
    count(*) as total_orders
from sales
group by product_id
order by total_orders desc;

-- Ans 5: Most popular product for each customer 

with rankings as (select 
	sales.customer_id as customer_id, 
    menu.product_name as product_name,
    count(menu.product_name) as total_orders,
    rank() over (partition by sales.customer_id order by count(menu.product_name) DESC) as ranking
from sales 
left join menu 
	on sales.product_id = menu.product_id
group by sales.customer_id, menu.product_name)
select customer_id, product_name, total_orders from rankings where ranking = 1;

-- Answer 6: First item bought after customers became members
-- filter orders 

with order_ranking as (
SELECT 
	sales.customer_id as customer_id, 
    sales.order_date as order_date,
    menu.product_name as product_name,
    dense_rank () over (partition by sales.customer_id order by sales.order_date) as order_rank
from sales 
left join members
	on sales.customer_id = members.customer_id
left join menu
	on sales.product_id = menu.product_id
where sales.order_date >= members.join_date
group by sales.customer_id, sales.order_date, members.join_date, menu.product_name
)

select customer_id, order_date, product_name 
from order_ranking where order_rank = 1;

-- Answer 7 

with order_ranking as (
SELECT 
	sales.customer_id as customer_id, 
    sales.order_date as order_date,
    menu.product_name as product_name,
    dense_rank () over (partition by sales.customer_id order by sales.order_date DESC) as order_rank
from sales 
left join members
	on sales.customer_id = members.customer_id
left join menu
	on sales.product_id = menu.product_id
where sales.order_date < members.join_date
group by sales.customer_id, sales.order_date, members.join_date, menu.product_name
)

select customer_id, order_date, product_name 
from order_ranking where order_rank = 1;
    
-- Answer 8 

select 
	sales.customer_id as customer_id,
    sum(menu.price) as total_spend,
    count(*) as items_ordered
from sales
left join menu
	on sales.product_id = menu.product_id
left join members
	on sales.customer_id = members.customer_id
where sales.order_date < members.join_date
group by sales.customer_id;

-- Ans 9 

with points_table as (
select 
	sales.customer_id as customer_id,
    menu.product_name as product_name, 
    case when menu.product_name = "Sushi" then menu.price*2 else menu.price end as points
from sales
left join menu 
	on sales.product_id = menu.product_id)
    
select 
	customer_id,
    sum(points) as total_points
from points_table
group by customer_id;

-- Ans 10

select 
	sales.customer_id as customer_id,
    menu.product_name as product_name, 
    sales.order_date as order_date,
    members.join_date as join_date,
    datediff(members.join_date, sales.order_date) as date_diff,
    case 
		when datediff(sales.order_date, members.join_date) between 0 and 7 then menu.price*2 
		when menu.product_name = "Sushi" then menu.price*2 
		else menu.price end
	as points
from sales
left join menu 
	on sales.product_id = menu.product_id
left join members
	on sales.customer_id = members.customer_id
group by customer_id, product_name, order_date, join_date, points;

    