import 'package:flutter/material.dart';

class ShakeNowCta extends StatelessWidget {
  final VoidCallback onTap;

  const ShakeNowCta({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: surface.withValues(alpha: 0.6),
          backgroundBlendMode: BlendMode.luminosity,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B6B).withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.vibration_rounded,
              color: Color(0xFFFF6B6B),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Shake Now',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
