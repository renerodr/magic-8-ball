import 'package:shared_preferences/shared_preferences.dart';

class DailyFortuneService {
  static const _lastAskedKey = 'daily_fortune_last_asked';
  static const _streakKey = 'daily_fortune_streak';
  static const _totalAskedKey = 'daily_fortune_total';

  DateTime? _lastAsked;
  int _streak = 0;
  int _totalAsked = 0;

  int get streak => _streak;
  int get totalAsked => _totalAsked;
  bool get isDailyFortuneAvailable => _canAskToday();

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAskedStr = prefs.getString(_lastAskedKey);
    _lastAsked = lastAskedStr != null ? DateTime.parse(lastAskedStr) : null;
    _streak = prefs.getInt(_streakKey) ?? 0;
    _totalAsked = prefs.getInt(_totalAskedKey) ?? 0;
  }

  bool _canAskToday() {
    if (_lastAsked == null) return true;
    final now = DateTime.now();
    final last = _lastAsked!;
    return now.year != last.year || now.month != last.month || now.day != last.day;
  }

  Future<void> recordAsked() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastAsked != null) {
      final lastDate = DateTime(
        _lastAsked!.year,
        _lastAsked!.month,
        _lastAsked!.day,
      );
      final difference = today.difference(lastDate).inDays;

      if (difference == 1) {
        _streak++;
      } else if (difference > 1) {
        _streak = 1;
      }
      // If difference == 0, same day - don't increment
    } else {
      _streak = 1;
    }

    _totalAsked++;
    _lastAsked = now;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastAskedKey, now.toIso8601String());
    await prefs.setInt(_streakKey, _streak);
    await prefs.setInt(_totalAskedKey, _totalAsked);
  }

  bool get isStreakReward => _streak > 0 && _streak % 7 == 0;

  String get dailyPrompt =>
      'What does today hold for me? Give a single mystical fortune (max 12 words).';

  Future<void> reset() async {
    _streak = 0;
    _totalAsked = 0;
    _lastAsked = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastAskedKey);
    await prefs.remove(_streakKey);
    await prefs.remove(_totalAskedKey);
  }
}
