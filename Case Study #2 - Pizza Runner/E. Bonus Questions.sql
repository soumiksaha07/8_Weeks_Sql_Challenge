-- If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

insert into pizza_names (pizza_id, pizza_name)
values (3, 'Supreme');

insert into pizza_recipes (pizza_id, toppings)
values (3, (select group_concat(topping_id separator ',') from pizza_toppings));

select pn.pizza_id, pizza_name, toppings
from pizza_names pn inner join pizza_recipes pr on pn.pizza_id = pr.pizza_id
group by 1,2,3
order by 1 asc;
