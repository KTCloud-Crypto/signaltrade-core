# SignalTrade Core

SignalTrade 폴리레포를 **함께 실행하고 운영하는 기준 저장소**입니다. 사용자 인증, 전략 계산, 주문 같은 비즈니스 기능은 각 서비스 저장소에 두고, 이 저장소는 서비스가 같은 환경에서 안전하게 만나는 방법을 관리합니다.

## 이 저장소가 맡는 일

- 공통 메시지 계약과 관측성 보조 코드 관리
- 공유 PostgreSQL의 Alembic migration 단일 실행
- 로컬 kind 클러스터, PostgreSQL, Redis, LocalStack 구성
- 서비스 이미지 조합과 향후 AWS·EKS 배포 선언 관리
- GitOps와 모니터링 설정의 기준 경로 제공

## 디렉터리

```text
packages/       서비스가 함께 쓰는 메시지 계약과 보조 패키지
database/       전체 스키마 migration과 migration 이미지
infrastructure/ 로컬 kind, 향후 Terraform 인프라
gitops/         Argo CD가 읽을 환경별 배포 선언
monitoring/     metric, 로그, 대시보드·알림 구성
scripts/        로컬 환경 검증 보조 스크립트
```

## 서비스와의 관계

각 서비스는 이 저장소를 소스 코드 의존성으로 직접 참조하지 않습니다. 서비스 저장소에서 Docker 이미지를 만들고, Core의 kind manifest가 그 이미지를 Deployment로 실행합니다.

```text
서비스 저장소 코드 → Docker image → kind/EKS Deployment
                                  ↑
                            signaltrade-core
```

Strategy, Trading, Portfolio가 기록한 Outbox 이벤트는 Messaging을 통해 Queue로 전달됩니다. Core는 이 흐름에 필요한 로컬 Queue·DB·네트워크만 준비하며, 주문이나 사용자 데이터를 직접 처리하지 않습니다.

## 로컬 실행

```sh
make create-cluster
make apply
make build-migrations
make load-migrations
make migrate
make verify
```

Telegram을 사용할 때만 `.env.example`을 `.env`로 복사해 Bot Token과 Username을 넣고 `infrastructure/local/kind/load-local-secrets.sh`를 실행합니다. 실제 Secret과 로컬 데이터는 Git에 저장하지 않습니다.

## 운영 단계

현재 `infrastructure/local/kind`은 로컬 검증용입니다. 운영 전환 시 같은 저장소에 Terraform, Helm, Argo CD, 모니터링 구성을 추가하고, kind의 PostgreSQL·Redis·LocalStack은 RDS·ElastiCache·SQS로 바뀝니다.
