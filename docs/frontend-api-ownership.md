# Frontend API 소유권

| API 영역 | 소유 서비스 | 데이터 |
|---|---|---|
| `/auth`, `/users` | Identity | 사용자·인증·거래소 키·Telegram 연결 |
| `/strategies` | Strategy | 전략 목록·구독·신호 |
| `/paper-account`, `/trades`, 실행·청산 API | Trading | 모의계좌·주문·체결 |
| `/positions`, `/analytics` | Portfolio | 포지션·잔고·손익 |

Frontend는 `/api`로 요청하고 프록시가 소유 서비스로 전달합니다. `/strategies` 경로 중 포지션은 Portfolio, 실행·청산은 Trading, 나머지는 Strategy가 처리합니다.
