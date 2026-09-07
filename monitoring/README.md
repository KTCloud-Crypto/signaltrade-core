# 모니터링

기존 단일 호스트 모니터링 구성을 MSA용 Kubernetes 리소스로 이전한 경로입니다. Prometheus가 `signaltrade` namespace의 API와 worker Pod를 서비스 라벨로 자동 발견하고, Alloy가 Kubernetes 로그를 Loki로 전달하며, Grafana가 기존 대시보드 7개를 자동 프로비저닝합니다.

## 로컬 배포

Core 저장소에서 `make apply`를 실행하면 플랫폼 리소스 다음에 이 디렉터리의 Kustomize 구성이 배포됩니다. 상태 확인은 `make verify`로 수행합니다.

Grafana는 cluster 내부의 `grafana:3000` Service로 제공되며 Frontend의 `/monitoring/` reverse proxy를 통해 접근합니다. 로컬 기본 계정은 `admin` / `signaltrade-local-admin`이고, 운영에서는 `grafana-admin` Secret을 외부 Secret 관리 방식으로 반드시 교체합니다.

```sh
kubectl --context kind-signaltrade-local -n signaltrade get pods
kubectl --context kind-signaltrade-local -n signaltrade port-forward svc/grafana 3000:3000
```

## 구성

- `prometheus/`: Pod 자동 발견, worker/API, PostgreSQL, node, cAdvisor 수집
- `alloy/`: Kubernetes Pod 로그 발견과 Loki 전달
- `loki/`: 14일 로그 보존 설정
- `grafana/`: datasource provisioning과 기존 운영 대시보드
- `*.yaml`: Kubernetes workload, Service, PVC, RBAC

## 확인할 항목

- Pod 준비 상태, 재시작 횟수, CPU·메모리
- API 응답 시간과 오류 비율
- Strategy 신호 수, Trading 주문 성공·실패 수
- Outbox pending 건수, SQS Queue 적체와 DLQ 메시지
- RDS 연결·저장 공간, Redis 메모리

서비스는 표준 출력으로 구조화 로그를 남기고, Token·거래소 키·Authorization 값은 로그에 기록하지 않습니다. 운영에서는 이 구성을 Helm/Argo CD overlay로 전환하고, PVC StorageClass·Grafana Secret·환경 label을 환경별 값으로 덮어씁니다. AWS 인프라 지표와 로그는 CloudWatch를 함께 사용합니다.
