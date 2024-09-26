-- 3.1. In relation to the products:

-- What categories of tech products does Magist have?

/* 'computers'
'computers_accessories'
'electronics'
'pc_gamer'
'tablets_printing_image'
'telephony' */

-- How many products of these tech categories have been sold (within the time window of the database snapshot)? 
-- 3858 

SELECT T.product_category_name_english, COUNT(DISTINCT OI.product_id) AS sold_products
FROM products AS P
JOIN product_category_name_translation AS T ON P.product_category_name = T.product_category_name
JOIN order_items AS OI ON P.product_id = OI.product_id
WHERE T.product_category_name_english IN ('computers', 'computers_accessories', 'electronics', 'pc_gamer', 'tablets_printing_image', 'telephony', 'consoles_games', 'signaling_and_security', 'fixed_telephony')
GROUP BY T.product_category_name_english
ORDER BY sold_products DESC;


-- What percentage does that represent from the overall number of products sold?

SELECT COUNT(DISTINCT (OI.product_id)) AS sold_tech_products
FROM products AS P
JOIN product_category_name_translation AS T ON P.product_category_name = T.product_category_name
JOIN order_items AS OI ON P.product_id = OI.product_id
WHERE T.product_category_name_english IN ('computers', 'computers_accessories', 'electronics', 'pc_gamer', 'tablets_printing_image', 'telephony', 'consoles_games', 'signaling_and_security', 'fixed_telephony');

SELECT COUNT(DISTINCT product_id) AS total_sold_products
FROM order_items;
-- (3858 / 32951)*100 = 11,7 %


-- What’s the average price of the products being sold? : 120.65

SELECT AVG(price)
FROM order_items;


-- Are expensive tech products popular? * no

SELECT 
    COUNT(OI.product_id) AS sold_products,
    CASE
        WHEN OI.price >= 1000 THEN 'yes'
        ELSE 'no'
    END AS isexpensive
FROM
    products AS P JOIN product_category_name_translation AS T ON P.product_category_name = T.product_category_name
	JOIN order_items AS OI ON P.product_id = OI.product_id
WHERE T.product_category_name_english IN ('computers', 'computers_accessories', 'electronics', 'pc_gamer', 'tablets_printing_image', 'telephony', 'consoles_games', 'signaling_and_security', 'fixed_telephony')
GROUP BY isexpensive
ORDER BY sold_products DESC;




-- 3.2. In relation to the sellers:

-- How many months of data are included in the magist database? --- 25 months

SELECT  TIMESTAMPDIFF(MONTH, MIN(order_purchase_timestamp), MAX(order_purchase_timestamp))
FROM orders;


-- How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers? 3095

SELECT COUNT(DISTINCT seller_id) 
FROM sellers;


SELECT 
    COUNT(DISTINCT OI.seller_id) AS seller_tech
FROM
    products AS P
        JOIN
    product_category_name_translation AS T ON P.product_category_name = T.product_category_name
        JOIN
    order_items AS OI ON P.product_id = OI.product_id
WHERE
    T.product_category_name_english IN ('computers' , 'computers_accessories',
        'electronics',
        'pc_gamer',
        'tablets_printing_image',
        'telephony',
        'consoles_games',
        'signaling_and_security',
        'fixed_telephony');


				-- percentage (511 / 3095) * 100 = 15,51 %



-- What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers?

SELECT SUM(OI.price) AS total
FROM
    order_items OI
        LEFT JOIN
    orders o USING (order_id)
WHERE
    o.order_status NOT IN ('unavailable' , 'canceled');



SELECT 
    SUM(oi.price) AS total
FROM
    order_items oi
        LEFT JOIN
    orders o USING (order_id)
        LEFT JOIN
    products p USING (product_id)
        LEFT JOIN
    product_category_name_translation pt USING (product_category_name)
WHERE
    o.order_status NOT IN ('unavailable' , 'canceled')
        AND pt.product_category_name_english IN ('computers' , 'computers_accessories',
        'electronics',
        'pc_gamer',
        'tablets_printing_image',
        'telephony',
        'consoles_games',
        'signaling_and_security',
        'fixed_telephony');




