#Customer Insights
#Identify the top 10 customers by order value.

SELECT 
    blinkit_customers.customer_id,
    blinkit_customers.customer_name,
    SUM(blinkit_orders.order_total) AS order_value
FROM
    blinkit_customers
        JOIN
    blinkit_orders ON blinkit_customers.customer_id = blinkit_orders.customer_id
GROUP BY 1 , 2
ORDER BY order_value DESC
LIMIT 10;

#count the number of customers in each segment (Premium, Regular, Inactive, New)

SELECT 
    customer_segment,
    COUNT(DISTINCT customer_id) AS Number_of_customers_in_each_segment
FROM
    blinkit_customers
GROUP BY 1;

#find the customers with an average order value more than 500 and more than 10 orders

SELECT 
    customer_id, customer_name
FROM
    blinkit_customers
WHERE
    avg_order_value > 500
        AND total_orders > 10;

#Order and Delivery Performance
#List orders that were delivered late along with reasons for delay

SELECT 
    order_id, delivery_status, reasons_if_delayed
FROM
    blinkit_delivery_performance
WHERE
    delivery_status NOT IN ('On Time');

#calculate the average delivery time (in minutes) per delivery partner

SELECT 
    blinkit_delivery_performance.delivery_partner_id,
    AVG(TIMESTAMPDIFF(MINUTE,
        blinkit_orders.order_date,
        blinkit_orders.actual_delivery_time)) AS average_delivery_time
FROM
    blinkit_delivery_performance
        JOIN
    blinkit_orders ON blinkit_delivery_performance.order_id = blinkit_orders.order_id
GROUP BY 1;

#find the top 5 stores by total order revenue

SELECT 
    blinkit_orders.store_id,
    SUM(blinkit_order_items.quantity * blinkit_order_items.unit_price) AS Revenue
FROM
    blinkit_orders
        JOIN
    blinkit_order_items ON blinkit_orders.order_id = blinkit_order_items.order_id
GROUP BY 1
ORDER BY Revenue DESC
LIMIT 5;


#Product and Inventory Analysis
#identity products that have had damaged stocks more than 5 times in total

SELECT 
    blinkit_products.product_name, blinkit_products.product_id,
    SUM(damaged_stock) AS total_damaged_count
FROM (
    SELECT product_id, damaged_stock
    FROM blinkit_inventory
    WHERE damaged_stock > 0

    UNION ALL

    SELECT product_id, damaged_stock
    FROM blinkit_inventoryNew
    WHERE damaged_stock > 0
) AS combined_inventory join blinkit_products on combined_inventory.product_id = blinkit_products.product_id
GROUP BY 
    1, 2
HAVING 
    SUM(damaged_stock) > 5;
    
    
#calcuate the total quantity ordered for each product

SELECT 
    blinkit_products.product_name,
    blinkit_products.product_id,
    SUM(blinkit_order_items.quantity) AS Total_Quantity_Ordered
FROM
    blinkit_products
        LEFT JOIN
    blinkit_order_items ON blinkit_products.product_id = blinkit_order_items.product_id
GROUP BY 1 , 2;

#find products that often fall below the minimum stock level (compare current stock with min stock)

SELECT 
    blinkit_products.product_id,
    blinkit_products.product_name,
    blinkit_products.min_stock_level,
    stock_summary.total_current_stock,
    (blinkit_products.min_stock_level - stock_summary.total_current_stock) AS stock_gap
FROM (
    SELECT 
        product_id,
        SUM(GREATEST(stock_received - damaged_stock, 0)) AS total_current_stock
    FROM blinkit_inventory
    GROUP BY product_id
) AS stock_summary
JOIN blinkit_products ON stock_summary.product_id = blinkit_products.product_id
WHERE stock_summary.total_current_stock < blinkit_products.min_stock_level
ORDER BY stock_gap DESC;


#Marketing Campaign Effectiveness
#calculate total revenue generated and ROAS for each marketing campaign

SELECT 
    campaign_id,
    campaign_name,
    SUM(revenue_generated) AS Total_Revenue_Generated,
    SUM(roas) AS Total_ROAS
FROM
    blinkit_marketing_performance
GROUP BY 1 , 2;


#find the campaign with the highest conversion rate (conversion/impression)

SELECT 
    campaign_id,
    campaign_name,
    SUM(conversions / impressions) AS Conversion_Rate
FROM
    blinkit_marketing_performance
GROUP BY 1 , 2
ORDER BY Conversion_Rate DESC
LIMIT 1;


#list all campaigns targetted at premium customers and their performance metrics

SELECT 
    campaign_id,
    campaign_name,
    target_audience,
    SUM((conversions / impressions) * 100) AS Conversion_Rate,
    SUM(spend / conversions) AS Cost_per_Conversion,
    SUM((clicks / impressions) * 100) AS Click_Through_Rate
FROM
    blinkit_marketing_performance
WHERE
    target_audience = 'Premium'
GROUP BY 1 , 2 , 3;



#Customer Feedback Analysis
#Count feedback entries by sentiment (Positive, Neutral, Negative)

SELECT 
    sentiment, COUNT(sentiment) AS Feedback_Count
FROM
    blinkit_customer_feedback
GROUP BY 1;

#list customers negative feedback and their corresponding orders

SELECT 
    blinkit_customer_feedback.customer_id,
    blinkit_customers.customer_name,
    blinkit_customer_feedback.order_id,
    blinkit_customer_feedback.sentiment
FROM
    blinkit_customer_feedback
        JOIN
    blinkit_customers ON blinkit_customer_feedback.customer_id = blinkit_customers.customer_id
WHERE
    blinkit_customer_feedback.sentiment = 'Negative';





