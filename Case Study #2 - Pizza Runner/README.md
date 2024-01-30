# Case Study #2 - Pizza Runner
<p align="center"> <img src="https://8weeksqlchallenge.com/images/case-study-designs/2.png" height=620 width=500 > </p>

## Business Task
Did you know that over 115 million kilograms of pizza is consumed daily worldwide??? (Well according to Wikipedia anyway…)

Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”

Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

Because Danny had a few years of experience as a data scientist - he was very aware that data collection was going to be critical for his business’ growth.

He has prepared for us an entity relationship diagram of his database design but requires further assistance to clean his data and apply some basic calculations so he can better direct his runners and optimise Pizza Runner’s operations.

All datasets exist within the pizza_runner database schema - be sure to include this reference within your SQL scripts as you start exploring the data and answering the case study questions.

## Entity Relationship Diagram
<img src="https://github.com/manaswipatil/8-Week-SQL-Challenges/assets/50437663/e8ebc37a-1e29-4929-90ce-006fe534040f" />

## Data Cleaning & Transformation
There are some `null` values in the data that needs fixing up.

### Table: `customer_orders`
<img src="https://github.com/manaswipatil/8-Week-SQL-Challenges/assets/50437663/f63e1bcf-1b00-4a46-8faf-774199d5ed5c" />

- The columns exclusions and extras both contains null/ blank values/ `null` as string values.
- Created a temporary table with all the columns and fixed NULL values by replcing with empty string ''.

```sql
  SELECT
  order_id,
  customer_id,
  pizza_id,
  CASE WHEN exclusions IN (' ', 'null') OR exclusions is null THEN ''
  ELSE exclusions
  END AS exclusions,
  CASE WHEN extras IN (' ', 'null') OR extras is null THEN ''
  ELSE extras
  END AS extras,
  order_time
  INTO #customer_orders_cleaned
  From customer_orders;
```
<img src="https://github.com/manaswipatil/8-Week-SQL-Challenges/assets/50437663/9f2ae440-94d4-4dec-9afa-13dd8c6f1760" />

We will use `#customer_orders_cleaned` temporary table for all the queries.

### Table: `runner_orders`
<img src="https://github.com/manaswipatil/8-Week-SQL-Challenges/assets/50437663/c5678ad4-1cc0-45f7-859a-6718bf75c456" />

- The values in columns distance and duration has suffix as 'km', 'mins', 'minutes' etc., alsong with null values.
- The columns pickup_time and cancellation contains `NULL` values/ 'null' as string values.
- Created a temporary table with all the columns and fixed the `NULL` values / blank/empty values by replacing with a empty string ''.
- trimmed the values in distance and cancellation column to remove suffix.
- fixed datatypes for columns - `pickup_time` `distance` `duration`

```sql
 SELECT
  order_id,
  runner_id,
  CASE 
	WHEN pickup_time IN (' ', 'null') OR pickup_time is null THEN ''
	ELSE pickup_time
	END AS pickup_time,
  CASE 
	WHEN distance IN (' ', 'null') OR distance is null THEN ''
	WHEN distance LIKE '%km' THEN TRIM('km' from distance)
	ELSE distance
  END AS distance,
  CASE 
	WHEN duration IN (' ', 'null') OR duration is null THEN ''
	WHEN duration LIKE '%mins%' THEN TRIM('mins' from duration)
	WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
	WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
	
	ELSE duration
  END AS duration,
  CASE 
	WHEN cancellation IN (' ', 'null') OR cancellation is null THEN ''
	ELSE cancellation
  END AS cancellation
  INTO #runner_orders_cleaned
  From runner_orders;

 alter table #runner_orders_cleaned
  alter column pickup_time datetime;
  alter table #runner_orders_cleaned
  alter column distance float;
  alter table #runner_orders_cleaned
  alter column duration integer;

```
<img src="https://github.com/manaswipatil/8-Week-SQL-Challenges/assets/50437663/f2f537bd-0ea5-4383-b555-ade8df550f55" />

We will use `#runner_orders_cleaned` temporary table for all the queries.

## Case Study Questions & Solutions

## A. Pizza Metrics

