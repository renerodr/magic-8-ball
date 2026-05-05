import 'package:flutter/material.dart';
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
import '../widgets/tilt_gradient_widget.dart';
import 'history_screen.dart';

const _apiKey = String.fromEnvironment('OPENROUTER_KEY', defaultValue: 'YOUR_KEY_HERE');

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
  late final AiService _aiService;

  _BallState _state = _BallState.idle;
  String _currentAnswer = '';

  @override
  void initState() {
    super.initState();
    _aiService = AiService(client: http.Client(), apiKey: _apiKey);
    _shakeService.onShake.listen((_) => _onShake());
  }

  Future<void> _onShake() async {
    if (_state == _BallState.thinking) return;
    setState(() => _state = _BallState.thinking);
    await Future.wait([
      _hapticService.onShake(),
      _soundService.playSlosh(),
    ]);

    final answer = await _aiService.getAnswer(
      question: _questionController.text.trim(),
    );

    await _historyService.addReading(Reading(
      question: _questionController.text.trim(),
      answer: answer,
      timestamp: DateTime.now(),
    ));

    setState(() {
      _currentAnswer = answer;
      _state = _BallState.revealed;
    });
    await _hapticService.onReveal();
  }

  void _reset() => setState(() => _state = _BallState.idle);

  @override
  void dispose() {
    _shakeService.dispose();
    _soundService.dispose();
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isThinking = _state == _BallState.thinking;
    final isRevealed = _state == _BallState.revealed;

    return GestureDetector(
      onTap: isRevealed ? _reset : null,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.history),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.brightness_6_outlined),
                      onPressed: widget.onToggleTheme,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: _questionController,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
                    letterSpacing: 1,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask a question...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _onShake(),
                child: TiltGradientWidget(
                  size: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      isThinking
                          ? const MagicBallWidget()
                              .animate(onPlay: (c) => c.repeat())
                              .shimmer(duration: 1000.ms, color: Colors.white24)
                          : const MagicBallWidget(),
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
                padding: const EdgeInsets.only(bottom: 32),
                child: Text(
                  isThinking
                      ? 'Consulting the oracle...'
                      : isRevealed
                          ? 'Tap to ask again'
                          : 'Shake to reveal your fate',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
                    letterSpacing: 1.5,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
