--Q1 Find out the top 5 customers who made the highest profits.
SELECT 
    c.customer_id,
    c.customer_name,
    SUM(o.sale - p.cogs * o.quantity) AS total_profit
FROM 
    customers c
JOIN 
    orders o ON c.customer_id = o.customer_id
JOIN 
    products p ON o.product_id = p.product_id
GROUP BY 
    c.customer_id,
    c.customer_name
ORDER BY 
    total_profit DESC
LIMIT 5;

-- Q2 Find out the average quantity ordered per category

SELECT category,
		AVG(quantity) as avg_quantity
		FROM orders
		WHERE category is not NULL
		GROUP BY 1
		ORDER BY 2 DESC
		
---Q3 Identify the top 5 products that have generated the highest revenue.

SELECT product_id,
	   product_name,
	   revenue,
	   dn
FROM(
	Select o.product_id,
	   p.product_name,
	   ROUND(SUM(o.sale)::NUMERIC,2) as revenue,
	   DENSE_RANK() OVER(Order BY SUM(o.sale) DESC) as dn
	   FROM orders as o
	   JOIN products as p
	   ON o.product_id = p.product_id
	   GROUP BY 1 , 2
)
WHERE dn<6

--Q4 Determine the top 5 products whose revenue has decreased compared to previous year(2022)
-- product_id ,last_year_revenue ,current_year(2023) _revenue  and decrease ratio
WITH lastyear_rev
AS
(SELECT 
     product_id,
	 SUM(sale) as total_sale
FROM orders
WHERE EXTRACT(Year FROM Order_date)=2022
Group BY 1
),
cur_year_rev
AS
(SELECT 
     product_id,
	 SUM(sale) as total_sale
FROM orders
WHERE EXTRACT(Year FROM Order_date)=2023
Group BY 1
)
SELECT lr.product_id,
       lr.total_sale as last_year_sale,
	   cr.total_sale as cur_year_sale,
	   (lr.total_sale - cr.total_sale)/lr.total_sale * 100 as Decrease_ratio
	   FROM lastyear_rev as lr
	   JOIN cur_year_rev as cr
	   ON lr.product_id=cr.product_id
	   WHERE lr.total_sale>cr.total_sale
	   ORDER BY 4 DESC Limit 5


--Q5 Identify the highest profitable sub-category.

SELECT o.sub_category,
	   SUM(o.quantity*(p.price - p.cogs) ) as profit
	   FROM Orders as o
	   JOIN Products as p
	   ON o.product_id = p.product_id
	   GROUP BY 1
	   ORDER BY 2 DESC
	   LIMIT 1
	   
--Q6 Find out the top 5 states with the highest total orders.
SELECT state,
       no_of_orders,
	   dn
FROM
(SELECT state,
	   COUNT(order_id) as no_of_orders,
	   DENSE_RANK() OVER(ORDER BY COUNT(order_id) DESC) as dn
	   FROM orders
	   WHERE state is NOT NULL
	   GROUP BY 1
	   ORDER BY 2 DESC
) WHERE dn<6

--Q7 Determine the month with the highest number of orders.
SELECT EXTRACT(Month FROM order_date ) as order_month ,
       COUNT(order_id) as no_of_orders
	   FROM orders
	   GROUP BY 1
	   ORDER BY 2 DESC
	   LIMIT 1
	   
--Q8 Calculate the profit margin percentage for each sale (Profit divided by Sales).

SELECT ROUND((((o.quantity*(p.price - p.cogs))/o.sale)*100)::NUMERIC ,2)as profit_margin
	   FROM Orders as o
	   JOIN Products as p
	   ON o.product_id = p.product_id
	  
	  
	  
--Q9 Calculate the percentage contribution of each sub-category

--sales percentage contribution
SELECT sub_category,
       SUM(sale),
	   ROUND(((SUM(sale)/ (SELECT SUM(sale) FROM orders))*100)::NUMERIC,2) as Percent_contri
	   FROM orders
	   GROUP BY 1 	   
--orders percentage contribution
SELECT sub_category,
       COUNT(order_id),
	   ROUND(((COUNT(order_id)*100/ (SELECT COUNT(order_id) FROM orders)))::NUMERIC,4)
	   as Percent_contri
	   FROM orders
	   GROUP BY 1
	   
	   

--Q10 Identify the top 2 categories that have received maximum returns and their return percentage.

SELECT o.category,
	   COUNT(o.order_id),
	   (COUNT(o.order_id)*100)/(SELECT COUNT(*) FROM Returns) as return_percentage
       FROM Orders as o
	   JOIN returns as r
	   ON o.order_id = r.order_id
	   GROUP BY 1
	   ORDER BY 3 DESC
	   LIMIT 2



--- return percentage based on the total no.of orders in each category
--- returns in each category / total no. of orders in each category
WITH category_totals AS 
( 
	 SELECT  
	  category,
	  COUNT(*) as total_orders
	  FROM Orders 
	  GROUP BY 1

),
category_returns AS
(
	SELECT
	o.category,
	COUNT(*) as total_returns
	FROM Orders as o
	JOIN Returns as r
	ON o.order_id=r.order_id
	GROUP BY 1
)
SELECT ct.category,
       ct.total_orders,
	   COALESCE(cr.total_returns, 0) AS total_returns,
	   (COALESCE(cr.total_returns, 0)*100/ct.total_orders) AS return_percentage
	   FROM category_totals as ct
	   JOIN category_returns as cr
	   ON ct.category=cr.category
       


	    
	   

		
		














