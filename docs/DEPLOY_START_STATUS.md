# Deploy Start Status

현재 바로 확인된 배포 상태 요약입니다.

마지막 로컬 검증 기준일: 2026-05-25

## 확인된 사실

- Flutter 프론트 저장소:
  - 현재 저장소 폴더는 `frontend`
  - Dart package 이름은 `naroo_flutter`
  - release workflow 파일 추가됨:
    - `.github/workflows/flutter-release.yml`
  - release workflow는 이제 `NAROO_API_BASE_URL`이 없거나 `https://`가 아니면 실패함
- 백엔드 저장소:
  - 로컬 경로: `../backend`
  - Git remote: `https://github.com/seongj-un/naroo.git`
  - Spring Boot 3.4.x / Java 17 / MySQL / Redis 구조 확인
  - Railway deploy workflow 추가됨:
    - `.github/workflows/backend-deploy-railway.yml`

## 2026-05-25 로컬 QA 결과

- 프론트:
  - `flutter analyze` 통과
  - `flutter test` 통과
  - `flutter run -d web-server --web-port 3000 --dart-define=NAROO_API_BASE_URL=http://localhost:8080` 기동 확인
- 백엔드:
  - `NAROO_AUTH_REFRESH_COOKIE_SECURE=false NAROO_JWT_SECRET=<local-secret> NAROO_SEED_STUDENT_ENABLED=true ./gradlew bootRun` 기동 확인
  - `./gradlew test` 통과
  - `GET http://localhost:8080/actuator/health` 응답 `{"status":"UP"}` 확인
- 실제 API 플로우:
  - 회원가입, 이메일 인증, 로그인, 학습 홈, 시작점 선택, 진단 세션 생성, 진단 답안 제출, 결과 조회, 회복 미션 생성, 회복 미션 제출, 다음 미션 생성까지 로컬 API 기준 통과
  - 로컬 이메일 인증 토큰은 백엔드 로그 라인 `email verification requested userId=... email=... token=...` 에서 확인 가능
  - `POST /api/auth/email/resend` 성공, `nextRetryAt` 응답, 즉시 재요청 `429 AUTH_EMAIL_VERIFICATION_RESEND_TOO_SOON` 확인
  - `POST /api/auth/reissue` 성공, 새 `accessToken` 발급과 `refresh_token` rotation 확인
  - 이전 refresh token 재사용 `401 AUTH_INVALID_REFRESH_TOKEN`, 빈 cookie 요청 `401 AUTH_REFRESH_TOKEN_REQUIRED` 확인
  - `NAROO_AUTH_REFRESH_COOKIE_SECURE=true`, `NAROO_AUTH_REFRESH_COOKIE_SAME_SITE=None` 로 실행 시 `login` 과 `reissue` 응답 `Set-Cookie` 에 `Secure; HttpOnly; SameSite=None` 포함 확인
  - 이 항목은 로컬 헤더 검증 완료 상태이며, 실제 HTTPS 브라우저 round-trip 검증은 아직 남아 있음
- 브라우저 QA 메모:
  - `http://localhost:3000` 렌더링과 주요 화면 전환은 확인
  - Computer Use 기반 Chrome 입력 자동화에서 텍스트 입력 오타가 반복되어, 전체 플로우 성공 판정은 API 검증 기준으로 확정

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
  - `.github/workflows/backend-test.yml`
  - `.github/workflows/backend-deploy-railway.yml`
- 배포 플랫폼 설정 파일:
  - `railway.toml` 확인
- health endpoint:
  - 로컬 `GET /actuator/health` 확인 완료

## 백엔드 환경변수 실제 이름

`../backend/src/main/resources/application.yaml` 기준:

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
- Android signing secret 없음

## 바로 다음 실행 순서

1. `../backend`를 Railway에 첫 배포
2. Railway에서 MySQL / Redis 연결
3. Backend production URL 확보
4. frontend 저장소 variable에 `NAROO_API_BASE_URL` 등록
5. 프론트 workflow로 web release build 검증
6. Android signing secret 준비 후 AAB build 검증
