# Architecture

## File Map

```
magic_8_ball/
├── assets/sounds/water_slosh.mp3      # Shake sound effect (must be provided)
├── lib/
│   ├── main.dart                      # runApp entry point
│   ├── app.dart                       # MagicApp: owns ThemeMode, passes onToggleTheme
│   ├── constants/
│   │   ├── classic_answers.dart       # kClassicAnswers — List<String>, 20 entries
│   │   └── app_theme.dart             # darkTheme (8-ball) + lightTheme (crystal ball)
│   ├── models/
│   │   └── reading.dart               # Reading{question, answer, timestamp} + JSON
│   ├── services/
│   │   ├── ai_service.dart            # OpenRouter HTTP + classic fallback
│   │   ├── shake_service.dart         # Accelerometer → shake Stream<void>
│   │   ├── sound_service.dart         # audioplayers wrapper
│   │   ├── haptic_service.dart        # HapticFeedback wrappers
│   │   └── history_service.dart       # SharedPreferences CRUD for readings
│   ├── widgets/
│   │   ├── magic_ball_widget.dart     # Static ball: circle + gradient + "8"
│   │   ├── answer_reveal_widget.dart  # AnimatedOpacity answer text overlay
│   │   └── tilt_gradient_widget.dart  # Gyroscope-driven shimmer overlay
│   └── screens/
│       ├── home_screen.dart           # Main screen — state machine + service wiring
│       └── history_screen.dart        # Readings list + Hero animation
└── test/
    ├── models/reading_test.dart
    ├── services/
    │   ├── ai_service_test.dart
    │   ├── history_service_test.dart
    │   └── shake_service_test.dart
    └── widgets/
        ├── magic_ball_widget_test.dart
        └── answer_reveal_widget_test.dart
```

## State Machine (HomeScreen)

```
idle ──[shake]──► thinking ──[AI response]──► revealed ──[tap]──► idle
                     │
                     └──[error]──► revealed (fallback answer)
```

- `idle`: ball shows, no answer visible, shake detection active
- `thinking`: shake fired, shimmer on ball, AI call in flight, shake ignored
- `revealed`: answer fades in (1.2s AnimatedOpacity), haptic double-pulse fires

## Service Responsibilities

| Service | Input | Output | Side Effects |
|---|---|---|---|
| `ShakeService` | Accelerometer stream | `Stream<void> onShake` | none |
| `AiService` | question string | `Future<String>` answer | HTTP call to OpenRouter |
| `SoundService` | — | — | Plays `water_slosh.mp3` |
| `HapticService` | — | — | HapticFeedback calls |
| `HistoryService` | `Reading` | `Future<List<Reading>>` | SharedPreferences I/O |

## Data Flow (Shake → Reveal)

```
ShakeService.onShake
  → HomeScreen._onShake()
      ├── HapticService.onShake()         (immediate)
      ├── SoundService.playSlosh()         (immediate)
      └── AiService.getAnswer(question)    (async)
            → HistoryService.addReading()
            → setState(revealed)
            → HapticService.onReveal()
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
