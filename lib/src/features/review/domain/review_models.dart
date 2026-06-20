// Domain models for the teacher / human-in-the-loop review feature.
//
// These mirror the backend `app/modules/review` schemas. Review is
// asynchronous and non-blocking: items are surfaced after AI generation, never
// gating the learner.

double? _toDoubleOrNull(Object? value) =>
    value == null ? null : (value as num).toDouble();

int _toInt(Object? value) => value == null ? 0 : (value as num).toInt();

String _toStr(Object? value) => value == null ? '' : value.toString();

List<String> _toStringList(Object? value) => value is List
    ? value.map((e) => e.toString()).toList(growable: false)
    : const <String>[];

class ReviewItem {
  const ReviewItem({
    required this.id,
    required this.artifactType,
    required this.artifactId,
    required this.status,
    required this.triggerReasons,
    required this.confidence,
    required this.priority,
    required this.subject,
    required this.conceptId,
    required this.learnerId,
    required this.summary,
    required this.reviewerId,
    required this.createdAt,
    required this.firstReviewedAt,
    required this.resolvedAt,
  });

  final String id;
  final String artifactType;
  final String artifactId;
  final String status;
  final List<String> triggerReasons;
  final double? confidence;
  final int priority;
  final String? subject;
  final String? conceptId;
  final String? learnerId;
  final String summary;
  final String? reviewerId;
  final String createdAt;
  final String? firstReviewedAt;
  final String? resolvedAt;

  factory ReviewItem.fromJson(Map<String, dynamic> json) => ReviewItem(
    id: _toStr(json['id']),
    artifactType: _toStr(json['artifact_type']),
    artifactId: _toStr(json['artifact_id']),
    status: _toStr(json['status']),
    triggerReasons: _toStringList(json['trigger_reasons']),
    confidence: _toDoubleOrNull(json['confidence']),
    priority: _toInt(json['priority']),
    subject: json['subject']?.toString(),
    conceptId: json['concept_id']?.toString(),
    learnerId: json['learner_id']?.toString(),
    summary: _toStr(json['summary']),
    reviewerId: json['reviewer_id']?.toString(),
    createdAt: _toStr(json['created_at']),
    firstReviewedAt: json['first_reviewed_at']?.toString(),
    resolvedAt: json['resolved_at']?.toString(),
  );
}

class ReviewAction {
  const ReviewAction({
    required this.id,
    required this.action,
    required this.notes,
    required this.reviewerId,
    required this.beforeJson,
    required this.afterJson,
    required this.createdAt,
  });

  final String id;
  final String action;
  final String notes;
  final String? reviewerId;
  final Map<String, dynamic>? beforeJson;
  final Map<String, dynamic>? afterJson;
  final String createdAt;

  factory ReviewAction.fromJson(Map<String, dynamic> json) => ReviewAction(
    id: _toStr(json['id']),
    action: _toStr(json['action']),
    notes: _toStr(json['notes']),
    reviewerId: json['reviewer_id']?.toString(),
    beforeJson: json['before_json'] is Map
        ? Map<String, dynamic>.from(json['before_json'] as Map)
        : null,
    afterJson: json['after_json'] is Map
        ? Map<String, dynamic>.from(json['after_json'] as Map)
        : null,
    createdAt: _toStr(json['created_at']),
  );
}

class ReviewItemDetail extends ReviewItem {
  const ReviewItemDetail({
    required super.id,
    required super.artifactType,
    required super.artifactId,
    required super.status,
    required super.triggerReasons,
    required super.confidence,
    required super.priority,
    required super.subject,
    required super.conceptId,
    required super.learnerId,
    required super.summary,
    required super.reviewerId,
    required super.createdAt,
    required super.firstReviewedAt,
    required super.resolvedAt,
    required this.artifact,
    required this.actions,
  });

  final Map<String, dynamic>? artifact;
  final List<ReviewAction> actions;

  factory ReviewItemDetail.fromJson(Map<String, dynamic> json) {
    final base = ReviewItem.fromJson(json);
    return ReviewItemDetail(
      id: base.id,
      artifactType: base.artifactType,
      artifactId: base.artifactId,
      status: base.status,
      triggerReasons: base.triggerReasons,
      confidence: base.confidence,
      priority: base.priority,
      subject: base.subject,
      conceptId: base.conceptId,
      learnerId: base.learnerId,
      summary: base.summary,
      reviewerId: base.reviewerId,
      createdAt: base.createdAt,
      firstReviewedAt: base.firstReviewedAt,
      resolvedAt: base.resolvedAt,
      artifact: json['artifact'] is Map
          ? Map<String, dynamic>.from(json['artifact'] as Map)
          : null,
      actions: json['actions'] is List
          ? (json['actions'] as List)
                .map((e) => ReviewAction.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList(growable: false)
          : const <ReviewAction>[],
    );
  }
}

class ReviewQueue {
  const ReviewQueue({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
  });

  final List<ReviewItem> items;
  final int total;
  final int limit;
  final int offset;

