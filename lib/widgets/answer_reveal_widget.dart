import 'package:flutter/material.dart';

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

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeIn,
      child: Container(
        width: 160,
        height: 160,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0x99000033),
        ),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            answer.toUpperCase(),
            textAlign: TextAlign.center,
            style: textStyle.copyWith(fontSize: 18, height: 1.3),
          ),
        ),
      ),
    );
  }
}
