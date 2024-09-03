# Case Study #1 - Danny's Diner

## Problem Statement

Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers. 

Full description: [Case Study #1 - Danny's Diner](https://8weeksqlchallenge.com/case-study-1/)

## Case Study Questions

Each of the following case study questions can be answered using a single SQL statement. I'll mostly use two queries for convenience purposes.

#### 1. What is the total amount each customer spent at the restaurant?

````sql
select s.customer_id, sum(mn.price) 'total_amount_spent'
from sales s left join menu mn using (product_id)
group by 1;
  ````

| customer_id | total_amount_spent |
| ----------- | ------------------ |
| A           | 76                 |
| B           | 74                 |
| C           | 36                 |

---
#### 2. How many days has each customer visited the restaurant?

````sql
select customer_id, count(distinct order_date) 'total customers visited'
from sales
group by 1;
  ````
  
| customer_id | total_customers_visited |
| ----------- | ----------------        |
| A           |   4                     |
| B           |   6                     |
| C           |   2                     |

---

#### 3. What was the first item from the menu purchased by each customer?

To get the first item we need to rank the items ordered by each customer in a temporary table using `WITH` statement. 

After we have those ranks, we can select the rows with the rank = 1. As the customer A made two orders at the first day, we need to use `ORDER BY` in the window function by two criteria: `order_date` and `product_id`.

In the final query I cast date as `varchar` to remove time ans show the date only.

````sql
with cte as (select s.customer_id, product_name, order_date,
row_number() over (partition by customer_id order by s.order_date asc) 'first_item'
from sales s left join menu mn on s.product_id = mn.product_id)

select customer_id, product_name
from cte
where first_item = 1;
````  

| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

---

***The first purchase for customer A was sushi***

***The first purchase for customer B was curry***

***The first (and the only) purchase for customer C was ramen***

#### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
select mn.product_name, count(mn.product_name) 'count'
from sales s inner join menu mn on s.product_id = mn.product_id
group by 1
order by 2 desc
limit 1;
  ````
 | product_name | count |
| ------------ | -------|
| ramen        | 8      |

---
 
***The most purchased item on the menu was ramen, it was purchased 8 times in total.***

#### 5. Which item was the most popular for each customer?

Let's look at all the results sorted by purchase frequency:

````sql
SET
  search_path = dannys_diner;
SELECT
  customer_id,
  product_name,
  COUNT(product_name) AS total_purchase_quantity
FROM
  sales AS s
  INNER JOIN menu AS m ON s.product_id = m.product_id
GROUP BY
  customer_id,
  product_name
ORDER BY
  total_purchase_quantity DESC
````

| customer_id | product_name | total_purchase_quantity |
| ----------- | ------------ | ----------------------- |
| C           | ramen        | 3                       |
| A           | ramen        | 3                       |
| B           | curry        | 2                       |
| B           | sushi        | 2                       |
| B           | ramen        | 2                       |
| A           | curry        | 2                       |
| A           | sushi        | 1                       |

---

Now we can select the most popular products for each customer using `rank` window function:

````sql
SET
  search_path = dannys_diner;
WITH ranked AS (
    SELECT
      customer_id,
      product_name,
      COUNT(product_name) AS total_purchase_quantity,
      rank() OVER (
        PARTITION BY customer_id
        ORDER BY
          COUNT(product_name) desc
      ) AS rank
    FROM
      sales AS s
      JOIN menu AS m ON s.product_id = m.product_id
    GROUP BY
      customer_id,
      product_name
  )
SELECT
  customer_id,
  product_name,
  total_purchase_quantity
FROM
  ranked
WHERE
  rank = 1
 ```` 
 
| customer_id | product_name | total_purchase_quantity |
| ----------- | ------------ | ----------------------- |
| A           | ramen        | 3                       |
| B           | ramen        | 2                       |
| B           | curry        | 2                       |
| B           | sushi        | 2                       |
| C           | ramen        | 3                       |

---
 
***The most popular item for customer A was ramen, they purchased it 3 times.***

***The most popular item for customer B was curry, ramen and sushi, they purchased each dish 2 times.***

***The most popular item for customer C was ramen, they purchased it 3 times.***

#### 6. Which item was purchased first by the customer after they became a member?

Let's consider that if the purchase date matches the membership date, then the purchase made on this date, was the first customer's purchase as a member. 
It means that we need to include this date in the WHERE statement.

````sql
with cte as (
	select distinct s.customer_id, product_id, join_date, order_date,
	row_number() over (partition by customer_id order by order_date) 'ranks'
	from sales s left join members m on s.customer_id = m.customer_id
	where order_date >= join_date)
select customer_id, join_date, order_date, product_name
from cte inner join menu mn using(product_id)
where ranks = 1
order by 1 asc;
  ````

| customer_id | join_date  | order_date | product_name |
| ----------- | ---------- | ---------- | ------------ |
| A           | 2021-01-07 | 2021-01-07 | curry        |
| B           | 2021-01-09 | 2021-01-11 | sushi        |

----

#### 7. Which item was purchased just before the customer became a member?

Customer A purchased their membership on January, 7 - and they placed an order that day. 
We do not have time and therefore can not say exactly if this purchase was made before of after they became a member. 
Let's consider that if the purchase date matches the membership date, then the purchase made on this date, was the first customer's purchase as a member. 
It means that we need to exclude this date in the `WHERE` statement.

````sql
SET
  search_path = dannys_diner;
WITH ranked AS (
    SELECT
      s.customer_id,
      order_date,
      join_date,
      product_name,
      rank() OVER (
        PARTITION BY s.customer_id
        ORDER BY
          order_date DESC
      ) AS rank
    FROM
      sales AS s
      JOIN members AS mm ON s.customer_id = mm.customer_id
      JOIN menu AS m ON s.product_id = m.product_id
    WHERE
      order_date < join_date
  )
SELECT
  customer_id,
  join_date::varchar,
  order_date::varchar,
  product_name
FROM
  ranked AS r
WHERE
  rank = 1
ORDER BY
  1
  ````

| customer_id | join_date  | order_date | product_name |
| ----------- | ---------- | ---------- | ------------ |
| A           | 2021-01-07 | 2021-01-01 | sushi        |
| A           | 2021-01-07 | 2021-01-01 | curry        |
| B           | 2021-01-09 | 2021-01-04 | sushi        |

---

Customer A purchased two items on January, 1 - the date before they became a member. 
We need more information to tell exactly what item was purchased before they became a member: order number or purchase time. I am keeping two items in the list for now.

***Customer A purchased curry and sushi on 2021-01-01***

***Customer B purchased sushi on 2021-01-04***

#### 8. What is the total items and amount spent for each member before they became a member?

Let's consider that if the purchase date matches the membership date, then the purchase made on this date, was the first customer's purchase as a member. 
It means that we need to exclude this date in the WHERE statement.

````sql
with cte as (
	select s.customer_id, s.product_id,
	row_number() over(partition by customer_id order by order_date desc) 'ranks'
	from sales s left join members m using(customer_id)
	where order_date < join_date)

select customer_id, count(c.product_id) 'total_items', sum(mn.price) 'total_amount_spent'
from cte c inner join menu mn using(product_id)
group by 1;
  ````

| customer_id | total_items | total_amount_amount |
| ----------- | ------------| --------------------|
| A           | 2           | 25                  |
| B           | 3           | 40                  |

---

#### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

````sql
with cte as (select s.customer_id, mn.product_name,
case 
	when product_name = 'sushi' then sum(price) * 20 else sum(price) * 10
end as 'total_points'
from sales s inner join menu mn using(product_id)
group by 1,2)

select customer_id, sum(total_points) 'total_points'
from cte
group by 1;
  ````

| customer_id | total_points |
| ----------- | ------       |
| A           | 860          |
| B           | 940          |
| C           | 360          |

---

#### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

First we need to count points as usual: 10 points for each dollar spent on curry and ramen and 20 points for each dollar spent on sushi. 
We add this calculation to the `CTE` using `WITH` statement. Next we use this `CTE` to add extra 10 points for all the purchases of curry and
ramen made by customers on the first week of their membership and return the sum of new points. The points for sushi remain the same - 20 points.

````sql
select customer_id,
sum(case
	when datediff(s.order_date, m.join_date) <= 7 then (price) * 20
end) as 'total_points'
from sales s inner join members m using (customer_id)
inner join menu mn on s.product_id = mn.product_id
where s.order_date >= m.join_date
and s.order_date <= '2021-1-31'
group by 1
order by 1;
  ````

| customer_id | total_points |
| ----------- | ---------- |
| A           | 1020       |
| B           | 440        |

---

***Customer A at the end of January would have 1020 points***

***Customer B at the end of January would have 440 points*** and 0 benefits from their first week membership

## Bonus Questions

### Join All The Things

````sql
create table combined (
select sales.customer_id, order_date, product_name, price,
case
	when order_date >= join_date then "Y" else "N"
end as "members"
from sales left join members on sales.customer_id = members.customer_id
left join menu using (product_id)
);
````

| customer_id | order_date | product_name | price | members |
| ----------- | ---------- | ------------ | ----- | ------  |
| A           | 2021-01-01 | curry        | 15    | N       |
| A           | 2021-01-01 | sushi        | 10    | N       |
| A           | 2021-01-07 | curry        | 15    | Y       |
| A           | 2021-01-10 | ramen        | 12    | Y       |
| A           | 2021-01-11 | ramen        | 12    | Y       |
| A           | 2021-01-11 | ramen        | 12    | Y       |
| B           | 2021-01-01 | curry        | 15    | N       |
| B           | 2021-01-02 | curry        | 15    | N       |
| B           | 2021-01-04 | sushi        | 10    | N       |
| B           | 2021-01-11 | sushi        | 10    | Y       |
| B           | 2021-01-16 | ramen        | 12    | Y       |
| B           | 2021-02-01 | ramen        | 12    | Y       |
| C           | 2021-01-01 | ramen        | 12    | N       |
| C           | 2021-01-01 | ramen        | 12    | N       |
| C           | 2021-01-07 | ramen        | 12    | N       |

---

### Rank All The Things

First we need to select all the necessary columns from `sales`, `menu` and `members` tables - we do that using CTE and `WITH` statement.
Next we can rank orders from this table by `customer_id` and `member` columns.

````sql
select *,
case
	when members = "Y" then rank() over (partition by customer_id, members order by order_date) else "null"
end as ranking
from combined;
  ````
 
 | customer_id | order_date | product_name | price | members | ranking |
| -----------  | ---------- | ------------ | ----- | ------  | ------- |
| A            | 2021-01-01 | curry        | 15    | N       | null    |
| A            | 2021-01-01 | sushi        | 10    | N       | null    |
| A            | 2021-01-07 | curry        | 15    | Y       | 1       |
| A            | 2021-01-10 | ramen        | 12    | Y       | 2       |
| A            | 2021-01-11 | ramen        | 12    | Y       | 3       |
| A            | 2021-01-11 | ramen        | 12    | Y       | 3       |
| B            | 2021-01-01 | curry        | 15    | N       | null    |
| B            | 2021-01-02 | curry        | 15    | N       | null    |
| B            | 2021-01-04 | sushi        | 10    | N       | null    |
| B            | 2021-01-11 | sushi        | 10    | Y       | 1       |
| B            | 2021-01-16 | ramen        | 12    | Y       | 2       |
| B            | 2021-02-01 | ramen        | 12    | Y       | 3       |
| C            | 2021-01-01 | ramen        | 12    | N       | null    |
| C            | 2021-01-01 | ramen        | 12    | N       | null    |
| C            | 2021-01-07 | ramen        | 12    | N       | null    |

---
