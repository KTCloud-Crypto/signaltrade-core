# Repository boundaries

## 저장소 책임

| 저장소 | 책임 |
|---|---|
| `signaltrade-core` | 로컬 플랫폼, 공통 인프라, 저장소 간 운영 계약 |
| `signaltrade-identity` | 사용자 인증, 프로필, 거래소 API 키, 보안 감사 |
| `signaltrade-strategy` | 시세 처리, 전략 설정·평가, 신호 생성 |
| `signaltrade-trading` | 주문 사전 검증, 주문·체결, 실행 복구 |
| `signaltrade-portfolio` | 포지션 projection, 잔고 정합성, 손익 |
| `signaltrade-notification` | Telegram 입력과 사용자 알림 |
| `signaltrade-messaging` | 메시지 계약, Queue adapter, outbox 기반 구성요소 |
| `signaltrade-frontend` | 웹 UI와 외부 API 연동 |

## 경계 규칙

1. 각 디렉터리는 자체 `.git`을 가진 독립 저장소다.
2. 부모 `SignalTrade`에는 `.git`을 만들지 않는다.
3. 서비스는 다른 저장소의 소스 디렉터리를 import하거나 이미지에 복사하지 않는다.
4. 동기 통신은 명시적인 HTTP API 계약으로, 비동기 통신은 버전이 있는 메시지
   계약으로 수행한다.
5. 서비스별 Deployment, migration, Secret 템플릿은 해당 서비스 저장소가 소유한다.
6. 클러스터 수준 인프라와 공통 네임스페이스 정책은 `signaltrade-core`가 소유한다.
7. 실제 비밀값과 로컬 데이터는 Git에 커밋하지 않는다.

## 추출 순서

`core` 골격 → `identity` → `strategy` → `trading` → `portfolio` →
`notification` → `messaging` → `frontend`

각 단계는 이전 단계가 새 kind 환경에서 health/readiness 및 핵심 회귀 검증을 통과한
뒤 진행한다.

