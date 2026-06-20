import 'package:flutter/foundation.dart';

import '../domain/review_models.dart';

/// Holds teacher-review queue/detail/metrics state. Mirrors the app's existing
/// ChangeNotifier controller pattern.
class ReviewController extends ChangeNotifier {
  ReviewController({required ReviewRepository repository})
    : _repository = repository;

  final ReviewRepository _repository;

  // Queue state.
  List<ReviewItem> _items = const [];
  int _total = 0;
  bool _isLoadingQueue = false;
  String? _queueError;

  // Filters.
  String _statusFilter = 'open';
  String? _typeFilter;
  String? _triggerFilter;

  // Detail state.
  ReviewItemDetail? _detail;
  bool _isLoadingDetail = false;
  String? _detailError;

  // Action state.
  bool _isActing = false;
  String? _actionError;

  // Metrics state.
  ReviewMetrics? _metrics;
  bool _isLoadingMetrics = false;
  String? _metricsError;

  List<ReviewItem> get items => _items;
  int get total => _total;
  bool get isLoadingQueue => _isLoadingQueue;
  String? get queueError => _queueError;

  String get statusFilter => _statusFilter;
  String? get typeFilter => _typeFilter;
  String? get triggerFilter => _triggerFilter;

  ReviewItemDetail? get detail => _detail;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailError => _detailError;

  bool get isActing => _isActing;
  String? get actionError => _actionError;

  ReviewMetrics? get metrics => _metrics;
  bool get isLoadingMetrics => _isLoadingMetrics;
  String? get metricsError => _metricsError;

  Future<void> loadQueue() async {
    _isLoadingQueue = true;
    _queueError = null;
    notifyListeners();
    try {
      final queue = await _repository.fetchQueue(
        status: _statusFilter,
        artifactType: _typeFilter,
        trigger: _triggerFilter,
      );
      _items = queue.items;
      _total = queue.total;
    } catch (error) {
      _queueError = error.toString();
    } finally {
      _isLoadingQueue = false;
      notifyListeners();
    }
  }

  void setStatusFilter(String status) {
    if (_statusFilter == status) return;
    _statusFilter = status;
    loadQueue();
  }

  void setTypeFilter(String? type) {
    if (_typeFilter == type) return;
    _typeFilter = type;
    loadQueue();
  }

  void setTriggerFilter(String? trigger) {
    if (_triggerFilter == trigger) return;
    _triggerFilter = trigger;
    loadQueue();
  }

  Future<void> loadDetail(String id) async {
    _isLoadingDetail = true;
    _detailError = null;
    _detail = null;
    notifyListeners();
    try {
      _detail = await _repository.fetchItem(id);
    } catch (error) {
      _detailError = error.toString();
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<bool> approve(String id, {String notes = ''}) =>
      _runAction(() => _repository.approve(id, notes: notes));

  Future<bool> reject(String id, {required String reason}) =>
      _runAction(() => _repository.reject(id, reason: reason));

  Future<bool> correct(
    String id, {
    required Map<String, dynamic> fields,
    String notes = '',
  }) async {
    final ok = await _runAction(
      () => _repository.correct(id, fields: fields, notes: notes),
    );
    if (ok) {
      // Refresh the detail so the corrected artifact is shown.
      await loadDetail(id);
    }
    return ok;
  }

  Future<bool> _runAction(Future<Object?> Function() action) async {
    _isActing = true;
    _actionError = null;
    notifyListeners();
    try {
      await action();
      await loadQueue();
      return true;
    } catch (error) {
      _actionError = error.toString();
      return false;
    } finally {
      _isActing = false;
      notifyListeners();
    }
  }

  Future<void> loadMetrics() async {
    _isLoadingMetrics = true;
    _metricsError = null;
    notifyListeners();
    try {
      _metrics = await _repository.fetchMetrics();
    } catch (error) {
      _metricsError = error.toString();
    } finally {
      _isLoadingMetrics = false;
      notifyListeners();
    }
  }
}
