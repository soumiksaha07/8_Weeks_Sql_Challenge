 -- What is the total amount each customer spent at the restaurant?

select s.customer_id, concat('$ ',sum(mn.price)) 'total amount'
from sales s left join menu mn using (product_id)
group by 1;

-- How many days has each customer visited the restaurant?

select customer_id, count(distinct order_date) 'total customers visited'
from sales
group by 1;

-- What was the first item from the menu purchased by each customer?

with cte as (select s.customer_id, product_name, order_date,
row_number() over (partition by customer_id order by s.order_date asc) 'first_item'
from sales s left join menu mn on s.product_id = mn.product_id)

select customer_id, product_name
from cte
where first_item = 1;

-- What is the most purchased item on the menu and how many times was it purchased by all customers?

select mn.product_name, count(mn.product_name) 'count'
from sales s inner join menu mn on s.product_id = mn.product_id
group by 1
order by 2 desc
limit 1;

-- Which item was the most popular for each customer?

with cte as (select s.customer_id, product_name 'popular_item', count(mn.product_name) 'total_purchase',
dense_rank() over (partition by customer_id order by count(mn.product_name) desc) 'ranks'
from sales s left join menu mn on s.product_id = mn.product_id
group by 1,2)

select customer_id, popular_item, total_purchase
from cte
where ranks = 1;

-- Which item was purchased first by the customer after they became a member?

with cte as (
	select distinct s.customer_id, product_id,
	row_number() over (partition by customer_id order by order_date) 'ranks'
	from sales s left join members m on s.customer_id = m.customer_id
	where order_date > join_date)
	
select customer_id, product_name
from cte inner join menu mn using(product_id)
where ranks = 1
order by 1 asc;

-- Which item was purchased just before the customer became a member?

with cte as (
	select distinct s.customer_id, product_id,
	row_number() over (partition by customer_id order by order_date desc) 'ranks'
	from sales s left join members m on s.customer_id = m.customer_id
	where order_date < join_date)
	
select customer_id, product_name
from cte inner join menu mn using(product_id)
where ranks = 1
order by 1 asc;

-- What is the total items and amount spent for each member before they became a member?

with cte as (
	select s.customer_id, s.product_id,
	row_number() over(partition by customer_id order by order_date desc) 'ranks'
	from sales s left join members m using(customer_id)
	where order_date < join_date)

select customer_id, count(c.product_id) 'total items', sum(mn.price) 'total spent'
from cte c inner join menu mn using(product_id)
group by 1;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

with cte as (select s.customer_id, mn.product_name,
case 
	when product_name = 'sushi' then sum(price) * 20 else sum(price) * 10
end as 'total_points'
from sales s inner join menu mn using(product_id)
group by 1,2)

select customer_id, sum(total_points) 'total points'
from cte
group by 1;

-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

select customer_id,
sum(case
	when datediff(s.order_date, m.join_date) <= 7 then (price) * 20
end) as 'total_points'
from sales s inner join members m using (customer_id)
inner join menu mn on s.product_id = mn.product_id
where s.order_date >= m.join_date
and s.order_date <= '2021-1-31'
group by 1;

/* Bonus Questions: */
-- Join All The Things with basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL. Fill Member column as 'N' if the purchase was made before becoming a member and 'Y' if the after is made after joining the membership.*/

create table combined (
select sales.customer_id, order_date, product_name, price,
case
	when order_date >= join_date then "Y" else "N"
end as "members"
from sales left join members on sales.customer_id = members.customer_id
left join menu using (product_id)
);

-- Rank All The Things Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

select *,
case
	when members = "Y" then row_number() over (partition by customer_id, members order by order_date) else "null"
end as ranking
from combined;
