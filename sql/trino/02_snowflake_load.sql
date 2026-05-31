INSERT INTO clickhouse.star.stg_sales
SELECT
    source,
    nullif(trim(customer_first_name), '')                                   AS customer_first_name,
    nullif(trim(customer_last_name), '')                                    AS customer_last_name,
    try_cast(nullif(trim(customer_age), '') AS integer)                     AS customer_age,
    nullif(trim(customer_email), '')                                        AS customer_email,
    nullif(trim(customer_country), '')                                      AS customer_country,
    nullif(trim(customer_postal_code), '')                                  AS customer_postal_code,
    lower(nullif(trim(customer_pet_type), ''))                              AS customer_pet_type,
    nullif(trim(customer_pet_name), '')                                     AS customer_pet_name,
    nullif(trim(customer_pet_breed), '')                                    AS customer_pet_breed,
    nullif(trim(seller_first_name), '')                                     AS seller_first_name,
    nullif(trim(seller_last_name), '')                                      AS seller_last_name,
    nullif(trim(seller_email), '')                                          AS seller_email,
    nullif(trim(seller_country), '')                                        AS seller_country,
    nullif(trim(seller_postal_code), '')                                    AS seller_postal_code,
    nullif(trim(product_name), '')                                          AS product_name,
    nullif(trim(product_category), '')                                      AS product_category,
    nullif(trim(product_brand), '')                                         AS product_brand,
    nullif(trim(product_material), '')                                      AS product_material,
    nullif(trim(product_color), '')                                         AS product_color,
    nullif(trim(product_size), '')                                          AS product_size,
    nullif(trim(product_description), '')                                   AS product_description,
    try_cast(nullif(trim(product_price), '') AS decimal(12,2))              AS product_price,
    try_cast(nullif(trim(product_weight), '') AS decimal(10,3))             AS product_weight,
    try_cast(nullif(trim(product_rating), '') AS decimal(3,2))              AS product_rating,
    try_cast(nullif(trim(product_reviews), '') AS integer)                  AS product_reviews,
    try(cast(date_parse(nullif(trim(product_release_date), ''), '%c/%e/%Y') AS date)) AS product_release_date,
    try(cast(date_parse(nullif(trim(product_expiry_date), ''), '%c/%e/%Y') AS date))  AS product_expiry_date,
    try(cast(date_parse(nullif(trim(sale_date), ''), '%c/%e/%Y') AS date)) AS sale_date,
    try_cast(nullif(trim(sale_quantity), '') AS integer)                    AS sale_quantity,
    try_cast(nullif(trim(sale_total_price), '') AS decimal(14,2))           AS sale_total_price,
    nullif(trim(store_name), '')                                            AS store_name,
    nullif(trim(store_location), '')                                        AS store_location,
    nullif(trim(store_city), '')                                            AS store_city,
    nullif(trim(store_state), '')                                           AS store_state,
    nullif(trim(store_country), '')                                         AS store_country,
    nullif(trim(store_phone), '')                                           AS store_phone,
    nullif(trim(store_email), '')                                           AS store_email,
    nullif(trim(pet_category), '')                                          AS pet_category,
    nullif(trim(supplier_name), '')                                         AS supplier_name,
    nullif(trim(supplier_contact), '')                                      AS supplier_contact,
    nullif(trim(supplier_email), '')                                        AS supplier_email,
    nullif(trim(supplier_phone), '')                                        AS supplier_phone,
    nullif(trim(supplier_address), '')                                      AS supplier_address,
    nullif(trim(supplier_city), '')                                         AS supplier_city,
    nullif(trim(supplier_country), '')                                      AS supplier_country
FROM (
    SELECT 'pg' AS source, r.* FROM postgresql.public.raw_sales r
    UNION ALL
    SELECT 'ch' AS source, r.* FROM clickhouse.raw.raw_sales r
);


INSERT INTO clickhouse.star.dim_pet_category
SELECT pet_category_id, arbitrary(pet_type), arbitrary(category_name)
FROM (
    SELECT
        to_hex(sha256(to_utf8(customer_pet_type))) AS pet_category_id,
        customer_pet_type                          AS pet_type,
        pet_category                               AS category_name
    FROM clickhouse.star.stg_sales
    WHERE customer_pet_type IS NOT NULL
)
GROUP BY pet_category_id;


INSERT INTO clickhouse.star.dim_pet_breed
SELECT breed_id, arbitrary(breed_name), arbitrary(pet_category_id)
FROM (
    SELECT
        to_hex(sha256(to_utf8(concat(coalesce(customer_pet_breed, ''), '||', coalesce(customer_pet_type, ''))))) AS breed_id,
        customer_pet_breed                          AS breed_name,
        to_hex(sha256(to_utf8(customer_pet_type)))  AS pet_category_id
    FROM clickhouse.star.stg_sales
    WHERE customer_pet_breed IS NOT NULL AND customer_pet_type IS NOT NULL
)
GROUP BY breed_id;


