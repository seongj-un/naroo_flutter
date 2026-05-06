# Release Checklist

Last updated: 2026-05-06

## API and HTTPS

- Build production clients with an HTTPS API URL:

```bash
flutter build web \
  --dart-define=NAROO_BUILD_PROFILE=production \
  --dart-define=NAROO_API_BASE_URL=https://<production-api-domain>
```

- Release builds reject insecure API URLs unless `NAROO_ALLOW_INSECURE_API=true` is explicitly provided.
- Do not ship `localhost`, `127.0.0.1`, or plain HTTP as `NAROO_API_BASE_URL`.
- Backend CORS must allow the exact frontend origin. Do not use `*` when credentials are enabled.

## Refresh Cookie

- Production backend must set the refresh cookie with `Secure`, `HttpOnly`, and an HTTPS domain.
- Local HTTP testing can use `NAROO_AUTH_REFRESH_COOKIE_SECURE=false`.
- Web builds use credentialed requests so the browser can send the refresh cookie.
- iOS/Android builds keep the refresh cookie in memory for the current app session.

## Android Store Build

- Application ID is currently `com.naroo.app`.
- Create `android/key.properties` locally before a Play Store build:

```properties
storeFile=/absolute/path/to/release-keystore.jks
storePassword=<store-password>
keyAlias=<key-alias>
keyPassword=<key-password>
```

- `android/key.properties` must stay uncommitted.
- Build command:

```bash
flutter build appbundle \
  --dart-define=NAROO_BUILD_PROFILE=production \
  --dart-define=NAROO_API_BASE_URL=https://<production-api-domain>
```

## iOS App Store Build

- Bundle ID is currently `com.naroo.app`.
- Set the Apple Developer Team and provisioning profile in Xcode.
- Build command:

```bash
flutter build ios --release \
  --dart-define=NAROO_BUILD_PROFILE=production \
  --dart-define=NAROO_API_BASE_URL=https://<production-api-domain>
```

## Manual QA Before Submission

- Fresh install opens the Naroo entry screen.
- Login succeeds against the production API.
- Diagnostic, result, recovery mission, and mission submission all complete.
- Refresh-token reissue works after access-token expiry.
- Offline backend/network failure shows a user-facing error message.
