# Visual Polish Roadmap

A phased plan to elevate the Magic 8-Ball app from functional to visually stunning. Each phase builds on the previous, with clear deliverables and implementation guidance.

---

## Phase 1: Ball Surface & Dimension (Foundation)

**Goal:** Transform the flat ball into a tangible, physical object with depth and material presence.

### 1.1 Multi-Layer Radial Gradient System
Replace the single radial gradient with a sophisticated 5-stop gradient that mimics a glossy sphere:

```dart
// Dark theme gradient stops (outside to center):
// 1. Outer edge: #0A0A0F (deep shadow)
// 2. Mid-shadow: #1A1A2E (soft transition)
// 3. Base color: #0D0D1A (main ball surface)
// 4. Highlight zone: #1E1E3A (subtle light catch)
// 5. Specular hotspot: #3D3D5C (gloss reflection)

// Light theme gradient stops:
// 1. Outer edge: #E0D0FF (soft shadow)
// 2. Mid-tone: #F0E8FF (transition)
// 3. Base color: #FFFFFF (main surface)
// 4. Highlight zone: #FFFFFF (full white)
// 5. Specular hotspot: #FFFFFF at 80% opacity
```

**Key implementation:** Use `RadialGradient` with precise `stops` array `[0.0, 0.4, 0.7, 0.9, 1.0]` to create the spherical illusion.

### 1.2 Dynamic Specular Highlight
Add a secondary highlight layer that responds to device tilt using gyroscope data:
- Position highlight using `Alignment` based on `_tiltX` and `_tiltY` inverted
- Size: 60x60 dp circular highlight with Gaussian blur (20dp)
- Opacity: 0.3-0.6 based on tilt angle
- Color: White with subtle purple tint in dark mode

**Implementation approach:** Overlay a `ClipOval` with blurred `Container` on top of the ball, animated via `AnimatedAlign`.

### 1.3 Rim Lighting Effect
Add a subtle rim light that catches the ball's edge:
- Use a `BoxShadow` with negative spread radius
- Color: Primary color at 15% opacity
- Blur: 60dp, Spread: -10dp
- Only visible in dark theme

