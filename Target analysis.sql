#1. Data type of all columns in the "customers" table.
#2. Get the time range between which the orders were placed.
SELECT 
MIN(order_purchase_timestamp) as start_time,
MAX(order_purchase_timestamp) as end_time
FROM `Target_SQL.orders`;

#Count the Cities & States of customers who ordered during the given 
#period.

SELECT 
c.customer_city,c.customer_state
FROM `Target_SQL.orders` as o
JOIN `Target_SQL.customers` as c
ON o.customer_id = c.customer_id
WHERE EXTRACT (YEAR from o.order_purchase_timestamp) = 2018
AND EXTRACT (MONTH from o.order_purchase_timestamp) BETWEEN 1 AND 3;

#Is there a growing trend in the no. of orders placed over the past years?
SELECT
COUNT(order_id) AS Orders,
EXTRACT (MONTH from order_purchase_timestamp) 
FROM `Target_SQL.orders`
GROUP BY EXTRACT (MONTH from order_purchase_timestamp)
ORDER BY EXTRACT (MONTH from order_purchase_timestamp);

#During what time of the day, do the Brazilian customers mostly place
#their orders? (Dawn, Morning, Afternoon or Night)
#■ 0-6 hrs : Dawn
#■ 7-12 hrs : Mornings
#■ 13-18 hrs : Afternoon
#■ 19-23 hrs : Night

SELECT 
COUNT(order_id),
EXTRACT (HOUR from order_purchase_timestamp)
FROM `Target_SQL.orders`
GROUP BY EXTRACT (HOUR from order_purchase_timestamp)
ORDER BY COUNT(order_id) DESC;

#3. Evolution of E-commerce orders in the Brazil region:
#1. Get the month on month no. of orders 

SELECT 
EXTRACT (MONTH from order_purchase_timestamp) AS Month,
EXTRACT (YEAR from order_purchase_timestamp) AS Year,
COUNT(*) 
FROM `Target_SQL.orders`
GROUP BY Month,Year
ORDER BY Month,Year;

#How are the customers distributed across all the states,city?
SELECT COUNT(DISTINCT customer_id),customer_state,customer_city
FROM `Target_SQL.customers`
GROUP BY customer_state,customer_city
ORDER BY COUNT( customer_id) DESC;

#Get the % increase in the cost of orders from year 2017 to 2018
#(include months between Jan to Aug only).
#You can use the "payment_value" column in the payments table to get
#the cost of orders.
WITH current_cte AS (
SELECT 
SUM(p.payment_value)as total_payment,
EXTRACT (YEAR from o.order_purchase_timestamp) AS Year
FROM `Target_SQL.orders` AS o
JOIN `Target_SQL.payments`AS p
ON o.order_id = p.order_id
WHERE EXTRACT(YEAR from o.order_purchase_timestamp) IN  (2017,2018) 
AND EXTRACT(MONTH from o.order_purchase_timestamp) BETWEEN 1 AND 8
GROUP BY Year
),

yearly_comparison AS (
SELECT
year,
total_payment,
LEAD(total_payment) OVER(ORDER BY Year desc) as prev_year
from current_cte
)

SELECT ROUND(((total_payment-prev_year)/prev_year)*100,2)
from yearly_comparison;

#Calculate the Total & Average value of order price for each state.

SELECT c.customer_state,
ROUND(SUM(oi.price),1) AS Total_price,
ROUND(AVG(oi.price),1) AS avg_price
FROM `Target_SQL.order_items` as oi
JOIN `Target_SQL.orders` as o
ON oi.order_id = o.order_id
JOIN `Target_SQL.customers` as c
ON o.customer_id = c.customer_id
GROUP BY c.customer_state;

#Calculate the Total & Average value of order freight for each state.

SELECT c.customer_state,
ROUND(SUM(oi.freight_value),1) AS Total_value,
ROUND(AVG(oi.freight_value),1) AS avg_value
FROM `Target_SQL.order_items` as oi
JOIN `Target_SQL.orders` as o
ON oi.order_id = o.order_id
JOIN `Target_SQL.customers` as c
ON o.customer_id = c.customer_id
GROUP BY c.customer_state;

#1. Find the no. of days taken to deliver each order from the order’s
#purchase date as delivery time.
#Also, calculate the difference (in days) between the estimated & actual
#delivery date of an order.
#Do this in a single query.


SELECT order_id,
DATE_DIFF(DATE(order_delivered_customer_date),DATE(order_purchase_timestamp),DAY) AS no_of_days_taken,
DATE_DIFF(DATE(order_delivered_customer_date),DATE(order_estimated_delivery_date),DAY) AS diff_ines
FROM `Target_SQL.orders`;

#Find out the top 5 states with the highest & lowest average freight
#value.
SELECT c.customer_state,
AVG(oi.freight_value)
FROM `Target_SQL.order_items` as oi
JOIN `Target_SQL.orders` as o
ON oi.order_id = o.order_id
JOIN `Target_SQL.customers` as c
ON o.customer_id = c.customer_id
GROUP BY c.customer_state

ORDER BY AVG(oi.freight_value) DESC
LIMIT 5;

#Find out the top 5 states with the highest & lowest average delivery
#time.
SELECT c.customer_state,
AVG(EXTRACT(DATE from o.order_delivered_customer_date) - EXTRACT(DATE from o.order_purchase_timestamp)) as avg_time_delivery
FROM `Target_SQL.order_items` as oi
JOIN `Target_SQL.orders` as o
ON oi.order_id = o.order_id
JOIN `Target_SQL.customers` as c
ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY avg_time_delivery
LIMIT 5;

#Find out the top 5 states where the order delivery is really fast as
#compared to the estimated date of delivery.
SELECT c.customer_state,
AVG(EXTRACT(DATE from o.order_delivered_customer_date) - EXTRACT(DATE from o.order_estimated_delivery_date)) as time_delivery
FROM `Target_SQL.order_items` as oi
JOIN `Target_SQL.orders` as o
ON oi.order_id = o.order_id
JOIN `Target_SQL.customers` as c
ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY time_delivery 
LIMIT 5;

#Find the month on month no. of orders placed using different payment
#types.
SELECT count(*),p.payment_type,
EXTRACT(MONTH FROM o.order_purchase_timestamp) as month,
EXTRACT(YEAR FROM o.order_purchase_timestamp) as YEAR
FROM `Target_SQL.orders` as o 
JOIN `Target_SQL.payments` as p   
ON o.order_id = p.order_id
GROUP BY month,p.payment_type,YEAR
ORDER BY month,p.payment_type,YEAR;

#Find the no. of orders placed on the basis of the payment installments
#that have been paid.

SELECT count(order_id) AS num_orders ,payment_installments
FROM `Target_SQL.payments`
GROUP BY payment_installments


