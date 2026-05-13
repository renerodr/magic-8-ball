# P8 Design Doc — Cinematic Polish Pass

## Overview

This document turns the P8 roadmap items into concrete, buildable specifications. The goal is to make the home screen, reveal flow, history, and streak states feel crafted and alive without changing the core interaction model.

---

## Design Principles

- **State is visible.** Every screen state (idle, listening, thinking, revealed) should look meaningfully different.
- **Motion serves purpose.** Particles, glows, and transitions communicate state changes, not just decoration.
- **Respect reduced motion.** All looping and ambient motion must be disableable.
- **Small screens first.** Layout must not overflow on 320×568 logical pixels.

---

## State System

HomeScreen now has five visual states:

| State | Trigger | Visual Signature |
|-------|---------|-----------------|
| **idle** | No active session | Soft ambient motion, default background |
| **listening** | Speech-to-text active | Pulsing orb, microphone waveform hint |
| **thinking** | AI request in flight | Shimmer on orb, particle burst, darker scene |
| **revealed** | Answer ready | Glow settle, answer card slides up, scene tint by category |
| **streak** | 7-day streak reward | Golden card override with fanfare hooks |

---

## 1. Dynamic Background Scenes

### Approach
Replace the single scaffold background with a state-driven `AnimatedContainer` layer behind all content.

### Color Maps

```dart
// lib/constants/scene_colors.dart
class SceneColors {
  static const idleDark = Color(0xFF0A0A0F);
  static const idleLight = Color(0xFFF5F0FF);

  static const listeningDark = Color(0xFF1A0A1A);
  static const listeningLight = Color(0xFFFFF0F5);

  static const thinkingDark = Color(0xFF0A0A1A);
  static const thinkingLight = Color(0xFFF0F0FF);

  static const revealedDark = Color(0xFF0F0A14);
  static const revealedLight = Color(0xFFFAF5FF);
}
```

### Category Tints

When revealed, blend a subtle radial overlay:

| Category | Dark Tint | Light Tint |
|----------|-----------|------------|
| General | coral/teal blend | warm coral wash |
| Love | deep rose | soft pink |
| Career | gold/teal | amber glow |
| Daily | sunrise orange | peach wash |

Implementation: `RadialGradient` overlay at 8% opacity, centered on the orb, 300dp radius.

---

## 2. Particle Layer

### Approach
A single `CustomPainter` widget stacked behind the orb but above the background. Respects reduced motion.

### Particle Types

| Type | Count | Motion | Color |
|------|-------|--------|-------|
| Sparkle | 6-8 | Slow drift + twinkle | White, 15-30% opacity |
| Bubble | 4-6 | Float upward, wobble | Primary at 10% |
| Star fleck | 3-5 | Static drift | White at 8% |

### Behavior by State

- **idle:** All types active, slow drift.
- **listening:** Sparkles pulse faster (1Hz).
- **thinking:** Bubble count doubles, drift speed 1.5×, brief burst on enter.
- **revealed:** Sparkles burst outward from orb center, then settle.
- **streak:** Gold flecks replace sparkles.

### Performance

- Max 20 particles.
- Repaint via `AnimationController` at 30fps only when particles are visible.
- `RepaintBoundary` around the painter.

---

## 3. Reveal Choreography

### Timeline (0ms = answer ready)

```
0ms     - Orb scale 1.0 → 1.08 → 1.0 (spring, 400ms)
        - Background overlay fades in (300ms)
100ms   - Particle burst from orb center (6 sparkles, outward 40dp)
200ms   - Answer card begins slide from y+60dp to y=0 (500ms, easeOutCubic)
400ms   - Answer text fades in with slight blur-to-sharp (300ms)
600ms   - Category icon scales in from 0 to 1 (200ms, elastic)
800ms   - Glow settle: subtle radial pulse on orb (2s loop, 3 iterations)
1200ms  - State stable
```

### Implementation

Use `flutter_animate` chained effects on the answer card widget. The orb pulse is a separate `AnimationController` in `MagicBallWidget` triggered by a `didUpdateWidget` check on `isRevealed`.

---

## 4. Layout Hierarchy Pass

### Problems to Solve