  factory ReviewQueue.fromJson(Map<String, dynamic> json) => ReviewQueue(
    items: json['items'] is List
        ? (json['items'] as List)
              .map((e) => ReviewItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(growable: false)
        : const <ReviewItem>[],
    total: _toInt(json['total']),
    limit: _toInt(json['limit']),
    offset: _toInt(json['offset']),
  );
}

class ReviewTypeBreakdown {
  const ReviewTypeBreakdown({
    required this.artifactType,
    required this.reviewed,
    required this.corrected,
    required this.rejected,
    required this.approved,
    required this.correctionRate,
  });

  final String artifactType;
  final int reviewed;
  final int corrected;
  final int rejected;
  final int approved;
  final double correctionRate;

  factory ReviewTypeBreakdown.fromJson(Map<String, dynamic> json) =>
      ReviewTypeBreakdown(
        artifactType: _toStr(json['artifact_type']),
        reviewed: _toInt(json['reviewed']),
        corrected: _toInt(json['corrected']),
        rejected: _toInt(json['rejected']),
        approved: _toInt(json['approved']),
        correctionRate: _toDoubleOrNull(json['correction_rate']) ?? 0,
      );
}

class ReviewTriggerPrecision {
  const ReviewTriggerPrecision({
    required this.trigger,
    required this.totalResolved,
    required this.caughtProblem,
    required this.precision,
  });

  final String trigger;
  final int totalResolved;
  final int caughtProblem;
  final double precision;

  factory ReviewTriggerPrecision.fromJson(Map<String, dynamic> json) =>
      ReviewTriggerPrecision(
        trigger: _toStr(json['trigger']),
        totalResolved: _toInt(json['total_resolved']),
        caughtProblem: _toInt(json['caught_problem']),
        precision: _toDoubleOrNull(json['precision']) ?? 0,
      );
}

class ReviewTimePoint {
  const ReviewTimePoint({
    required this.date,
    required this.reviewed,
    required this.corrected,
  });

  final String date;
  final int reviewed;
  final int corrected;

  factory ReviewTimePoint.fromJson(Map<String, dynamic> json) => ReviewTimePoint(
    date: _toStr(json['date']),
    reviewed: _toInt(json['reviewed']),
    corrected: _toInt(json['corrected']),
  );
}

class ReviewMetrics {
  const ReviewMetrics({
    required this.reviewedTotal,
    required this.correctedTotal,
    required this.correctionRate,
    required this.approvalRate,
    required this.rejectionRate,
    required this.backlogOpen,
    required this.backlogOldestAgeDays,
    required this.byType,
    required this.triggerPrecision,
    required this.timeSeries,
  });

  final int reviewedTotal;
  final int correctedTotal;
  final double correctionRate;
  final double approvalRate;
  final double rejectionRate;
  final int backlogOpen;
  final double? backlogOldestAgeDays;
  final List<ReviewTypeBreakdown> byType;
  final List<ReviewTriggerPrecision> triggerPrecision;
  final List<ReviewTimePoint> timeSeries;

  factory ReviewMetrics.fromJson(Map<String, dynamic> json) => ReviewMetrics(
    reviewedTotal: _toInt(json['reviewed_total']),
    correctedTotal: _toInt(json['corrected_total']),
    correctionRate: _toDoubleOrNull(json['correction_rate']) ?? 0,
    approvalRate: _toDoubleOrNull(json['approval_rate']) ?? 0,
    rejectionRate: _toDoubleOrNull(json['rejection_rate']) ?? 0,
    backlogOpen: _toInt(json['backlog_open']),
    backlogOldestAgeDays: _toDoubleOrNull(json['backlog_oldest_age_days']),
    byType: json['by_type'] is List
        ? (json['by_type'] as List)
              .map((e) => ReviewTypeBreakdown.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(growable: false)
        : const <ReviewTypeBreakdown>[],
    triggerPrecision: json['trigger_precision'] is List
        ? (json['trigger_precision'] as List)
              .map((e) => ReviewTriggerPrecision.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(growable: false)
        : const <ReviewTriggerPrecision>[],
    timeSeries: json['time_series'] is List
        ? (json['time_series'] as List)
              .map((e) => ReviewTimePoint.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(growable: false)
        : const <ReviewTimePoint>[],
  );
}

abstract class ReviewRepository {
  Future<ReviewQueue> fetchQueue({
    String? status,
    String? artifactType,
    String? trigger,
    String? subject,
    int limit = 50,
    int offset = 0,
  });

  Future<ReviewItemDetail> fetchItem(String id);

  Future<ReviewItem> approve(String id, {String notes = ''});

  Future<ReviewItem> reject(String id, {required String reason});

  Future<ReviewItemDetail> correct(
    String id, {
    required Map<String, dynamic> fields,
    String notes = '',
  });

  Future<ReviewMetrics> fetchMetrics();

  Future<ReviewItem> flag({
    required String artifactType,
    required String artifactId,
    required String reason,
  });

  /// Authoritative backend role check used to gate the teacher UI.
  Future<bool> isCurrentUserTeacher();
}
