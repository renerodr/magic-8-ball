# Architecture

## File Map

```
magic_8_ball/
├── assets/sounds/
│   ├── water_slosh.mp3         # Shake sound effect
│   ├── reveal_chime.mp3        # Reveal chime sound
│   └── button_click.mp3        # Button tap sound
├── lib/
│   ├── main.dart               # runApp entry point
│   ├── app.dart                # MagicApp: owns ThemeMode, passes onToggleTheme
│   ├── constants/
│   │   ├── app_theme.dart      # darkTheme (8-ball) + lightTheme (crystal ball)
│   │   ├── category_fallbacks.dart  # 100 category-specific fallback answers (20 each)
│   │   ├── category_prompts.dart    # CategoryPromptTemplates + CategoryPromptConfig
│   │   ├── classic_answers.dart     # Legacy fallback list (deprecated, kept for compat)
│   │   └── scene_colors.dart       # AppVisualState → background color mappings
│   ├── models/
│   │   ├── oracle_persona.dart     # OraclePersona enum (spark, luna, oraclePro)
│   │   ├── question_category.dart  # QuestionCategory enum (general, love, career, yesNo, daily)
│   │   └── reading.dart            # Reading{question, answer, timestamp, isFavorite} + JSON
│   ├── services/
│   │   ├── ai_service.dart         # OpenRouter HTTP + category/persona-aware fallback
│   │   ├── daily_fortune_service.dart  # Daily fortune tracking + streak logic
│   │   ├── haptic_patterns.dart    # HapticPattern enum + HapticPatterns.execute()
│   │   ├── haptic_service.dart     # HapticFeedback wrappers, SharedPreferences persistence
│   │   ├── history_service.dart    # SharedPreferences CRUD for readings
│   │   ├── home_widget_service.dart    # Home screen widget data bridge
│   │   ├── notification_service.dart   # Local notification scheduling (opt-in)
│   │   ├── oracle_context_service.dart # Persona + context memory for AI prompts
│   │   ├── shake_service.dart      # Accelerometer → shake Stream<void>
│   │   ├── share_service.dart      # Widget-to-PNG + share_plus integration
│   │   ├── sound_manager.dart      # Central audio: one-shots, loops, mute, tilt-reactive
│   │   ├── sound_service.dart      # DEPRECATED — redirects to SoundManager
│   │   └── speech_service.dart     # speech_to_text wrapper, persisted toggle
│   ├── utils/
│   │   ├── motion_policy.dart      # Reduced-motion policy for all animations
│   │   └── reduced_motion.dart     # MediaQuery accessibleNavigation check
│   ├── widgets/
│   │   ├── answer_card_widget.dart  # Answer display with golden variant + category icon
│   │   ├── dynamic_background.dart  # State-driven background color transitions
│   │   ├── favorite_button.dart    # Star toggle for history cards
│   │   ├── follow_up_suggestions.dart  # Post-answer suggestion chips per category
│   │   ├── magic_ball_widget.dart   # Ball: gradient + triangle window + animations
│   │   ├── particle_layer.dart     # Drifting sparkle/bubble/star particles
│   │   ├── pulsing_background.dart # Pulsing ambient background
│   │   ├── settings_sheet.dart     # Sound, haptics, voice input toggles
│   │   ├── shake_now_cta.dart      # "Shake Now" call-to-action button
│   │   ├── streak_indicator.dart    # Streak count + flame icon
│   │   ├── tilt_gradient_widget.dart  # Gyroscope-driven shimmer overlay
│   │   └── voice_input_button.dart    # Mic icon for voice input
│   └── screens/
│       ├── history_screen.dart     # Card list + favorites filter + search + swipe delete
│       ├── home_screen.dart        # Main screen — state machine + all service wiring
│       └── onboarding_screen.dart  # 3-screen first-launch intro
└── test/
    ├── models/reading_test.dart
    ├── services/
    │   ├── ai_service_test.dart
    │   ├── daily_fortune_service_test.dart
    │   ├── history_service_test.dart
    │   ├── settings_persistence_test.dart
    │   ├── shake_service_test.dart
    │   └── speech_service_test.dart
    └── widgets/
        ├── answer_card_widget_test.dart
        ├── favorite_button_test.dart
        ├── magic_ball_widget_test.dart
        ├── p0_2_verification_test.dart
        ├── shake_now_cta_test.dart
        └── voice_input_button_test.dart
```

