.PHONY: up down logs ps psql clickhouse trino

COMPOSE := docker compose

up:
	@chmod +x initdb-postgres/*.sh initdb-clickhouse/*.sh 2>/dev/null || true
	@$(COMPOSE) up -d
	@echo ""
	@echo "  Trino UI:        http://localhost:8080  (пользователь: admin)"
	@echo "  ClickHouse HTTP: http://localhost:8123  (admin/admin)"
	@echo "  PostgreSQL:      localhost:5432         (admin/admin, база sales)"

down:
	@$(COMPOSE) down -v

logs:
	@$(COMPOSE) logs -f --tail=100

ps:
	@$(COMPOSE) ps

psql:
	@$(COMPOSE) exec postgres psql -U admin -d sales

clickhouse:
	@$(COMPOSE) exec clickhouse clickhouse-client --user admin --password admin

trino:
	@$(COMPOSE) exec trino trino

snowflake:
	@$(COMPOSE) exec -T trino trino --catalog clickhouse --schema star -f /dev/stdin < sql/trino/01_snowflake_ddl.sql
	@$(COMPOSE) exec -T trino trino --catalog clickhouse --schema star -f /dev/stdin < sql/trino/02_snowflake_load.sql

reports:
	@$(COMPOSE) exec -T trino trino --catalog clickhouse --schema reports -f /dev/stdin < sql/trino/03_reports_ddl.sql
	@$(COMPOSE) exec -T trino trino --catalog clickhouse --schema reports -f /dev/stdin < sql/trino/04_reports_load.sql

etl: snowflake reports
