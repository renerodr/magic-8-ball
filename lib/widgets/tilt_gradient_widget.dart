import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class TiltGradientWidget extends StatefulWidget {
  final Widget child;
  final double size;

  const TiltGradientWidget({
    super.key,
    required this.child,
    required this.size,
  });

  @override
  State<TiltGradientWidget> createState() => _TiltGradientWidgetState();
}

class _TiltGradientWidgetState extends State<TiltGradientWidget> {
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  StreamSubscription<GyroscopeEvent>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = gyroscopeEventStream().listen((event) {
      if (!mounted) return;
      setState(() {
        _tiltX = (_tiltX + event.y * 0.05).clamp(-0.6, 0.6);
        _tiltY = (_tiltY + event.x * 0.05).clamp(-0.6, 0.6);
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: ClipOval(
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(_tiltX - 0.5, _tiltY - 0.5),
                  end: Alignment(_tiltX + 0.5, _tiltY + 0.5),
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
