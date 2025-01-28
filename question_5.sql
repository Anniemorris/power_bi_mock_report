SELECT 
    EXTRACT(YEAR FROM DATE_TRUNC('day', TO_DATE(o.order_date, 'DD/MM/YYYY'))) AS Year,
    p.category,
    SUM((CAST(REPLACE(p.sale_price::TEXT, '£', '') AS NUMERIC) - CAST(REPLACE(p.cost_price::TEXT, '£', '') AS NUMERIC)) * o.product_quantity) AS total_profit
FROM 
    orders o
JOIN 
    dim_products p ON o.product_code = p.product_code
JOIN 
    dim_stores s ON o.store_code = s.store_code
WHERE 
    s.country_region = 'Wiltshire' 
    AND TO_DATE(o.order_date, 'DD/MM/YYYY') BETWEEN '2021-01-01' AND '2021-12-31'
GROUP BY 
    Year, p.category
ORDER BY 
    total_profit DESC;



