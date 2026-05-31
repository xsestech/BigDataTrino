set -eu

CH_USER="${CLICKHOUSE_USER:-default}"
CH_PASSWORD="${CLICKHOUSE_PASSWORD:-}"

for f in /data/mock_data_6.csv \
         /data/mock_data_7.csv \
         /data/mock_data_8.csv \
         /data/mock_data_9.csv \
         /data/mock_data_10.csv; do
    echo "Loading $f"
    clickhouse-client --user "$CH_USER" --password "$CH_PASSWORD" \
        --database raw \
        --query "INSERT INTO raw_sales FORMAT CSVWithNames" < "$f"
done

clickhouse-client --user "$CH_USER" --password "$CH_PASSWORD" \
    --query "SELECT count() AS raw_sales_rows FROM raw.raw_sales;"
