# Case Study #2 - Pizza Runner
<img src="https://8weeksqlchallenge.com/images/case-study-designs/2.png" height=620 width=500 />

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




