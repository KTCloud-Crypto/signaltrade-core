# DB migration

공유 PostgreSQL의 Alembic migration을 한 번만 실행하는 경로입니다. 서비스 Pod는 migration을 직접 실행하지 않습니다.

로컬에서는 저장소 루트에서 `make build-migrations`, `make load-migrations`, `make migrate` 순서로 실행합니다.
