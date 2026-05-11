import 'onboarding_profile.dart';

class OnboardingException implements Exception {
  const OnboardingException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class OnboardingRepository {
  Future<void> saveProfile(OnboardingProfile profile);
}
