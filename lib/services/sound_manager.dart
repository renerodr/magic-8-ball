import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SoundEvent {
  buttonTap,
  shakeSlosh,
  revealChime,
  streakFanfare,
  errorBuzzer,
  favoriteStar,
  shareWhoosh,
}

enum AmbientLoop {
  idlePad,
  thinkingPulse,
  revealedTail,
}

class SoundManager {
  final AudioPlayer _oneShotPlayer = AudioPlayer();
  final AudioPlayer _loopPlayer = AudioPlayer();
  bool _isMuted = false;
  bool _isHapticsEnabled = true;
  AmbientLoop? _currentLoop;

  static const Map<SoundEvent, String> _assetMap = {
    SoundEvent.buttonTap: 'sounds/button_click.mp3',
    SoundEvent.shakeSlosh: 'sounds/water_slosh.mp3',
    SoundEvent.revealChime: 'sounds/reveal_chime.mp3',
    SoundEvent.streakFanfare: 'sounds/reveal_chime.mp3',
    SoundEvent.errorBuzzer: 'sounds/button_click.mp3',
    SoundEvent.favoriteStar: 'sounds/button_click.mp3',
    SoundEvent.shareWhoosh: 'sounds/water_slosh.mp3',
  };

  static const Map<AmbientLoop, String> _loopAssetMap = {
    AmbientLoop.idlePad: 'sounds/water_slosh.mp3',
    AmbientLoop.thinkingPulse: 'sounds/reveal_chime.mp3',
    AmbientLoop.revealedTail: 'sounds/reveal_chime.mp3',
  };

  static const Map<SoundEvent, double> _volumeMap = {
    SoundEvent.buttonTap: 0.6,
    SoundEvent.shakeSlosh: 0.8,
    SoundEvent.revealChime: 0.7,
    SoundEvent.streakFanfare: 0.8,
    SoundEvent.errorBuzzer: 0.5,
    SoundEvent.favoriteStar: 0.6,
    SoundEvent.shareWhoosh: 0.6,
  };

  static const Map<AmbientLoop, double> _loopVolumeMap = {
    AmbientLoop.idlePad: 0.15,
    AmbientLoop.thinkingPulse: 0.15,
    AmbientLoop.revealedTail: 0.1,
  };

  bool get isMuted => _isMuted;
  bool get isHapticsEnabled => _isHapticsEnabled;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isMuted = prefs.getBool('sound_muted') ?? false;
    _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
  }

  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_muted', muted);
    if (muted) {
      await stopAll();
    }
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    _isHapticsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptics_enabled', enabled);
  }

  Future<void> play(SoundEvent event) async {
    if (_isMuted) return;
    try {
      final asset = _assetMap[event];
      if (asset == null) return;
      final volume = _volumeMap[event] ?? 0.5;
      await _oneShotPlayer.play(AssetSource(asset), volume: volume);
    } catch (_) {
      // Audio failures never block
    }
  }

  Future<void> startLoop(AmbientLoop loop, {double? tiltAdjustment}) async {
    if (_isMuted) return;
    if (_currentLoop == loop) return;

    await stopLoop(_currentLoop);

    try {
      final asset = _loopAssetMap[loop];
      if (asset == null) return;

      await _loopPlayer.setReleaseMode(ReleaseMode.loop);
      final baseVolume = _loopVolumeMap[loop] ?? 0.15;
      final volume = tiltAdjustment != null ? baseVolume * (0.8 + tiltAdjustment.abs()) : baseVolume;
      
      await _loopPlayer.play(AssetSource(asset), volume: volume);
      _currentLoop = loop;
    } catch (_) {
      // Audio failures never block
    }
  }

  Future<void> stopLoop(AmbientLoop? loop) async {
    if (loop != null && loop == _currentLoop) {
      try {
        await _loopPlayer.stop();
        _currentLoop = null;
      } catch (_) {}
    }
  }

  Future<void> stopAll() async {
    try {
      await _oneShotPlayer.stop();
    } catch (_) {}
    try {
      await _loopPlayer.stop();
      _currentLoop = null;
    } catch (_) {}
  }

  void updateTilt(double tiltX) {
    if (_isMuted || _currentLoop == null) return;
    try {
      final baseVolume = _loopVolumeMap[_currentLoop] ?? 0.15;
      final adjustedVolume = (baseVolume * (0.8 + tiltX.abs())).clamp(0.0, 1.0);
      _loopPlayer.setVolume(adjustedVolume);
    } catch (_) {}
  }

  void dispose() {
    _oneShotPlayer.dispose();
    _loopPlayer.dispose();
  }
}
