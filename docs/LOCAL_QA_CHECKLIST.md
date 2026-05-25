# Local QA Checklist

Last updated: 2026-05-25

이 문서는 Naroo 로컬 통합 QA를 다시 수행할 때 바로 따라갈 수 있는 최소 절차를 정리한다.

## 1. 백엔드 준비

전제:

- MySQL이 `localhost:3306` 에서 실행 중
- Redis가 `localhost:6379` 에서 실행 중

백엔드 실행:

```bash
cd backend
NAROO_AUTH_REFRESH_COOKIE_SECURE=false \
NAROO_JWT_SECRET=local-dev-secret-local-dev-secret-local \
NAROO_SEED_STUDENT_ENABLED=true \
./gradlew bootRun
```

빠른 확인:

```bash
curl http://localhost:8080/actuator/health
```

기대값:

- `{"status":"UP"}`

## 2. 프론트 실행

```bash
cd frontend
flutter run -d web-server --web-port 3000 \
  --dart-define=NAROO_API_BASE_URL=http://localhost:8080
```

브라우저 접속:

- `http://localhost:3000`

## 3. 자동 검증

프론트:

```bash
cd frontend
flutter analyze
flutter test
```

백엔드:

```bash
cd backend
./gradlew test
```

## 4. 수동 플로우 체크

### 시드 계정 로그인 플로우

시드 계정:

- `loginId`: `student01`
- `password`: `password123`

확인 항목:

1. 로그인 화면이 정상 렌더링된다.
2. 시드 계정 로그인 후 학습 홈이 열린다.
3. 이미 완료된 진단/미션이 있으면 홈 상태가 기존 진행도에 맞게 보인다.

### 신규 계정 진단 플로우

예시 신규 계정:

- `loginId`: 임의 값
- `email`: 임의 값
- `password`: `password123`
- `nickname`: `나루`
- `mathStatus`: `UNKNOWN`

확인 항목:

1. 회원가입 성공
2. 백엔드 로그에서 이메일 인증 토큰 확인
3. 이메일 인증 성공
4. 로그인 성공
5. 학습 홈 `nextAction` 이 `START_DIAGNOSTIC`
6. 시작점으로 `FUNCTION` 선택
7. 진단 세션 생성 성공
8. 진단 문항 조회 성공
9. `unknown` 포함 답안 제출 성공
10. 약점 결과 화면 진입 가능
11. 첫 회복 미션 생성 성공
12. 회복 미션 답변 제출 성공
13. 학습 홈 복귀 후 `nextAction` 이 `CREATE_RECOVERY_MISSION` 으로 변경
14. 같은 진단 기준으로 다음 약점 미션 생성 가능

## 5. API 기준 기대 상태

이미 2026-05-25 에 로컬 검증된 항목:

- `POST /api/auth/sign-up`
- `POST /api/auth/login`
- `POST /api/auth/email/verify`
- `POST /api/auth/email/resend`
- `POST /api/auth/reissue`
- `GET /api/auth/me`
- `GET /api/me/learning-home`
- `GET /api/math-areas`
- `POST /api/diagnostics/starting-point`
- `POST /api/diagnostics`
- `GET /api/diagnostics/{diagnosticSessionId}/questions`
- `POST /api/diagnostics/{diagnosticSessionId}/answers`
- `GET /api/diagnostics/{diagnosticSessionId}/result`
- `POST /api/recovery-missions`
- `GET /api/recovery-missions/{recoveryMissionId}`
- `POST /api/recovery-missions/{recoveryMissionId}/submissions`

아직 별도 확인이 필요한 항목:

- 배포 환경의 브라우저 round-trip cookie `SameSite=None; Secure`
- Flutter web semantics 기반 브라우저 상호작용 안정성

## 6. Auth Endpoint Notes

`POST /api/auth/email/resend`

- 미인증 로그인 세션에서 성공
- 응답에 `nextRetryAt` 포함
- 같은 계정으로 즉시 재요청 시 `429` 와 `AUTH_EMAIL_VERIFICATION_RESEND_TOO_SOON` 확인
- 백엔드 로그에서 새 이메일 인증 토큰 출력 확인

`POST /api/auth/reissue`

- `refresh_token` cookie만으로 성공
- 응답에 새 `accessToken` 포함
- 응답 `Set-Cookie` 로 refresh token rotation 확인
- 이전 refresh token 재사용 시 `401` 와 `AUTH_INVALID_REFRESH_TOKEN`
- cookie 없이 호출 시 `401` 와 `AUTH_REFRESH_TOKEN_REQUIRED`

`SameSite=None; Secure`

- 2026-05-25 로컬 헤더 검증 완료
- 백엔드를 `NAROO_AUTH_REFRESH_COOKIE_SECURE=true` 와 `NAROO_AUTH_REFRESH_COOKIE_SAME_SITE=None` 으로 실행했을 때
  - `POST /api/auth/login` 응답 `Set-Cookie` 확인
  - `POST /api/auth/reissue` 응답 `Set-Cookie` 확인
- 실제 응답 헤더 예시:
  - `Secure; HttpOnly; SameSite=None`
- 주의:
  - 이 검증은 로컬 HTTP에서 응답 헤더가 올바르게 생성되는지 확인한 것
  - 실제 브라우저가 cross-site 환경에서 해당 cookie를 저장하고 재전송하는지는 HTTPS 배포 환경에서 추가 확인 필요
