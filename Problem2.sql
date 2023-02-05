CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

USE pizza_runner;


DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);

INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;

CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;

CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;

CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;

CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);

INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;

CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
 
-- Pizza metrics
-- Ans 1 

select count(*) from customer_orders;

-- Ans 2

select count(distinct order_id) from customer_orders;

-- Ans 3 

select 
	runner_id, 
    count(*) 
from runner_orders 
where cancellation = 'null' 
or cancellation is Null 
or cancellation = '' 
group by runner_id;

select 
	runner_id, 
    count(*) as successful_orders 
from runner_orders 
where duration != 'null' 
group by runner_id;

-- And 4

select 
	customer_orders.pizza_id, 
    count(*) as no_orders 
from customer_orders 
	left join runner_orders 
    on customer_orders.order_id = runner_orders.order_id 
where runner_orders.duration != 'null' 
group by customer_orders.pizza_id;

-- Ans 5 

select 
	customer_orders.customer_id, 
	pizza_names.pizza_name, 
    count(*) as no_orders 
from customer_orders 
	left join pizza_names 
    on customer_orders.pizza_id = pizza_names.pizza_id 
group by customer_orders.customer_id, pizza_names.pizza_name;

-- Ans 6 

select 
	customer_orders.order_id, 
    count(*) as no_pizzas 
from customer_orders 
	left join runner_orders 
    on customer_orders.order_id = runner_orders.order_id 
where runner_orders.duration = 'null' 
group by order_id 
order by no_pizzas DESC LIMIT 1; 

-- Ans 7 

select 
	customer_id, 
    sum(case when (exclusions != 'null' and exclusions != '') or (extras is not Null and extras != 'null' and extras != '') then 1 else 0 end) as at_least_1_mod,
    sum(case when (exclusions = 'null' or exclusions = '') and (extras is Null or extras = 'null' or extras = '') then 1 else 0 end) as no_changes
from customer_orders group by customer_id;

-- Ans 8 

select 
	count(*) 
from customer_orders 
where (exclusions != 'null' and exclusions != '') 
	and (extras is not Null and extras != 'null' and extras != '');

-- Ans 9 

select 
	hour(order_time)as hour, 
    count(*) as no_orders 
from customer_orders 
group by hour(order_time);

-- Ans 10 

select 
	week(order_time)as week, 
    count(*) as no_orders 
from customer_orders 
group by week(order_time);

-- Runner and customer exp. 

-- Ans 1 

SELECT 
    EXTRACT(WEEK from registration_date) as week_no,
    count(*) as sign_ups
from runners
group by EXTRACT(WEEK from registration_date);

-- Ans 2 

select 
	r.runner_id, 
    avg(TIMESTAMPDIFF(MINUTE,c.order_time, r.pickup_time)) as pickup_time 
from runner_orders as r 
	left join customer_orders as c 
    on r.order_id = c.order_id 
group by runner_id;

-- Ans 3 

-- Ans 4 

select 
	customer_orders.customer_id, 
    round(avg(runner_orders.distance),2) as avg_dist 
from runner_orders 
	left join customer_orders 
    on runner_orders.order_id = customer_orders.order_id 
group by customer_orders.customer_id;

-- Ans 5 

select 
	(max(duration)- min(duration)) as diff_in_delivery 
from runner_orders 
where duration != 'null';

-- Ans 6 

select 
	runner_id, 
    order_id, 
    duration 
from runner_orders 
order by runner_id, order_id;

-- Ans 7 

select 
	runner_id, 
    sum(case when duration != 'null' then 1 else 0 end)/count(*) as success_del 
from runner_orders 
group by runner_id;

-- Ingredient optimisation

-- Ans 1 

-- Prices and ratings 

-- Ans 1 

select 
	sum(case when c.pizza_id = 1 then 12 else 10 end) as total_revenue 
from customer_orders as c 
	left join runner_orders as r 
    on c.order_id = r.order_id 
where r.duration != 'null';

-- Ans 2 
    
create table ratings (
	rating_id INT not null primary key,
	customer_id int,
    order_id int,
    runner_id int,
    rating int check (rating between 0 and 5)
);

-- Ans 4 something went wrong here 

SELECT 
    distinct r.order_id, 
    c.customer_id,
    r.runner_id, 
    rt.rating,
    c.order_time, 
    r.pickup_time, 
    r.runner_id, 
    avg(TIMESTAMPDIFF(MINUTE,c.order_time, r.pickup_time)) as order_pickup_dur,
    r.duration, 
    avg(r.distance/r.duration) as speed
from runner_orders as r
	left join customer_orders as c  
    on r.order_id = c.order_id
    left join ratings as rt 
    on c.order_id = rt.order_id 
where r.duration != 'null';
    
   
    
select
	order_id,
    customer_id,
	count(distinct order_id) as no_orders
from customer_orders
group by order_id;

    