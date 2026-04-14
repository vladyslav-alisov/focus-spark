import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_item.dart';

class LocalStorageRepository {
  LocalStorageRepository(this._preferences);

  static const _tasksKey = 'tasks';
  static const _completedTaskCountKey = 'completed_task_count';
  static const _focusSessionCountKey = 'focus_session_count';
  static const _bestGameScoreKey = 'best_game_score';

  final SharedPreferences _preferences;

  static Future<LocalStorageRepository> create() async {
    final preferences = await SharedPreferences.getInstance();
    return LocalStorageRepository(preferences);
  }

  Future<List<TaskItem>> loadTasks() async {
    final payload = _preferences.getStringList(_tasksKey) ?? <String>[];
    return payload
        .map(
          (task) => TaskItem.fromJson(jsonDecode(task) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> saveTasks(List<TaskItem> tasks) {
    final payload = tasks.map((task) => jsonEncode(task.toJson())).toList();
    return _preferences.setStringList(_tasksKey, payload);
  }

  int loadCompletedTaskCount() =>
      _preferences.getInt(_completedTaskCountKey) ?? 0;

  Future<void> saveCompletedTaskCount(int value) {
    return _preferences.setInt(_completedTaskCountKey, value);
  }

  int loadFocusSessionCount() =>
      _preferences.getInt(_focusSessionCountKey) ?? 0;

  Future<void> saveFocusSessionCount(int value) {
    return _preferences.setInt(_focusSessionCountKey, value);
  }

  int loadBestGameScore() => _preferences.getInt(_bestGameScoreKey) ?? 0;

  Future<void> saveBestGameScore(int value) {
    return _preferences.setInt(_bestGameScoreKey, value);
  }
}
