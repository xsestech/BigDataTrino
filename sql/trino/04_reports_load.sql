
INSERT INTO clickhouse.reports.report_params VALUES
    ('top_products',          10),
    ('top_customers',         10),
    ('top_stores',             5),
    ('top_suppliers',          5),
    ('top_rated_products',    10),
    ('top_reviewed_products', 10);


INSERT INTO clickhouse.reports.product_sales
SELECT
    p.product_id,
    coalesce(p.product_name, '')                  AS product_name,
    coalesce(pc.category_name, '')                AS category,
    s.total_quantity,
    s.total_revenue,
    s.sales_count,
    CAST(coalesce(p.rating, 0) AS decimal(5,2))   AS avg_rating,
    CAST(coalesce(p.reviews, 0) AS bigint)        AS total_reviews
FROM (
    SELECT
        product_id,
        CAST(sum(quantity)    AS bigint)        AS total_quantity,
        CAST(sum(total_price) AS decimal(18,2)) AS total_revenue,
        CAST(count(*)         AS bigint)        AS sales_count
    FROM clickhouse.star.fact_sales
    GROUP BY product_id
) s
JOIN clickhouse.star.dim_product p ON p.product_id = s.product_id
LEFT JOIN clickhouse.star.dim_product_category pc ON pc.product_category_id = p.product_category_id;


INSERT INTO clickhouse.reports.customer_sales
SELECT
    c.customer_id,
    concat_ws(' ', c.first_name, c.last_name) AS full_name,
    coalesce(c.email, '')                     AS email,
    coalesce(l.country, '')                    AS country,
    s.orders_count,
    s.total_spent,
    s.avg_check
FROM (
    SELECT
        customer_id,
        CAST(count(*)         AS bigint)        AS orders_count,
        CAST(sum(total_price) AS decimal(18,2)) AS total_spent,
        CAST(avg(total_price) AS decimal(18,2)) AS avg_check
    FROM clickhouse.star.fact_sales
    GROUP BY customer_id
) s
JOIN clickhouse.star.dim_customer c ON c.customer_id = s.customer_id
LEFT JOIN clickhouse.star.dim_location l ON l.location_id = c.location_id;


INSERT INTO clickhouse.reports.time_sales
SELECT
    CAST(year(sale_date)  AS integer)       AS year,
    CAST(month(sale_date) AS integer)       AS month,
    CAST(count(*)         AS bigint)        AS orders_count,
    CAST(sum(quantity)    AS bigint)        AS total_quantity,
    CAST(sum(total_price) AS decimal(18,2)) AS total_revenue,
    CAST(avg(total_price) AS decimal(18,2)) AS avg_order
FROM clickhouse.star.fact_sales
WHERE sale_date IS NOT NULL
GROUP BY year(sale_date), month(sale_date);


INSERT INTO clickhouse.reports.store_sales
SELECT
    st.store_id,
    coalesce(st.store_name, '') AS store_name,
    coalesce(l.city, '')        AS city,
    coalesce(l.state, '')       AS state,
    coalesce(l.country, '')      AS country,
    s.orders_count,
    s.total_revenue,
    s.avg_check
FROM (
    SELECT
        store_id,
        CAST(count(*)         AS bigint)        AS orders_count,
        CAST(sum(total_price) AS decimal(18,2)) AS total_revenue,
        CAST(avg(total_price) AS decimal(18,2)) AS avg_check
    FROM clickhouse.star.fact_sales
    GROUP BY store_id
) s
JOIN clickhouse.star.dim_store st ON st.store_id = s.store_id
LEFT JOIN clickhouse.star.dim_location l ON l.location_id = st.location_id;


INSERT INTO clickhouse.reports.supplier_sales
SELECT
    sup.supplier_id,
    coalesce(sup.supplier_name, '') AS supplier_name,
    coalesce(l.country, '')          AS country,
    s.orders_count,
    s.total_quantity,
    s.total_revenue,
    s.avg_product_price