### 1.4 Inner Triangle Window (The "Eye")
Redesign the center window where answers appear:
- Replace circular window with the classic Magic 8-Ball triangle shape
- Use `CustomPainter` or `ClipPath` with triangle path
- Dark blue gradient fill (#000033 to #000066)
- Subtle inner shadow for depth
- Blue glow emanating from behind (20dp blur, primary color at 30%)

---

## Phase 2: Animation Ecosystem (Life)

**Goal:** Make every interaction feel responsive and magical through purposeful motion.

### 2.1 Shake Response Animation
When shake is detected, trigger a micro-animation sequence:

```
Timeline (0ms = shake detected):
0ms   - Ball scales down to 0.95 (anticipation)
50ms  - Ball rotates 5° left + scales to 1.02 (impact)
100ms - Ball rotates 5° right
150ms - Ball returns to center, scale 1.0
```

**Implementation:** Use `flutter_animate` with staggered effects triggered by state change.

### 2.2 Liquid Distortion Effect (Thinking State)
While consulting the oracle:
- Add subtle wobble animation to the ball surface
- Use `Transform` with slight skewX/skewY oscillation
- Frequency: 0.5Hz, Amplitude: 2°
- Combine with existing shimmer effect

### 2.3 Answer Reveal Sequence
Replace simple fade-in with theatrical reveal:

```
Timeline:
0ms     - Triangle window begins to glow brighter
300ms   - Answer text fades in with blur-to-sharp transition
500ms   - Answer scales from 0.9 to 1.0 with elastic curve
800ms   - Subtle particle burst (4-6 sparkles) from triangle
1200ms  - Settle state
```

**Implementation:** Chain `Animate` widgets with `then()` syntax for precise timing.

### 2.4 Floating Idle Animation
When idle, the ball should feel alive:
- Gentle vertical float: ±4dp over 4 seconds
- Subtle breathing scale: 1.0 to 1.02 over 3 seconds
- Out of sync for organic feel

---

## Phase 3: Typography & Text Polish (Clarity)

**Goal:** Establish clear visual hierarchy and mystical atmosphere through text.

### 3.1 Question Input Redesign
Transform the question field from plain to purposeful:

**Visual treatment:**
- Remove underline, add subtle pill-shaped container
- Background: Surface color at 30% opacity with 1dp border
- Border color: Primary at 20% opacity, animates to 50% on focus
- Placeholder text: Italic with opacity pulse animation
- Cursor: Primary color, 2dp width

**Focus animation:**
- On focus: Border brightens, container subtly scales to 1.02
- On submit: Brief "sending" shimmer across text

### 3.2 Answer Typography System
Elevate the answer display:

**Current:** Generic displayLarge at 18sp
**New:**
- Font: Cinzel Decorative (import via google_fonts)
- Size: 20sp for short answers, 16sp for long
- Line height: 1.4 for readability
- Letter spacing: 0.5 (open) for mystical feel
- Text shadow: Subtle drop shadow for depth (1dp blur, black at 30%)
- Color: White with slight blue tint (#E8E8FF)

**Responsive sizing:** Auto-scale font size based on answer length to prevent overflow.

### 3.3 Microcopy Animation
The helper text ("Shake to reveal...") should feel ambient:
- Gentle opacity pulse: 0.7 to 0.9 over 3 seconds
- Subtle letter-spacing animation on state change
- Fade transitions between states (150ms crossfade)

---

## Phase 4: History Screen Transformation (Narrative)

**Goal:** Turn history from a list into a story of past consultations.

### 4.1 Card-Based Layout
Replace `ListView` with staggered card design:

**Card design:**
- Background: Surface color with subtle gradient overlay
- Border radius: 16dp
- Elevation: 1dp with custom shadow (primary color at 5%)
- Padding: 20dp all sides
- Margin: 12dp vertical between cards

**Card content structure:**
```
[Answer - Cinzel, 18sp, white, centered]
[Question - Body text, 14sp, secondary at 70%, italic if empty]
[Timestamp - Caption, 11sp, muted, right-aligned]
```

### 4.2 Empty State Design
Transform "No readings yet" into an invitation:

**Visual:**
- Large faded ball icon (80dp, opacity 0.1)
- Text: "The oracle awaits your first question"
- Subtext: "Shake your device to begin"
- Call-to-action button: "Ask Now" that triggers haptic and navigates

**Animation:** Ball icon gentle rotation (5° oscillation), opacity pulse.

### 4.3 Entry Animations
As cards appear on screen:
- Staggered fade-in: Each card delays 50ms from previous
- Slide up: 20dp vertical translation with fade
- Scale: 0.95 to 1.0
- Duration: 400ms with ease-out curve

### 4.4 Swipe Actions
Add swipe-to-delete with flair:
- Background: Red gradient revealing delete icon
- Swipe threshold: 30% of width
- Delete animation: Card shrinks and fades before removal
- Undo: Snackbar with "Reading dismissed" + undo action

### 4.5 Hero Transition Refinement
Improve the existing Hero animation:
- Add shared element transition for the triangle window shape
- Animate background color from card to ball surface
- Duration: 500ms with custom curve

---

## Phase 5: Ambient Atmosphere (Immersion)

**Goal:** Create a surrounding environment that reinforces the mystical theme.

### 5.1 Animated Background
Replace solid scaffold background with subtle depth:

**Dark theme:**
- Base: #0A0A0F
- Radial gradient overlay emanating from ball position
- Color: Primary at 5% opacity, 400dp radius
- Subtle pulse animation on the gradient intensity

**Light theme:**
- Base: #F5F0FF
- Soft vignette gradient (darker at edges)
- Subtle shimmer particles (optional, performance-conscious)

### 5.2 Particle Dust Effect (Optional)
Add mystical floating particles in the background:
- Count: 15-20 particles max (performance limit)
- Size: 1-3dp circles
- Color: White at 10-20% opacity
- Motion: Slow drift with sine-wave horizontal movement
- Speed: 10-30dp per second vertical drift
- Reset: Loop from bottom when exiting top

**Implementation:** Use `CustomPainter` with `AnimationController` at 30fps.

### 5.3 Status Bar Integration
Seamless status bar treatment:
- Dark theme: Translucent status bar, icons white
- Light theme: Translucent status bar, icons dark
- Use `SystemUiOverlayStyle` for consistency

### 5.4 Bottom Safe Area Treatment
For devices with home indicators:
- Gradient fade at bottom edge (20dp)
- Prevents harsh cutoff of content

---

## Phase 6: Micro-Interactions (Delight)

**Goal:** Add unexpected moments of delight through detailed interaction design.

### 6.1 Button Feedback System
Replace standard `IconButton` with custom feedback:

**Visual feedback:**
- On press: Scale to 0.9, opacity to 0.7
- On release: Spring back to 1.0 with overshoot
- Ripple: Custom ripple color (primary at 20%)

**Haptic sync:** Light impact on press, medium on release.

### 6.2 Theme Transition
Smooth theme switching animation:
- Crossfade duration: 600ms
- Ball rotates 360° during transition
- Background color morphs through purple midpoint
- Text elements crossfade

### 6.3 Question Submission
When user submits (via return key or tap):
- Brief "ripple" effect from input field center
- Question text animates upward and fades
- Input field clears with typewriter-reverse effect (optional polish)

### 6.4 Sound Wave Visualization
Optional visual sound indicator during shake:
- 3 horizontal bars that animate to the slosh sound
- Bars emanate from ball position
- Fade out after sound completes

---

## Phase 7: Iconography & Visual Assets (Consistency)

**Goal:** Ensure every visual element feels cohesive and purposeful.

### 7.1 Custom Icon Set
Replace Material icons with custom or customized icons:

**History icon:** Hourglass or scroll instead of list
**Theme toggle:** Sun/moon with morphing animation
**Delete:** Mystical "erase" symbol (crystal being cleared)

**Implementation:** Use `AnimatedSwitcher` for theme toggle morph.

### 7.2 App Icon Polish
Ensure launcher icon matches app aesthetic:
- Glossy ball with triangle window
- Deep shadows for depth
- Adaptive icon support for Android
- All required sizes for iOS

### 7.3 Splash Screen
Branded launch experience:
- Animated ball appearing from darkness
- Brief glow pulse
- Transition to app without jarring cut

---

## Implementation Priority Matrix

| Priority | Phase | Effort | Impact |
|----------|-------|--------|--------|
| P0 | 1.1, 1.4, 2.3, 3.2 | Medium | High |
| P1 | 2.1, 2.2, 4.1, 6.1 | Medium | High |
| P2 | 1.2, 3.1, 4.2, 4.3, 5.1 | Medium | Medium |
| P3 | 2.4, 4.4, 4.5, 6.2, 6.3 | Medium | Medium |
| P4 | 1.3, 5.2, 5.3, 6.4, 7.x | High | Low |

---

## Design Principles to Follow

1. **Purposeful Motion:** Every animation should communicate state or provide feedback. Avoid decoration-only motion.

2. **Depth Hierarchy:** Use shadow, scale, and blur to create clear z-order. The ball should always feel "in front."

3. **Theme Consistency:** Both dark and light themes should feel like the same app. Maintain identical interaction patterns.

4. **Performance First:** Target 60fps. Use `RepaintBoundary` around animated areas. Test on mid-range devices.

5. **Accessibility:** Ensure contrast ratios meet WCAG 2.1 AA. Animations should respect `prefers-reduced-motion`.

6. **Progressive Enhancement:** Core functionality works without animations. Effects enhance, never block.

---

## Quick Wins (Start Here)

For immediate visual improvement with minimal effort:

1. **Add ball gradient stops** (Phase 1.1) - 30 minutes
2. **Implement idle floating animation** (Phase 2.4) - 20 minutes
3. **Add text shadow to answers** (Phase 3.2) - 5 minutes
4. **Create triangle window** (Phase 1.4) - 45 minutes
5. **Add button press feedback** (Phase 6.1) - 20 minutes

Total: ~2 hours for dramatic visual improvement.

---

## Testing Checklist

- [ ] Ball looks spherical on both themes
- [ ] Answer text is readable at all sizes
- [ ] Animations run at 60fps on mid-tier device
- [ ] No visual glitches during state transitions
- [ ] History cards scroll smoothly with 50+ entries
- [ ] Theme switch is seamless
- [ ] Reduced motion preference is respected
- [ ] All text meets contrast requirements (4.5:1 minimum)

---

## Implementation Review Addendum (2026-05-05)

This review checks the current polish implementation against the roadmap and adds corrective work.

### What landed well

- Ball surface depth improved with multi-stop gradients and a triangular inner window.
- History cards now have stronger structure and visual hierarchy.
- Empty state copy and visual treatment are closer to the product tone.

### Gaps and quality issues to fix next

1. **Shake micro-animation is not wired through HomeScreen**
   - `MagicBallWidget` supports `isShaking`, but `HomeScreen` does not pass a shake trigger state.
   - Result: Phase 2.1 timeline animation path exists in code but never runs.

2. **Input focus polish is incomplete**
   - The input container style changed, but focus-driven border/scale behavior from Phase 3.1 is missing.
   - Placeholder pulse and submit shimmer are still not implemented.

3. **Button feedback regressed accessibility and semantics**
   - `IconButton` was replaced with a custom `GestureDetector` icon wrapper.
   - This drops built-in semantics, focus/keyboard behavior, hit-test sizing, and Material ripple consistency.
   - Haptic mapping is also mismatched (`onShake` + `onReveal` used for button press/release).

4. **Reduced-motion handling is partial**
   - Floating/breathing now stop when `accessibleNavigation` is on.
   - Other new animations (answer reveal chain, history stagger, empty-state loop, shimmer) still ignore reduced-motion.

5. **History navigation architecture issue**
   - Empty-state CTA pushes a new `HomeScreen(onToggleTheme: () {})` and clears the stack.
   - This bypasses `MagicApp` state ownership and can desync theme behavior.

6. **History list perf and behavior need hardening**
   - Every card rebuild creates a new animation chain. No one-time entry guard.
   - Delete flow removes data inside `confirmDismiss` before final dismiss confirmation animation ends.
   - No undo path yet, even though roadmap Phase 4.4 calls for one.

7. **Plan/code drift on answer window shape**
   - Roadmap Phase 1.4 asks for a triangle reveal window.
   - `AnswerRevealWidget` still renders answer content in a circular reveal surface.

### Roadmap updates

Add this as a new top priority block before current P0 items:

#### P0.1 Stabilization Pass (Completed 2026-05-05)

**Goal:** Fix interaction correctness, accessibility regressions, and architecture drift introduced during visual updates.

1. **Wire shake animation trigger end-to-end** ✅
   - Added `bool _isShaking` in `HomeScreen`.
   - Set true on shake start, false after AI response returns.
   - Passed `isShaking: _isShaking` into `MagicBallWidget`.
   - Acceptance: one full shake micro-animation fires per shake, including tap-to-shake path.

2. **Restore semantic buttons with animated feedback** ✅
   - Wrapped `IconButton` inside `AnimatedBuilder` + `Transform.scale` instead of replacing it.
   - Removed mismatched haptic calls from button press/release.
   - Acceptance: VoiceOver/TalkBack labels and keyboard activation work, press animation still visible.

3. **Fix home navigation from History empty state** ✅
   - Replaced `pushAndRemoveUntil(HomeScreen(...))` with `Navigator.pop(context)`.
   - Triggered haptic before navigation.
   - Acceptance: theme toggle and app state still flow from `MagicApp` without dummy callbacks.

4. **Add global reduced-motion policy** ✅
   - Created `MotionPolicy` utility (`lib/utils/motion_policy.dart`).
   - All animation durations/effects now route through that policy.
   - For reduced motion: stagger delays zero out, loops disabled, large transforms shortened.
   - Acceptance: no continuous animation remains when reduced motion is on.

5. **Align reveal surface with triangle design** ✅
   - Created `TriangleClipper` (`lib/utils/triangle_clipper.dart`).
   - `AnswerRevealWidget` now uses `ClipPath` with triangle clip.
   - Acceptance: answer reveal silhouette matches Magic 8-ball window.

#### P0.2 Verification Additions (pending)

- Add widget tests for:
  - shake animation trigger state transition in `HomeScreen`
  - reduced-motion mode disabling continuous loops
  - history CTA returning to existing home route
  - semantic button activation by keyboard

- Add manual QA steps:
  - test with iOS/Android accessibility reduced-motion enabled
  - test screen reader focus order on Home and History

### Priority matrix update

Insert row:

| Priority | Phase | Effort | Impact |
|----------|-------|--------|--------|
| P0.1 | Stabilization Pass (new) | Medium | Critical |

Then continue original matrix ordering.

---

*Last updated: 2026-05-05*
*Next review: After P0.2 verification*

---

## v2 Roadmap — Cosmic Bubblegum Expansion

### Where We Are

Cosmic Bubblegum redesign shipped. Palette, ball, answer card, voice input, shake CTA all in production. 25/25 tests pass.

---

### P0: Stabilization

| Task | Description |
|---|---|
| Update `AGENTS.md` | Refresh tech stack, dependencies, key rules. Remove deprecated `TriangleClipper` / `AnswerRevealWidget` references. |
| P0.2 Verification | Complete pending widget tests from stabilization pass. |
| iOS mic permissions | Add `NSMicrophoneUsageDescription` to `Info.plist` for `speech_to_text`. |

---

### P1: Sound & Haptic Ecosystem

Every interaction gets an auditory and tactile identity.

| Feature | Description |
|---|---|
| Reveal chime | Soft bell/chime when answer appears. Plays after haptic reveal. |
| Button clicks | Subtle tap sound on history/theme buttons. |
| Ambient background loop | Very quiet, slow atmospheric pad in idle state (optional toggle). |
| Haptic patterns | Different haptics for success (reveal) vs. neutral (fallback) vs. error (network). |
| Sound toggle | Mute switch in app bar. Persist with `shared_preferences`. |

**New files:** `lib/services/sound_manager.dart`

---

### P2: Favorites & Enhanced History

Give users a reason to revisit past readings.

| Feature | Description |
|---|---|
| Favorite a reading | Star icon on history cards. Toggles favorite state. |
| Favorites filter | Toggle in history app bar to show only favorites. |
| Search history | Text search across questions and answers. |
| Delete with undo | Swipe-to-delete with Snackbar undo. |

**New files:** `lib/widgets/favorite_button.dart`, updates to `HistoryService`

---

### P3: Daily Fortune & Streaks

Drive daily engagement.

| Feature | Description |
|---|---|
| Daily fortune | One free "fortune" per day with enhanced AI prompt ("What does today hold for me?"). |
| Streak counter | Consecutive days of asking. Visual flame indicator. |
| Streak reward | Every 7 days, a special golden answer card. |
| Notification reminder | Gentle local notification if user hasn't asked by evening (opt-in). |

**New files:** `lib/services/daily_fortune_service.dart`, `lib/services/notification_service.dart`

---

### P4: Question Categories

Guide the AI toward better, more contextual answers.

| Feature | Description |
|---|---|
| Category chips | Horizontal scroll of chips under input: General, Love, Career, Yes/No. |
| Category-aware prompts | Appends category context to AI prompt ("The user is asking about their career..."). |
| Category icon on answer card | Small icon in corner of answer card indicating category. |

---

### P5: Onboarding & First Launch

Convert downloads into engaged users.

| Feature | Description |
|---|---|
| Onboarding flow | 3-screen intro: "Ask a question", "Shake your phone", "Discover your fate". |
| First-launch demo | Pre-loaded first reading with a fun, guaranteed positive answer. |
| App icon polish | Custom launcher icon matching iridescent bubble. |
| Splash screen | Animated ball appearing from darkness. |

---

### P6: Share Reading as Image

Organic growth through social sharing.

| Feature | Description |
|---|---|
| Share button on answer card | Tap to generate styled image of the reading. |
| Styled card export | Beautiful graphic with ball, question, answer, and timestamp. Uses `flutter/rendering` to capture widget as PNG. |
| Share via system sheet | Uses `share_plus` package. |

---

### P7: Home Screen Widget

Passive engagement and daily reminder.

| Feature | Description |
|---|---|
| Daily fortune widget | Small widget showing today's fortune text. |
| Medium widget | Shows fortune + streak count. |
| Tap to open app | Deep link into daily fortune flow. |

**Platform:** iOS WidgetKit + Android App Widgets. High effort, low impact for single-player app.

---

### Priority Matrix

| Phase | Effort | Impact | Recommended Order |
|---|---|---|---|
| P0 Stabilization | Low | Critical | Immediate |
| P1 Sound & Haptic | Medium | High | 1st |
| P2 Favorites & History | Medium | High | 2nd |
| P3 Daily Fortune | Medium | High | 3rd |
| P4 Categories | Low | Medium | 4th |
| P5 Onboarding | Medium | Medium | 5th |
| P6 Share Image | Medium | Medium | 6th |
| P7 Widget | High | Low | Deferred |

---

## v3 Roadmap — Level Up Pass

### Intent

The next three phases turn the app from a polished utility into a small magical game. The work starts with another visual polish pass, then upgrades sound/game feel, then gives the AI a stronger oracle identity.

### Phase Order

| Phase | Focus | Goal |
|---|---|---|
| P8 | Cinematic Polish Pass | Make the home screen, reveal flow, history, and streak states feel crafted and alive. |
| P9 | Soundscape & Game Feel | Give every meaningful action a sound and haptic identity. |
| P10 | Living Oracle AI | Make AI answers feel contextual, voiced, and character-driven. |

---

### P8: Cinematic Polish Pass

**Goal:** Improve the app's visual appeal without changing the core interaction model.

| Feature | Description |
|---|---|
| Dynamic background scenes | Shift background treatment by state: idle, listening, thinking, revealed. |
| Category-tinted visuals | Use rose for Love, gold/teal for Career, sunrise tones for Daily, and coral/teal for General. |
| Particle layer | Add drifting sparkles, bubbles, and star flecks around the orb. Respect reduced motion. |
| Reveal choreography | Sequence the reveal as orb pulse, particle burst, answer card slide, then glow settle. |
| Layout hierarchy pass | Reduce crowding around input, category chips, streak, daily fortune, answer card, and share button. |
| Golden streak card | Give 7-day streak rewards a real golden card treatment with glow and fanfare-ready hooks. |
| History polish | Improve empty, favorites-only, and no-search-result states with better visual treatment. |

**Acceptance:**

- Home screen looks alive in idle state.
- Thinking and revealed states look distinct.
- Small screens do not overflow.
- Reduced motion disables particles and looping motion.

---

### P9: Soundscape & Game Feel

**Goal:** Make the app feel tactile, musical, and toy-like.

| Feature | Description |
|---|---|
| Curated sound pack | Replace generated placeholder sounds with tap, shake, shimmer, reveal, streak, and error sounds. |
| SoundManager | Centralize volume, mute, sound categories, one-shots, loops, and failure handling. |
| Ambient state loops | Idle gets an airy pad, thinking gets shimmer pulses, revealed gets a short sparkle tail. |
| Tilt-reactive audio | Pan or soften selected sounds based on gyroscope data. |
| Haptic sequencer | Define named patterns for shake, reveal, favorite, error, streak, and share. |
| Settings panel | Add controls for sound, haptics, voice input, and reduced-motion shortcuts. |

**Acceptance:**

- Mute applies everywhere.
- Audio failures never block the answer flow.
- Major actions feel different by sound and haptic feedback.
- Looping sounds start and stop cleanly on state changes.

---

### P10: Living Oracle AI

**Goal:** Make the AI feel like a character with tone, context, and memory.

| Feature | Description |
|---|---|
| Oracle personas | Add Spark, Luna, and Oracle Pro answer styles. |
| Category prompt templates | Give each category its own style rules, length target, and fallback set. |
| Follow-up prompt | After an answer, offer one tap action such as "Ask a follow-up" or "Give me a sign". |
| Local context memory | Feed recent questions, favorites, streak, category, and persona into prompts without storing secrets. |
| Answer quality guardrails | Limit length, avoid recent repeats, and remove generic filler. |
| Category-aware fallback | Replace one generic fallback list with category-specific offline answers. |

**Acceptance:**

- Same question can feel different by persona and category.
- Answers fit the card.
- Offline fallback matches the selected category.
- No API keys, prompts, or private user data are logged.

---

### v3 Priority Matrix

| Phase | Effort | Impact | Recommended Order |
|---|---|---|---|
| P8 Cinematic Polish | Medium | High | 1st |
| P9 Soundscape & Game Feel | Medium | High | 2nd |
| P10 Living Oracle AI | High | High | 3rd |

---

### Status

v2 phases P0-P7 are implemented and committed to `main`. P8 is implemented and ready to commit. P9 spec is drafted. P10 is approved for planning.

#### P8 Implementation Status (2026-05-12)

**Completed:**
- Dynamic background scenes with state-driven color transitions
- Category tint overlays on reveal
- Particle layer with sparkle, bubble, and star fleck types
- Orb pulse animation on reveal (spring curve, 400ms)
- Answer card choreography (slide, fade, scale, category icon)
- Golden streak card for 7-day rewards
- History screen empty states (no readings, favorites-only, no search results)
- Layout hierarchy pass with proper spacing
- Small screen adaptation (orb scales to 0.85 on <600dp)
- Reduced motion policy for all P8 features

**Test Coverage:**
- All 36 widget and service tests pass
- P0.2 verification tests confirm semantic buttons, reduced motion, state transitions

**Files Created:**
- `lib/constants/scene_colors.dart`
- `lib/widgets/dynamic_background.dart`
- `lib/widgets/particle_layer.dart`

**Files Modified:**
- `lib/screens/home_screen.dart` — state system, layout zones, background wiring
- `lib/screens/history_screen.dart` — empty states, search, favorites filter
- `lib/widgets/magic_ball_widget.dart` — reveal pulse animation, small screen scaling
- `lib/widgets/answer_card_widget.dart` — reveal choreography, golden variant, category icon
- `lib/utils/motion_policy.dart` — particle policy, reduced duration helpers

**Pending:**
- P9 implementation (SoundManager, haptic patterns, settings panel)
- P10 planning (oracle personas, category templates, context memory)

---

*Last updated: 2026-05-12*
*Next review: After P9 implementation*
