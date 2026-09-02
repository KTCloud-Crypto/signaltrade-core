# signaltrade-core

SignalTrade 폴리레포의 로컬 플랫폼과 저장소 간 계약을 관리합니다.

이 저장소는 애플리케이션 런타임의 공용 Python 패키지가 아닙니다. 각 서비스는
독립적으로 빌드·배포되어야 하며, 다른 서비스 저장소의 소스 코드를 직접 참조하지
않습니다.

## 현재 범위

- `signaltrade-local` kind 클러스터 생성 설정
- `signaltrade` 네임스페이스와 공통 Kubernetes 라벨
- 폴리레포 저장소 경계와 점진적 추출 순서 기록
- 로컬 플랫폼의 정적·실행 환경 검증

PostgreSQL, Redis, Queue 및 ingress는 서비스 추출에 필요한 시점에 이 저장소에
추가합니다. 애플리케이션 Deployment와 서비스별 Secret은 각 서비스 저장소에서
관리합니다.

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

클러스터 삭제는 명시적으로 실행합니다.

```sh
make delete-cluster
```

## 기준 코드

최초 골격은 `KTCloud-Crypto`의 `feat/132`, 커밋
`013107ae8ddd08bed02d88db89af7eeb0cf65bba`를 기준으로 작성했습니다. 기준
모노레포는 읽기 전용 참조이며 이 저장소의 Git 이력과 독립적입니다.

