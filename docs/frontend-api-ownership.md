# 웹 화면 API 소유권

Frontend는 같은 origin의 `/api`로 요청합니다. Ingress 또는 운영 프록시가 경로를 보고 실제 서비스로 전달하므로, 화면은 서비스 주소를 직접 알 필요가 없습니다.

## 경로별 담당 서비스

| 경로 | 서비스 | 주요 기능 |
|---|---|---|
| `/auth/*` | Identity | 회원가입, 로그인, 비밀번호 재설정 |
| `/users/*` | Identity | 프로필, Upbit 키, Telegram 연결 |
| `/strategies` | Strategy | 전략 목록, 지원 종목, 구독, 신호 |
| `/paper-account/*` | Trading | 모의 입출금, 모의계좌 원장 |
| `/trades` | Trading | 실전 거래 기록 |
| `/strategies/executions` | Trading | 실행 결과 조회 |
| `/strategies/*/manual-sell` | Trading | 수동 매도 요청 |
| `/strategies/liquidate-all` | Trading | 전략 포지션 일괄 매도 |
| `/positions/*` | Portfolio | 실제 잔고, 포지션, 정합성 |
| `/analytics` | Portfolio | 거래·손익 분석 |

## 경로가 겹치는 이유

초기 모노레포의 URL을 유지하기 위해 일부 Portfolio·Trading API도 `/strategies/*` 경로를 사용합니다. 프록시는 다음 순서로 구분합니다.

1. 포지션 관련 경로는 Portfolio
2. 실행 결과·수동 매도·일괄 매도는 Trading
3. 그 밖의 전략 경로는 Strategy

이 규칙은 Frontend의 기존 응답 형식을 유지하면서 서비스별 데이터 쓰기 책임을 분리하기 위한 것입니다.
