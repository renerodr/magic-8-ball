import 'package:flutter_test/flutter_test.dart';
import 'package:magic_8_ball/services/speech_service.dart';

void main() {
  test('SpeechService can be instantiated', () {
    final service = SpeechService();
    expect(service.isAvailable, isFalse);
    expect(service.isListening, isFalse);
  });
}
