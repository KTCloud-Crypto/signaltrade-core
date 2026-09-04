# SignalTrade Core

SignalTrade를 구성하는 여러 서비스를 같은 환경에 배치하고 운영하기 위한 **인프라 기준 저장소**입니다. 회원, 전략, 주문 같은 비즈니스 기능은 각 도메인 저장소에 두고, Core는 서비스들이 사용할 공통 실행 환경과 배포 기준을 관리합니다.

## 주요 역할

- 전체 서비스가 공유하는 PostgreSQL 스키마 migration 관리
- 로컬 Kubernetes(kind) 클러스터와 기반 서비스 구성
- 로컬 개발용 PostgreSQL, Redis, LocalStack SQS 구성
- 서비스 주소, 환경 변수, Secret 주입 방식 관리
- Argo CD와 GitOps 배포 선언은 별도 `signaltrade-gitops` 저장소에서 관리
- 여러 서비스가 사용하는 메시지 계약과 공통 보조 패키지 관리

## 데이터 권한

Core는 사용자 요청을 처리하지 않으며 도메인 테이블에도 직접 쓰지 않습니다. 대신 각 서비스가 소유하는 테이블의 생성·변경 이력을 `database/`의 migration으로 통합 관리합니다.

즉, **테이블의 업무 데이터는 소유 서비스가 쓰고, 테이블 구조는 Core migration이 관리**합니다. 이 원칙을 통해 여러 저장소가 각자 임의로 DB 구조를 바꾸는 문제를 방지합니다.

## 서비스 통신 기반

동기 처리가 필요한 경우 서비스 간 내부 HTTP API를 사용합니다. 비동기 처리는 다음 흐름을 사용합니다.

```text
도메인 서비스 → message_outbox → Messaging → SQS Queue → 대상 Worker
```

Queue는 역할별로 세 개입니다.

- Trading Queue: 주문 실행과 포지션 조정 명령
- Strategy Queue: 전략 예산 변경 이벤트
- Notification Queue: 사용자 알림 요청

로컬에서는 AWS 기능을 흉내 내는 LocalStack SQS를 사용하고, 운영에서는 AWS SQS로 교체합니다. Redis는 Identity의 만료형 보안 데이터와 Notification의 중복 전송 방지에 사용합니다.

## 주요 디렉터리

- `database/`: 전체 DB 스키마 migration
- `packages/`: 공통 메시지 계약과 보조 패키지
- `infrastructure/local/kind/`: 로컬 Kubernetes 실행 환경
- `scripts/`: 로컬 환경 구성·검증 스크립트

Core에는 kind 클러스터 설정과 개발용 PostgreSQL·Redis·LocalStack을 유지합니다. 애플리케이션 Deployment, migration Job, ingress 설정, Helm values와 Argo CD Application은 `signaltrade-gitops`에서 관리합니다.

Core는 실제 주문이나 인증 로직을 구현하지 않습니다. 서비스 코드는 각 저장소에서 이미지로 만들고, `signaltrade-gitops`의 배포 선언이 해당 이미지를 kind 또는 EKS에 배포합니다.
