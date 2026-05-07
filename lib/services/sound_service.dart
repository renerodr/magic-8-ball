import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _ambientPlayer = AudioPlayer();
  bool _isMuted = false;

  bool get isMuted => _isMuted;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isMuted = prefs.getBool('sound_muted') ?? false;
  }

  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_muted', muted);
    if (muted) {
      await _ambientPlayer.stop();
    }
  }

  Future<void> _play(String assetPath) async {
    if (_isMuted) return;
    try {
      await _player.play(AssetSource(assetPath));
    } catch (_) {
      // Sound is non-critical; swallow errors.
    }
  }

  Future<void> playSlosh() => _play('sounds/water_slosh.mp3');

  Future<void> playRevealChime() => _play('sounds/reveal_chime.mp3');

  Future<void> playButtonClick() => _play('sounds/button_click.mp3');

  Future<void> playAmbient() async {
    if (_isMuted) return;
    try {
      await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
      await _ambientPlayer.play(AssetSource('sounds/water_slosh.mp3'), volume: 0.15);
    } catch (_) {
      // Ambient is optional; swallow errors.
    }
  }

  Future<void> stopAmbient() async {
    try {
      await _ambientPlayer.stop();
    } catch (_) {}
  }

  void dispose() {
    _player.dispose();
    _ambientPlayer.dispose();
  }
}
