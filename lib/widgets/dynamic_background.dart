import 'package:flutter/material.dart';
import '../constants/scene_colors.dart';
import '../models/question_category.dart';
import '../utils/motion_policy.dart';

class DynamicBackground extends StatelessWidget {
  final AppVisualState state;
  final QuestionCategory? category;
  final Widget child;

  const DynamicBackground({
    super.key,
    required this.state,
    this.category,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final backgroundColor = SceneColors.backgroundFor(state, brightness);
    final motion = MotionPolicy.of(context);
    final tintColor = category != null && state == AppVisualState.revealed
        ? SceneColors.tintFor(category!, brightness)
        : null;

    return AnimatedContainer(
      duration: motion.reducedDuration(const Duration(milliseconds: 400)),
      curve: Curves.easeInOut,
      color: backgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (tintColor != null)
            AnimatedOpacity(
              duration: motion.reducedDuration(const Duration(milliseconds: 300)),
              opacity: 0.08,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [tintColor, Colors.transparent],
                    radius: 0.8,
                    center: Alignment.center,
                  ),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}
