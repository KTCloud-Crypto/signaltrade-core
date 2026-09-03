# Frontend API ownership

Baseline: `KTCloud-Crypto` commit `013107a`. This inventory is generated from the
actual `apiFetch` call sites in the existing frontend. The `/api` prefix is owned by
the edge proxy and is not part of an application service route.

| Method | Frontend path | Owner | Owned data / reason |
|---|---|---|---|
| POST | `/auth/signup` | Identity | user credentials |
| POST | `/auth/login` | Identity | access token / authentication |
| POST | `/auth/password-reset/request` | Identity | password-reset token |
| POST | `/auth/password-reset/confirm` | Identity | user password |
| GET, PUT | `/users/me` | Identity | user profile and execution preference |
| GET | `/users/me/status` | Identity | account-link status (not balances) |
| GET, POST | `/users/me/telegram-link-code` | Identity | Telegram identity link |
| DELETE | `/users/me/telegram-link` | Identity | Telegram identity link |
| POST, DELETE | `/users/me/exchange-key` | Identity | encrypted Upbit credentials |
| POST | `/users/me/password` | Identity | user password |
| GET | `/strategies` | Strategy | strategy catalogue + user subscription view |
| GET | `/strategies/active` | Strategy | active subscription view |
| GET | `/strategies/markets` | Strategy | supported-market catalogue |
| GET | `/strategies/markets/tickers` | Strategy | market data used by strategies/UI |
| GET | `/strategies/allocation` | Strategy | subscription allocation |
| GET | `/strategies/subscription-events` | Strategy | subscription history |
| GET | `/strategies/signals` | Strategy | strategy signals |
| PUT | `/strategies/{id}/subscription` | Strategy | user strategy subscription |
| POST | `/strategies/{id}/test-signal` | Strategy | strategy signal + outbox |
| GET | `/strategies/reserved` | Strategy | reserved subscription budgets |
| GET, PUT | `/paper-account` | Trading | simulated cash account |
| POST | `/paper-account/deposit` | Trading | simulated cash ledger |
| POST | `/paper-account/withdraw` | Trading | simulated cash ledger |
| GET | `/paper-account/ledger` | Trading | simulated cash ledger |
| GET | `/strategies/executions` | Trading | order/execution history |
| POST | `/strategies/liquidate-all` | Trading | liquidation commands |
| POST | `/strategies/{id}/manual-sell` | Trading | manual execution command |
| GET | `/trades` | Trading | normalized trade records |
| GET | `/strategies/positions` | Portfolio | position projection (legacy URL retained) |
| GET | `/positions/dashboard` | Portfolio | exchange balance + position projection |
| GET | `/positions/summary` | Portfolio | portfolio performance projection |
| POST | `/positions/reconciliation/deduct` | Portfolio | position reconciliation adjustment + outbox |
| GET | `/analytics` | Portfolio | portfolio/trading performance read model |

## Boundary rules

- Identity is the only writer of users, authentication state, API keys and links.
- Strategy is the only writer of catalogue, subscriptions, subscription events,
  runtime values and signals. It emits signals through the shared outbox contract.
- Trading is the only writer of paper accounts, execution requests, executions and trades.
- Portfolio is the only writer of reconciliation incidents/adjustments and owns all
  position/performance projections. During the shared-database transition it reads
  Strategy and Trading tables through explicitly read-only mappings.
- The historical `/strategies/*` namespace cannot determine ownership by prefix.
  The frontend proxy routes `positions` to Portfolio and `executions`,
  `liquidate-all`, and `*/manual-sell` to Trading before routing the remaining paths
  to Strategy.
