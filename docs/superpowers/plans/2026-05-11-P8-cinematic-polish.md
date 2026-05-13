# P8 Implementation Plan — Cinematic Polish Pass

## Goal

Implement all P8 design specifications in a single branch. Verify on device/emulator before finishing.

## Phase Order

1. Foundation (colors, motion policy, background widget)
2. Particle system
3. Orb and answer card choreography
4. Layout hierarchy pass
5. Golden streak card
6. History screen polish
7. Integration and verification

---

## Task 1: Foundation

### 1.1 Create `lib/constants/scene_colors.dart`

**Spec:** Export state colors (idle, listening, thinking, revealed) for dark and light themes, plus category tint colors.

**Acceptance:**
- All colors compile.
- Colors are used by `DynamicBackground`.

### 1.2 Update `lib/utils/motion_policy.dart`

**Spec:** Ensure `MotionPolicy` exposes a `shouldShowParticles` boolean and `reducedDuration(Duration)` helper. P8 features will query these.

**Acceptance:**
- `shouldShowParticles` returns false when reduced motion is on.
- `reducedDuration` returns zero or shortened durations.

### 1.3 Create `lib/widgets/dynamic_background.dart`

**Spec:** Stateless widget that takes `AppState state` and `QuestionCategory? category`. Uses `AnimatedContainer` with `BoxDecoration` to crossfade background colors over 400ms. In revealed state, overlays a radial gradient at 8% opacity using category tint.

**Acceptance:**
- Background color animates smoothly between states.
- Category tint is visible in revealed state.
- Reduced motion: instant swap (0ms duration).

---

## Task 2: Particle System

### 2.1 Create `lib/widgets/particle_layer.dart`

**Spec:** CustomPainter with three particle types (sparkle, bubble, star fleck). Max 20 particles. AnimationController at 30fps. Respects `MotionPolicy.shouldShowParticles`. Behavior changes by state: idle drift, listening fast pulse, thinking burst, revealed outward burst, streak gold flecks.

**Acceptance:**
- Particles render behind orb, above background.
- Performance: no jank on mid-range device.
- Hidden when reduced motion is on.
- Burst triggers correctly on state enter.

---

## Task 3: Orb and Answer Card Choreography

### 3.1 Update `lib/widgets/magic_ball_widget.dart`

**Spec:** Add orb pulse animation on reveal: scale 1.0 → 1.08 → 1.0 over 400ms with spring curve. Scale down to 0.85 when screen height < 600dp. Trigger via `didUpdateWidget` on `isRevealed` transition.

**Acceptance:**
- Pulse fires once per reveal.
- No pulse when reduced motion is on (single 200ms scale to 1.02).
- Orb scales correctly on small screens.

### 3.2 Update `lib/widgets/answer_card.dart`

**Spec:** Implement reveal choreography: slide from y+60dp, blur-to-sharp text fade, category icon scale-in. Use `flutter_animate`. Accept `isRevealed` and `category` params. Support golden variant for streak.

**Acceptance:**
- Timeline matches design doc (0ms orb, 200ms card slide, 400ms text, 600ms icon).
- Category icon appears in revealed state.
- Reduced motion: fade only, no translation.

---

## Task 4: Layout Hierarchy Pass

### 4.1 Update `lib/screens/home_screen.dart`

**Spec:** Restructure vertical layout into defined zones: streak row, daily fortune chip, orb, answer card, category chips, input, CTA. Minimum 12dp spacing. Hide daily fortune chip when screen height < 500dp. Pass `state` and `category` to `DynamicBackground` and `ParticleLayer`.

**Acceptance:**
- No overflow on 320×568 logical pixels.
- Daily fortune chip hides on small screens.
- All interactive elements have >= 12dp separation.

---

## Task 5: Golden Streak Card

### 5.1 Create `lib/widgets/golden_answer_card.dart`

**Spec:** Extend or wrap `AnswerCard` with golden gradient background, gold border, glow shadow, warmer text, flame icon header. Expose `onFanfare` callback as no-op hook.

**Acceptance:**
- Golden card renders distinctly from standard card.
- Glow is visible but not overwhelming.
- `onFanfare` hook exists for P9.

### 5.2 Wire streak trigger in `HomeScreen`

**Spec:** When `StreakService` reports a 7-day streak reward, pass `isGolden: true` to answer card widget.

**Acceptance:**
- Golden card appears on 7-day streak answers.

---

## Task 6: History Screen Polish

### 6.1 Update `lib/screens/history_screen.dart`

**Spec:** Add three empty states: no readings, favorites-only empty, no search results. Each with icon, copy, subcopy, and optional CTA. Ensure CTA uses `Navigator.pop` (not push new home).

**Acceptance:**
- All three states show correct copy and visuals.
- CTA navigates back to home correctly.

---

## Task 7: Integration and Verification

### 7.1 Run static analysis

```bash
flutter analyze
```

**Acceptance:** No errors or warnings.

### 7.2 Run tests

```bash
flutter test
```

**Acceptance:** All existing tests pass. New behavior does not break old tests.

### 7.3 Manual QA checklist

- [ ] Idle state: particles drift, background is default.
- [ ] Listening state: background shifts, sparkles pulse.
- [ ] Thinking state: shimmer on orb, bubble burst.
- [ ] Revealed state: orb pulse, card slide, text fade, category icon, tint overlay.
- [ ] Streak state: golden card appears.
- [ ] Small screen: no overflow, orb scales, daily fortune hides.
- [ ] Reduced motion: no particles, instant background swaps, no orb loop.
- [ ] History: all empty states render correctly.

---

## Rollback Plan

If any task introduces regressions:
1. Revert the specific file changes.
2. Re-run `flutter test` to confirm baseline.
3. Re-implement with smaller scope.

---

*Approved for execution.*
