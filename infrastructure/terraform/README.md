# Terraform

AWS 인프라를 추가할 경로입니다. EKS, RDS, ElastiCache, SQS, ECR, ALB, Secrets Manager를 환경별로 관리합니다.

실제 `tfstate`, `tfplan`, `tfvars` 값은 Git에 올리지 않습니다. 공유가 필요한 값은 `*.tfvars.example`만 사용합니다.
