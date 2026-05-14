import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/network/api_client.dart';
import '../domain/auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({
    required ApiClient apiClient,
    required String googleWebClientId,
  }) : _apiClient = apiClient,
       _googleSignIn = GoogleSignIn(
         scopes: const ['email', 'profile'],
         clientId: googleWebClientId.isEmpty ? null : googleWebClientId,
         serverClientId: kIsWeb || googleWebClientId.isEmpty
             ? null
             : googleWebClientId,
       );

  final ApiClient _apiClient;
  final GoogleSignIn _googleSignIn;

  @override
  Future<AuthSession> signIn(SignInRequest request) async {
    try {
      final json = await _apiClient.postJson(
        '/api/v1/auth/sign-in',
        body: {
          'email_or_phone': request.emailOrPhone.trim(),
          'password': request.password,
          'role': request.role.name,
        },
      );
      return _toAuthSession(json, request.role);
    } on ApiClientException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<AuthSession> signInWithGoogle({required AuthRole role}) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw const AuthException('Google sign-in was cancelled.');
      }
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthException(
          'Google did not return idToken. Set serverClientId/web client id.',
        );
      }

      final json = await _apiClient.postJson(
        '/api/v1/auth/google',
        body: {
          'id_token': idToken,
          'access_token': auth.accessToken,
          'role': role.name,
        },
      );
      return _toAuthSession(json, role);
    } on AuthException {
      rethrow;
    } on ApiClientException catch (error) {
      throw AuthException(error.message);
    } catch (error) {
      throw AuthException('Google sign-in failed: $error');
    }
  }

  AuthSession _toAuthSession(Map<String, dynamic> json, AuthRole role) {
    return AuthSession(
      userId: (json['user_id'] ?? '').toString(),
      displayName: (json['display_name'] ?? '').toString(),
      role: role,
      token: (json['token'] ?? '').toString(),
    );
  }
}
