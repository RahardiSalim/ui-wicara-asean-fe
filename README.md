# Wicara Mobile

Flutter mockup for the Wicara landing, authentication, and onboarding flow.

## Structure

- `lib/src/app`: app shell, routes, and dependency injection.
- `lib/src/core`: shared theme tokens and reusable widgets.
- `lib/src/features/landing`: first-run landing screen.
- `lib/src/features/auth`: auth domain contract, mock data source, and sign-in UI.
- `lib/src/features/onboarding`: post-login setup flow and mock profile state.
- `lib/src/features/pretest`: adaptive pretest question, reasoning canvas, and result state.
- `lib/src/features/home`: post-pretest home shell with queue, progress, and profile tabs.

## Backend Swap

The UI depends on repository contracts, not concrete backend clients. Replace
`MockAuthRepository`, `MockOnboardingRepository`, and `MockPretestRepository`
in `lib/main.dart` with API-backed implementations when the backend is ready.

```dart
runApp(
  WicaraApp(
    authRepository: ApiAuthRepository(client),
    onboardingRepository: ApiOnboardingRepository(client),
    pretestRepository: ApiPretestRepository(client),
  ),
);
```
