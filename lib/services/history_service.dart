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

  Future<void> toggleFavorite(Reading reading) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];

    for (var i = 0; i < existing.length; i++) {
      final item = Reading.fromJson(
        jsonDecode(existing[i]) as Map<String, dynamic>,
      );
      if (item.timestamp == reading.timestamp &&
          item.question == reading.question &&
          item.answer == reading.answer) {
        final updated = reading.copyWith(isFavorite: !reading.isFavorite);
        existing[i] = jsonEncode(updated.toJson());
        break;
      }
    }

    await prefs.setStringList(_key, existing);
  }

  Future<List<Reading>> getFavorites() async {
    final all = await getReadings();
    return all.where((r) => r.isFavorite).toList();
  }

  Future<List<Reading>> searchReadings(String query) async {
    final all = await getReadings();
    final lowerQuery = query.toLowerCase();
    return all.where((r) {
      return r.question.toLowerCase().contains(lowerQuery) ||
          r.answer.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
