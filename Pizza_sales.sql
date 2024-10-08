-- Retrieve the total number of orders placed --
SELECT count(order_id) AS Total_Orders
FROM orders;
				-- OR --
SELECT count(distinct(order_id)) AS Total_Orders
FROM order_details ;

-- Calculate the total revenue generated from pizza sales. --
SELECT round(SUM(quantity*price),2) AS Total_Revenue
FROM Order_Details od
JOIN Pizzas p ON od.pizza_id = p.pizza_id;

-- Identify the highest-priced pizza. --
SELECT pt.name, p.price AS Highest_Price_Pizza
FROM pizza_types pt 
LEFT JOIN pizzas p ON pt.pizza_type_id=p.pizza_type_id 
ORDER BY price DESC
LIMIT 1;

-- Identify the most common pizza size ordered. --
SELECT p.size, sum(od.quantity) AS Highest_pizza_size_ord
FROM order_details od 
LEFT JOIN pizzas p ON od.pizza_id=p.pizza_id
GROUP BY p.size
ORDER BY Highest_pizza_size_ord DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities. --
SELECT pt.name, sum(od.quantity) AS Most_ord_pizzas
FROM order_details od 
LEFT JOIN pizzas p ON od.pizza_id=p.pizza_id 
JOIN pizza_types pt ON p.pizza_type_id=pt.pizza_type_id
GROUP BY pt.name
ORDER BY Most_ord_pizzas DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered. --
SELECT pt.category,sum(od.quantity) AS Ords_by_pizza_cat
FROM order_details od 
LEFT JOIN pizzas p ON od.pizza_id=p.pizza_id 
JOIN pizza_types pt ON p.pizza_type_id=pt.pizza_type_id
GROUP BY pt.category
ORDER BY Ords_by_pizza_cat DESC
;

-- Determine the distribution of orders by hour of the day. --
SELECT HOUR(time) AS Order_hour, count(order_id) AS Total_orders
FROM orders
GROUP BY HOUR(time)
ORDER BY Total_orders DESC ;

-- To find the category-wise distribution of pizzas. --
SELECT category, count(category) AS count
FROM pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day. --
SELECT  date AS Day, sum(od.quantity) AS Total_orders
FROM orders o
LEFT JOIN order_details od ON o.order_id=od.order_id
GROUP BY date;

-- Determine the top 3 most ordered pizza types based on revenue. --
SELECT pt.name, sum(quantity*price) AS Revenue
FROM order_details od 
LEFT JOIN pizzas p ON od.pizza_id=p.pizza_id 
JOIN pizza_types pt ON p.pizza_type_id=pt.pizza_type_id
GROUP BY pt.name
ORDER BY Revenue DESC
LIMIT 3
;

-- Calculate the percentage contribution of each pizza type to total revenue. --
WITH total_revenue_cte AS (
    SELECT ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
)
SELECT pt.name, 
       ROUND((SUM(od.quantity * p.price) / tr.total_revenue) * 100, 2) AS total_per_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
CROSS JOIN total_revenue_cte tr
GROUP BY pt.name, tr.total_revenue
ORDER BY total_per_revenue DESC;


--  Calculate cumulative revenue --
          -- Calculate daily revenue using CTE --
WITH RevenuePerDate AS (SELECT o.date, 
        ROUND(SUM(quantity * price), 2) AS Revenue
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY o.date
)
        -- Cumulative revenue --
SELECT date,Revenue,
    ROUND(SUM(Revenue) OVER (ORDER BY date), 2) AS Cumulative_Revenue
FROM RevenuePerDate
ORDER BY date;

-- Calculate the revenue generated by each pizza type grouped by category and type. --
WITH RevenuePerPizzaType AS (
    SELECT pt.category, pt.name AS pizza_type_name, ROUND(SUM(od.quantity * p.price), 2) AS Revenue  
    FROM pizza_types pt
    JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details od ON od.pizza_id = p.pizza_id
    GROUP BY pt.category, pt.name  
)
SELECT category, pizza_type_name, Revenue, `rank`  
FROM ( SELECT category, pizza_type_name, Revenue, 
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY Revenue DESC) AS `rank`  -- Generate rank within each category
    FROM RevenuePerPizzaType
) ranked_pizzas
WHERE `rank` <= 3;  




