# 데이터베이스 변경

SignalTrade는 폴리레포 전환 중에도 하나의 PostgreSQL을 공유합니다. 이 경로는 그 스키마를 변경하는 Alembic migration의 **단일 실행 지점**입니다.

## 원칙

- 서비스 API와 Worker는 시작할 때 migration을 실행하지 않습니다.
- migration은 배포마다 한 번만 실행합니다.
- 테이블의 쓰기 소유 서비스는 분리하되, 스키마 변경 이력은 여기서 함께 관리합니다.
- 실제 DB 접속 정보나 덤프는 Git에 저장하지 않습니다.

## 구성

```text
alembic/             revision 파일과 Alembic 설정
Dockerfile            migration 전용 이미지
kubernetes/          로컬 migration Job 선언
```

## 로컬 실행

저장소 루트에서 아래 순서로 실행합니다.

```sh
make build-migrations
make load-migrations
make migrate
```

kind에서는 `database-migration` Job이 완료된 뒤 서비스 Pod를 실행합니다. 운영에서는 같은 migration 이미지를 Helm Job 또는 승인된 배포 단계에서 한 번 실행합니다.
