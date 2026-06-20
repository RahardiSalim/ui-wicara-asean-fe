import '../../../core/network/api_client.dart';
import '../domain/analytics_models.dart';

class ApiAnalyticsRepository implements AnalyticsRepository {
  const ApiAnalyticsRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<AnalyticsOverview> fetchOverview() async {
    final json = await _apiClient.getJson('/api/v1/analytics/overview');
    return AnalyticsOverview.fromJson(json);
  }

  @override
  Future<AnalyticsTrends> fetchTrends({String period = 'month'}) async {
    final json = await _apiClient.getJson(
      '/api/v1/analytics/trends',
      queryParameters: {'period': period},
    );
    return AnalyticsTrends.fromJson(json);
  }

  @override
  Future<AnalyticsVelocity> fetchVelocity() async {
    final json = await _apiClient.getJson('/api/v1/analytics/velocity');
    return AnalyticsVelocity.fromJson(json);
  }

  @override
  Future<AnalyticsAtRisk> fetchAtRisk({int limit = 20}) async {
    final json = await _apiClient.getJson(
      '/api/v1/analytics/at-risk',
      queryParameters: {'limit': '$limit'},
    );
    return AnalyticsAtRisk.fromJson(json);
  }
}
