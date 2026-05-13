# P9 Design Doc — Soundscape & Game Feel

## Overview

This document turns the P9 roadmap items into concrete, buildable specifications. The goal is to make the app feel tactile, musical, and toy-like by giving every meaningful action a sound and haptic identity.

---

## Design Principles

- **Audio failures never block.** Every sound call is fire-and-forget with a try/catch. The answer flow continues even if audio crashes.
- **Mute is global.** One toggle silences everything: one-shots, loops, haptics. Persisted via `shared_preferences`.
- **Loops are state-bound.** Ambient sounds start and stop with HomeScreen state transitions, not UI events.
- **Haptics are semantic.** Each named pattern maps to a user action, not just a generic buzz.

---

## 1. SoundManager

### Why
`SoundService` exists but is thin. P9 centralizes volume, mute, categories, one-shots, loops, and failure handling into a single manager.

### Sound Categories

| Category | Purpose | Volume Default |
|----------|---------|---------------|
| ui | Buttons, toggles, navigation | 0.6 |
| shake | Physical shake, slosh | 0.8 |
| reveal | Answer appear, chime | 0.7 |
| ambient | Idle pad, thinking shimmer | 0.15 |
| fanfare | Streak reward, celebration | 0.8 |
| error | Network fail, dismiss | 0.5 |

### API

```dart
class SoundManager {
  bool get isMuted;
  Future<void> setMuted(bool muted);
  
  // One-shots by category
  Future<void> play(SoundEvent event);
  
  // Loops bound to state
  Future<void> startLoop(AmbientLoop loop);
  Future<void> stopLoop(AmbientLoop loop);
  
  // Global stop
  Future<void> stopAll();
}
```

### Sound Events

```dart
enum SoundEvent {
  buttonTap,      // ui
  shakeSlosh,     // shake
  revealChime,    // reveal
  streakFanfare,  // fanfare
  errorBuzzer,    // error
  favoriteStar,   // ui
  shareWhoosh,    // ui
}
```

### Ambient Loops

```dart
enum AmbientLoop {
  idlePad,      // airy, slow
  thinkingPulse,// shimmer, subtle
  revealedTail, // short sparkle decay
}
```

### Implementation Notes
- Use two `AudioPlayer` instances: one for one-shots, one for loops.
- On mute: stop loops immediately, ignore one-shots.
- On `setMuted(false)`: do not auto-restart loops; they restart on next state change.

---

## 2. Asset Plan

For now we reuse and rename existing assets plus add placeholder mappings for future real sounds.

| Asset Path | Maps To | Event |
|---|---|---|
| `sounds/water_slosh.mp3` | `shakeSlosh` | Shake |
| `sounds/reveal_chime.mp3` | `revealChime` | Reveal |
| `sounds/button_click.mp3` | `buttonTap` | Buttons |

**New placeholder entries** (create stub mappings that fall back to existing sounds if file missing):
- `streak_fanfare` → `reveal_chime` fallback
- `error_buzzer` → `button_click` fallback
- `favorite_star` → `button_click` fallback
- `share_whoosh` → `water_slosh` fallback
- `idle_pad` → `water_slosh` at 0.1 volume
- `thinking_pulse` → `reveal_chime` at 0.1 volume

This lets us wire the manager now and swap real assets later without code changes.

---

## 3. Haptic Sequencer

### Named Patterns

| Pattern | Action | Haptic Sequence |
|---------|--------|----------------|
| `shake` | Device shaken | Medium impact |
| `reveal` | Answer appears | Light → 120ms → Light |
| `favorite` | Star toggled | Selection click |
| `error` | Delete/dismiss/network fail | Heavy impact |
| `streak` | 7-day streak reached | Light → 80ms → Medium → 80ms → Heavy |
| `share` | Share sheet opens | Light impact |
| `buttonPress` | Any button tap | Light impact |

### Implementation
Replace `HapticService` methods with pattern-based API:

```dart
class HapticService {
  Future<void> trigger(HapticPattern pattern);
}

enum HapticPattern { shake, reveal, favorite, error, streak, share, buttonPress }
```

---

## 4. State-Driven Audio

HomeScreen visual states from P8 now drive ambient loops:

| Visual State | Audio Action |
|-------------|-------------|
| idle | Start `idlePad` loop |
| listening | Continue `idlePad`, slightly softer |
| thinking | Crossfade to `thinkingPulse` loop |
| revealed | Stop loops, play `revealedTail` one-shot |
| streak | Stop loops, play `streakFanfare` one-shot |

### Crossfade
Simple sequence: stop current loop, wait 50ms, start new loop. Not a true crossfade but clean enough.

---

## 5. Tilt-Reactive Audio

Use gyroscope data from `TiltGradientWidget` to pan the ambient loop left/right.
- Range: -0.5 to +0.5 based on tiltX.
- Applied to loop player's balance if platform supports it.
- Fallback: adjust volume from 0.8 to 1.0 based on tilt magnitude.

---

## 6. Settings Panel

### Trigger
Add a gear icon in HomeScreen app bar. Tap opens bottom sheet.

### Controls

| Control | Type | Default |
|---------|------|---------|
| Sound | Toggle | On |
| Haptics | Toggle | On |
| Voice Input | Toggle | On |
| Reduced Motion | Toggle | Follows system |

### Persistence
- Sound and haptics: `shared_preferences` keys `sound_enabled`, `haptics_enabled`.
- Voice input: `voice_input_enabled`.
- Reduced motion: read-only from system; toggle shows current state.

---

## Files to Create/Modify

### New Files
- `lib/services/sound_manager.dart` — replaces SoundService
- `lib/services/haptic_patterns.dart` — pattern enum + sequences
- `lib/widgets/settings_sheet.dart` — bottom sheet UI

### Modified Files
- `lib/services/sound_service.dart` — deprecate, redirect to SoundManager
- `lib/services/haptic_service.dart` — rewrite as pattern-based
- `lib/screens/home_screen.dart` — wire state-driven loops, settings button
- `lib/widgets/answer_card_widget.dart` — remove direct sound calls, use HomeScreen orchestration
- `lib/screens/history_screen.dart` — wire haptic patterns on favorite/delete/share

---

## Acceptance Criteria

- [ ] Mute toggle silences one-shots, loops, and haptics.
- [ ] Audio file failures do not crash the app or delay answers.
- [ ] Each major action has a distinct sound event and haptic pattern.
- [ ] Ambient loops start/stop cleanly on state transitions.
- [ ] Settings panel opens from HomeScreen and persists toggles.
- [ ] Tilt data adjusts ambient loop volume or balance.
- [ ] All existing widget tests still pass.

---

*Drafted for approval. No implementation until this doc is approved.*
