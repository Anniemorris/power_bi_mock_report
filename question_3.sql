SELECT 
    dim_stores.store_type, 
    SUM(orders_powerbi."Product Quantity" * CAST(REGEXP_REPLACE(dim_products.product_price, '[^0-9.]', '', 'g')
 AS NUMERIC)) AS Total_Revenue
FROM 
    orders_powerbi
JOIN 
    dim_products
    ON orders_powerbi.product_code = dim_products.product_code
JOIN 
    dim_stores
    ON orders_powerbi."Store Code" = dim_stores."store code"
WHERE
    dim_stores.country_code = 'DE'
    AND EXTRACT(YEAR FROM orders_powerbi."Order Date"::DATE) = 2022
GROUP BY
    dim_stores.store_type
ORDER BY 
    Total_Revenue DESC;
