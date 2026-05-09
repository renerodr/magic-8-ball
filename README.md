# Magic 8-Ball

A playful, AI-powered Magic 8-Ball app built with Flutter. Shake your phone, ask a question, and get mystical answers powered by OpenRouter. Features voice input, daily fortunes, favorites, and a beautiful iridescent bubble design.

## Features

### Core Experience
- **Shake to reveal** — Physical shake detection with haptic feedback and water slosh sound
- **Tap to reveal** — Tap the ball or the "Shake Now" CTA
- **Voice input** — Ask questions aloud with speech-to-text
- **AI-powered answers** — OpenRouter integration with cryptic, mystical responses
- **Classic fallback** — 20 classic Magic 8-Ball answers when offline

### Design
- **Iridescent bubble ball** — Multi-color rotating gradient with specular highlight and inner shadow
- **Frosted glass answer card** — Multi-line answers with BackdropFilter blur
- **Cosmic Bubblegum palette** — Warm cream / soft charcoal backgrounds, coral and teal accents
- **Gyroscope shimmer** — Ball surface reacts to device tilt
- **Dark and light themes** — Magic 8-Ball (dark) and Crystal Ball (light) modes

### Engagement
- **Daily fortune** — One free fortune per day with streak tracking
- **Streak rewards** — Golden answer card every 7 consecutive days
- **Question categories** — General, Love, Career, Yes/No, Daily
- **Favorites** — Star readings to revisit later
- **Search history** — Find past readings by question or answer
- **Share readings** — Share as text or capture the answer card as an image

### Onboarding & Polish
- **Animated onboarding** — 3-screen intro with floating ball animations
- **First-launch demo** — Auto-triggers a sample reading on first use
- **Sound ecosystem** — Water slosh, reveal chime, button clicks, mute toggle
- **Haptic patterns** — Different feedback for shake, reveal, success, error

## Tech Stack

- Flutter 3.11+
- Dart
- `sensors_plus` — Accelerometer (shake) + gyroscope (tilt)
- `audioplayers` — Sound effects
- `speech_to_text` — Voice input
- `shared_preferences` — History, streaks, settings persistence
- `http` — OpenRouter API
- `flutter_animate` — Entrance animations
- `google_fonts` — Nunito + Inter typography
- `share_plus` / `path_provider` — Sharing
- `home_widget` — Home screen widget scaffold

## Getting Started

### Prerequisites
- Flutter SDK 3.11 or newer
- An OpenRouter API key

### Installation

```bash
# Clone the repo
git clone <repo-url>
cd magic_8_ball

# Install dependencies
flutter pub get

# Run with your API key
flutter run --dart-define=OPENROUTER_KEY=<your_key>
```

### Build Release

```bash
# Android APK
flutter build apk --dart-define=OPENROUTER_KEY=<your_key>

# iOS (requires macOS and Xcode)
flutter build ios --dart-define=OPENROUTER_KEY=<your_key>
```

## Project Structure

```
lib/
  constants/
    app_theme.dart          # Cosmic Bubblegum themes
    classic_answers.dart    # 20 fallback answers
  models/
    reading.dart            # Question + answer + timestamp
    question_category.dart  # General, Love, Career, Yes/No, Daily
  screens/
    home_screen.dart        # Main screen with state machine
    history_screen.dart     # Past readings with search/favorites
    onboarding_screen.dart  # 3-page animated intro
  services/
    ai_service.dart         # OpenRouter API with fallback
    daily_fortune_service.dart  # Streak tracking
    history_service.dart    # SharedPreferences CRUD
    haptic_service.dart     # Haptic feedback patterns
    home_widget_service.dart    # Widget data bridge
    notification_service.dart   # Reminder scaffold
    share_service.dart      # Text and image sharing
    shake_service.dart      # Accelerometer shake detection
    sound_service.dart      # Audio playback with mute
    speech_service.dart     # Speech-to-text wrapper
  widgets/
    answer_card_widget.dart     # Frosted glass answer display
    favorite_button.dart        # Animated heart icon
    magic_ball_widget.dart      # Iridescent bubble ball
    pulsing_background.dart     # Ambient radial glow
    shake_now_cta.dart          # Gradient-border pill button
    streak_indicator.dart       # Fire icon with streak count
    tilt_gradient_widget.dart   # Gyroscope shimmer overlay
    voice_input_button.dart     # Pulsing mic button
```

## Architecture

The app uses a simple state machine in `HomeScreen`:

```
idle → thinking → revealed → idle
```

- **idle**: Ball floats and breathes, input is active
- **thinking**: Ball wobbles with sparkle icon, AI call in flight
- **revealed**: Answer card slides up, chime plays, haptic fires

No state transitions are allowed while `thinking`.

## Configuration

### API Key
Never hardcode the API key. Pass it at build time:

```bash
flutter run --dart-define=OPENROUTER_KEY=sk-or-v1-...
```

Or create a `.env` file (not committed):

```
OPENROUTER_KEY=sk-or-v1-...
```

### iOS Permissions
The app requests microphone access for voice input. The usage description is set in `ios/Runner/Info.plist`.

### Shake Sensitivity
Adjust `_threshold` in `ShakeService` (default: 15 m/s²):

| Threshold | Feel |
|---|---|
| 10 | Very sensitive — fires on wrist flick |
| 15 | Default — deliberate shake required |
| 20 | Firm — two-handed shake needed |

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/ai_service_test.dart
flutter test test/widgets/favorite_button_test.dart
```

## Roadmap

See `docs/visual-polish-roadmap.md` for the full v2 roadmap and future plans.

## License

MIT
