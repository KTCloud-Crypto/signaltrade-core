# Database migrations

공유 PostgreSQL을 사용하는 전환 기간의 Alembic migration 단일 실행 지점입니다.
기준 모노레포의 migration을 이곳으로 옮기고, 서비스 컨테이너는 시작할 때 migration을
실행하지 않습니다.

기준 revision은 `c8d9e0f1a2b3` 단일 head입니다. 로컬 실행 순서는 저장소 루트의
`make build-migrations load-migrations migrate`를 사용합니다.
