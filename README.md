# signaltrade-core

SignalTrade 폴리레포의 로컬 플랫폼과 저장소 간 계약을 관리합니다.

이 저장소는 애플리케이션 런타임의 공용 Python 패키지가 아닙니다. 각 서비스는
독립적으로 빌드·배포되어야 하며, 다른 서비스 저장소의 소스 코드를 직접 참조하지
않습니다.

## 디렉터리

```text
packages/       공통 메시지 계약과 관측성 보조 패키지
database/       전체 Alembic migration의 단일 실행 지점
infrastructure/ kind 및 향후 AWS Terraform
gitops/         환경별 애플리케이션 조합 선언
monitoring/     Prometheus, Loki, Grafana 구성
```

비즈니스 모델과 서비스 Repository는 두지 않습니다. 서비스별 소스와 Dockerfile은 각
서비스 저장소가 소유하고, Core의 GitOps 선언은 검증된 image tag 조합만 관리합니다.

## 요구 사항

- Docker
- kind
- kubectl

## 로컬 클러스터

```sh
make create-cluster
make apply
make verify
```

공통 패키지 검증:

```sh
python3 -m pip install -e 'packages/signaltrade-core[dev]'
pytest packages/signaltrade-core/tests
```

클러스터 삭제는 명시적으로 실행합니다.

```sh
make delete-cluster
```

## 기준 코드

최초 골격은 `KTCloud-Crypto`의 `feat/132`, 커밋
`013107ae8ddd08bed02d88db89af7eeb0cf65bba`를 기준으로 작성했습니다. 기준
모노레포는 읽기 전용 참조이며 이 저장소의 Git 이력과 독립적입니다.
