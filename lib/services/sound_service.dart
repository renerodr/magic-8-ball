import 'sound_manager.dart';

@Deprecated('Use SoundManager instead. SoundService will be removed in a future version.')
class SoundService {
  SoundManager? _manager;

  bool get isMuted => _manager?.isMuted ?? false;

  Future<void> initialize() async {
    _manager = SoundManager();
    await _manager!.initialize();
  }

  @Deprecated('Use SoundManager.setMuted instead')
  Future<void> setMuted(bool muted) async {
    await _manager?.setMuted(muted);
  }

  @Deprecated('Use SoundManager.play(SoundEvent.shakeSlosh) instead')
  Future<void> playSlosh() async {
    await _manager?.play(SoundEvent.shakeSlosh);
  }

  @Deprecated('Use SoundManager.play(SoundEvent.revealChime) instead')
  Future<void> playRevealChime() async {
    await _manager?.play(SoundEvent.revealChime);
  }

  @Deprecated('Use SoundManager.play(SoundEvent.buttonTap) instead')
  Future<void> playButtonClick() async {
    await _manager?.play(SoundEvent.buttonTap);
  }

  @Deprecated('Use SoundManager.startLoop instead')
  Future<void> playAmbient() async {
    await _manager?.startLoop(AmbientLoop.idlePad);
  }

  @Deprecated('Use SoundManager.stopLoop instead')
  Future<void> stopAmbient() async {
    await _manager?.stopLoop(AmbientLoop.idlePad);
  }

  void dispose() {
    _manager?.dispose();
  }
}
