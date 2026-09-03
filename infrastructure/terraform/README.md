# AWS 인프라

AWS 운영 인프라를 코드로 관리할 경로입니다. 로컬 kind 검증이 끝난 뒤 환경별 모듈을 추가합니다.

## 예정 구성

- 네트워크: VPC, subnet, 보안 그룹, 필요한 endpoint
- 실행 환경: EKS, Node Group, Pod 권한
- 데이터: RDS PostgreSQL, ElastiCache Redis
- 메시지·이미지: SQS와 DLQ, ECR
- 외부 연결: ALB, ACM, Route 53
- 비밀값: Secrets Manager와 External Secrets

```text
modules/                 재사용 가능한 AWS 구성
environments/staging/    검증 환경 값
environments/production/ 운영 환경 값
```

실제 `tfstate`, `tfplan`, `tfvars`와 Secret 값은 Git에 올리지 않습니다. 공유가 필요한 변수 이름은 `*.tfvars.example`로만 관리합니다.