-- (3094387.351388624 / 16008872.139586091) * 100 = 19.33 % 

-- Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?

SELECT 13494400.74/ 3095 / 25;
SELECT 1666211.28 / 454 / 25;


-- 3.3. In relation to the delivery time:
-- What’s the average time between the order being placed and the product being delivered?


SELECT order_purchase_timestamp, order_delivered_customer_date FROM orders;

SELECT TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date) as days_AVG
FROM orders
ORDER BY days_AVG DESC;

SELECT AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)) as days_AVG
FROM orders;
-- 12,1 days


-- How many orders are delivered on time vs orders delivered with a delay?

SELECT 
    SUM(CASE 
		WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN '1'
        WHEN order_estimated_delivery_date = NULL THEN 0
        WHEN order_delivered_customer_date = NULL THEN 0
        ELSE 0
    END) AS 'on time',
    SUM(CASE 
		WHEN order_delivered_customer_date > order_estimated_delivery_date THEN '1'
		WHEN order_estimated_delivery_date = NULL THEN 0
        WHEN order_delivered_customer_date = NULL THEN 0
        ELSE 0
    END) AS 'delayed'
FROM
    orders
;

-- 91 % are deliver on time --


-- Is there any pattern for delayed orders, e.g. big products being delayed more often?

SELECT OI.price, OI.freight_value,P.product_weight_g, P.product_length_cm, P.product_height_cm, P.product_width_cm,
CASE 
		WHEN O.order_delivered_customer_date > O.order_estimated_delivery_date THEN 'delayed'
        ELSE 'on time'
    END AS delivery_status
FROM orders as O
JOIN order_items AS OI ON O.order_id=OI.order_id
JOIN products AS P ON OI.product_id = P.product_id;
;

SELECT 
    CASE 
        WHEN OI.price < 100 THEN 'Low price'
        WHEN OI.price BETWEEN 100 AND 500 THEN 'Medium price'
        ELSE 'High price'
    END AS price_range,
    COUNT(CASE 
        WHEN O.order_delivered_customer_date > O.order_estimated_delivery_date THEN 1 
    END) AS delayed_orders,
    COUNT(*) AS total_orders,
    (COUNT(CASE 
        WHEN O.order_delivered_customer_date > O.order_estimated_delivery_date THEN 1 
    END) / COUNT(*)) * 100 AS delay_percentage
FROM orders AS O
JOIN order_items AS OI ON O.order_id = OI.order_id
GROUP BY price_range;

SELECT 
    CASE 
        WHEN P.product_weight_g < 1000 THEN 'Light'
        WHEN P.product_weight_g BETWEEN 1000 AND 5000 THEN 'Medium'
        ELSE 'Heavy'
    END AS weight_range,
    COUNT(CASE 
        WHEN O.order_delivered_customer_date > O.order_estimated_delivery_date THEN 1 
    END) AS delayed_orders,
    COUNT(*) AS total_orders,
    (COUNT(CASE 
        WHEN O.order_delivered_customer_date > O.order_estimated_delivery_date THEN 1 
    END) / COUNT(*)) * 100 AS delay_percentage
FROM orders AS O
JOIN order_items AS OI ON O.order_id = OI.order_id
JOIN products AS P ON OI.product_id = P.product_id
GROUP BY weight_range;

SELECT 
    CASE 
        WHEN OI.freight_value < 20 THEN 'Low freight'
        WHEN OI.freight_value BETWEEN 20 AND 50 THEN 'Medium freight'
        ELSE 'High freight'
    END AS freight_range,
    COUNT(CASE 
        WHEN O.order_delivered_customer_date > O.order_estimated_delivery_date THEN 1 
    END) AS delayed_orders,
    COUNT(*) AS total_orders,
    (COUNT(CASE 
        WHEN O.order_delivered_customer_date > O.order_estimated_delivery_date THEN 1 
    END) / COUNT(*)) * 100 AS delay_percentage
FROM orders AS O
JOIN order_items AS OI ON O.order_id = OI.order_id
GROUP BY freight_range;

