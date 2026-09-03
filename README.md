# SignalTrade Core

폴리레포 전체를 조합하는 운영·로컬 환경 저장소입니다. 서비스 비즈니스 코드는 두지 않습니다.

```text
packages/       공통 메시지 계약과 관측성 보조 코드
database/       전체 DB migration
infrastructure/ kind와 향후 AWS 인프라
gitops/         환경별 배포 조합
monitoring/     모니터링 조합
```

각 서비스는 독립 이미지로 빌드하고, 이 저장소는 kind에서 그 이미지를 함께 실행합니다. 운영에서는 같은 역할을 Terraform·Helm·Argo CD가 수행합니다.

로컬 기본 환경은 `make create-cluster`, `make apply`로 준비합니다. Telegram 연동만 필요하면 `.env.example`을 `.env`로 복사해 값을 넣고 `infrastructure/local/kind/load-local-secrets.sh`를 실행합니다.
