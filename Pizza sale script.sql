--  Pizza hut database analyses --

-- Create database 
create database if not exists pizzahut;

use pizzahut ;

-- Import using import wizard pizzas and pizzas type

-- check tables in pizzahut database
show tables ;

-- show data of above loaded tables
 select * from pizza_types ;
 select * from pizzahut.pizza_types ; 

 select * from pizzas ;
 select * from pizzahut.pizzas ;

-- Import  Order table by creating its table manually
create table orders ( order_id integer not null ,
					order_date date not null , 
                    order_time time not null , 
                    primary key (order_id)  );
-- now immport data using -data import wizard

-- Import  Order_details data  by creating its table manually    
create table if not exists order_detail ( order_details_id int not null , 
										order_id  int not null , 
                                        pizza_id text not null , 
                                        quantity int not null , 
                                        primary key (order_details_id) ) ;

-- change name of table order_detail to order_details
rename table order_detail to order_details ;

select * from order_details ;
select * from pizzahut.order_details ;

show tables;
select * from  order_details;
select * from  orders;
select * from  pizza_types;
select * from  pizzas;


-- Q1 Retreive the total number of orders placed
SELECT count(order_id) as total_orders from orders ; 

--  Q2 Calculate the total revenue generated from pizza sales. quantity x price (join)
select round(sum(order_details.quantity * pizzas.price),2) as total_sales
from order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id; 

-- Q3 Identify the highest-priced pizza. (join)
select pizza_types.name , pizzas.price
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc limit 1 ;

-- Q4 Identify the most common pizza size ordered. (join - group by)
select pizzas.size , count(order_details.order_details_id) as order_count 
from  pizzas
join order_details 
on pizzas.pizza_id = order_details.pizza_id 
group by pizzas.size
order by order_count desc limit 1 ; 

-- Q5 List the top 5 most ordered pizza types along with their quantities. (use of 3 tables)
select pt.name , sum(o.quantity) as total_order_quantity
from pizza_types as pt join pizzas as p
on  pt.pizza_type_id = p.pizza_type_id
join order_details as o
on o.pizza_id = p.pizza_id
group by pt.name 
order by total_order_quantity desc limit 5 ;


## -- Intermediate Questions -- ##
-- Q1 Join the necessary tables to find the total quantity of each pizza category ordered.
select pt.category , sum(od.quantity) as Quantity 
from pizza_types as pt 
join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
join order_details as od
on od.pizza_id = p.pizza_id 
group by pt.category 
order by quantity desc ; 

-- Q2 Determine the distribution of orders by hour of the day.
select hour(order_time) from orders ;  -- It will extract hour from order_time column
select hour(order_time) as order_hour , count(order_id) as order_count from orders group by order_hour order by order_count desc ; 

-- Q3  Join relevant tables to find the category-wise distribution of pizzas.
 select pt.category , count(od.quantity) as quantity
 from pizza_types as pt 
 Join pizzas as p 
 on pt.pizza_type_id = p.pizza_type_id
 join order_details as od 
 on p.pizza_id = od.pizza_id 
 group by pt.category order by quantity desc;
 
-- Q4 Group the orders by date and calculate the average number of pizzas ordered per day.
 select o.order_date , sum(od.quantity) as quantity 
from orders as o 
join order_details as od
on o.order_id = od.order_id 
group by o.order_date order by quantity desc ;                -- it will give total quantity on date basis now to calcualate avg we will use it as sub query

select round(avg(quantity),0) as avg_pizza_ordered_perday from
(select o.order_date , sum(od.quantity) as quantity 
from orders as o 
join order_details as od
on o.order_id = od.order_id 
group by o.order_date order by quantity desc) as total_quantity ;     -- This will return avg per day order

-- Q5 Determine the top 3 most ordered pizza types based on revenue.
select pt.name , sum(od.quantity*p.price) as revenue
from pizza_types as pt
join pizzas as p
on p.pizza_type_id = pt.pizza_type_id
join order_details as od
on od.pizza_id = p.pizza_id 
group by pt.name order by revenue desc limit 3 ; 

## -- Advanced level -- ##
-- Q1 Calculate the percentage contribution of each pizza type to total revenue.
select pt.category , sum(od.quantity*p.price)
from pizza_types as pt
join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
join order_details as od 
on  od.pizza_id = p.pizza_id
group by pt.category ;    -- it will return category wise total revenue

 -- way -- using sub query
select pt.category , ROUND(sum(od.quantity * p.price)*100  / 
						(select sum(od2.quantity*p2.price) from order_details as od2 join pizzas as p2 on od2.pizza_id = p2.pizza_id),2) as revenue_percentage
		from pizza_types as pt
		join pizzas as p
		on pt.pizza_type_id = p.pizza_type_id
		join order_details as od 
		on  od.pizza_id = p.pizza_id
		group by pt.category ;               
 
 -- Q2 Analyze the cumulative revenue generated over time. for cumulative we use window function
  SELECT 
    o.order_date,
    ROUND(SUM(od.quantity * p.price), 2) AS daily_revenue,
    ROUND(SUM(SUM(od.quantity * p.price)) OVER (ORDER BY o.order_date), 2) AS cumulative_revenue
	FROM orders o
	JOIN order_details od 
	ON o.order_id = od.order_id
	JOIN pizzas p 
	ON od.pizza_id = p.pizza_id
	GROUP BY order_date
	ORDER BY o.order_date;
      
-- Q3 Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category ,name , revenue  from
(select category , name , revenue , rank() over(partition by category order by revenue desc ) as rn
from
(select pt.category , pt.name , sum(od.quantity * p.price) as revenue
from pizza_types as pt 
join pizzas as p 
on p.pizza_type_id = pt.pizza_type_id
join order_details as od
on od.pizza_id = p.pizza_id
group by pt.category , pt.name) as a) as b
where rn <= 3 ;


select * from  order_details;
select * from  orders;
select * from  pizza_types;
select * from  pizzas;


                                       
