# 배포 선언

이 경로는 환경별로 어떤 서비스 이미지 조합을 배포할지 선언하는 공간입니다. 서비스 코드 저장소는 이미지를 만들고, Core의 GitOps 선언은 검증된 이미지 tag를 선택합니다.

## 운영 흐름

```text
서비스 저장소 CI → ECR image
Core의 환경별 image tag 변경 → Argo CD
Argo CD → EKS Deployment·Service·Ingress 동기화
```

현재는 로컬 kind 검증이 기준이므로 운영 Application은 아직 추가하지 않았습니다. 이후 `staging/`, `production/` 경로와 Argo CD Application을 이곳에 둡니다.
