set sql_safe_updates = 0;

update customer_orders
set exclusions = 
case
	when exclusions = '' or exclusions = 'null' then null
    else exclusions
end,
extras = 
case
	when extras = '' or extras = 'null' then null
    else extras
end;

select * from customer_orders;


alter table runner_orders
modify column pickup_time datetime;

alter table runner_orders
modify column duration int;

alter table runner_orders
modify column distance float;

update runner_orders
set pickup_time = 
case
	when pickup_time = 'null' then null
    else pickup_time
end,
distance = 
case
	when distance = 'null' then null
    else cast(regexp_replace(distance, '[a-z]+', '') as float)
end,
duration = 
case
	when duration = 'null' then null
    else cast(regexp_replace(duration, '[a-z]+', '') as float)
end,
cancellation = 
case
	when cancellation = '' or cancellation = 'null' then null
    else cancellation
end;

select * from runner_orders;