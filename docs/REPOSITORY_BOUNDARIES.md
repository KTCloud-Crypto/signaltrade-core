# 저장소 경계와 통신

SignalTrade는 서비스별 코드·배포·테스트를 분리한 폴리레포 구조입니다. 부모 `SignalTrade`는 단순 작업 공간이며 Git 저장소가 아닙니다.

## 서비스 책임

| 저장소 | 담당 기능 | 주된 통신 |
|---|---|---|
| Core | 공통 계약, migration, 기반 인프라 | DB·클러스터 기반 구성 |
| GitOps | Kubernetes·Helm·Argo CD 배포 선언 | 서비스 이미지 조합과 환경별 배포 상태 |
| Identity | 사용자, 인증, Upbit 키, Telegram 연결 | Frontend·내부 HTTP |
| Strategy | 시세, 전략 카탈로그, 구독, 신호 | Frontend·Outbox |
| Trading | 모의계좌, 주문 요청, 체결, 거래 기록 | Queue 소비·내부 HTTP |
| Portfolio | 포지션, 잔고 정합성, 손익 조회 | Frontend·Trading 읽기 |
| Notification | Telegram 알림과 명령 | Queue 소비·내부 HTTP |
| Messaging | Outbox를 Queue로 발행 | DB 읽기·Queue 발행 |
| Frontend | 사용자 웹 화면 | API Gateway 경로 호출 |

## 데이터 소유 원칙

- Identity만 사용자·인증·암호화된 거래소 키를 씁니다.
- Strategy만 전략 목록·사용자 구독·신호를 씁니다.
- Trading만 주문 요청·실행·체결·모의계좌를 씁니다.
- Portfolio만 포지션 조정과 정합성 incident를 씁니다.
- Messaging은 비즈니스 테이블을 수정하지 않고 pending Outbox만 발행합니다.

공유 DB 전환 기간에는 다른 서비스의 테이블을 읽을 수 있지만 직접 쓰지 않습니다.

## 통신 방식

```text
Frontend → Identity / Strategy / Trading / Portfolio

Strategy → Outbox → Messaging → Trading Queue → Trading
Trading  → Outbox → Messaging → Portfolio Queue → Portfolio
Trading  → Outbox → Messaging → Notification Queue → Notification → Telegram
```

동기 요청은 명시적인 내부 HTTP API와 서비스 토큰을 사용합니다. 비동기 처리에는 메시지 ID와 idempotency key를 포함한 Outbox·Queue 계약을 사용합니다.