## State Machine (HomeScreen)

```
idle ──[shake/tap/voice]──► thinking ──[AI response]──► revealed ──[tap]──► idle
  │                              │
  └──[voice input]──► listening  └──[error]──► revealed (fallback answer)
```

- `idle`: ball shows, no answer visible, shake detection active, ambient idle loop plays
- `listening`: voice input active, mic icon pulses, returns to idle if canceled
- `thinking`: shake fired, shimmer on ball, AI call in flight, shake ignored, thinking pulse loop plays
- `revealed`: answer displayed with category icon, reveal chime + haptic fire, follow-up suggestions shown

Visual state (`AppVisualState`) derives from ball state + listening flag + streak reward:
- `idle`, `listening`, `thinking`, `revealed`, `streak`

## Service Responsibilities

| Service | Input | Output | Side Effects |
|---|---|---|---|
| `ShakeService` | Accelerometer stream | `Stream<void> onShake` | none |
| `AiService` | question, category, persona, streak | `Future<String>` answer | HTTP to OpenRouter, context recording |
| `SoundManager` | `SoundEvent` / `AmbientLoop` | — | Plays audio assets, tilt-reactive volume |
| `HapticService` | `HapticPattern` | — | `HapticFeedback` calls, persisted toggle |
| `HistoryService` | `Reading` | `Future<List<Reading>>` | SharedPreferences I/O |
| `OracleContextService` | question, answer, persona | context string | In-memory ring buffer (last 10) |
| `DailyFortuneService` | — | streak, daily availability | SharedPreferences I/O |
| `SpeechService` | — | transcript string | Microphone, persisted toggle |
| `ShareService` | widget key + data | — | PNG capture + share_plus |
| `HomeWidgetService` | fortune text, streak | — | home_widget platform channel |
| `NotificationService` | — | — | Local notification scheduling |

## Data Flow (Shake → Reveal)

```
ShakeService.onShake / tap / voice
  → HomeScreen._onShake()
      ├── HapticService.trigger(shake)          (immediate)
      ├── SoundManager.play(shakeSlosh)          (immediate)
      ├── SoundManager.startLoop(thinkingPulse)  (immediate)
      └── AiService.getAnswer(question, category, persona, streak)  (async)
            → OracleContextService.buildContextForPrompt()
            → HTTP POST to OpenRouter
            → _postProcess(): filler removal, word truncation, punctuation strip,
              unicode normalization, repeat detection
            → HistoryService.addReading()
            → DailyFortuneService.recordAsked()
            → HomeWidgetService.updateDailyFortune()
            → setState(revealed)
            → HapticService.trigger(reveal | streak)
            → SoundManager.play(revealChime | streakFanfare)
            → SoundManager.stopAll()
```

## API Configuration

OpenRouter endpoint: `https://openrouter.ai/api/v1/chat/completions`

Key injected at build time:
```bash
flutter run --dart-define=OPENROUTER_KEY=sk-or-...
```

Read in code:
```dart
const _apiKey = String.fromEnvironment('OPENROUTER_KEY', defaultValue: '');
```

Default model: `openai/gpt-3.5-turbo` — swap in `AiService._model`.

## Persistence Keys

| Key | Service | Type | Default |
|---|---|---|---|
| `oracle_persona` | OracleContextService | int | 0 (spark) |
| `sound_muted` | SoundManager | bool | false |
| `haptics_enabled` | HapticService | bool | true |
| `voice_input_enabled` | SpeechService | bool | true |
| `has_seen_first_demo` | HomeScreen | bool | false |

## Motion Policy

All animations route through `MotionPolicy` (`lib/utils/motion_policy.dart`):
- When `accessibleNavigation` is on: particles disabled, loops stopped, stagger delays zeroed, large transforms shortened
- `_revealScaleAnimationReduced` provides an alternate animation path in `MagicBallWidget`
