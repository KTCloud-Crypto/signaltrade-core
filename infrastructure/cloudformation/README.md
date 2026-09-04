# AWS CloudFormation

- `eks-foundation.yml`: 기존 VPC 위 EKS, 서브넷/NAT, Node Group, EKS add-on, 기반 IAM 및 RDS 접근
- `application-foundation.yml`: 서비스별 ECR, SQS 3개와 DLQ, ElastiCache Redis, Worker Pod Identity
- `frontend-cloudfront.yml`: 프론트엔드 S3, CloudFront, API/모니터링 ALB origin, Route 53
- `security-baseline.yml`: CloudTrail과 감사 로그 버킷

`eks-foundation`은 현재 운영 중인 기반을 이어서 관리하고, MSA 의존 자원은 별도
`application-foundation` 스택으로 배포합니다. 실제 변경 전에는 반드시 CloudFormation Change Set으로
교체·삭제 대상이 없는지 확인합니다. 같은 AWS 리소스를 Terraform으로 중복 관리하지 않습니다.

Redis는 전송 암호화를 사용하므로 Secrets Manager의 `REDIS_URL`은
`rediss://<endpoint>:6379/0` 형식으로 저장합니다.
