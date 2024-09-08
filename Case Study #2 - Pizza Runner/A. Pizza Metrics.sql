----------------------------------
-- CASE STUDY #2: PIZZA RUNNER --
----------------------------------

-- Author: Soumik Saha
-- Date: 06/09/2024 
-- Tool used: MySQL Server

--------------------------------------
-- CASE STUDY QUESTIONS & SOLUTIONS --
--------------------------------------


-- How many pizzas were ordered?

select count(pizza_id) 'total_pizza_ordered'
from customer_orders; 

-- How many unique customer orders were made?

select count(distinct customer_id) 'unique_customers'
from customer_orders;

-- How many successful orders were delivered by each runner?

select runner_id, count(order_id) 'successful_orders' 
from runner_orders
where cancellation is null
group by 1;

-- How many of each type of pizza was delivered?

select p.pizza_name, count(c.pizza_id) 'total_delivery'
from customer_orders c inner join runner_orders r using (order_id)
inner join pizza_names p using (pizza_id)
where cancellation is null
group by 1;

-- How many Vegetarian and Meatlovers were ordered by each customer?

select c.customer_id, p.pizza_name, count(c.pizza_id) 'total_delivery'
from customer_orders c inner join pizza_names p using (pizza_id)
group by 1,2
order by 1;

-- What was the maximum number of pizzas delivered in a single order?

select order_id, count(pizza_id) 'count_pizzas'
from customer_orders
group by 1
order by 2 desc
limit 1;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

select c.customer_id, 
sum(case
	 when exclusions is not null or extras is not null then 1 else 0
     end) as atleast_one_changes,
sum(case
	 when exclusions is null and extras is null then 1 else 0
     end) as no_changes
from customer_orders c inner join runner_orders r on c.order_id = r.order_id
where r.cancellation is null
group by 1;

-- How many pizzas were delivered that had both exclusions and extras?

select count(pizza_id) 'total_delivered_pizzas'
from customer_orders c inner join runner_orders r on c.order_id = r.order_id
where exclusions is not null and extras is not null and r.cancellation is null;

-- What was the total volume of pizzas ordered for each hour of the day?

select hour(order_time) 'hour', count(pizza_id) 'total_volume_of_pizzas'
from customer_orders
group by 1
order by 1;

-- What was the volume of orders for each day of the week?

select dayname(order_time) 'day', count(order_id) 'total_volume_of_orders'
from customer_orders
group by 1;
