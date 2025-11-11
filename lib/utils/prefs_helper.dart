import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class PrefsHelper {
  static const String _key = 'tasks_data';

  static Future<void> saveTasks(Map<DateTime, List<Task>> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final data = tasks.map((key, value) => MapEntry(
        key.toIso8601String(), value.map((t) => t.toJson()).toList()));
    await prefs.setString(_key, jsonEncode(data));
  }

  static Future<Map<DateTime, List<Task>>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return {};
    final Map<String, dynamic> data = jsonDecode(jsonString);
    return data.map((key, value) {
      final date = DateTime.parse(key);
      final tasks = (value as List).map((t) => Task.fromJson(t)).toList();
      return MapEntry(date, tasks);
    });
  }
}
