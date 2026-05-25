# Deploy Inputs

현재 코드베이스 기준 배포 입력값 정리 문서입니다.

이 앱의 현재 배포 전제:

- Frontend: Flutter app
- Web frontend: `flutter build web` 결과물 배포 가능
- Backend source: 현재 워크스페이스의 sibling repo `../backend`
- Backend dependency: 별도 Spring Boot API 서버 필요
- Infra dependency: MySQL, Redis

주의:

- 이 저장소는 Flutter 앱 저장소임
- 현재 상위 워크스페이스에는 Spring Boot 백엔드가 `../backend` 에 별도 Git 저장소로 존재함
- 따라서 이 문서의 Backend 항목은 현재 워크스페이스의 `../backend` 기준 배포 입력값임
- Backend 빌드/배포 명령은 이 저장소 루트가 아니라 `../backend` 에서 실행하는 명령임

## 1. 배포 대상

### Frontend

- Mobile:
    - iOS: App Store / TestFlight
    - Android: Google Play Store / Internal Testing
- Web optional:
    - `build/web` 정적 배포
    - 후보: Firebase Hosting / Vercel / Netlify

### Backend

- 배포 대상:
    - 별도 Spring Boot API 서버
- 현재 저장소 포함 여부:
    - 포함되어 있지 않음
- 필요 런타임:
    - Java 17
    - MySQL
    - Redis
- 추천 플랫폼:
    - Railway
- 후보 플랫폼:
    - Railway
    - Render
    - Cloud Run
    - Fly.io
- 주의:
    - `Railway`는 추천안일 뿐 확정값이 아님
    - 아래 URL과 명령 예시는 `Railway`를 선택했을 때의 예시임

## 2. 운영 URL

- Backend production URL:
    - 예: `https://naroo-api.up.railway.app`
    - 커스텀 도메인 사용 시 예: `https://api.naroo.com`
- API base URL:
    - Backend production URL과 동일
    - 예: `https://naroo-api.up.railway.app`
- Web production URL:
    - Web을 배포할 경우만 작성
    - 예: `https://naroo.vercel.app`
- Mobile store URL:
    - 출시 후 작성
    - iOS: TBD
    - Android: TBD

## 3. Flutter 빌드 값

### Mobile / Release

```text
NAROO_BUILD_PROFILE=production
NAROO_API_BASE_URL=https://naroo-api.up.railway.app
```

### Web / Release

```text
NAROO_BUILD_PROFILE=production
NAROO_API_BASE_URL=https://naroo-api.up.railway.app
```

주의:

- `NAROO_API_BASE_URL`은 현재 Flutter 앱이 호출할 Spring Boot API 서버 주소여야 함
- 프론트 저장소에 넘길 형식은 정확히 `NAROO_API_BASE_URL=https://<backend-domain>` 임
- `/api`, `/rest/v1`, trailing slash 같은 추가 경로를 붙이지 않는 것을 기준으로 관리
- Supabase를 직접 호출하는 구조가 아니므로 `https://.../rest/v1` 같은 Supabase REST 주소를 넣으면 안 됨
- 릴리즈 빌드는 `https://` 주소가 필요함
- 개발 환경에서는 로컬 API 주소를 사용할 수 있으나, 운영 빌드에는 반드시 운영 Backend URL을 사용해야 함
- Backend production URL이 확정되기 전에는 Flutter release 빌드 값을 확정할 수 없음

## 4. Backend 환경변수

이 항목은 현재 워크스페이스의 `../backend` Spring Boot 서비스 기준으로 필요한 값입니다.

`../backend/src/main/resources/application.yaml` 기준 확인된 서버 설정:

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
- `NAROO_AUTH_REFRESH_COOKIE_SAME_SITE`

추가로 확정이 필요한 값:

- Spring profile 값
- 운영 Redis host / port 값
- JWT / auth 관련 secret
- CORS 허용 origin
- 외부 API key가 있다면 해당 secret
- 실제 메일 발송 어댑터 도입 시 메일 관련 secret

권장 환경변수 예시:

```env
SPRING_PROFILES_ACTIVE=prod

MYSQL_URL=jdbc:mysql://[host]:[port]/[database]?useSSL=true&serverTimezone=Asia/Seoul&characterEncoding=UTF-8
MYSQL_USER=[mysql_user]
MYSQL_PASS=[mysql_password]

NAROO_REDIS_HOST=[redis_host]
NAROO_REDIS_PORT=[redis_port]

NAROO_JWT_SECRET=[long_random_secret]
NAROO_AUTH_REFRESH_COOKIE_SECURE=true
NAROO_JWT_ACCESS_TOKEN_TTL_MINUTES=60
NAROO_JWT_REFRESH_TOKEN_TTL_DAYS=3

NAROO_CORS_ALLOWED_ORIGINS=https://naroo.vercel.app
```

