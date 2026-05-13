import 'package:shared_preferences/shared_preferences.dart';
import '../models/oracle_persona.dart';

class OracleContextService {
  OraclePersona _currentPersona = OraclePersona.spark;
  final List<String> _recentQuestions = [];
  final List<String> _recentAnswers = [];
  final Set<String> _favoriteThemes = {};

  OraclePersona get currentPersona => _currentPersona;
  List<String> get recentQuestions => List.unmodifiable(_recentQuestions);
  List<String> get recentAnswers => List.unmodifiable(_recentAnswers);
  Set<String> get favoriteThemes => Set.unmodifiable(_favoriteThemes);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final personaIndex = prefs.getInt('oracle_persona') ?? 0;
    _currentPersona = OraclePersona.values[
      personaIndex.clamp(0, OraclePersona.values.length - 1)
    ];
  }

  Future<void> setPersona(OraclePersona persona) async {
    _currentPersona = persona;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('oracle_persona', persona.index);
  }

  void recordExchange(String question, String answer) {
    _recentQuestions.add(question);
    _recentAnswers.add(answer);
    if (_recentQuestions.length > 10) {
      _recentQuestions.removeAt(0);
      _recentAnswers.removeAt(0);
    }
  }

  void addFavoriteTheme(String theme) {
    _favoriteThemes.add(theme);
    if (_favoriteThemes.length > 5) {
      _favoriteThemes.remove(_favoriteThemes.first);
    }
  }

  String buildContextForPrompt({int? streak}) {
    final buffer = StringBuffer();

    if (_recentQuestions.isNotEmpty) {
      buffer.write('Recent: ');
      for (var i = 0; i < _recentQuestions.length; i++) {
        buffer.write('Q: "${_recentQuestions[i]}" → A: "${_recentAnswers[i]}". ');
      }
    }

    if (_favoriteThemes.isNotEmpty) {
      buffer.write('Interests: ${_favoriteThemes.join(", ")}. ');
    }

    if (streak != null && streak >= 7) {
      buffer.write('$streak-day streak. ');
    }

    return buffer.toString().trim();
  }

  bool isRecentAnswer(String answer) {
    final lower = answer.toLowerCase();
    return _recentAnswers.any((a) => a.toLowerCase() == lower);
  }

  void clear() {
    _recentQuestions.clear();
    _recentAnswers.clear();
    _favoriteThemes.clear();
  }
}
