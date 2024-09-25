-- How many unique nodes are there on the Data Bank system?

select count(distinct node_id) 'unique nodes'
from customer_nodes;

-- What is the number of nodes per region?

select region_name, count(node_id) 'total nodes per region'
from customer_nodes cn right join regions r on cn.region_id = r.region_id
group by 1;

-- How many customers are allocated to each region?

select region_name, count(distinct customer_id) 'total_customers'
from customer_nodes cn right join regions r on cn.region_id = r.region_id
group by 1;

-- How many days on average are customers reallocated to a different node?

select round(avg(datediff(end_date, start_date)), 0) 
from customer_nodes
where end_date!='9999-12-31';
