# AWS CloudFormation

- `eks-foundation.yml`: 기존 VPC 위 EKS, 서브넷/NAT, Node Group, EKS add-on, 기반 IAM 및 RDS 접근
- `msa-nodegroup.yml`: 기존 EKS에 연결하는 MSA 전용 Managed Node Group
- `application-foundation.yml`: 서비스별 ECR, ECR Push용 GitHub OIDC Role, SQS 3개와 DLQ,
  ElastiCache Redis, Worker Pod Identity, 공통 runtime Secret
- `runtime-secrets.yml`: 환경별 `common`, `identity`, `notification`, `database` Secret 컨테이너
- `external-secrets-staging-access.yml`: 기존 External Secrets Role의 staging 경로 읽기 권한
- `frontend-cloudfront.yml`: 프론트엔드 S3, CloudFront, API/모니터링 ALB origin, Route 53
- `security-baseline.yml`: CloudTrail과 감사 로그 버킷

`eks-foundation`은 현재 운영 중인 기반을 이어서 관리하고, MSA 의존 자원은 별도
`application-foundation` 스택으로 배포합니다. 실제 변경 전에는 반드시 CloudFormation Change Set으로
교체·삭제 대상이 없는지 확인합니다. 같은 AWS 리소스를 Terraform으로 중복 관리하지 않습니다.

Redis는 전송 암호화를 사용하므로 Secrets Manager의 `REDIS_URL`은
`rediss://<endpoint>:6379/0` 형식으로 저장합니다.

ECR 이미지는 변경 불가능한 Git commit SHA tag를 사용합니다. 각 폴리레포의 GitHub Actions
Role은 해당 서비스 ECR에만 push할 수 있으며, untagged 이미지는 14일 후 정리하고 tagged
이미지는 최근 30개를 유지합니다. staging 공통 Secret은
`signaltrade/staging/common`에서 관리합니다.

Runtime Secret은 환경별로 다음 경로를 사용합니다. CloudFormation은 Secret 컨테이너와
접근 경로를 관리하고 Secret 값은 Git에 저장하지 않습니다.

- `signaltrade/<environment>/common`: 내부 인증값과 환경 공통 설정
- `signaltrade/<environment>/identity`: 암호화·인증 전용 키
- `signaltrade/<environment>/notification`: 알림 채널 자격 증명
- `signaltrade/<environment>/database`: RDS 접속 정보
- `/signaltrade/<environment>/monitoring/*`: SSM Parameter Store의 모니터링 자격 증명
