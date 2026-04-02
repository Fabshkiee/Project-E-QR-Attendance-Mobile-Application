# PowerSync and Supabase Integration Guide

This is a detailed technical guide for how data sync and auth currently work in this project.

This document includes:
- Architecture and execution flow
- Project code snippets with explanations
- Sync rules examples
- Offline behavior
- Troubleshooting playbook

This document does not include secret values from the environment file.

## 1. High-Level Architecture

The app is an offline-first Flutter app using a local PowerSync database.

Core responsibilities:
- Flutter app UI and QR scanner
- PowerSync local SQLite database
- PowerSync service synchronization
- Optional Supabase Auth session token for identity
- Optional backend token endpoint

Relevant files:
- lib/main.dart
- lib/powersync/powersync.dart
- lib/powersync/backend_connector.dart
- lib/services/auth_api.dart
- lib/models/schema.dart
- lib/features/qr_scanner/qr_scanner_page.dart

## 2. App Startup and Initialization

Code from lib/main.dart:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  if (supabaseUrl != null && supabaseUrl.isNotEmpty &&
      supabaseAnonKey != null && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  await openDatabase();
  await TablesReader.printTables(db);
  runApp(const MyApp());
}
```

Explanation:
1. Dotenv is loaded first, so configuration is available.
2. Supabase is initialized only when URL and anon key are configured.
3. PowerSync local DB is opened and sync connection starts.
4. App runs after database and sync setup is prepared.

## 3. PowerSync Database Setup

Code from lib/powersync/powersync.dart:

```dart
openDatabase() async {
  final dir = await getApplicationSupportDirectory();
  final path = join(dir.path, 'powersync-dart.db');

  db = PowerSyncDatabase(schema: schema, path: path);
  await db.initialize();

  await db.connect(connector: MyBackendConnector(db));
}
```

Explanation:
1. Creates a persistent local DB file.
2. Applies the local schema.
3. Starts sync with PowerSync service through the connector.

Important:
- If connect is not called, only local DB exists and no remote data sync occurs.

## 4. Credential Resolution Flow

Code from lib/services/auth_api.dart:

```dart
class AuthApi {
  Future<String> getPowerSyncJwt() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      final accessToken = session?.accessToken;
      if (accessToken != null && accessToken.isNotEmpty) {
        return accessToken;
      }
    } catch (_) {
      // Supabase is optional; fall through to the existing auth options.
    }

    final tokenUrl = dotenv.env['POWERSYNC_TOKEN_URL'];
    if (tokenUrl == null || tokenUrl.isEmpty) {
      final directToken = dotenv.env['INSTANCE_TOKEN'];
      if (directToken != null && directToken.isNotEmpty) {
        return directToken;
      }
      throw StateError(
        'Missing auth config in .env. Set POWERSYNC_TOKEN_URL or INSTANCE_TOKEN.',
      );
    }

    final uri = Uri.parse(tokenUrl);
    final client = HttpClient();

    try {
      final request = await client.postUrl(uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');

      final appAuthToken = dotenv.env['APP_AUTH_TOKEN'];
      if (appAuthToken != null && appAuthToken.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $appAuthToken');
      }

      request.add(utf8.encode('{}'));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError('Token request failed (${response.statusCode}): $body');
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw StateError('Unexpected token response format');
      }

      final token = (decoded['token'] ?? decoded['powersync_token'])?.toString();
      if (token == null || token.isEmpty) {
        throw StateError('Token missing in backend response');
      }

      return token;
    } finally {
      client.close();
    }
  }
}
```

Credential priority order:
1. Supabase session access token
2. Custom token endpoint URL
3. Fallback static token

Why this matters:
- Supabase session token can carry a real user id claim for rules that use request.user_id().
- Static dev tokens may not provide the user identity your bucket parameters need.

## 5. Backend Connector

Code from lib/powersync/backend_connector.dart:

```dart
class MyBackendConnector extends PowerSyncBackendConnector {
  final PowerSyncDatabase db;
  final AuthApi _authApi;

  MyBackendConnector(this.db, {AuthApi? authApi}) : _authApi = authApi ?? AuthApi();

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final endpoint = dotenv.env['INSTANCE_URL'];
    final token = await _authApi.getPowerSyncJwt();

    if (endpoint == null || endpoint.isEmpty) {
      throw StateError('Missing INSTANCE_URL in .env');
    }

    return PowerSyncCredentials(endpoint: endpoint, token: token);
  }
}
```

Explanation:
- fetchCredentials is called by PowerSync whenever credentials are needed or refreshed.
- Endpoint always comes from configuration.
- Token always comes from AuthApi flow.

## 6. Local Schema Used by PowerSync

Code from lib/models/schema.dart:

```dart
const schema = Schema([
  Table('users', [
    Column.text('auth_user_id'),
    Column.text('short_id'),
    Column.text('full_name'),
    Column.text('nickname'),
    Column.text('contact_number'),
    Column.text('role'),
    Column.text('qr_token'),
    Column.text('created_at'),
    Column.text('updated_at')
  ]),
  Table('members', [
    Column.text('status'),
    Column.text('started_date'),
    Column.text('valid_until'),
    Column.integer('membership_type_id'),
    Column.text('coach_id')
  ]),
  Table('staff', [
    Column.text('subrole'),
    Column.text('last_active')
  ]),
  Table('membership_types', [
    Column.text('name'),
    Column.text('monthly_fee'),
    Column.text('student_fee'),
    Column.text('created_at')
  ]),
  Table('attendance_logs', [
    Column.text('user_id'),
    Column.text('check_in_time'),
    Column.text('status_at_scan'),
    Column.text('created_at')
  ])
]);
```

Notes:
- This defines columns available locally for app queries.
- PowerSync internal tables with prefix ps_ are normal and expected.

## 7. QR Scanner Validation Flow

Code from lib/features/qr_scanner/qr_scanner_page.dart:

```dart
final List<String> qrParts = scannedValue?.split(':') ?? [];
if (qrParts.length < 4) {
  print('Invalid QR format');
  return;
}

