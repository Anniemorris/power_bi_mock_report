CREATE OR REPLACE VIEW "store_summary" AS
SELECT 
    s.store_type, 
    SUM(CAST(REPLACE(p.product_price, '£', '') AS NUMERIC) * o."Product Quantity") AS total_sales,
    (SUM(CAST(REPLACE(p.product_price, '£', '') AS NUMERIC) * o."Product Quantity") * 100.0 /
     SUM(SUM(CAST(REPLACE(p.product_price, '£', '') AS NUMERIC) * o."Product Quantity")) OVER ()) AS percentage_of_total_sales,
    COUNT(o."User ID") AS order_count
FROM 
    orders_powerbi o
JOIN 
    dim_products p ON o.product_code = p.product_code
JOIN 
    dim_stores s ON o."Store Code" = s."store code"
GROUP BY 
    s.store_type;

SELECT * FROM store_summary;