FROM (
    SELECT
        pr.supplier_id,
        CAST(count(*)          AS bigint)        AS orders_count,
        CAST(sum(f.quantity)   AS bigint)        AS total_quantity,
        CAST(sum(f.total_price) AS decimal(18,2)) AS total_revenue,
        CAST(avg(pr.price)     AS decimal(18,2)) AS avg_product_price
    FROM clickhouse.star.fact_sales f
    JOIN clickhouse.star.dim_product pr ON pr.product_id = f.product_id
    GROUP BY pr.supplier_id
) s
JOIN clickhouse.star.dim_supplier sup ON sup.supplier_id = s.supplier_id
LEFT JOIN clickhouse.star.dim_location l ON l.location_id = sup.location_id;


INSERT INTO clickhouse.reports.product_quality
SELECT
    p.product_id,
    coalesce(p.product_name, '')                AS product_name,
    CAST(coalesce(p.rating, 0) AS decimal(5,2)) AS rating,
    CAST(coalesce(p.reviews, 0) AS bigint)      AS reviews,
    s.total_quantity_sold,
    s.total_revenue
FROM (
    SELECT
        product_id,
        CAST(sum(quantity)    AS bigint)        AS total_quantity_sold,
        CAST(sum(total_price) AS decimal(18,2)) AS total_revenue
    FROM clickhouse.star.fact_sales
    GROUP BY product_id
) s
JOIN clickhouse.star.dim_product p ON p.product_id = s.product_id;


INSERT INTO clickhouse.reports.top_products
SELECT rank, product_id, product_name, category, total_quantity, total_revenue
FROM (
    SELECT
        product_id, product_name, category, total_quantity, total_revenue,
        CAST(row_number() OVER (ORDER BY total_quantity DESC, total_revenue DESC) AS bigint) AS rank
    FROM clickhouse.reports.product_sales
)
WHERE rank <= (SELECT max(param_value) FROM clickhouse.reports.report_params WHERE param_name = 'top_products');

INSERT INTO clickhouse.reports.top_customers
SELECT rank, customer_id, full_name, country, orders_count, total_spent
FROM (
    SELECT
        customer_id, full_name, country, orders_count, total_spent,
        CAST(row_number() OVER (ORDER BY total_spent DESC) AS bigint) AS rank
    FROM clickhouse.reports.customer_sales
)
WHERE rank <= (SELECT max(param_value) FROM clickhouse.reports.report_params WHERE param_name = 'top_customers');

INSERT INTO clickhouse.reports.top_stores
SELECT rank, store_id, store_name, city, country, orders_count, total_revenue
FROM (
    SELECT
        store_id, store_name, city, country, orders_count, total_revenue,
        CAST(row_number() OVER (ORDER BY total_revenue DESC) AS bigint) AS rank
    FROM clickhouse.reports.store_sales
)
WHERE rank <= (SELECT max(param_value) FROM clickhouse.reports.report_params WHERE param_name = 'top_stores');

INSERT INTO clickhouse.reports.top_suppliers
SELECT rank, supplier_id, supplier_name, country, total_revenue, total_quantity
FROM (
    SELECT
        supplier_id, supplier_name, country, total_revenue, total_quantity,
        CAST(row_number() OVER (ORDER BY total_revenue DESC) AS bigint) AS rank
    FROM clickhouse.reports.supplier_sales
)
WHERE rank <= (SELECT max(param_value) FROM clickhouse.reports.report_params WHERE param_name = 'top_suppliers');

INSERT INTO clickhouse.reports.top_rated_products
SELECT rank, product_id, product_name, rating, reviews, total_revenue
FROM (
    SELECT
        product_id, product_name, rating, reviews, total_revenue,
        CAST(row_number() OVER (ORDER BY rating DESC, reviews DESC) AS bigint) AS rank
    FROM clickhouse.reports.product_quality
)
WHERE rank <= (SELECT max(param_value) FROM clickhouse.reports.report_params WHERE param_name = 'top_rated_products');

INSERT INTO clickhouse.reports.top_reviewed_products
SELECT rank, product_id, product_name, reviews, rating, total_quantity_sold
FROM (
    SELECT
        product_id, product_name, reviews, rating, total_quantity_sold,
        CAST(row_number() OVER (ORDER BY reviews DESC, rating DESC) AS bigint) AS rank
    FROM clickhouse.reports.product_quality
)
WHERE rank <= (SELECT max(param_value) FROM clickhouse.reports.report_params WHERE param_name = 'top_reviewed_products');