INSERT INTO clickhouse.star.dim_pet
SELECT pet_id, arbitrary(pet_name), arbitrary(breed_id)
FROM (
    SELECT
        to_hex(sha256(to_utf8(concat(coalesce(customer_pet_name, ''), '||', coalesce(customer_pet_breed, ''), '||', coalesce(customer_pet_type, ''))))) AS pet_id,
        customer_pet_name AS pet_name,
        to_hex(sha256(to_utf8(concat(coalesce(customer_pet_breed, ''), '||', coalesce(customer_pet_type, ''))))) AS breed_id
    FROM clickhouse.star.stg_sales
    WHERE customer_pet_name IS NOT NULL AND customer_pet_breed IS NOT NULL AND customer_pet_type IS NOT NULL
)
GROUP BY pet_id;


INSERT INTO clickhouse.star.dim_location
SELECT location_id, arbitrary(country), arbitrary(state), arbitrary(city), arbitrary(postal_code)
FROM (
    SELECT
        to_hex(sha256(to_utf8(concat(coalesce(customer_country, ''), '||', '', '||', '', '||', coalesce(customer_postal_code, ''))))) AS location_id,
        customer_country AS country, CAST(NULL AS varchar) AS state, CAST(NULL AS varchar) AS city, customer_postal_code AS postal_code
    FROM clickhouse.star.stg_sales WHERE customer_country IS NOT NULL
    UNION ALL
    SELECT
        to_hex(sha256(to_utf8(concat(coalesce(seller_country, ''), '||', '', '||', '', '||', coalesce(seller_postal_code, ''))))),
        seller_country, CAST(NULL AS varchar), CAST(NULL AS varchar), seller_postal_code
    FROM clickhouse.star.stg_sales WHERE seller_country IS NOT NULL
    UNION ALL
    SELECT
        to_hex(sha256(to_utf8(concat(coalesce(store_country, ''), '||', coalesce(store_state, ''), '||', coalesce(store_city, ''), '||', '')))),
        store_country, store_state, store_city, CAST(NULL AS varchar)
    FROM clickhouse.star.stg_sales WHERE store_country IS NOT NULL
    UNION ALL
    SELECT
        to_hex(sha256(to_utf8(concat(coalesce(supplier_country, ''), '||', '', '||', coalesce(supplier_city, ''), '||', '')))),
        supplier_country, CAST(NULL AS varchar), supplier_city, CAST(NULL AS varchar)
    FROM clickhouse.star.stg_sales WHERE supplier_country IS NOT NULL
)
GROUP BY location_id;


INSERT INTO clickhouse.star.dim_product_category
SELECT product_category_id, arbitrary(category_name)
FROM (
    SELECT
        to_hex(sha256(to_utf8(product_category))) AS product_category_id,
        product_category                          AS category_name
    FROM clickhouse.star.stg_sales
    WHERE product_category IS NOT NULL
)
GROUP BY product_category_id;


INSERT INTO clickhouse.star.dim_brand
SELECT brand_id, arbitrary(brand_name)
FROM (
    SELECT
        to_hex(sha256(to_utf8(product_brand))) AS brand_id,
        product_brand                          AS brand_name
    FROM clickhouse.star.stg_sales
    WHERE product_brand IS NOT NULL
)
GROUP BY brand_id;


INSERT INTO clickhouse.star.dim_supplier
SELECT supplier_id, arbitrary(supplier_name), arbitrary(contact_name), arbitrary(email),
       arbitrary(phone), arbitrary(address), arbitrary(location_id)
FROM (
    SELECT
        to_hex(sha256(to_utf8(concat(coalesce(supplier_name, ''), '||', coalesce(supplier_email, ''))))) AS supplier_id,
        supplier_name    AS supplier_name,
        supplier_contact AS contact_name,
        supplier_email   AS email,
        supplier_phone   AS phone,
        supplier_address AS address,
        to_hex(sha256(to_utf8(concat(coalesce(supplier_country, ''), '||', '', '||', coalesce(supplier_city, ''), '||', '')))) AS location_id
    FROM clickhouse.star.stg_sales
    WHERE supplier_name IS NOT NULL
)
GROUP BY supplier_id;


INSERT INTO clickhouse.star.dim_customer
SELECT customer_id, arbitrary(first_name), arbitrary(last_name), arbitrary(age),
       arbitrary(email), arbitrary(location_id), arbitrary(pet_id)
