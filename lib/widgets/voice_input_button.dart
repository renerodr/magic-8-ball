import 'package:flutter/material.dart';

class VoiceInputButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onTap;

  const VoiceInputButton({
    super.key,
    required this.isListening,
    required this.onTap,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.isListening) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(VoiceInputButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isListening && oldWidget.isListening) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.isListening
        ? const Color(0xFFFF6B6B)
        : const Color(0xFF4ECDC4);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: widget.isListening ? 0.15 : 0.0),
            ),
            child: Center(
              child: widget.isListening
                  ? Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Icon(
                        Icons.mic,
                        color: iconColor,
                        size: 22,
                      ),
                    )
                  : Icon(
                      Icons.mic_none,
                      color: iconColor,
                      size: 22,
                    ),
            ),
          );
        },
      ),
    );
  }
}
