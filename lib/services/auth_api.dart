import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthApi {
  Future<String> getPowerSyncJwt() async {
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

      // Temporary fallback for local testing.
      // Replace APP_AUTH_TOKEN with your real user session token flow.
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