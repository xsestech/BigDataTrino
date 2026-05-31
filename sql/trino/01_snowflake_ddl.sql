DROP TABLE IF EXISTS clickhouse.star.stg_sales;
CREATE TABLE clickhouse.star.stg_sales (
    source                 varchar,
    customer_first_name    varchar,
    customer_last_name     varchar,
    customer_age           integer,
    customer_email         varchar,
    customer_country       varchar,
    customer_postal_code   varchar,
    customer_pet_type      varchar,
    customer_pet_name      varchar,
    customer_pet_breed     varchar,
    seller_first_name      varchar,
    seller_last_name       varchar,
    seller_email           varchar,
    seller_country         varchar,
    seller_postal_code     varchar,
    product_name           varchar,
    product_category       varchar,
    product_brand          varchar,
    product_material       varchar,
    product_color          varchar,
    product_size           varchar,
    product_description    varchar,
    product_price          decimal(12,2),
    product_weight         decimal(10,3),
    product_rating         decimal(3,2),
    product_reviews        integer,
    product_release_date   date,
    product_expiry_date    date,
    sale_date              date,
    sale_quantity          integer,
    sale_total_price       decimal(14,2),
    store_name             varchar,
    store_location         varchar,
    store_city             varchar,
    store_state            varchar,
    store_country          varchar,
    store_phone            varchar,
    store_email            varchar,
    pet_category           varchar,
    supplier_name          varchar,
    supplier_contact       varchar,
    supplier_email         varchar,
    supplier_phone         varchar,
    supplier_address       varchar,
    supplier_city          varchar,
    supplier_country       varchar
) WITH (engine = 'Log');


DROP TABLE IF EXISTS clickhouse.star.dim_pet_category;
CREATE TABLE clickhouse.star.dim_pet_category (
    pet_category_id varchar NOT NULL,
    pet_type        varchar,
    category_name   varchar
) WITH (engine = 'MergeTree', order_by = ARRAY['pet_category_id']);

DROP TABLE IF EXISTS clickhouse.star.dim_pet_breed;
CREATE TABLE clickhouse.star.dim_pet_breed (
    breed_id        varchar NOT NULL,
    breed_name      varchar,
    pet_category_id varchar
) WITH (engine = 'MergeTree', order_by = ARRAY['breed_id']);

DROP TABLE IF EXISTS clickhouse.star.dim_pet;
CREATE TABLE clickhouse.star.dim_pet (
    pet_id   varchar NOT NULL,
    pet_name varchar,
    breed_id varchar
) WITH (engine = 'MergeTree', order_by = ARRAY['pet_id']);

DROP TABLE IF EXISTS clickhouse.star.dim_location;
CREATE TABLE clickhouse.star.dim_location (
    location_id varchar NOT NULL,
    country     varchar,
    state       varchar,
    city        varchar,
    postal_code varchar
) WITH (engine = 'MergeTree', order_by = ARRAY['location_id']);

DROP TABLE IF EXISTS clickhouse.star.dim_product_category;
CREATE TABLE clickhouse.star.dim_product_category (
    product_category_id varchar NOT NULL,
    category_name       varchar
) WITH (engine = 'MergeTree', order_by = ARRAY['product_category_id']);

DROP TABLE IF EXISTS clickhouse.star.dim_brand;
CREATE TABLE clickhouse.star.dim_brand (
    brand_id   varchar NOT NULL,
    brand_name varchar
) WITH (engine = 'MergeTree', order_by = ARRAY['brand_id']);

DROP TABLE IF EXISTS clickhouse.star.dim_supplier;
CREATE TABLE clickhouse.star.dim_supplier (
    supplier_id   varchar NOT NULL,
    supplier_name varchar,
    contact_name  varchar,
    email         varchar,
    phone         varchar,
    address       varchar,
    location_id   varchar
) WITH (engine = 'MergeTree', order_by = ARRAY['supplier_id']);

DROP TABLE IF EXISTS clickhouse.star.dim_customer;
CREATE TABLE clickhouse.star.dim_customer (
    customer_id varchar NOT NULL,
    first_name  varchar,
    last_name   varchar,
    age         integer,
    email       varchar,
    location_id varchar,
    pet_id      varchar
) WITH (engine = 'MergeTree', order_by = ARRAY['customer_id']);

DROP TABLE IF EXISTS clickhouse.star.dim_seller;
CREATE TABLE clickhouse.star.dim_seller (
    seller_id   varchar NOT NULL,
    first_name  varchar,
    last_name   varchar,
    email       varchar,
    location_id varchar
) WITH (engine = 'MergeTree', order_by = ARRAY['seller_id']);

DROP TABLE IF EXISTS clickhouse.star.dim_store;
CREATE TABLE clickhouse.star.dim_store (
    store_id       varchar NOT NULL,
    store_name     varchar,
    store_location varchar,
    phone          varchar,
    email          varchar,
    location_id    varchar
) WITH (engine = 'MergeTree', order_by = ARRAY['store_id']);

DROP TABLE IF EXISTS clickhouse.star.dim_product;
CREATE TABLE clickhouse.star.dim_product (
    product_id          varchar NOT NULL,
    product_name        varchar,
    description         varchar,
    price               decimal(12,2),
    weight              decimal(10,3),
    color               varchar,
    size                varchar,
    material            varchar,
    rating              decimal(3,2),
    reviews             integer,
    release_date        date,
    expiry_date         date,
    product_category_id varchar,
    brand_id            varchar,
    supplier_id         varchar
) WITH (engine = 'MergeTree', order_by = ARRAY['product_id']);


DROP TABLE IF EXISTS clickhouse.star.fact_sales;
CREATE TABLE clickhouse.star.fact_sales (
    sale_id     bigint NOT NULL,
    sale_date   date,
    customer_id varchar,
    seller_id   varchar,
    product_id  varchar,
    store_id    varchar,
    quantity    integer,
    total_price decimal(14,2)
) WITH (engine = 'MergeTree', order_by = ARRAY['sale_id']);
