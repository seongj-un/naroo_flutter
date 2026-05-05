# Naroo

## Local Development

Start MySQL and Redis:

```bash
docker compose up -d
```

Run the application:

```bash
./gradlew bootRun
```

Run the Flutter web frontend against a backend:

```bash
flutter run -d web-server --web-port 3000 \
  --dart-define=NAROO_API_BASE_URL=http://localhost:8080
```

Build the Flutter web frontend for a deployed backend:

```bash
flutter build web \
  --dart-define=NAROO_API_BASE_URL=https://your-backend.example.com
```

Default local services:

- MySQL: `localhost:3306`, database `naroo`, user `naroo`, password `naroo`
- Redis: `localhost:6379`
- Email verification sender: local logging adapter. Check the application log for the verification token.

The application also accepts Xquare-style environment variables:

- `MYSQL_URL`
- `MYSQL_USER`
- `MYSQL_PASS`

Useful endpoints:

- `GET /api/math-areas`
- `POST /api/auth/sign-up`
- `POST /api/auth/email/verify`
- `POST /api/auth/login`
- `POST /api/auth/reissue`
- `GET /api/auth/me`
- `POST /api/diagnostics/starting-point`
- `POST /api/diagnostics`
- `GET /api/diagnostics/{diagnosticSessionId}/questions`

Example signup body:

```json
{
  "loginId": "student01",
  "email": "student01@example.com",
  "password": "password123",
  "nickname": "나루",
  "mathStatus": "UNKNOWN"
}
```

Example email verification body:

```json
{
  "token": "token-from-application-log"
}
```

Example starting point body:

```json
{
  "selectionType": "WEAK_AREA",
  "mathArea": "FUNCTION",
  "note": "함수가 제일 헷갈려요"
}
```

Create a diagnostic session after selecting a starting point:

```bash
curl -X POST http://localhost:8080/api/diagnostics \
  -H "Authorization: Bearer <access-token>"
```

Fetch diagnostic questions:

```bash
curl http://localhost:8080/api/diagnostics/<diagnostic-session-id>/questions \
  -H "Authorization: Bearer <access-token>"
```

Stop local infrastructure:

```bash
docker compose down
```