Web을 배포하지 않고 모바일 앱만 운영할 경우:

```env
NAROO_CORS_ALLOWED_ORIGINS=[server-policy-specific-origins]
```

주의:

- 모바일 앱은 브라우저 CORS의 직접 대상이 아님
- 그렇더라도 운영 서버에서 `NAROO_CORS_ALLOWED_ORIGINS=*`처럼 너무 넓은 설정은 권장하지 않음
- Web을 나중에 붙일 가능성이 있다면 처음부터 허용 origin을 명시적으로 관리하는 것이 안전함
- Flutter Web을 배포할 경우에는 Web production URL을 `NAROO_CORS_ALLOWED_ORIGINS`에 추가해야 함

## 5. GitHub 저장소 설정

### GitHub Actions Variables

이 저장소, 즉 Flutter 앱 저장소 기준:

- `NAROO_API_BASE_URL=https://naroo-api.up.railway.app`
- `NAROO_BUILD_PROFILE=production`

### GitHub Actions Secrets

Android signing 관련 secret:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

iOS signing / App Store Connect 관련 secret:

- `IOS_CERTIFICATE_BASE64`
- `IOS_CERTIFICATE_PASSWORD`
- `IOS_PROVISIONING_PROFILE_BASE64`
- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_BASE64`

Flutter Web 배포 관련 secret:

- 사용하는 배포 플랫폼에 따라 필요
- 예:
    - `VERCEL_TOKEN`
    - `VERCEL_ORG_ID`
    - `VERCEL_PROJECT_ID`
    - `FIREBASE_SERVICE_ACCOUNT`

Backend 관련 secret:

- 현재 Flutter 저장소에서 백엔드를 직접 배포하지 않는다면 필요 없음
- 별도 백엔드 저장소에서 관리하는 것을 권장
- 백엔드 저장소에서 관리할 수 있는 값:
    - `MYSQL_URL`
    - `MYSQL_USER`
    - `MYSQL_PASS`
    - `NAROO_REDIS_HOST`
    - `NAROO_REDIS_PORT`
    - `NAROO_JWT_SECRET`
    - `NAROO_CORS_ALLOWED_ORIGINS`
    - `NAROO_AUTH_REFRESH_COOKIE_SECURE`
    - 기타 인증/외부 API secret

주의:

- `NAROO_API_BASE_URL`은 공개되어도 되는 값이므로 보통 Variable에 저장
- DB 비밀번호, JWT secret, signing key는 반드시 Secret에 저장
- Android/iOS signing 관련 값은 로컬 파일을 직접 커밋하지 말고 GitHub Secrets 또는 배포 플랫폼의 secret 기능을 사용
- 이 Flutter 저장소에 백엔드 DB secret을 넣는 것은 특별한 이유가 없다면 권장하지 않음

## 6. 배포 워크플로 메모

### Backend

현재 저장소에는 Spring Boot 백엔드 소스가 없으므로, 아래 명령은 이 저장소에서 실행하는 명령이 아닙니다.

Backend 저장소가 따로 있을 경우, 해당 Backend 저장소에서 별도로 관리해야 하는 항목:

- Java 17 설정
- MySQL 연결 설정
- Redis 연결 설정
- Spring profile 설정
- JWT/auth secret 설정
- CORS 설정
- 배포 플랫폼 설정
- health check endpoint 설정

Backend 저장소 기준 예시:

```text
Build Command:
./gradlew bootJar

