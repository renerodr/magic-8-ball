import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reading.dart';
import '../models/question_category.dart';
import '../services/ai_service.dart';
import '../services/haptic_service.dart';
import '../services/haptic_patterns.dart';
import '../services/history_service.dart';
import '../services/shake_service.dart';
import '../services/sound_manager.dart';
import '../widgets/answer_card_widget.dart';
import '../widgets/magic_ball_widget.dart';
import '../constants/scene_colors.dart';
import '../widgets/dynamic_background.dart';
import '../widgets/particle_layer.dart';
import '../widgets/shake_now_cta.dart';
import '../widgets/tilt_gradient_widget.dart';
import '../widgets/voice_input_button.dart';
import '../services/speech_service.dart';
import '../services/daily_fortune_service.dart';
import '../services/notification_service.dart';
import '../services/share_service.dart';
import '../services/home_widget_service.dart';
import '../widgets/streak_indicator.dart';
import '../widgets/settings_sheet.dart';
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
  late final SoundManager _soundManager;
  final _historyService = HistoryService();
  final _questionFocusNode = FocusNode();
  final _speechService = SpeechService();
  final _dailyFortuneService = DailyFortuneService();
  final _notificationService = NotificationService();
  final _shareService = ShareService();
  final _homeWidgetService = HomeWidgetService();
  final _answerCardKey = GlobalKey();
  late final AiService _aiService;

  StreamSubscription<void>? _shakeSubscription;
  _BallState _state = _BallState.idle;
  String _currentAnswer = '';
  bool _isShaking = false;
  bool _isListening = false;
  bool _isStreakReward = false;
  QuestionCategory _selectedCategory = QuestionCategory.general;

  AppVisualState _visualState() {
    if (_isListening && _state == _BallState.idle) {
      return AppVisualState.listening;
    }
    switch (_state) {
      case _BallState.idle:
        return AppVisualState.idle;
      case _BallState.thinking:
        return AppVisualState.thinking;
      case _BallState.revealed:
        return _isStreakReward ? AppVisualState.streak : AppVisualState.revealed;
    }
  }

  @override
  void initState() {
    super.initState();
    _aiService = AiService(client: http.Client(), apiKey: _apiKey);
    _soundManager = SoundManager();
    _hapticService.initialize();
    _soundManager.initialize();
    _shakeSubscription = _shakeService.onShake.listen((_) => _onShake());
    _dailyFortuneService.initialize();
    _notificationService.initialize();
    _homeWidgetService.initialize();
    _checkFirstLaunchDemo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _soundManager.startLoop(AmbientLoop.idlePad);
    });
  }

  Future<void> _checkFirstLaunchDemo() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenDemo = prefs.getBool('has_seen_first_demo') ?? false;
    if (!hasSeenDemo) {
      await prefs.setBool('has_seen_first_demo', true);
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _showFirstLaunchDemo();
      }
    }
  }

  void _showFirstLaunchDemo() {
    _questionController.text = 'Will I have a great day?';
    _onShake();
  }

  Future<void> _onShake() async {
    if (_state == _BallState.thinking) return;
    setState(() {
      _state = _BallState.thinking;
      _isShaking = true;
    });

    _hapticService.trigger(HapticPattern.shake);
    _soundManager.play(SoundEvent.shakeSlosh);
    _soundManager.startLoop(AmbientLoop.thinkingPulse);

    final answer = await _aiService.getAnswer(
      question: _questionController.text.trim(),
      category: _selectedCategory,
    );

    final timestamp = DateTime.now();
    await _historyService.addReading(Reading(
      question: _questionController.text.trim(),
      answer: answer,
      timestamp: timestamp,
    ));
    await _dailyFortuneService.recordAsked();
    final isStreak = _dailyFortuneService.isStreakReward;

    setState(() {
      _currentAnswer = answer;
      _state = _BallState.revealed;
      _isShaking = false;
      _isStreakReward = isStreak;
    });

    if (isStreak) {
      _hapticService.trigger(HapticPattern.streak);
      _soundManager.play(SoundEvent.streakFanfare);
    } else {
      _hapticService.trigger(HapticPattern.reveal);
      _soundManager.play(SoundEvent.revealChime);
    }
    _soundManager.stopAll();

    await _homeWidgetService.updateDailyFortune(answer);
    await _homeWidgetService.updateStreak(_dailyFortuneService.streak);
  }

  void _reset() {
    setState(() {
      _state = _BallState.idle;
      _isStreakReward = false;
    });
    _soundManager.startLoop(AmbientLoop.idlePad);
  }

  Future<void> _startVoiceInput() async {
    if (_state != _BallState.idle) return;

    final available = await _speechService.initialize();
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone access is needed for voice input.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    setState(() => _isListening = true);
    _soundManager.startLoop(AmbientLoop.idlePad);
    final result = await _speechService.listen();
    setState(() => _isListening = false);

    if (result != null && result.isNotEmpty) {
      _questionController.text = result;
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        await _onShake();
      }
    }
  }

  @override
  void dispose() {
    _shakeSubscription?.cancel();
    _shakeService.dispose();
    _soundManager.dispose();
    _speechService.stop();
    _questionController.dispose();
    _questionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isThinking = _state == _BallState.thinking;
    final isRevealed = _state == _BallState.revealed;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visualState = _visualState();
    final screenHeight = MediaQuery.of(context).size.height;

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
              onTap: () => _hapticService.trigger(HapticPattern.buttonPress),
            ),
            actions: [
              _AnimatedIconButton(
                icon: Icon(Icons.settings_rounded),
                tooltip: 'Settings',
                onPressed: _showSettingsSheet,
                onTap: () => _hapticService.trigger(HapticPattern.buttonPress),
              ),
              _AnimatedIconButton(
                icon: Icon(
                  _soundManager.isMuted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                ),
                tooltip: _soundManager.isMuted ? 'Unmute' : 'Mute',
                onPressed: () async {
                  await _soundManager.setMuted(!_soundManager.isMuted);
                  setState(() {});
                },
                onTap: () => _hapticService.trigger(HapticPattern.buttonPress),
              ),
              _AnimatedIconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                ),
                tooltip: 'Toggle theme',
                onPressed: widget.onToggleTheme,
                onTap: () => _hapticService.trigger(HapticPattern.buttonPress),
              ),
            ],
          ),
          body: DynamicBackground(
            state: visualState,
            category: isRevealed ? _selectedCategory : null,
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: _QuestionInput(
                        controller: _questionController,
                        focusNode: _questionFocusNode,
                        onSubmitted: _onShake,
                        isListening: _isListening,
                        onMicTap: _startVoiceInput,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _CategoryChips(
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (category) {
                        setState(() => _selectedCategory = category);
                      },
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          StreakIndicator(streak: _dailyFortuneService.streak),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_state == _BallState.idle &&
                        _dailyFortuneService.isDailyFortuneAvailable &&
                        screenHeight >= 500)
                      GestureDetector(
                        onTap: () {
                          _questionController.text = _dailyFortuneService.dailyPrompt;
                          _onShake();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.wb_sunny,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Daily Fortune',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ParticleLayer(state: visualState),
                          GestureDetector(
                            onTap: _onShake,
                            child: TiltGradientWidget(
                              size: 300,
                              child: MagicBallWidget(
                                isShaking: _isShaking,
                                isThinking: isThinking,
                                isRevealed: isRevealed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    RepaintBoundary(
                      key: _answerCardKey,
                      child: AnswerCardWidget(
                        answer: _currentAnswer,
                        isVisible: isRevealed,
                        isRevealed: isRevealed,
                        categoryIcon: isRevealed ? _selectedCategory.icon : null,
                        question: _questionController.text.trim(),
                        isGolden: _isStreakReward,
                      ),
                    ),
                    if (isRevealed)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: GestureDetector(
                          onTap: () async {
                            await _shareService.shareReadingAsImage(
                              repaintKey: _answerCardKey,
                              answer: _currentAnswer,
                              question: _questionController.text.trim(),
                              timestamp: DateTime.now(),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.share,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Share Reading',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (_state == _BallState.idle)
                      ShakeNowCta(onTap: _onShake),
                    const SizedBox(height: 32),
                    Text(
                      isThinking
                          ? 'Consulting the oracle...'
                          : isRevealed
                              ? 'Tap to ask again'
                              : 'Shake your phone, tap the ball, or ask aloud',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const _BottomFadeGradient(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSettingsSheet() async {
    _hapticService.trigger(HapticPattern.buttonPress);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SettingsSheet(
        soundManager: _soundManager,
        hapticService: _hapticService,
        speechService: _speechService,
        onSettingsChanged: () => setState(() {}),
      ),
    );
  }
}

class _BottomFadeGradient extends StatelessWidget {
  const _BottomFadeGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
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
  final bool isListening;
  final VoidCallback onMicTap;

  const _QuestionInput({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.isListening,
    required this.onMicTap,
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
                hintText: widget.isListening ? 'Listening...' : 'Ask anything...',
                hintStyle: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: _pulseAnimation.value * 0.5),
                  fontStyle: FontStyle.italic,
                ),
                border: InputBorder.none,
                suffixIcon: VoiceInputButton(
                  isListening: widget.isListening,
                  onTap: widget.onMicTap,
                ),
              ),
              onSubmitted: (_) => widget.onSubmitted(),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedIconButton extends StatefulWidget {
  final Icon icon;
  final String tooltip;
  final VoidCallback onPressed;
  final VoidCallback? onTap;

  const _AnimatedIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.onTap,
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
    widget.onTap?.call();
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

class _CategoryChips extends StatelessWidget {
  final QuestionCategory selectedCategory;
  final ValueChanged<QuestionCategory> onCategorySelected;

  const _CategoryChips({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: QuestionCategory.values.map((category) {
          final isSelected = category == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category.icon,
                    size: 16,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(category.label),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => onCategorySelected(category),
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 13,
              ),
              backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
