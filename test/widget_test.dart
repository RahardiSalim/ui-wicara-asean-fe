import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wicara_mobile/src/app/wicara_app.dart';
import 'package:wicara_mobile/src/features/auth/data/mock_auth_repository.dart';
import 'package:wicara_mobile/src/features/onboarding/data/mock_onboarding_repository.dart';
import 'package:wicara_mobile/src/features/pretest/data/mock_pretest_repository.dart';

void main() {
  testWidgets('landing page opens the sign in page', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const WicaraApp(
        authRepository: MockAuthRepository(delay: Duration.zero),
        onboardingRepository: MockOnboardingRepository(delay: Duration.zero),
        pretestRepository: MockPretestRepository(delay: Duration.zero),
      ),
    );

    expect(
      find.text('Prerequisite-first AI tutor\nfor ASEAN learners'),
      findsOneWidget,
    );
    expect(find.text('Get started'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.byIcon(Icons.mail_outline_rounded), findsOneWidget);
  });

  testWidgets('sign in opens onboarding and advances through setup', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const WicaraApp(
        authRepository: MockAuthRepository(delay: Duration.zero),
        onboardingRepository: MockOnboardingRepository(delay: Duration.zero),
        pretestRepository: MockPretestRepository(delay: Duration.zero),
      ),
    );

    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'aisyah@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text("Let's set you up"), findsOneWidget);
    expect(find.text('Aisyah Putri'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Choose your subjects'), findsOneWidget);
    expect(find.text('Math'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('How would you like to learn?'), findsOneWidget);
    expect(find.text('Continue to adaptive pretest'), findsOneWidget);
  });

  testWidgets('pretest moves from question to reasoning and result', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const WicaraApp(
        authRepository: MockAuthRepository(delay: Duration.zero),
        onboardingRepository: MockOnboardingRepository(delay: Duration.zero),
        pretestRepository: MockPretestRepository(delay: Duration.zero),
      ),
    );

    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'aisyah@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue to adaptive pretest'));
    await tester.pumpAndSettle();

    expect(find.text('Knowledge Space Theory'), findsWidgets);
    expect(find.text('Submit answer'), findsOneWidget);

    await tester.ensureVisible(find.text('Submit answer'));
    await tester.tap(find.text('Submit answer'));
    await tester.pumpAndSettle();

    expect(find.text('Help us understand your thinking'), findsOneWidget);
    expect(find.text('Canvas'), findsOneWidget);

    await tester.ensureVisible(find.byIcon(Icons.arrow_upward_rounded));
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Your knowledge state'), findsOneWidget);
    expect(find.text('Continue to my path'), findsOneWidget);

    await tester.ensureVisible(find.text('Continue to my path'));
    await tester.tap(find.text('Continue to my path'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back, Aisha 👋'), findsOneWidget);
    expect(find.text("Today's learning queue"), findsOneWidget);

    await tester.tap(find.text('Learn'));
    await tester.pumpAndSettle();

    expect(find.text('Calculus I'), findsWidgets);
    expect(find.text('Gallery'), findsOneWidget);

    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();

    expect(find.text('Content Gallery'), findsOneWidget);
    expect(find.text('Derivatives intuition'), findsOneWidget);

    await tester.tap(find.text('Derivatives intuition'));
    await tester.pumpAndSettle();

    expect(find.text('What does a derivative tell us?'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Cheatsheet summary'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();

    expect(find.text('Progress'), findsWidgets);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsWidgets);
  });
}