Start Command:
java -jar build/libs/naroo-*.jar
```

로컬 QA 기준 이미 확인된 값:

- `GET /actuator/health` 응답 가능
- `NAROO_AUTH_REFRESH_COOKIE_SECURE=false` 로 로컬 HTTP cookie QA 가능
- 로컬 이메일 인증은 로그 토큰 방식 사용 가능

주의:

- 위 명령은 별도 Spring Boot 백엔드 저장소에 `gradlew`, `build.gradle`, `src/main` 등이 있을 때만 유효함
- 현재 Flutter 저장소 루트에서는 위 명령을 실행할 수 없음
- 현재 저장소에서 확인되는 Gradle 파일은 Android 빌드용 `android/gradlew`임
- `android/gradlew`는 Spring Boot 서버 빌드용이 아님

권장 Backend 배포 순서:

1. 별도 Backend 저장소 확인
2. MySQL 운영 인스턴스 준비
3. Redis 운영 인스턴스 준비
4. Backend 환경변수 등록
5. Spring Boot API 서버 배포
6. 현재는 `/health` endpoint가 확인되지 않았으므로 기본 API 엔드포인트로 서버 정상 동작 확인
7. Backend production URL 확정
8. Flutter `NAROO_API_BASE_URL`에 Backend production URL 반영
9. Flutter release build 진행

Railway 사용 시 권장 구성:

```text
Railway Project
├─ naroo-api: Spring Boot API
├─ MySQL
└─ Redis
```

Backend production URL 예시:

```text
https://naroo-api.up.railway.app
```

### Flutter Web

- 빌드 명령:

```bash
flutter build web --release \
  --dart-define=NAROO_BUILD_PROFILE=production \
  --dart-define=NAROO_API_BASE_URL=https://naroo-api.up.railway.app
```

- 배포 대상:
    - `build/web`
- 배포 플랫폼 후보:
    - Firebase Hosting
    - Vercel
    - Netlify
- 배포 트리거:
    - 예: `main` merge 후 자동 배포

주의:

- Vercel/Netlify에 빌드 명령만 넣는다고 항상 바로 동작하는 것은 아님
- Flutter Web 빌드를 배포 플랫폼에서 직접 수행하려면 Flutter SDK 설치 단계가 필요함
- 더 안정적인 방식은 GitHub Actions에서 Flutter Web을 빌드한 뒤 `build/web` 결과물을 배포하는 방식임

Vercel 사용 시 선택지:

#### 방식 A. GitHub Actions에서 빌드 후 Vercel 배포

권장 방식:

```text
GitHub Actions
→ Flutter SDK 설치
→ flutter pub get
→ flutter build web --release
→ build/web 산출물 생성
→ Vercel에 정적 산출물 배포
```

#### 방식 B. Vercel에서 직접 빌드

가능하지만 Flutter SDK 설치 설정이 필요함.

예시:

```text
Build Command:
flutter build web --release --dart-define=NAROO_BUILD_PROFILE=production --dart-define=NAROO_API_BASE_URL=https://naroo-api.up.railway.app

Output Directory:
build/web
```

주의:

- 방식 B를 사용할 경우 Vercel 빌드 환경에 Flutter SDK가 준비되어야 함
- Flutter SDK 설치가 어렵다면 방식 A를 권장함

### Mobile

#### Android

- 빌드 명령:

```bash
flutter build appbundle --release \
  --dart-define=NAROO_BUILD_PROFILE=production \
  --dart-define=NAROO_API_BASE_URL=https://naroo-api.up.railway.app
```

- 산출물:
    - `build/app/outputs/bundle/release/app-release.aab`
- 테스트 배포:
    - Google Play Console Internal Testing
- 정식 배포:
    - Google Play Store

주의:

- Android release build에는 signing 설정이 필요함
- Google Play 배포용으로는 APK보다 AAB 사용을 권장함
- `android/gradlew`는 Android 앱 빌드용이며 Spring Boot 백엔드 빌드용이 아님

#### iOS

- 빌드 명령:

```bash
flutter build ipa --release \
  --dart-define=NAROO_BUILD_PROFILE=production \
  --dart-define=NAROO_API_BASE_URL=https://naroo-api.up.railway.app
