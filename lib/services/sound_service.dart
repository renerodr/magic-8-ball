import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playSlosh() async {
    try {
      await _player.play(AssetSource('sounds/water_slosh.mp3'));
    } catch (_) {
      // Sound is non-critical; swallow errors so the shake flow continues.
    }
  }

  void dispose() => _player.dispose();
}