1. **Input crowding:** Question field sits too close to category chips on small screens.
2. **Streak indicator:** Flame icon + count compete with the orb for attention.
3. **Daily fortune button:** Positioned ambiguously between input and orb.
4. **Share button:** Appears only on revealed but lacks clear anchoring.

### New Layout Zones

```
[SafeArea top]
[AppBar: theme toggle | history]                    (48dp)
[Streak row: flame + count, right-aligned]          (24dp)
[Spacer]                                            (flex: 1)
[Daily fortune chip, centered, subtle]              (32dp)
[Magic Orb]                                         (~200dp)
[Answer card, overlaying orb bottom]                (adaptive)
[Category chips, centered]                          (40dp)
[Question input, padded]                            (56dp)
[Shake CTA or Share button, centered]               (48dp)
[SafeArea bottom]
```

### Rules

- Minimum 12dp between all interactive elements.
- On screens < 600dp logical height, orb scales to 0.85.
- On screens < 500dp logical height, daily fortune chip hides.
- Answer card max height: 30% of screen. Scrollable if content exceeds.

---

## 5. Golden Streak Card

### Trigger
Every 7-day streak reward answer uses the golden card treatment instead of the standard frosted glass card.

### Visual Spec

- **Background:** Linear gradient from `Color(0xFFFFD700)` to `Color(0xFFFFA500)` at 20% opacity over the standard frosted base.
- **Border:** 1.5dp solid gold at 40% opacity.
- **Glow:** BoxShadow, gold at 15%, 20dp blur.
- **Text:** Slightly warmer white (`Color(0xFFFFF8E7)`).
- **Icon:** Small flame icon in the card header, gold colored.

### Fanfare Hooks

The card widget exposes an `onFanfare` callback. For now it is a no-op commented hook. P9 will wire sound.

---

## 6. History Polish

### Empty State

- **Visual:** Large faded orb icon (64dp, opacity 0.08) centered.
- **Copy:** "The oracle awaits your first question" (Cinzel, 18sp).
- **Subcopy:** "Shake your device or type below to begin" (body, 14sp, secondary).
- **CTA:** "Ask a Question" button that pops back to home and focuses input.

### Favorites-Only Empty

- **Copy:** "No starred readings yet."
- **Subcopy:** "Tap the star on any reading to save it."

### No Search Results

- **Copy:** "The mists are unclear…"
- **Subcopy:** "Try different words or browse your full history."

### Card Entry Animation

Existing staggered fade-in is fine. Ensure it respects `MotionPolicy` delays.

---

## Reduced Motion Policy

All new P8 features must respect `MotionPolicy`:

| Feature | Reduced Motion Behavior |
|---------|------------------------|
| Background scene transitions | Instant color swap (0ms duration) |
| Particle layer | Hidden entirely |
| Orb pulse on reveal | Single 200ms scale to 1.02, no loop |
| Answer card slide | Fade only, no translation |
| Sparkle burst | Skip |
| Golden card glow | Static shadow, no pulse |
| History stagger | No delay, instant opacity |

---

## Files to Create/Modify

### New Files

- `lib/constants/scene_colors.dart` — state + category color maps
- `lib/widgets/particle_layer.dart` — CustomPainter particle system
- `lib/widgets/golden_answer_card.dart` — streak reward card variant
- `lib/widgets/dynamic_background.dart` — state-driven background container

### Modified Files

- `lib/screens/home_screen.dart` — wire state system, layout zones, background
- `lib/widgets/magic_ball_widget.dart` — orb pulse on reveal, scale adaptation
- `lib/widgets/answer_card.dart` — reveal choreography, category tint
- `lib/screens/history_screen.dart` — empty states, favorites-only, no-results
- `lib/utils/motion_policy.dart` — ensure new features query policy

---

## Acceptance Criteria

- [ ] Home screen looks alive in idle state (particles drift).
- [ ] Listening state shows distinct visual treatment.
- [ ] Thinking state shows shimmer + particle burst.
- [ ] Revealed state shows choreographed sequence (orb pulse, card slide, text fade).
- [ ] Category tints are visible in revealed state.
- [ ] 7-day streak triggers golden card with glow.
- [ ] Small screens (320×568) do not overflow.
- [ ] Reduced motion disables particles and looping motion.
- [ ] History empty/favorites/search states have polished copy and visuals.

---

*Drafted for approval. No implementation until this doc is approved.*
