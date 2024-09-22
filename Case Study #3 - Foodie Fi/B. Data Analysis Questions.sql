-- How many customers has Foodie-Fi ever had?

select count(distinct customer_id) 'unique_customers'
from subscriptions;

-- What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

select month(start_date) 'month_id', monthname(start_date) 'month', count(customer_id) 'customers_in_trial'
from subscriptions left join plans using (plan_id)
where plan_name = 'trial'
group by 1,2
order by 1;

-- What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

select plan_name, count(s.customer_id) 'count_of_events'
from subscriptions s inner join plans p on s.plan_id = p.plan_id
where start_date > '2020-12-31'
group by plan_name;

-- What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

with cte as 
(select count(distinct customer_id) 'unique_customers', 
sum(case when plan_name = 'churn' then 1 else 0 end) 'churned_customers'
from subscriptions s inner join plans p on s.plan_id = p.plan_id)

select churned_customers, round(100 * churned_customers / unique_customers, 1) 'churned_customers%'
from cte;

-- How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

with next_plan as (
select customer_id, start_date, plan_name,
lead(plan_name, 1) over (order by customer_id) 'next_plans'
from subscriptions s left join plans p using (plan_id) )
,
churn_after_trial as (
select count(*) 'customers_churn_after_trial'
from next_plan
where plan_name = 'trial' and next_plans = 'churn')

select customers_churn_after_trial, 
concat(floor(customers_churn_after_trial / (select count(distinct customer_id) from subscriptions) * 100), '%') 'churn_percentage'
from churn_after_trial;

-- What is the number and percentage of customer plans after their initial free trial?

with next_plan as (
select customer_id, start_date, plan_name,
lead(plan_name, 1) over (order by customer_id) 'next_plans'
from subscriptions s left join plans p using (plan_id) )
,
after_trial as (
select next_plans, count(*) 'customers_after_trial'
from next_plan
where plan_name = 'trial' and next_plans != 'trial'
group by next_plans)

select next_plans, customers_after_trial, 
concat(floor(customers_after_trial / (select count(distinct customer_id) from subscriptions) * 100), '%') 'percentage'
from after_trial
order by 2 desc;

-- What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

select plan_name, count(distinct customer_id) 'customers'
from subscriptions s left join plans p using (plan_id)
where start_date <= '2020-12-31'
group by 1;

-- How many customers have upgraded to an annual plan in 2020?

with next_plan as(
select *,
lead(plan_name,1) over (order by start_date) 'next_plans'
from subscriptions s left join plans p using (plan_id)
)
select count(*) 'total customers upgraded to annual'
from next_plan
where next_plans = 'pro annual' and year(start_date) = '2020';

-- How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

with trial_plan as (
select customer_id, start_date 'join_date'
from subscriptions s left join plans p on s.plan_id = p.plan_id
where plan_name = 'trial'
),
date_upg_annual as (
select customer_id, start_date 'annual_date'
from subscriptions s left join plans p on s.plan_id = p.plan_id
where plan_name = 'pro annual'
)
select round(avg(datediff(annual_date , join_date)),0) 'avg_days_to_annual'
from trial_plan tp inner join date_upg_annual d using (customer_id) ;

-- How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

with next_plan as (
select customer_id, start_date, plan_name,
lead(plan_name, 1) over (order by customer_id) 'next_plans'
from subscriptions s left join plans p using (plan_id)
where year(start_date) = '2020')

select count(*) 'downgraded from a pro monthly to a basic monthly'
from next_plan
where plan_name = 'pro monthly' and next_plans = 'basic monthly';
