import '../domain/onboarding_profile.dart';
import '../domain/onboarding_repository.dart';

class MockOnboardingRepository implements OnboardingRepository {
  const MockOnboardingRepository({
    this.delay = const Duration(milliseconds: 350),
  });

  final Duration delay;

  @override
  Future<void> saveProfile(OnboardingProfile profile) async {
    await Future<void>.delayed(delay);

    if (profile.fullName.trim().isEmpty) {
      throw const OnboardingException('Please complete your profile.');
    }
  }
}
