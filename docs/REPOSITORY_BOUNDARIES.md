# 저장소 경계

| 저장소 | 역할 | 통신 |
|---|---|---|
| Core | 공통 계약, migration, 인프라 | 배포 조합 관리 |
| Identity | 사용자·인증·거래소 키 | 내부 HTTP |
| Strategy | 시세·전략·신호 | Outbox → Queue |
| Trading | 주문·체결·모의계좌 | Queue 소비 |
| Portfolio | 포지션·잔고 정합성 | Trading 데이터 읽기 |
| Notification | Telegram 알림·명령 | Queue 소비, 내부 HTTP |
| Messaging | Outbox 발행 | Queue 발행 |
| Frontend | 웹 화면 | API 호출 |

각 서비스는 다른 저장소의 코드를 직접 가져오지 않습니다. 동기 요청은 내부 HTTP, 비동기 처리는 Outbox와 Queue를 사용합니다. 부모 `SignalTrade`는 Git 저장소가 아닙니다.