```

- 산출물:
    - `build/ios/ipa/*.ipa`
- 테스트 배포:
    - TestFlight
- 정식 배포:
    - App Store

주의:

- iOS 배포에는 Apple Developer Program 가입이 필요함
- iOS release build에는 signing, provisioning profile, bundle identifier 설정이 필요함
- App Store Connect 업로드 설정이 필요함

스토어 배포 전 준비 항목:

- 앱 아이콘
- 스플래시 이미지
- 앱 이름
- 앱 설명
- 스크린샷
- 개인정보처리방침 URL
- 앱 권한 설명 문구
- 문의 이메일
- 테스트 계정, 로그인 기능이 있는 경우

## 7. 확인 체크리스트

### 저장소 구조 확인

- [ ] 현재 저장소가 Flutter 앱 저장소임을 확인함
- [ ] 현재 저장소 안에 Spring Boot 백엔드 소스가 없음을 확인함
- [ ] 백엔드 저장소 또는 백엔드 배포 위치가 별도로 존재하는지 확인함
- [ ] 현재 저장소의 `android/gradlew`가 Android 빌드용임을 확인함
- [ ] 현재 저장소 루트에서 `./gradlew bootJar`를 실행하는 구조가 아님을 확인함

### Backend

- [ ] Backend 배포 플랫폼이 확정됨
    - 추천: Railway
- [ ] Backend 저장소 또는 배포 소스 위치가 확정됨
- [ ] MySQL 운영 인스턴스가 준비됨
- [ ] Redis 운영 인스턴스가 준비됨
- [ ] Backend 환경변수가 등록됨
    - `MYSQL_URL`
    - `MYSQL_USER`
    - `MYSQL_PASS`
    - `NAROO_REDIS_HOST`
    - `NAROO_REDIS_PORT`
    - `NAROO_JWT_SECRET`
    - `NAROO_CORS_ALLOWED_ORIGINS`
    - 기타 필요한 secret
- [ ] CORS 허용 origin이 정리됨
    - Web 배포 시: `https://naroo.vercel.app`
    - 모바일만 운영 시: 서버 정책에 맞게 명시적으로 관리
- [ ] Backend production URL이 확정됨
    - 예: `https://naroo-api.up.railway.app`
- [ ] Backend health check가 가능함
    - 현재 backend repo에는 actuator/health endpoint가 확인되지 않았음

### Flutter

- [ ] `NAROO_API_BASE_URL` 값이 확정됨
    - 예: `https://naroo-api.up.railway.app`
- [ ] 운영 API URL이 `https://` 로 시작함
- [ ] Flutter release 빌드에 사용할 값이 확정됨
- [ ] Web을 배포할지 여부가 확정됨
- [ ] Web production URL이 확정됨
    - Web 배포 시에만 필요
- [ ] Flutter Web 배포 방식이 확정됨
    - GitHub Actions 빌드 후 배포
    - 또는 배포 플랫폼에서 Flutter SDK 설치 후 직접 빌드
- [ ] Android signing 준비가 됨
- [ ] iOS signing 준비가 됨
- [ ] GitHub Actions variable/secret 필요 항목이 정리됨
- [ ] Google Play Console 테스트 트랙 준비가 됨
- [ ] App Store Connect / TestFlight 준비가 됨
- [ ] 개인정보처리방침 URL이 준비됨
- [ ] 앱 권한 설명 문구가 준비됨
- [ ] 출시용 앱 이름, 아이콘, 스크린샷이 준비됨

## 8. 기타 메모

- 현재 코드베이스는 Supabase 직접 호출 구조가 아니라 Spring Boot API 호출 구조임
- 따라서 `NAROO_API_BASE_URL`에는 Supabase URL이 아니라 Spring Boot API 서버 URL을 넣어야 함
- 현재 저장소에는 Spring Boot 백엔드 소스가 없음
- 로컬에서 확인된 별도 백엔드 저장소는 `../backend`이며 원격은 `https://github.com/seongj-un/naroo.git`임
- 백엔드 관련 빌드/실행 명령은 별도 백엔드 저장소 기준으로만 유효함
- 프론트만 배포해서는 동작하지 않고, 운영 MySQL/Redis를 포함한 백엔드 배포가 먼저 필요함
- 배포 순서는 Backend → Flutter release build → Store/Web 배포 순서가 안정적임
- Web을 배포하지 않는다면 Frontend production URL은 App Store / Google Play Store URL로 관리하면 됨
- Web을 배포한다면 Web production URL과 Backend CORS 설정을 함께 확정해야 함
- Android/iOS 앱은 CORS 영향을 받지 않지만, Flutter Web은 브라우저에서 동작하므로 CORS 설정이 필요함
- 운영 API URL은 반드시 `https://` 로 시작하는 주소를 사용하는 것을 권장함
- 초기에는 Railway 기본 URL을 사용하고, 나중에 커스텀 도메인 `https://api.naroo.com`으로 변경 가능함
- 이 Flutter 저장소에 DB 비밀번호나 JWT secret 같은 백엔드 secret을 넣지 않는 것을 권장함
- Backend secret은 별도 백엔드 저장소 또는 백엔드 배포 플랫폼에서 관리하는 것이 안전함
- 현재 GitHub 상태 확인 결과:
  - frontend repo variables 없음
  - frontend repo secrets 없음
  - backend repo workflows 없음
  - backend repo deploy config 파일 없음
