import 'package:shared_preferences/shared_preferences.dart';

import '../domain/auth_repository.dart';

class AuthSessionStore {
  static const _userIdKey = 'auth.user_id';
  static const _displayNameKey = 'auth.display_name';
  static const _roleKey = 'auth.role';
  static const _tokenKey = 'auth.token';
  static const _onboardingCompletedKey = 'auth.onboarding_completed';

  AuthSession? _session;

  AuthSession? get currentSession => _session;

  String? get accessToken => _session?.token;

  Future<void> restore() async {
    final preferences = await SharedPreferences.getInstance();
    final userId = preferences.getString(_userIdKey);
    final token = preferences.getString(_tokenKey);
    if (userId == null || userId.isEmpty || token == null || token.isEmpty) {
      _session = null;
      return;
    }

    final roleName = preferences.getString(_roleKey) ?? AuthRole.learner.name;
    _session = AuthSession(
      userId: userId,
      displayName: preferences.getString(_displayNameKey) ?? 'Learner',
      role: _roleFromName(roleName),
      token: token,
      onboardingCompleted:
          preferences.getBool(_onboardingCompletedKey) ?? false,
    );
  }

  Future<void> save(AuthSession session) async {
    _session = session;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_userIdKey, session.userId);
    await preferences.setString(_displayNameKey, session.displayName);
    await preferences.setString(_roleKey, session.role.name);
    await preferences.setString(_tokenKey, session.token ?? '');
    await preferences.setBool(
      _onboardingCompletedKey,
      session.onboardingCompleted,
    );
  }

  Future<void> markOnboardingCompleted({String? displayName}) async {
    final session = _session;
    if (session == null) {
      return;
    }

    await save(
      session.copyWith(
        displayName: displayName?.trim().isNotEmpty == true
            ? displayName!.trim()
            : session.displayName,
        onboardingCompleted: true,
      ),
    );
  }

  Future<void> clear() async {
    _session = null;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_userIdKey);
    await preferences.remove(_displayNameKey);
    await preferences.remove(_roleKey);
    await preferences.remove(_tokenKey);
    await preferences.remove(_onboardingCompletedKey);
  }

  AuthRole _roleFromName(String value) {
    for (final role in AuthRole.values) {
      if (role.name == value) {
        return role;
      }
    }
    return AuthRole.learner;
  }
}

final authSessionStore = AuthSessionStore();
