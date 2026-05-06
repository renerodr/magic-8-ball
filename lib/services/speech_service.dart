import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech;
  bool _isAvailable = false;

  SpeechService({SpeechToText? speech}) : _speech = speech ?? SpeechToText();

  Future<bool> initialize() async {
    _isAvailable = await _speech.initialize(
      onError: (error) => debugPrint('Speech error: $error'),
      onStatus: (status) => debugPrint('Speech status: $status'),
    );
    return _isAvailable;
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
      partialResults: true,
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
  bool get isAvailable => _isAvailable;
}
