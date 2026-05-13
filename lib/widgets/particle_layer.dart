import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/scene_colors.dart';
import '../utils/motion_policy.dart';

class ParticleLayer extends StatefulWidget {
  final AppVisualState state;

  const ParticleLayer({
    super.key,
    required this.state,
  });

  @override
  State<ParticleLayer> createState() => _ParticleLayerState();
}

class _ParticleLayerState extends State<ParticleLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();
  Size? _lastSize;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.addListener(_onTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final motion = MotionPolicy.of(context);
    if (!motion.shouldShowParticles) {
      _controller.stop();
      return;
    }
    if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ParticleLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      _onStateChange(widget.state);
    }
  }

  void _onStateChange(AppVisualState state) {
    if (state == AppVisualState.thinking) {
      _addBurst(count: 6);
    } else if (state == AppVisualState.revealed) {
      _addBurst(count: 8, outward: true);
    } else if (state == AppVisualState.streak) {
      _convertToGold();
    }
  }

  void _addBurst({required int count, bool outward = false}) {
    final size = _lastSize ?? const Size(300, 300);
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 20 + _random.nextDouble() * 40;
      _particles.add(Particle.burst(
        x: centerX,
        y: centerY,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        outward: outward,
      ));
    }
    _trimParticles();
  }

  void _convertToGold() {
    for (final p in _particles) {
      p.color = const Color(0xFFFFD700);
    }
  }

  void _trimParticles() {
    if (_particles.length > 20) {
      _particles.removeRange(0, _particles.length - 20);
    }
  }

  void _onTick() {
    if (!mounted) return;
    final dt = 1 / 30;

    for (final p in _particles) {
      p.update(dt, widget.state, _random);
    }

    _particles.removeWhere((p) => p.isDead);

    final targetCount = _targetCountForState(widget.state);
    if (_particles.length < targetCount) {
      _spawnParticle();
    }

    setState(() {});
  }

  int _targetCountForState(AppVisualState state) {
    switch (state) {
      case AppVisualState.idle:
        return 12;
      case AppVisualState.listening:
        return 10;
      case AppVisualState.thinking:
        return 18;
      case AppVisualState.revealed:
        return 14;
      case AppVisualState.streak:
        return 16;
    }
  }

  void _spawnParticle() {
    final size = _lastSize ?? const Size(300, 300);
    _particles.add(Particle.random(
      bounds: Rect.fromLTWH(0, 0, size.width, size.height),
      random: _random,
      state: widget.state,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = MotionPolicy.of(context);
    if (!motion.shouldShowParticles) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _lastSize = size;
        return CustomPaint(
          size: size,
          painter: _ParticlePainter(_particles),
        );
      },
    );
  }
}

enum ParticleType { sparkle, bubble, starFleck }

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  double maxLife;
  double size;
  ParticleType type;
  Color color;
  double opacity;
  double phase;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.maxLife,
    required this.size,
    required this.type,
    required this.color,
    this.phase = 0,
  }) : life = maxLife, opacity = 1.0;

  factory Particle.random({
    required Rect bounds,
    required Random random,
    required AppVisualState state,
  }) {
    final type = ParticleType.values[random.nextInt(ParticleType.values.length)];
    final isStreak = state == AppVisualState.streak;
    return Particle(
      x: bounds.left + random.nextDouble() * bounds.width,
      y: bounds.bottom + 10 + random.nextDouble() * 20,
      vx: (random.nextDouble() - 0.5) * 10,
      vy: -10 - random.nextDouble() * 20,
      maxLife: 4 + random.nextDouble() * 4,
      size: 1 + random.nextDouble() * 2.5,
      type: type,
      color: isStreak ? const Color(0xFFFFD700) : Colors.white,
      phase: random.nextDouble() * 2 * pi,
    );
  }

  factory Particle.burst({
    required double x,
    required double y,
    required double vx,
    required double vy,
    bool outward = false,
  }) {
    return Particle(
      x: x,
      y: y,
      vx: vx,
      vy: vy,
      maxLife: outward ? 1.2 : 2.0,
      size: 2 + Random().nextDouble() * 2,
      type: ParticleType.sparkle,
      color: Colors.white,
      phase: Random().nextDouble() * 2 * pi,
    );
  }

  bool get isDead => life <= 0;

  void update(double dt, AppVisualState state, Random random) {
    life -= dt;
    if (life <= 0) return;

    final speedMult = state == AppVisualState.thinking ? 1.5 : 1.0;
    x += vx * dt * speedMult;
    y += vy * dt * speedMult;

    phase += dt * 2;

    if (type == ParticleType.bubble) {
      x += sin(phase) * 0.5;
    }

    final lifeRatio = life / maxLife;
    opacity = lifeRatio.clamp(0.0, 1.0);

    if (type == ParticleType.sparkle && state == AppVisualState.listening) {
      opacity = (0.5 + 0.5 * sin(phase * 3)).clamp(0.0, 1.0) * lifeRatio;
    }
  }
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity * 0.25)
        ..style = PaintingStyle.fill;

      if (p.type == ParticleType.sparkle) {
        canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
      } else if (p.type == ParticleType.bubble) {
        canvas.drawCircle(Offset(p.x, p.y), p.size * 1.5, paint);
      } else {
        canvas.drawCircle(Offset(p.x, p.y), p.size * 0.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
