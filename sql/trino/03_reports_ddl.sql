CREATE TABLE clickhouse.reports.report_params (
    param_name  varchar NOT NULL,
    param_value integer
) WITH (engine = 'MergeTree', order_by = ARRAY['param_name']);


DROP TABLE IF EXISTS clickhouse.reports.product_sales;
CREATE TABLE clickhouse.reports.product_sales (
    product_id     varchar NOT NULL,
    product_name   varchar,
    category       varchar,
    total_quantity bigint,
    total_revenue  decimal(18,2),
    sales_count    bigint,
    avg_rating     decimal(5,2),
    total_reviews  bigint
) WITH (engine = 'MergeTree', order_by = ARRAY['product_id']);


DROP TABLE IF EXISTS clickhouse.reports.customer_sales;
CREATE TABLE clickhouse.reports.customer_sales (
    customer_id  varchar NOT NULL,
    full_name    varchar,
    email        varchar,
    country      varchar,
    orders_count bigint,
    total_spent  decimal(18,2),
    avg_check    decimal(18,2)
) WITH (engine = 'MergeTree', order_by = ARRAY['customer_id']);


DROP TABLE IF EXISTS clickhouse.reports.time_sales;
CREATE TABLE clickhouse.reports.time_sales (
    year           integer NOT NULL,
    month          integer NOT NULL,
    orders_count   bigint,
    total_quantity bigint,
    total_revenue  decimal(18,2),
    avg_order      decimal(18,2)
) WITH (engine = 'MergeTree', order_by = ARRAY['year', 'month']);


DROP TABLE IF EXISTS clickhouse.reports.store_sales;
CREATE TABLE clickhouse.reports.store_sales (
    store_id      varchar NOT NULL,
    store_name    varchar,
    city          varchar,
    state         varchar,
    country       varchar,
    orders_count  bigint,
    total_revenue decimal(18,2),
    avg_check     decimal(18,2)
) WITH (engine = 'MergeTree', order_by = ARRAY['store_id']);


DROP TABLE IF EXISTS clickhouse.reports.supplier_sales;
CREATE TABLE clickhouse.reports.supplier_sales (
    supplier_id       varchar NOT NULL,
    supplier_name     varchar,
    country           varchar,
    orders_count      bigint,
    total_quantity    bigint,
    total_revenue     decimal(18,2),
    avg_product_price decimal(18,2)
) WITH (engine = 'MergeTree', order_by = ARRAY['supplier_id']);


DROP TABLE IF EXISTS clickhouse.reports.product_quality;
CREATE TABLE clickhouse.reports.product_quality (
    product_id          varchar NOT NULL,
    product_name        varchar,
    rating              decimal(5,2),
    reviews             bigint,
    total_quantity_sold bigint,
    total_revenue       decimal(18,2)
) WITH (engine = 'MergeTree', order_by = ARRAY['product_id']);


DROP TABLE IF EXISTS clickhouse.reports.top_products;
CREATE TABLE clickhouse.reports.top_products (
    rank           bigint NOT NULL,
    product_id     varchar,
    product_name   varchar,
    category       varchar,
    total_quantity bigint,
    total_revenue  decimal(18,2)
) WITH (engine = 'MergeTree', order_by = ARRAY['rank']);


DROP TABLE IF EXISTS clickhouse.reports.top_customers;
CREATE TABLE clickhouse.reports.top_customers (
    rank         bigint NOT NULL,
    customer_id  varchar,
    full_name    varchar,
    country      varchar,
    orders_count bigint,
    total_spent  decimal(18,2)
) WITH (engine = 'MergeTree', order_by = ARRAY['rank']);

DROP TABLE IF EXISTS clickhouse.reports.top_stores;
CREATE TABLE clickhouse.reports.top_stores (
    rank          bigint NOT NULL,
    store_id      varchar,
    store_name    varchar,
    city          varchar,
    country       varchar,
    orders_count  bigint,
    total_revenue decimal(18,2)
) WITH (engine = 'MergeTree', order_by = ARRAY['rank']);

DROP TABLE IF EXISTS clickhouse.reports.top_suppliers;
CREATE TABLE clickhouse.reports.top_suppliers (
    rank           bigint NOT NULL,
    supplier_id    varchar,
    supplier_name  varchar,
    country        varchar,
    total_revenue  decimal(18,2),
    total_quantity bigint
) WITH (engine = 'MergeTree', order_by = ARRAY['rank']);

DROP TABLE IF EXISTS clickhouse.reports.top_rated_products;
CREATE TABLE clickhouse.reports.top_rated_products (
    rank          bigint NOT NULL,
    product_id    varchar,
    product_name  varchar,
    rating        decimal(5,2),
    reviews       bigint,
    total_revenue decimal(18,2)
) WITH (engine = 'MergeTree', order_by = ARRAY['rank']);

DROP TABLE IF EXISTS clickhouse.reports.top_reviewed_products;
CREATE TABLE clickhouse.reports.top_reviewed_products (
    rank                bigint NOT NULL,
    product_id          varchar,
    product_name        varchar,
    reviews             bigint,
    rating              decimal(5,2),
    total_quantity_sold bigint
) WITH (engine = 'MergeTree', order_by = ARRAY['rank']);
