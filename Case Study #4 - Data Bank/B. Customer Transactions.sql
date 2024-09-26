-- What is the unique count and total amount for each transaction type?

select txn_type, count(*) 'total transaction', sum(txn_amount) 'total amount'
from customer_transactions
group by 1;

-- What is the average total historical deposit counts and amounts for all customers?

with cte as (
select customer_id, count(*) 'total_deposit', sum(txn_amount) 'total_deposit_amount'
from customer_transactions
where txn_type = 'deposit'
group by 1)

select round(avg(total_deposit), 0) 'average_total_deposit', round(avg(total_deposit_amount), 0) 'average_total_deposit_amount'
from cte;

-- For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

with cte as (
select customer_id, month(txn_date) 'month_id', monthname(txn_date) 'months',
	sum(case when txn_type = 'deposit' then 1 else 0 end) 'deposit_count',
    sum(case when txn_type = 'purchase' then 1 else 0 end) 'purchase_count',
    sum(case when txn_type = 'withdrawal' then 1 else 0 end) 'withdrawal_count'
from customer_transactions
group by 1,2,3 )

select month_id, months, count(customer_id) 'customers'
from cte
where deposit_count > 1 and (purchase_count > 1 or withdrawal_count > 1)
group by 1,2
order by 1;

-- What is the closing balance for each customer at the end of the month?

with cte as (
select customer_id, txn_date,
	sum(case when txn_type = 'deposit' then txn_amount else -txn_amount end) 'closing_balance'
from customer_transactions
group by 1,2)

select customer_id, monthname(txn_date) 'end_of_month', sum(closing_balance) 'closing balance'
from cte
group by 1,2
order by 1;

-- What is the percentage of customers who increase their closing balance by more than 5%?

with cte as (
select customer_id, txn_date,
	sum(case when txn_type = 'deposit' then txn_amount else -txn_amount end) 'closing_balance'
from customer_transactions
group by 1,2),

cte2 as (select customer_id, monthname(txn_date) 'end_of_month', sum(closing_balance) 'closing balance'
from cte
group by 1,2
order by 1)

select count(distinct customer_id) * 100 / (select count(*) from customer_transactions)
from cte2;
