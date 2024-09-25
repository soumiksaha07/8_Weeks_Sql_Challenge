-- What is the unique count and total amount for each transaction type?

select txn_type, count(*) 'total transaction', sum(txn_amount) 'total amount'
from customer_transactions
group by 1;

-- What is the average total historical deposit counts and amounts for all customers?



-- For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?



-- What is the closing balance for each customer at the end of the month?



-- What is the percentage of customers who increase their closing balance by more than 5%?
