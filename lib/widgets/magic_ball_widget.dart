import 'package:flutter/material.dart';

class MagicBallWidget extends StatelessWidget {
  const MagicBallWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ballColor = isDark ? const Color(0xFF0D0D1A) : Colors.white;
    final innerColor = isDark ? primary : const Color(0xFF4A0080);

    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            ballColor,
            isDark ? Colors.black : const Color(0xFFE0D0FF),
          ],
          center: const Alignment(-0.3, -0.3),
          radius: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.5),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white30, width: 2),
            color: innerColor.withValues(alpha: 0.7),
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
    );
  }
}
