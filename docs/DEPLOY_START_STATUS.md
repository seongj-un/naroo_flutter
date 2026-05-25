# Deploy Start Status

현재 바로 확인된 배포 상태 요약입니다.

## 확인된 사실

- Flutter 프론트 저장소:
  - 현재 저장소는 `naroo_flutter`
  - release workflow 파일 추가됨:
    - `.github/workflows/flutter-release.yml`
- 백엔드 저장소:
  - 로컬 경로: `../naroo`
  - Git remote: `https://github.com/seongj-un/naroo.git`
  - Spring Boot 3.4.x / Java 17 / MySQL / Redis 구조 확인

## 프론트 저장소 상태

- GitHub Actions Variables:
  - 없음
- GitHub Actions Secrets:
  - 없음
- 현재 release workflow가 기대하는 최소 설정:
  - `NAROO_API_BASE_URL`
  - 형식: `NAROO_API_BASE_URL=https://<backend-domain>`
- Android AAB build까지 돌리려면 추가 필요:
  - `ANDROID_KEYSTORE_BASE64`
  - `ANDROID_KEYSTORE_PASSWORD`
  - `ANDROID_KEY_ALIAS`
  - `ANDROID_KEY_PASSWORD`

## 백엔드 저장소 상태

- GitHub Actions workflows:
  - 없음
- 배포 플랫폼 설정 파일:
  - 없음
  - 확인 대상: `Dockerfile`, `railway.json`, `railway.toml`, `render.yaml`, `fly.toml`
- health endpoint:
  - 현재 repo에서 actuator / health endpoint 확인되지 않음

## 백엔드 환경변수 실제 이름

`../naroo/src/main/resources/application.yaml` 기준:

- `MYSQL_URL`
- `MYSQL_USER`
- `MYSQL_PASS`
- `NAROO_REDIS_HOST`
- `NAROO_REDIS_PORT`
- `NAROO_CORS_ALLOWED_ORIGINS`
- `NAROO_JWT_SECRET`
- `NAROO_AUTH_REFRESH_COOKIE_SECURE`
- `NAROO_JWT_ACCESS_TOKEN_TTL_MINUTES`
- `NAROO_JWT_REFRESH_TOKEN_TTL_DAYS`

## 지금 남은 핵심 블로커

- Backend production URL 없음
- 프론트 저장소 `NAROO_API_BASE_URL` variable 없음
- 백엔드 저장소 배포 자동화 없음
- 백엔드 health check endpoint 없음
- Android signing secret 없음

## 바로 다음 실행 순서

1. `../naroo`를 Railway에 첫 배포
2. Railway에서 MySQL / Redis 연결
3. Backend production URL 확보
4. `naroo_flutter` repo에 `NAROO_API_BASE_URL` 등록
5. 프론트 workflow로 web release build 검증
6. Android signing secret 준비 후 AAB build 검증
