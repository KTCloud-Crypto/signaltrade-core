# Database migrations

공유 PostgreSQL을 사용하는 전환 기간의 Alembic migration 단일 실행 지점입니다.
기준 모노레포의 migration을 이곳으로 옮기고, 서비스 컨테이너는 시작할 때 migration을
실행하지 않습니다.

