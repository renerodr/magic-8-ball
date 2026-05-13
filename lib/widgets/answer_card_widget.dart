import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/motion_policy.dart';

class AnswerCardWidget extends StatelessWidget {
  final String answer;
  final bool isVisible;
  final bool isRevealed;
  final IconData? categoryIcon;
  final String? question;
  final bool isGolden;

  const AnswerCardWidget({
    super.key,
    required this.answer,
    required this.isVisible,
    this.isRevealed = false,
    this.categoryIcon,
    this.question,
    this.isGolden = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;
    final textStyle = Theme.of(context).textTheme.bodyLarge!;
    final trimmedAnswer = answer.trim();
    final motion = MotionPolicy.of(context);

    final cardContent = ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 320,
            minHeight: 80,
            maxHeight: 200,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          decoration: BoxDecoration(
            color: isGolden
                ? const Color(0xFFFFF8E7).withValues(alpha: 0.25)
                : surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isGolden
                  ? const Color(0xFFFFD700).withValues(alpha: 0.4)
                  : primary.withValues(alpha: 0.15),
              width: isGolden ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isGolden
                    ? const Color(0xFFFFD700).withValues(alpha: 0.15)
                    : primary.withValues(alpha: 0.1),
                blurRadius: isGolden ? 24 : 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (categoryIcon != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(
                    categoryIcon,
                    size: 14,
                    color: isGolden
                        ? const Color(0xFFFFD700).withValues(alpha: 0.6)
                        : Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                  )
                      .animate(target: isRevealed ? 1 : 0)
                      .scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.elasticOut,
                        delay: const Duration(milliseconds: 600),
                      ),
                ),
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (question != null && question!.isNotEmpty)
                      Text(
                        '"$question"',
                        textAlign: TextAlign.center,
                        style: textStyle.copyWith(
                          color: isGolden
                              ? const Color(0xFFFFF8E7).withValues(alpha: 0.8)
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          height: 1.4,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                          .animate()
                          .fadeIn(
                            duration: const Duration(milliseconds: 300),
                            delay: const Duration(milliseconds: 100),
                          ),
                    if (question != null && question!.isNotEmpty)
                      const SizedBox(height: 12),
                    Text(
                      trimmedAnswer,
                      textAlign: TextAlign.center,
                      style: textStyle.copyWith(
                        color: isGolden
                            ? const Color(0xFFFFF8E7)
                            : Theme.of(context).colorScheme.onSurface,
                        height: 1.4,
                      ),
                    )
                        .animate()
                        .then()
                        .fadeIn(
                          duration: const Duration(milliseconds: 300),
                          delay: const Duration(milliseconds: 400),
                        )
                        .scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1.0, 1.0),
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutBack,
                          delay: const Duration(milliseconds: 400),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: motion.reducedDuration(const Duration(milliseconds: 400)),
      curve: Curves.easeOut,
      child: isVisible
          ? cardContent
              .animate(target: isRevealed ? 1 : 0)
              .slideY(
                begin: 0.15,
                end: 0,
                duration: motion.reducedDuration(const Duration(milliseconds: 500)),
                curve: Curves.easeOutCubic,
                delay: motion.reducedDuration(const Duration(milliseconds: 200)),
              )
          : const SizedBox(width: 320, height: 80),
    );
  }
}