final String org = qrParts[0];
final String user = qrParts[1];
final String uid = qrParts[2];
final String qrToken = qrParts[3];
```

For member QR:

```dart
final memberRoleRows = await db.getAll(
  "SELECT id, short_id, role, qr_token FROM users WHERE LOWER(TRIM(role)) = 'member' LIMIT 1",
);
```

Then member UID check:

```dart
final matchedMemberRows = await db.getAll(
  "SELECT id, short_id, role, qr_token FROM users WHERE LOWER(TRIM(role)) = 'member' AND short_id = ? LIMIT 1",
  [uid],
);
```

Then token consistency check:

```dart
final member = matchedMemberRows.first;
final localQrToken = member['qr_token']?.toString() ?? '';

if (localQrToken.isNotEmpty && localQrToken != qrToken) {
  print('UID matched Member but qr_token did not match');
} else {
  print('Matched Member');
}
```

Why this logic exists:
- Role match ensures QR is validated against member accounts only.
- UID match binds QR to a known local profile.
- Token match adds an additional anti-tamper check.

## 8. Offline-First Behavior

PowerSync behavior in this app:
- Queries in scanner run against local database
- Works offline if the required rows were synced previously
- Sync resumes when network and valid credentials are available

Practical implications:
- First online sync is required before offline scanner validation can work.
- Empty local tables mean QR checks will fail even if remote Supabase has data.

## 9. Sync Rules Design Guidance

### 9.1 If using bucket parameters

Every data query must reference the parameter, for example:

```yaml
bucket_definitions:
  gym_data:
    parameters:
      - SELECT 'gym_bucket' AS id
    data:
      - SELECT * FROM users WHERE bucket.id = 'gym_bucket'
      - SELECT * FROM members WHERE bucket.id = 'gym_bucket'
      - SELECT * FROM staff WHERE bucket.id = 'gym_bucket'
      - SELECT * FROM membership_types WHERE bucket.id = 'gym_bucket'
      - SELECT * FROM attendance_logs WHERE bucket.id = 'gym_bucket'
```

### 9.2 If rules depend on request.user_id()

Example:

```yaml
parameters:
  - SELECT 'gym_bucket' AS id FROM users
    WHERE auth_user_id = request.user_id()
      AND role IN ('Admin', 'Staff')
```

This requires:
- Non-null request.user_id()
- A users row that maps auth_user_id to the authenticated user
- Role condition satisfied

If request.user_id() is null, no bucket is produced and local app tables stay empty.

## 10. Environment Variables Reference

Do not commit real values.

Variables used by current code:
- INSTANCE_URL
- SUPABASE_URL
- SUPABASE_ANON_KEY
- POWERSYNC_TOKEN_URL
- APP_AUTH_TOKEN
- INSTANCE_TOKEN

Recommended use:
- Production: Supabase session token path
- Development: temporary fallback token path

## 11. Troubleshooting Playbook

### Issue A: No local users with role Member

Symptoms:
- Scanner prints no local member role found
- Local roles output is empty

Likely causes:
- Bucket not created
- Users table not included in data queries
- Role value not synced as expected

Actions:
1. Verify sync rules include users data
2. Verify bucket is created for the current credentials
3. Print role list locally

### Issue B: Credentials show userId null

Symptoms:
- PowerSync logs credentials with userId null

Likely cause:
- Token does not provide expected identity for request.user_id()

Actions:
1. Use authenticated Supabase session before starting sync
2. Or adjust rules to not depend on request.user_id() for this deployment model

### Issue C: Authorization 401 with aud mismatch

Likely cause:
- Token audience does not match PowerSync endpoint instance

Action:
- Ensure endpoint and token are from the same PowerSync instance

### Issue D: Query must cover all bucket parameters

Likely cause:
- Data query missing bucket parameter reference

Action:
- Include bucket.id in every data query where clause

## 12. Useful SQL Checks During Debugging

```sql
SELECT COUNT(*) AS count FROM users;
SELECT DISTINCT role FROM users ORDER BY role;
SELECT id, short_id, role, qr_token FROM users LIMIT 20;
SELECT COUNT(*) AS count FROM members;
```

Use these checks after sync starts to confirm data availability before scanner validation.

## 13. Security and Operational Notes

- Never publish secret environment values in docs, commits, or screenshots.
- Prefer short-lived user-scoped auth tokens for production.
- Static tokens are for temporary development use only.
- Ensure role-based access is enforced at sync rules level, not only in Flutter UI.
