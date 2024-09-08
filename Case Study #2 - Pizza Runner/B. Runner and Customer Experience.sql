----------------------------------
-- CASE STUDY #2: PIZZA RUNNER --
----------------------------------

-- Author: Soumik Saha
-- Date: 06/09/2024 
-- Tool used: MySQL Server

--------------------------------------
-- CASE STUDY QUESTIONS & SCRIPTS --
--------------------------------------


-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

select week(registration_date)'each_week', count(runner_id) ' runners' 
from runners
group by 1;

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

with cte as (
select runner_id, timestampdiff(minute, order_time, pickup_time) 'duration'
from runner_orders r inner join customer_orders c using (order_id)
where cancellation is null
group by 1,2
)

select runner_id, concat(round(avg(duration), 2), ' min') 'average_duration'
from cte
group by 1;

-- Is there any relationship between the number of pizzas and how long the order takes to prepare?

with cte as (
select order_id, count(order_id) 'total_orders', timestampdiff(minute, order_time, pickup_time) 'prep_hour'
from runner_orders r inner join customer_orders c using (order_id)
where cancellation is null
group by 1,3
)

select total_orders, concat(round(avg(prep_hour), 2), ' min') 'average_prep_hour'
from cte
group by 1;

-- What was the average distance travelled for each customer?

select customer_id, concat(round(avg(distance), 2), ' km') 'average_distance'
from customer_orders c inner join runner_orders r using (order_id)
where cancellation is null
group by 1;

-- What was the difference between the longest and shortest delivery times for all orders?

select min(duration) 'shortlest_delivery_times', 
max(duration) 'longest_delivery_times',
(max(duration) - min(duration)) 'difference_between_times'
from runner_orders;

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?

select order_id, runner_id, count(pizza_id) 'total_pizzas', distance,
concat(round(distance / duration * 60, 2), ' km/h') 'average_speed'
from runner_orders r inner join customer_orders c using (order_id)
where cancellation is null
group by 1, 2, 4, 5
order by 2 asc;

-- What is the successful delivery percentage for each runner?

select runner_id, round(100 * sum(
case
	when cancellation is null then 1 else 0
    end) / count(*), 0) 'successful_delivery%'
from runner_orders
group by 1;
