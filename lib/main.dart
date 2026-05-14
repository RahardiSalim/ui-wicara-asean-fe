import 'package:flutter/material.dart';

import 'src/app/wicara_app.dart';
import 'src/core/network/api_client.dart';
import 'src/features/auth/data/api_auth_repository.dart';
import 'src/features/auth/data/auth_session_store.dart';
import 'src/features/curriculum/data/api_curriculum_repository.dart';
import 'src/features/onboarding/data/api_onboarding_repository.dart';
import 'src/features/pretest/data/mock_pretest_repository.dart';

const _googleWebClientId = String.fromEnvironment(
  'WICARA_GOOGLE_WEB_CLIENT_ID',
);

void main() {
  final apiClient = ApiClient(baseUrl: ApiClient.defaultBaseUrl);

  runApp(
    WicaraApp(
      authRepository: ApiAuthRepository(
        apiClient: apiClient,
        sessionStore: authSessionStore,
        googleWebClientId: _googleWebClientId,
      ),
      curriculumRepository: ApiCurriculumRepository(apiClient: apiClient),
      onboardingRepository: ApiOnboardingRepository(
        apiClient: apiClient,
        sessionStore: authSessionStore,
      ),
      pretestRepository: MockPretestRepository(),
    ),
  );
}