### 1. How many pizzas were ordered?
````sql
SELECT COUNT(*) AS pizza_order_count
FROM #customer_orders_cleaned;
````
<img src="https://github.com/manaswipatil/8-Week-SQL-Challenges/assets/50437663/71ca6a35-c82e-47e5-8224-87725719b2e0" >

### 2. How many unique customer orders were made?
````sql
SELECT COUNT(DISTINCT order_id) AS unique_orders_count
FROM #customer_orders_cleaned;
````
<img src="https://github.com/manaswipatil/8-Week-SQL-Challenges/assets/50437663/05a41987-c707-4ec6-b522-dc0cb1b87a4d" >

### 3. How many successful orders were delivered by each runner?
```sql
SELECT 
	runner_id, 
	COUNT(order_id) AS successful_orders_count
FROM #runner_orders_cleaned
WHERE cancellation = ''
GROUP BY runner_id;
```
<img src="https://github.com/manaswipatil/8-Week-SQL-Challenges/assets/50437663/d73b22fd-bc89-426f-882f-e1c5b4692594" >

### 4. How many of each type of pizza was delivered?
```sql
SELECT 
	p.pizza_name, 
	COUNT(c.pizza_id) AS delivered_pizzas_count
FROM #customer_orders_cleaned c
JOIN #runner_orders_cleaned r ON c.order_id = r.order_id
JOIN pizza_names p ON c.pizza_id = p.pizza_id
WHERE r.cancellation = ''
GROUP BY p.pizza_name
;
```
<img src="https://github.com/manaswipatil/8-Week-SQL-Challenges/assets/50437663/cd8da373-0a13-4577-a49d-f8b3846d1b05" >

### 5. How many Vegetarian and Meatlovers were ordered by each customer?
```sql
SELECT 
	c.customer_id,
	p.pizza_name, 
	COUNT(c.pizza_id) AS delivered_pizzas_count
FROM #customer_orders_cleaned c
JOIN pizza_names p ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id, p.pizza_name
ORDER BY c.customer_id, p.pizza_name
;
```
<img src="https://github.com/manaswipatil/8-Week-SQL-Challenges/assets/50437663/bed5b525-5da1-4f6e-b320-6a77d749edf7" >

### 6. What was the maximum number of pizzas delivered in a single order?
```sql
SELECT
	c.order_id,
	COUNT(c.pizza_id) AS max_pizza_delivered
FROM #customer_orders_cleaned c
JOIN #runner_orders_cleaned r ON c.order_id = r.order_id
WHERE r.cancellation = ''
GROUP BY c.order_id
ORDER BY c.order_id
;
```
<img src="https://github.com/manaswipatil/8-Week-SQL-Challenges/assets/50437663/19456c56-b8f3-4e50-8e4c-3ec40cd00d87" >

### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
```sql
SELECT
	customer_id,
	SUM(CASE
		WHEN exclusions <> '' OR extras <> '' THEN 1
		ELSE 0
		END) AS "least 1 change",

	SUM(CASE
		WHEN exclusions = '' AND extras = '' THEN 1
		ELSE 0
		END) AS "No Changes"
FROM #customer_orders_cleaned c
JOIN #runner_orders_cleaned r ON c.order_id = r.order_id
WHERE r.cancellation = ''
GROUP BY customer_id
ORDER BY customer_id
;
```
<img src="https://github.com/manaswipatil/8-Week-SQL-Challenges/assets/50437663/dae1dc5f-b285-4c96-bc62-8f10f773395c" >

### 8. How many pizzas were delivered that had both exclusions and extras?
```sql
SELECT
	COUNT(c.order_id) AS "pizza with exclusions & extras"
FROM #customer_orders_cleaned c
JOIN #runner_orders_cleaned r 
ON c.order_id = r.order_id
WHERE r.cancellation = ''
AND exclusions <> '' 
AND extras <> ''
;
```
<img src="https://github.com/manaswipatil/8-Week-SQL-Challenges/assets/50437663/63941a57-5bd6-46b3-ba66-c299b132dee0" >

### 9. What was the total volume of pizzas ordered for each hour of the day?
                                                                       

### 10. What was the volume of orders for each day of the week?


