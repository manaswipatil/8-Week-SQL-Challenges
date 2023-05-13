
--1. What is the total amount each customer spent at the restaurant?


    SELECT customer_id, sum(price)
    FROM dannys_diner.sales s
    inner join dannys_diner.menu m
    on s.product_id = m.product_id
    GROUP BY customer_id
    ORDER BY customer_id;

| customer_id | sum |
| ----------- | --- |
| A           | 76  |
| B           | 74  |
| C           | 36  |

--------------------------------------------------------------------------------------------------------------

--2. How many days has each customer visited the restaurant?


    SELECT customer_id, count(distinct order_date)
    FROM dannys_diner.sales
    GROUP BY customer_id
    ORDER BY customer_id;

| customer_id | count |
| ----------- | ----- |
| A           | 4     |
| B           | 6     |
| C           | 2     |

---------------------------------------------------------------------------------------------------------------

--3. What was the first item from the menu purchased by each customer?


    with first_order as
    (
      SELECT customer_id, min(order_date) AS order_date
    FROM dannys_diner.sales s
    GROUP BY customer_id
    ORDER BY customer_id
    )
    
    SELECT customer_id, string_agg(distinct product_name, ',')
    from dannys_diner.sales s
    inner join first_order f using(customer_id)
    inner join dannys_diner.menu m using(product_id)
    where s.order_date = f.order_date
    GROUP BY customer_id
    ;

| customer_id | string_agg  |
| ----------- | ----------- |
| A           | curry,sushi |
| B           | curry       |
| C           | ramen       |

------------------------------------------------------------------------------------------------------------------

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?


    WITH most_purchased as
    (
    SELECT product_id, count(product_id) 
    FROM dannys_diner.sales
    GROUP BY PRODUCT_ID
    LIMIT 1
    )
    
    SELECT customer_id, product_name, count(product_id)
    FROM dannys_diner.sales s
    INNER JOIN most_purchased mp USING(product_id)
    INNER JOIN dannys_diner.menu m USING(product_id)
    WHERE product_id = mp.product_id
    GROUP BY customer_id, product_name
    ;

| customer_id | product_name | count |
| ----------- | ------------ | ----- |
| B           | ramen        | 2     |
| A           | ramen        | 3     |
| C           | ramen        | 3     |

------------------------------------------------------------------------------------------------------------------

--5. Which item was the most popular for each customer?


    WITH item_rank AS
    (SELECT customer_id, product_id, 
    	count(product_id) as item_count
        ,DENSE_RANK() over (partition by customer_id ORDER BY count(product_id) desc) as rank
    FROM dannys_diner.sales
    GROUP BY customer_id, product_id
    ORDER BY customer_id, product_id
    )
    
    SELECT customer_id, STRING_AGG(product_name, ',')
    FROM item_rank r
    INNER JOIN dannys_diner.menu m USING(product_id)
    WHERE r.rank = 1
    GROUP BY customer_id
    ORDER BY customer_id
    ;

| customer_id | string_agg        |
| ----------- | ----------------- |
| A           | ramen             |
| B           | sushi,curry,ramen |
| C           | ramen             |

------------------------------------------------------------------------------------------------------------------

-- 6. Which item was purchased first by the customer after they became a member?


    WITH member_purchase AS
    (
    SELECT s.customer_id, s.order_date, m.product_name,
    	rank() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) as rn
    FROM dannys_diner.members mem
    INNER JOIN dannys_diner.sales s using (customer_id)
    INNER JOIN dannys_diner.menu m ON s.product_id = m.product_id
    WHERE s.order_date >= mem.join_date)
    
    SELECT *
    FROM member_purchase
    WHERE RN = 1;

| customer_id | order_date               | product_name | rn  |
| ----------- | ------------------------ | ------------ | --- |
| A           | 2021-01-07T00:00:00.000Z | curry        | 1   |
| B           | 2021-01-11T00:00:00.000Z | sushi        | 1   |

------------------------------------------------------------------------------------------------------------------

-- 7. Which item was purchased just before the customer became a member?


    WITH before_member_purchase AS
    (
    SELECT s.customer_id, s.order_date, m.product_name,
    	rank() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) as rn
    FROM dannys_diner.members mem
    INNER JOIN dannys_diner.sales s using (customer_id)
    INNER JOIN dannys_diner.menu m ON s.product_id = m.product_id
    WHERE s.order_date < mem.join_date
    )
    
    SELECT customer_id, order_date, STRING_AGG(product_name, ',') AS items_purchased
    FROM before_member_purchase
    WHERE rn = 1
    GROUP BY customer_id, order_date
    ;

| customer_id | order_date               | items_purchased |
| ----------- | ------------------------ | --------------- |
| A           | 2021-01-01T00:00:00.000Z | sushi,curry     |
| B           | 2021-01-04T00:00:00.000Z | sushi           |

------------------------------------------------------------------------------------------------------------------

-- 8. What is the total items and amount spent for each member before they became a member?


    SELECT s.customer_id, COUNT(m.product_name) as items_purchased, SUM(m.price) as amount_spent
        FROM dannys_diner.members mem
        INNER JOIN dannys_diner.sales s using (customer_id)
        INNER JOIN dannys_diner.menu m ON s.product_id = m.product_id
        WHERE s.order_date < mem.join_date
        GROUP BY S.customer_id
        ORDER BY S.customer_id;

| customer_id | items_purchased | amount_spent |
| ----------- | --------------- | ------------ |
| A           | 2               | 25           |
| B           | 3               | 40           |

------------------------------------------------------------------------------------------------------------------

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?


    WITH price_points as
    (
    SELECT *,
    CASE WHEN product_id = 1 then price*20
      ELSE price*10
      END as points
    FROM dannys_diner.menu
      )
      
    SELECT s.customer_id, sum(p.points) as points_earned
    FROM dannys_diner.sales s
    INNER JOIN price_points p ON s.product_id = p.product_id
    GROUP BY s.customer_id
    ORDER BY s.customer_id;

| customer_id | points_earned |
| ----------- | ------------- |
| A           | 860           |
| B           | 940           |
| C           | 360           |

------------------------------------------------------------------------------------------------------------------

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


    WITH offer_dates AS
    (
    SELECT customer_id, join_date, (join_date + integer '6') as Validity_date
    FROM dannys_diner.members
    )
    
    SELECT s.customer_id,
    	SUM(CASE WHEN s.order_date between d.join_date and d.Validity_date THEN price*20
        WHEN s.product_id = 1 THEN price*20
        ELSE price*10
        END) AS points
    FROM dannys_diner.sales s
    INNER JOIN offer_dates d USING(customer_id)
    INNER JOIN dannys_diner.menu m USING(product_id)
    WHERE EXTRACT(month from s.order_date) = 01
    GROUP BY s.customer_id
    ORDER BY s.customer_id
    ;

| customer_id | points |
| ----------- | ------ |
| A           | 1370   |
| B           | 820    |

------------------------------------------------------------------------------------------------------------------
