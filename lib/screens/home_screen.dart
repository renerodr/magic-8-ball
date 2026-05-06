import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '../models/reading.dart';
import '../services/ai_service.dart';
import '../services/haptic_service.dart';
import '../services/history_service.dart';
import '../services/shake_service.dart';
import '../services/sound_service.dart';
import '../widgets/answer_reveal_widget.dart';
import '../widgets/magic_ball_widget.dart';
import '../widgets/pulsing_background.dart';
import '../widgets/tilt_gradient_widget.dart';
import 'history_screen.dart';

const _apiKey = String.fromEnvironment('OPENROUTER_KEY', defaultValue: '');

enum _BallState { idle, thinking, revealed }

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomeScreen({super.key, required this.onToggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _questionController = TextEditingController();
  final _shakeService = ShakeService();
  final _hapticService = HapticService();
  final _soundService = SoundService();
  final _historyService = HistoryService();
  final _questionFocusNode = FocusNode();
  late final AiService _aiService;

  StreamSubscription<void>? _shakeSubscription;
  _BallState _state = _BallState.idle;
  String _currentAnswer = '';
  DateTime? _currentTimestamp;
  bool _isShaking = false;

  @override
  void initState() {
    super.initState();
    _aiService = AiService(client: http.Client(), apiKey: _apiKey);
    _shakeSubscription = _shakeService.onShake.listen((_) => _onShake());
  }

  Future<void> _onShake() async {
    if (_state == _BallState.thinking) return;
    setState(() {
      _state = _BallState.thinking;
      _isShaking = true;
    });

    await Future.wait([
      _hapticService.onShake(),
      _soundService.playSlosh(),
    ]);

    final answer = await _aiService.getAnswer(
      question: _questionController.text.trim(),
    );

    final timestamp = DateTime.now();
    await _historyService.addReading(Reading(
      question: _questionController.text.trim(),
      answer: answer,
      timestamp: timestamp,
    ));

    setState(() {
      _currentAnswer = answer;
      _currentTimestamp = timestamp;
      _state = _BallState.revealed;
      _isShaking = false;
    });
    await _hapticService.onReveal();
  }

  void _reset() => setState(() {
        _state = _BallState.idle;
        _currentTimestamp = null;
      });

  @override
  void dispose() {
    _shakeSubscription?.cancel();
    _shakeService.dispose();
    _soundService.dispose();
    _questionController.dispose();
    _questionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isThinking = _state == _BallState.thinking;
    final isRevealed = _state == _BallState.revealed;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: isRevealed ? _reset : null,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Magic 8 Ball'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: _AnimatedIconButton(
              icon: const Icon(Icons.history_rounded),
              tooltip: 'History',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              ),
            ),
            actions: [
              _AnimatedIconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                ),
                tooltip: 'Toggle theme',
                onPressed: widget.onToggleTheme,
              ),
            ],
          ),
          body: PulsingBackground(
            glowColor: primary,
            isDark: isDark,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: _QuestionInput(
                      controller: _questionController,
                      focusNode: _questionFocusNode,
                      onSubmitted: _onShake,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _onShake,
                    child: TiltGradientWidget(
                      size: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          isThinking
                              ? MagicBallWidget(isShaking: true, isThinking: true)
                                  .animate(onPlay: (c) => c.repeat())
                                  .shimmer(duration: 1000.ms, color: Colors.white24)
                              : MagicBallWidget(isShaking: _isShaking),
                          if (isRevealed && _currentTimestamp != null)
                            Hero(
                              tag: 'answer-${_currentTimestamp!.millisecondsSinceEpoch}',
                              child: AnswerRevealWidget(
                                answer: _currentAnswer,
                                isVisible: true,
                              ),
                            )
                          else
                            AnswerRevealWidget(
                              answer: _currentAnswer,
                              isVisible: isRevealed,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ShakeNowChip(onTap: _onShake),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Text(
                      isThinking
                          ? 'Consulting the oracle...'
                          : isRevealed
                          ? 'Tap the ball to ask again'
                          : 'Shake your phone or tap the ball',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                        letterSpacing: 0.8,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const _BottomFadeGradient(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomFadeGradient extends StatelessWidget {
  const _BottomFadeGradient();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 20,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            isDark
                ? const Color(0xFF0A0A0F).withValues(alpha: 0.5)
                : const Color(0xFFF5F0FF).withValues(alpha: 0.5),
          ],
        ),
      ),
    );
  }
}

class _QuestionInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmitted;

  const _QuestionInput({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  @override
  State<_QuestionInput> createState() => _QuestionInputState();
}

class _QuestionInputState extends State<_QuestionInput>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.7, end: 0.9).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = widget.focusNode.hasFocus);
    if (_isFocused) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.diagonal3Values(
            _isFocused ? 1.02 : 1.02,
            _isFocused ? 1.02 : 1.02,
            1.0,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surface
                  .withValues(alpha: isDark ? 0.35 : 0.8),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: primary.withValues(alpha: _isFocused ? 0.5 : 0.2),
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.95),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Ask anything...',
                hintStyle: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: _pulseAnimation.value * 0.5),
                  fontStyle: FontStyle.italic,
                ),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => widget.onSubmitted(),
            ),
          ),
        );
      },
    );
  }
}

class _ShakeNowChip extends StatelessWidget {
  final VoidCallback onTap;

  const _ShakeNowChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [primary.withValues(alpha: 0.8), secondary.withValues(alpha: 0.6)]
                : [primary, secondary],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.vibration_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Shake Now',
              style: TextStyle(
                color: Colors.white,
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

class _AnimatedIconButton extends StatefulWidget {
  final Icon icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _AnimatedIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _isPressed ? 0.7 : 1.0,
              child: IconButton(
                tooltip: widget.tooltip,
                icon: widget.icon,
                onPressed: null,
              ),
            ),
          );
        },
      ),
    );
  }
}
