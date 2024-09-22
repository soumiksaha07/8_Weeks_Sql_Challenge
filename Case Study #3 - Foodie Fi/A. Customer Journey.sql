Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey. Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier! */

select customer_id, p.plan_id, 
plan_name, start_date
from plans p inner join subscriptions s on p.plan_id = s.plan_id
where customer_id in (1,2,11,13,15,16,18,19);
