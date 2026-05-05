import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeService {
  static const double _threshold = 15.0;
  static const int _debounceMsec = 500;

  final Stream<List<double>> _source;
  late final StreamController<void> _shakeController;
  StreamSubscription<List<double>>? _subscription;
  DateTime _lastShake = DateTime.fromMillisecondsSinceEpoch(0);

  ShakeService() : _source = _realAccStream() {
    _init();
  }

  ShakeService.withStream(Stream<List<double>> stream) : _source = stream {
    _init();
  }

  void _init() {
    _shakeController = StreamController<void>.broadcast();
    _subscription = _source.listen(_onAccEvent);
  }

  Stream<void> get onShake => _shakeController.stream;

  void _onAccEvent(List<double> values) {
    final x = values[0], y = values[1], z = values[2];
    final magnitude = sqrt(x * x + y * y + z * z);
    final now = DateTime.now();
    if (magnitude > _threshold &&
        now.difference(_lastShake).inMilliseconds > _debounceMsec) {
      _lastShake = now;
      _shakeController.add(null);
    }
  }

  static Stream<List<double>> _realAccStream() {
    return accelerometerEventStream().map((e) => [e.x, e.y, e.z]);
  }

  void dispose() {
    _subscription?.cancel();
    _shakeController.close();
  }
}
