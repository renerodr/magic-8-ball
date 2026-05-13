import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpeechService {
  final SpeechToText _speech;
  bool _isAvailable = false;
  bool _isEnabled = true;

  SpeechService({SpeechToText? speech}) : _speech = speech ?? SpeechToText();

  bool get isEnabled => _isEnabled;
  bool get isAvailable => _isAvailable;

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool('voice_input_enabled') ?? true;
  }

  Future<bool> initialize() async {
    _isAvailable = await _speech.initialize(
      onError: (error) => debugPrint('Speech error: $error'),
      onStatus: (status) => debugPrint('Speech status: $status'),
    );
    return _isAvailable;
  }

  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voice_input_enabled', enabled);
  }

  Future<String?> listen() async {
    if (!_isAvailable) return null;

    String? result;
    await _speech.listen(
      onResult: (val) {
        result = val.recognizedWords;
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 1, milliseconds: 500),
    );

    while (_speech.isListening) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return result?.trim().isEmpty == true ? null : result;
  }

  Future<void> stop() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  bool get isListening => _speech.isListening;
}
