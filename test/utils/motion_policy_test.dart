import 'package:flutter_test/flutter_test.dart';
import 'package:magic_8_ball/utils/motion_policy.dart';

void main() {
  group('MotionPolicy', () {
    test('full motion allows particles', () {
      const policy = MotionPolicy(MotionLevel.full);
      expect(policy.shouldShowParticles, isTrue);
    });

    test('reduced motion disables particles', () {
      const policy = MotionPolicy(MotionLevel.reduced);
      expect(policy.shouldShowParticles, isFalse);
    });

    test('full motion stagger delay is 50ms per index', () {
      const policy = MotionPolicy(MotionLevel.full);
      expect(policy.staggerDelay(0), equals(Duration.zero));
      expect(policy.staggerDelay(1), equals(const Duration(milliseconds: 50)));
      expect(policy.staggerDelay(3), equals(const Duration(milliseconds: 150)));
    });

    test('reduced motion stagger delay is always zero', () {
      const policy = MotionPolicy(MotionLevel.reduced);
      expect(policy.staggerDelay(0), equals(Duration.zero));
      expect(policy.staggerDelay(5), equals(Duration.zero));
    });

    test('full motion card entry is 400ms', () {
      const policy = MotionPolicy(MotionLevel.full);
      expect(policy.cardEntryDuration(), equals(const Duration(milliseconds: 400)));
    });

    test('reduced motion card entry is 100ms', () {
      const policy = MotionPolicy(MotionLevel.reduced);
      expect(policy.cardEntryDuration(), equals(const Duration(milliseconds: 100)));
    });

    test('reducedDuration shortens long durations', () {
      const policy = MotionPolicy(MotionLevel.reduced);
      expect(policy.reducedDuration(const Duration(milliseconds: 500)), equals(const Duration(milliseconds: 100)));
    });

    test('reducedDuration zeros short durations', () {
      const policy = MotionPolicy(MotionLevel.reduced);
      expect(policy.reducedDuration(const Duration(milliseconds: 150)), equals(Duration.zero));
    });

    test('full motion reducedDuration returns original', () {
      const policy = MotionPolicy(MotionLevel.full);
      const d = Duration(milliseconds: 500);
      expect(policy.reducedDuration(d), equals(d));
    });

    test('isReduced is true for reduced level', () {
      const policy = MotionPolicy(MotionLevel.reduced);
      expect(policy.isReduced, isTrue);
    });

    test('isReduced is false for full level', () {
      const policy = MotionPolicy(MotionLevel.full);
      expect(policy.isReduced, isFalse);
    });
  });
}
