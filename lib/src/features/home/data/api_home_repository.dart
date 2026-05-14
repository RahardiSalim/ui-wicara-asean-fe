import '../../../core/network/api_client.dart';
import '../../auth/data/auth_session_store.dart';
import '../domain/home_repository.dart';
import '../domain/home_snapshot.dart';

class ApiHomeRepository implements HomeRepository {
  const ApiHomeRepository({
    required ApiClient apiClient,
    required AuthSessionStore sessionStore,
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore;

  final ApiClient _apiClient;
  final AuthSessionStore _sessionStore;

  @override
  Future<HomeSnapshot> fetchSnapshot() async {
    final token = _sessionStore.accessToken;
    if (token == null || token.isEmpty) {
      throw const ApiClientException('Please log in before opening dashboard.');
    }

    final profileJson = await _apiClient.getJson(
      '/api/v1/me/profile',
      headers: {'Authorization': 'Bearer $token'},
    );
    final subjectsJson = await _apiClient.getJson('/api/v1/subjects');
    final subjectNamesByCode = _subjectNamesByCode(subjectsJson);
    final selectedSubjectCodes = _stringList(profileJson['selected_subjects']);
    final selectedSubjects = selectedSubjectCodes
        .map((code) => subjectNamesByCode[code] ?? _titleFromCode(code))
        .toList(growable: false);

    return HomeSnapshot(
      displayName: _string(profileJson['full_name']).isNotEmpty
          ? _string(profileJson['full_name'])
          : (_sessionStore.currentSession?.displayName ?? 'Learner'),
      country: _string(profileJson['country_name']),
      educationLevel: _educationLabel(_string(profileJson['education_level'])),
      gradeLevel: _gradeLabel(_string(profileJson['grade_level'])),
      preferredLanguage: _languageLabel(
        _string(profileJson['preferred_language']),
      ),
      studyGoal: _string(profileJson['study_goal']),
      dailyStudyTime: _string(profileJson['daily_study_time_label']),
      selectedSubjects: selectedSubjects,
      availableSubjects: subjectNamesByCode.values.toList(growable: false),
      onboardingCompleted: profileJson['onboarding_completed'] == true,
    );
  }

  Map<String, String> _subjectNamesByCode(Map<String, dynamic> json) {
    final items = json['items'];
    if (items is! List) {
      return const {};
    }

    return {
      for (final item in items)
        if (item is Map<String, dynamic>)
          _string(item['code']): _string(item['name']),
    }..removeWhere((code, name) => code.isEmpty || name.isEmpty);
  }

  List<String> _stringList(Object? value) {
    if (value is! List) {
      return const [];
    }
    return value
        .map((item) => _string(item))
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  String _string(Object? value) => (value ?? '').toString().trim();

  String _educationLabel(String code) {
    return switch (code) {
      'elementary' => 'Elementary school',
      'junior_high' => 'Junior high school',
      'senior_high' => 'Senior high school',
      'university' => 'University',
      _ => code,
    };
  }

  String _gradeLabel(String code) {
    final match = RegExp(r'^grade_(\d+)$').firstMatch(code);
    if (match != null) {
      return 'Grade ${match.group(1)}';
    }
    return switch (code) {
      'undergraduate' => 'Undergraduate',
      'graduate' => 'Graduate',
      'postgraduate' => 'Postgraduate',
      _ => code,
    };
  }

  String _languageLabel(String code) {
    return switch (code) {
      'id' => 'Bahasa Indonesia',
      'en' => 'English',
      'ms' => 'Bahasa Melayu',
      'fil' => 'Filipino',
      'vi' => 'Vietnamese',
      _ => code,
    };
  }

  String _titleFromCode(String code) {
    return code
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}