FROM (
    SELECT
        to_hex(sha256(to_utf8(customer_email))) AS customer_id,
        customer_first_name AS first_name,
        customer_last_name  AS last_name,
        customer_age        AS age,
        customer_email      AS email,
        to_hex(sha256(to_utf8(concat(coalesce(customer_country, ''), '||', '', '||', '', '||', coalesce(customer_postal_code, ''))))) AS location_id,
        CASE WHEN customer_pet_name IS NOT NULL AND customer_pet_breed IS NOT NULL AND customer_pet_type IS NOT NULL
             THEN to_hex(sha256(to_utf8(concat(coalesce(customer_pet_name, ''), '||', coalesce(customer_pet_breed, ''), '||', coalesce(customer_pet_type, '')))))
             ELSE NULL END AS pet_id
    FROM clickhouse.star.stg_sales
    WHERE customer_email IS NOT NULL
)
GROUP BY customer_id;


SELECT seller_id, arbitrary(first_name), arbitrary(last_name), arbitrary(email), arbitrary(location_id)
FROM (
    SELECT
        to_hex(sha256(to_utf8(seller_email))) AS seller_id,
        seller_first_name AS first_name,
        seller_last_name  AS last_name,
        seller_email      AS email,
        to_hex(sha256(to_utf8(concat(coalesce(seller_country, ''), '||', '', '||', '', '||', coalesce(seller_postal_code, ''))))) AS location_id
    FROM clickhouse.star.stg_sales
    WHERE seller_email IS NOT NULL
)
GROUP BY seller_id;


INSERT INTO clickhouse.star.dim_store
SELECT store_id, arbitrary(store_name), arbitrary(store_location), arbitrary(phone),
       arbitrary(email), arbitrary(location_id)
FROM (
    SELECT
        to_hex(sha256(to_utf8(concat(coalesce(store_name, ''), '||', coalesce(store_country, ''), '||', coalesce(store_state, ''), '||', coalesce(store_city, ''))))) AS store_id,
        store_name     AS store_name,
        store_location AS store_location,
        store_phone    AS phone,
        store_email    AS email,
        to_hex(sha256(to_utf8(concat(coalesce(store_country, ''), '||', coalesce(store_state, ''), '||', coalesce(store_city, ''), '||', '')))) AS location_id
    FROM clickhouse.star.stg_sales
    WHERE store_name IS NOT NULL
)
GROUP BY store_id;


INSERT INTO clickhouse.star.dim_product
SELECT product_id, arbitrary(product_name), arbitrary(description), arbitrary(price),
       arbitrary(weight), arbitrary(color), arbitrary(size), arbitrary(material),
       arbitrary(rating), arbitrary(reviews), arbitrary(release_date), arbitrary(expiry_date),
       arbitrary(product_category_id), arbitrary(brand_id), arbitrary(supplier_id)
FROM (
    SELECT
        to_hex(sha256(to_utf8(concat(coalesce(product_name, ''), '||', coalesce(product_brand, ''))))) AS product_id,
        product_name        AS product_name,
        product_description AS description,
        product_price       AS price,
        product_weight      AS weight,
        product_color       AS color,
        product_size        AS size,
        product_material    AS material,
        product_rating      AS rating,
        product_reviews     AS reviews,
        product_release_date AS release_date,
        product_expiry_date  AS expiry_date,
        to_hex(sha256(to_utf8(product_category)))                                                       AS product_category_id,
        to_hex(sha256(to_utf8(product_brand)))                                                          AS brand_id,
        to_hex(sha256(to_utf8(concat(coalesce(supplier_name, ''), '||', coalesce(supplier_email, ''))))) AS supplier_id
    FROM clickhouse.star.stg_sales
    WHERE product_name IS NOT NULL
)
GROUP BY product_id;


INSERT INTO clickhouse.star.fact_sales
SELECT
    row_number() OVER (ORDER BY source, customer_email, seller_email, product_name, store_name, sale_date) AS sale_id,
    sale_date,
    to_hex(sha256(to_utf8(customer_email))) AS customer_id,
    to_hex(sha256(to_utf8(seller_email)))   AS seller_id,
    to_hex(sha256(to_utf8(concat(coalesce(product_name, ''), '||', coalesce(product_brand, ''))))) AS product_id,
    to_hex(sha256(to_utf8(concat(coalesce(store_name, ''), '||', coalesce(store_country, ''), '||', coalesce(store_state, ''), '||', coalesce(store_city, ''))))) AS store_id,
    sale_quantity    AS quantity,
    sale_total_price AS total_price
FROM clickhouse.star.stg_sales
WHERE customer_email IS NOT NULL
  AND seller_email IS NOT NULL
  AND product_name IS NOT NULL
  AND store_name IS NOT NULL;

