import 'package:flutter/foundation.dart';

import '../domain/analytics_models.dart';

/// Loads the four analytics views in parallel and exposes them to the Insights UI.
class AnalyticsController extends ChangeNotifier {
  AnalyticsController({required AnalyticsRepository repository})
    : _repository = repository;

  final AnalyticsRepository _repository;

  bool _isLoading = false;
  String? _error;
  AnalyticsOverview? _overview;
  AnalyticsVelocity? _velocity;
  AnalyticsTrends? _trends;
  AnalyticsAtRisk? _atRisk;
  String _trendPeriod = 'month';

  bool get isLoading => _isLoading;
  String? get error => _error;
  AnalyticsOverview? get overview => _overview;
  AnalyticsVelocity? get velocity => _velocity;
  AnalyticsTrends? get trends => _trends;
  AnalyticsAtRisk? get atRisk => _atRisk;
  String get trendPeriod => _trendPeriod;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.fetchOverview(),
        _repository.fetchVelocity(),
        _repository.fetchTrends(period: _trendPeriod),
        _repository.fetchAtRisk(limit: 20),
      ]);
      _overview = results[0] as AnalyticsOverview;
      _velocity = results[1] as AnalyticsVelocity;
      _trends = results[2] as AnalyticsTrends;
      _atRisk = results[3] as AnalyticsAtRisk;
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setTrendPeriod(String period) async {
    if (_trendPeriod == period) return;
    _trendPeriod = period;
    notifyListeners();
    try {
      _trends = await _repository.fetchTrends(period: period);
    } catch (_) {
      // keep the previous trends on failure
    }
    notifyListeners();
  }
}
