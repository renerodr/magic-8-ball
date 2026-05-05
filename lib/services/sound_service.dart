import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playSlosh() async {
    await _player.play(AssetSource('sounds/water_slosh.mp3'));
  }

  void dispose() => _player.dispose();
}
