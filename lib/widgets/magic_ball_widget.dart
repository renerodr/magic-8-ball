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
  late final Animation<double> _floatAnimation;
  late final Animation<double> _breatheAnimation;
  late final Animation<double> _shakeScaleAnimation;
  late final Animation<double> _shakeRotationAnimation;
  late final Animation<double> _wobbleAnimation;

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

    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Color> darkGradientColors = [
      const Color(0xFF0A0A0F),
      const Color(0xFF1A1A2E),
      const Color(0xFF0D0D1A),
      const Color(0xFF1E1E3A),
      const Color(0xFF3D3D5C),
    ];

    final List<Color> lightGradientColors = [
      const Color(0xFFE0D0FF),
      const Color(0xFFF0E8FF),
      Colors.white,
      Colors.white,
      Colors.white.withValues(alpha: 0.8),
    ];

    final List<double> gradientStops = [0.0, 0.4, 0.7, 0.9, 1.0];

    return AnimatedBuilder(
      animation: Listenable.merge([
        _floatController,
        _breatheController,
        _shakeController,
        _wobbleController,
      ]),
      builder: (context, child) {
        final floatOffset = _reduceMotion ? 0.0 : _floatAnimation.value;
        final breatheScale = _reduceMotion ? 1.0 : _breatheAnimation.value;
        final shakeScale = _shakeScaleAnimation.value;
        final shakeRotation = _shakeRotationAnimation.value;
        final wobbleSkew = _isThinking ? _wobbleAnimation.value : 0.0;

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
                      colors:
                          isDark ? darkGradientColors : lightGradientColors,
                      stops: gradientStops,
                      center: const Alignment(-0.3, -0.3),
                      radius: 0.9,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.5),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: primary.withValues(alpha: 0.15),
                        blurRadius: 60,
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? primary.withValues(alpha: 0.3)
                                : const Color(0xFF4A0080)
                                    .withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipPath(
                        clipper: _TriangleClipper(),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isDark
                                  ? [
                                      const Color(0xFF000066),
                                      const Color(0xFF000033)
                                    ]
                                  : [
                                      const Color(0xFFE6E6FF),
                                      const Color(0xFFCCCCFF)
                                    ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                    alpha: isDark ? 0.4 : 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '8',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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

class _TriangleClipper extends CustomClipper<Path> {
  const _TriangleClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
