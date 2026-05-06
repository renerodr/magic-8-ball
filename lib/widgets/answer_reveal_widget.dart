import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/motion_policy.dart';
import '../utils/triangle_clipper.dart';

class AnswerRevealWidget extends StatelessWidget {
  final String answer;
  final bool isVisible;

  const AnswerRevealWidget({
    super.key,
    required this.answer,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.displayLarge!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final policy = MotionPolicy.of(context);
    final trimmedAnswer = answer.trim();
    final answerFontSize = trimmedAnswer.length > 30 ? 16.0 : 20.0;

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: policy.revealDuration(),
      curve: Curves.easeIn,
      child: isVisible
          ? Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.4),
                    blurRadius: 35,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: ClipPath(
                clipper: const TriangleClipper(),
                child: Container(
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [const Color(0xFF151DA0), const Color(0xFF080E66)]
                          : [const Color(0xFF5A5CDB), const Color(0xFF3033B7)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 36),
                  child: Align(
                    alignment: const Alignment(0, -0.15),
                    child: Text(
                      trimmedAnswer,
                      textAlign: TextAlign.center,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle.copyWith(
                        fontSize: answerFontSize,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .then()
                        .blur(
                          duration: policy.isReduced ? 0.ms : 260.ms,
                          begin: const Offset(0, 5),
                        )
                        .fadeIn(
                          duration: policy.isReduced ? 0.ms : 220.ms,
                          delay: policy.isReduced ? 0.ms : 120.ms,
                        )
                        .scale(
                          begin: const Offset(0.95, 0.95),
                          end: const Offset(1.0, 1.0),
                          duration: policy.isReduced ? 0.ms : 320.ms,
                          curve: Curves.easeOutBack,
                          delay: policy.isReduced ? 0.ms : 150.ms,
                        ),
                  ),
                ),
              ),
            )
          : const SizedBox(width: 210, height: 210),
    );
  }
}
