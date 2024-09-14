-- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

select concat('$ ',
sum(case
	when pizza_name = 'Meatlovers' then 12
    when pizza_name = 'Vegetarian' then 10
end)) as total_revenue
from pizza_names p inner join customer_orders c using (pizza_id)
inner join runner_orders r on c.order_id = r.order_id
where cancellation is null;

-- What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra.

with cte as (
select extras,
sum(case
	when pizza_id = 1 then 12
    when pizza_id = 2 then 10
end) as total_revenue
from customer_orders c inner join runner_orders r on c.order_id = r.order_id
where cancellation is null
group by extras)

select concat('$ ',
sum(case
	when extras is null then total_revenue
    when length(extras) = 1 then total_revenue + 1
    else total_revenue + 2
end )) as after_extra_charge
from cte;

-- The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

Drop table customer_rating;

create table customer_rating(
order_id int not null,
rating int);
insert into customer_rating (order_id, rating)
values
(1,3),
(2,4),
(3,5),
(4,2),
(5,1),
(6,null),
(7,4),
(8,1),
(9,null),
(10,5); 

select * 
from customer_rating;

/* Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas */

select customer_id, c.order_id, r.runner_id, rating, order_time,
pickup_time, concat(timestampdiff(minute, order_time, pickup_time), ' min') 'Time_btw_OrderPickup', concat(duration, ' min') 'Delivery duration', concat(round(distance / duration * 60, 2), ' km/h') 'Average_speed', count(p.pizza_id)'Number_of_pizzas'
from customer_orders c left join pizza_names p on c.pizza_id = p.pizza_id
left join runner_orders r on c.order_id = r.order_id
left join customer_rating cr on c.order_id = cr.order_id
where cancellation is null
group by 1,2,3,4,5,6,8,9;

/* If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries? */

with cte as (select order_id,
sum(case
	when pizza_name = 'Meatlovers' then 12
    when pizza_name = 'Vegetarian' then 10
end) as total_revenue
from customer_orders c left join pizza_names p on c.pizza_id = p.pizza_id
group by 1
)
select concat('$ ', round(sum(total_revenue) - sum(distance * 0.30), 2)) 'profit'
from cte inner join runner_orders using (order_id)
where cancellation is null;
