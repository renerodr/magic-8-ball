import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reading.dart';

class HistoryService {
  static const _key = 'readings';

  Future<void> addReading(Reading reading) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];
    existing.add(jsonEncode(reading.toJson()));
    await prefs.setStringList(_key, existing);
  }

  Future<List<Reading>> getReadings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final readings = raw
        .map((s) => Reading.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
    readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return readings;
  }

  Future<void> deleteReading(Reading reading) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];
    final json = jsonEncode(reading.toJson());
    existing.removeWhere((item) => item == json);
    await prefs.setStringList(_key, existing);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
