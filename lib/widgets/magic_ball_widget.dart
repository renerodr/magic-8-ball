import 'dart:math' show pi;
import 'package:flutter/material.dart';

class MagicBallWidget extends StatefulWidget {
  final bool isShaking;
  final bool isThinking;

  const MagicBallWidget({
    super.key,
    this.isShaking = false,
    this.isThinking = false,
  });

  @override
  State<MagicBallWidget> createState() => _MagicBallWidgetState();
}

class _MagicBallWidgetState extends State<MagicBallWidget>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _breatheController;
  late final AnimationController _shakeController;
  late final AnimationController _wobbleController;
  late final AnimationController _gradientController;
  late final AnimationController _glowController;
  late final Animation<double> _floatAnimation;
  late final Animation<double> _breatheAnimation;
  late final Animation<double> _shakeScaleAnimation;
  late final Animation<double> _shakeRotationAnimation;
  late final Animation<double> _wobbleAnimation;
  late final Animation<double> _gradientAnimation;
  late final Animation<double> _glowAnimation;

  bool _reduceMotion = false;
  bool _isThinking = false;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _breatheController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _gradientController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
    _gradientAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.linear),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _shakeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.95), weight: 33),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.02), weight: 33),
      TweenSequenceItem(tween: Tween(begin: 1.02, end: 1.0), weight: 34),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));

    _shakeRotationAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.09), weight: 33),
      TweenSequenceItem(tween: Tween(begin: -0.09, end: 0.09), weight: 33),
      TweenSequenceItem(tween: Tween(begin: 0.09, end: 0.0), weight: 34),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));

    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
      }
    });

    _wobbleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _wobbleAnimation = Tween<double>(begin: -0.035, end: 0.035).animate(
      CurvedAnimation(parent: _wobbleController, curve: Curves.easeInOut),
    );
    _wobbleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _wobbleController.reset();
        if (_isThinking) {
          _wobbleController.forward();
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).accessibleNavigation;
    if (!_reduceMotion) {
      _floatController.repeat(reverse: true);
      _breatheController.repeat(reverse: true);
      _gradientController.repeat();
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MagicBallWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShaking && !oldWidget.isShaking) {
      _shakeController.forward();
    }
    if (widget.isThinking != oldWidget.isThinking) {
      setThinking(widget.isThinking);
    }
  }

  void setThinking(bool thinking) {
    if (_isThinking == thinking) return;
    _isThinking = thinking;
    if (_reduceMotion) return;
    if (thinking) {
      _wobbleController.forward();
    } else {
      _wobbleController.stop();
      _wobbleController.reset();
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _breatheController.dispose();
    _shakeController.dispose();
    _wobbleController.dispose();
    _gradientController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  List<Color> _getIridescentColors(double angle) {
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFFC9B1FF),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFE66D),
      const Color(0xFFFF6B6B),
    ];
    final shift = ((angle / (2 * pi)) * colors.length).floor() % colors.length;
    return [
      colors[shift % colors.length],
      colors[(shift + 1) % colors.length],
      colors[(shift + 2) % colors.length],
      colors[(shift + 3) % colors.length],
      colors[(shift + 4) % colors.length],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _floatController,
        _breatheController,
        _shakeController,
        _wobbleController,
        _gradientController,
        _glowController,
      ]),
      builder: (context, child) {
        final floatOffset = _reduceMotion ? 0.0 : _floatAnimation.value;
        final breatheScale = _reduceMotion ? 1.0 : _breatheAnimation.value;
        final shakeScale = _shakeScaleAnimation.value;
        final shakeRotation = _shakeRotationAnimation.value;
        final wobbleSkew = _isThinking ? _wobbleAnimation.value : 0.0;
        final glowOpacity = _reduceMotion ? 0.4 : _glowAnimation.value;
        final angle = _gradientAnimation.value;
        final iridescentColors = _getIridescentColors(angle);

        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Transform.scale(
            scale: breatheScale * shakeScale,
            child: Transform.rotate(
              angle: shakeRotation,
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(wobbleSkew)
                  ..rotateY(wobbleSkew),
                alignment: Alignment.center,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: iridescentColors,
                      stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                      center: const Alignment(-0.35, -0.35),
                      radius: 0.9,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: glowOpacity),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: primary.withValues(alpha: glowOpacity * 0.3),
                        blurRadius: 60,
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Specular highlight
                      Positioned(
                        top: 40,
                        left: 40,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.5),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Inner shadow for depth
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(0.4, 0.4),
                            radius: 0.8,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.15),
                            ],
                          ),
                        ),
                      ),
                      // Content: "8" when idle, sparkle when thinking
                      if (!widget.isThinking)
                        Text(
                          '8',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 12,
                                color: Colors.black.withValues(alpha: 0.3),
                              ),
                            ],
                          ),
                        )
                      else
                        const Icon(
                          Icons.auto_awesome,
                          size: 40,
                          color: Colors.white,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
