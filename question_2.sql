SELECT 
    EXTRACT(YEAR FROM DATE_TRUNC('day', orders_powerbi."Order Date"::timestamp)) AS Year,
    EXTRACT(MONTH FROM DATE_TRUNC('day', orders_powerbi."Order Date"::timestamp)) AS Month,
    SUM(orders_powerbi."Product Quantity" * CAST(REGEXP_REPLACE(dim_products.product_price, '[^0-9.]', '', 'g')
 AS NUMERIC)) AS Total_Revenue
FROM orders_powerbi
JOIN dim_products
ON orders_powerbi.product_code = dim_products.product_code
WHERE
    DATE_TRUNC('day', orders_powerbi."Order Date"::timestamp) BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY
    EXTRACT(YEAR FROM DATE_TRUNC('day', orders_powerbi."Order Date"::timestamp)), 
    EXTRACT(MONTH FROM DATE_TRUNC('day', orders_powerbi."Order Date"::timestamp))
ORDER BY 
    Total_Revenue DESC;

