import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_8_ball/services/shake_service.dart';

void main() {
  group('ShakeService', () {
    test('emits shake when magnitude exceeds threshold', () async {
      final controller = StreamController<List<double>>();
      final service = ShakeService.withStream(controller.stream);

      final shakes = <bool>[];
      final sub = service.onShake.listen((_) => shakes.add(true));

      controller.add([20.0, 20.0, 20.0]);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(shakes.length, equals(1));
      await sub.cancel();
      await controller.close();
    });

    test('does not emit when magnitude is below threshold', () async {
      final controller = StreamController<List<double>>();
      final service = ShakeService.withStream(controller.stream);

      final shakes = <bool>[];
      final sub = service.onShake.listen((_) => shakes.add(true));

      controller.add([1.0, 1.0, 9.8]);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(shakes, isEmpty);
      await sub.cancel();
      await controller.close();
    });

    test('debounces rapid shakes — only emits once within 500ms', () async {
      final controller = StreamController<List<double>>();
      final service = ShakeService.withStream(controller.stream);

      final shakes = <bool>[];
      final sub = service.onShake.listen((_) => shakes.add(true));

      controller.add([20.0, 20.0, 20.0]);
      controller.add([20.0, 20.0, 20.0]);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(shakes.length, equals(1));
      await sub.cancel();
      await controller.close();
    });
  });
}
