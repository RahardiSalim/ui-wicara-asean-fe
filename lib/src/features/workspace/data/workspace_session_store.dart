import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Stores workspace session IDs keyed by `${trackId}__${moduleId}` so
/// multiple modules can each keep their own independent session.
class WorkspaceSessionStore {
  static const _legacyTrackIdKey = 'workspace.track_id';
  static const _legacyModuleIdKey = 'workspace.module_id';
  static const _legacyWorkspaceIdKey = 'workspace.workspace_id';
  static const _sessionsMapKey = 'workspace.sessions_map';

  /// In-memory map: composite key → workspaceId
  final Map<String, String> _sessions = {};

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  Future<void> read() async {
    final preferences = await SharedPreferences.getInstance();

    // Migrate legacy single-session keys if present
    final legacyTrack = preferences.getString(_legacyTrackIdKey)?.trim();
    final legacyModule = preferences.getString(_legacyModuleIdKey)?.trim();
    final legacyWorkspace =
        preferences.getString(_legacyWorkspaceIdKey)?.trim();
    if (legacyTrack != null &&
        legacyTrack.isNotEmpty &&
        legacyModule != null &&
        legacyModule.isNotEmpty &&
        legacyWorkspace != null &&
        legacyWorkspace.isNotEmpty) {
      final key = _key(legacyTrack, legacyModule);
      _sessions[key] = legacyWorkspace;
      // Remove legacy keys so we don't re-migrate on next launch
      await preferences.remove(_legacyTrackIdKey);
      await preferences.remove(_legacyModuleIdKey);
      await preferences.remove(_legacyWorkspaceIdKey);
    }

    // Load the multi-session map
    final raw = preferences.getString(_sessionsMapKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          if (entry.value is String) {
            _sessions[entry.key] = entry.value as String;
          }
        }
      } catch (_) {
        // Corrupt data – start fresh
      }
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns the stored workspace ID for this (trackId, moduleId) pair, or
  /// `null` if no session has been saved yet.
  String? workspaceIdFor({
    required String trackId,
    required String moduleId,
  }) {
    final id = _sessions[_key(trackId, moduleId)];
    return (id == null || id.isEmpty) ? null : id;
  }

  Future<void> save({
    required String trackId,
    required String moduleId,
    required String workspaceId,
  }) async {
    final k = _key(trackId, moduleId);
    _sessions[k] = workspaceId;
    await _persist();
  }

  /// Removes the stored session for a specific (trackId, moduleId) pair.
  Future<void> clearSession({
    required String trackId,
    required String moduleId,
  }) async {
    _sessions.remove(_key(trackId, moduleId));
    await _persist();
  }

  /// Clears all stored sessions.
  Future<void> clearAll() async {
    _sessions.clear();
    await _persist();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _key(String trackId, String moduleId) =>
      '${trackId}__$moduleId';

  Future<void> _persist() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_sessionsMapKey, jsonEncode(_sessions));
  }
}

final workspaceSessionStore = WorkspaceSessionStore();
