# Cosmic Bubblegum Redesign — Design Spec

## Overview

A complete visual and interaction overhaul of the Magic 8-Ball app, moving from a dark/mysterious purple aesthetic to a playful, youthful "Cosmic Bubblegum" style. The ball is reimagined as an iridescent bubble. Text answers move from a cramped triangle cutout to a dedicated answer card. Voice input is added for a "Hey Siri"-style hands-free questioning flow.

## Goals

- Make the app feel joyful, approachable, and visually distinctive.
- Solve the readability problem for long AI-generated answers.
- Add voice input as a first-class interaction path.
- Maintain the core "shake to reveal" mechanic as the primary gesture.

## Non-Goals

- Do not change the AI service API or fallback logic.
- Do not add social sharing, user accounts, or custom themes.
- Do not support multiple languages in this redesign phase.

---

## Color Palette

### Backgrounds

| Mode | Color | Hex | Usage |
|---|---|---|---|
| Light | Warm cream | `#FAF7F2` | Scaffold background |
| Dark | Soft charcoal | `#1A1A23` | Scaffold background |

### Accents (shared across both modes)

| Name | Hex | Usage |
|---|---|---|
| Coral | `#FF6B6B` | Primary actions, active mic, shake CTA border |
| Teal | `#4ECDC4` | Secondary accents, mic button idle, hints |
| Butter yellow | `#FFE66D` | Highlights, sparkle icons, small joyful moments |
| Soft lavender | `#C9B1FF` | Tertiary glow, iridescent ball gradients |

### Surfaces

| Mode | Surface Color | Usage |
|---|---|---|
| Light | `Colors.white` | Cards, input fields |
| Dark | `Color(0xFF252530)` | Cards, input fields |

### Text

| Mode | Primary Text | Secondary Text |
|---|---|---|
| Light | `Color(0xFF1A1A23)` | `Color(0xFF6B6B7B)` |
| Dark | `Color(0xFFFAF7F2)` | `Color(0xFF8A8A9A)` |

---

## Typography

| Role | Font | Weight | Size | Usage |
|---|---|---|---|---|
| Headlines | `Nunito` | 700 | 28 | App bar title, empty states |
| Answer text | `Inter` | 500 | 18 | AI and fallback answers |
| Body / hints | `Inter` | 400 | 14 | Helper text, hints |
| Ball "8" | `Nunito` | 900 | 48 | Centered on idle ball |

All text uses `letterSpacing: 0.5` for headlines, `0.3` for body.

---

## The Ball — "Iridescent Bubble"

### Visual Form

- Perfect sphere, 300px diameter. No triangle cutout.
- Surface is a multi-stop radial gradient that slowly rotates (10s cycle).
- The gradient stops shift between coral, teal, lavender, and butter yellow.
- A strong white specular highlight at top-left (`Alignment(-0.35, -0.35)`).
- A faint inner shadow at bottom-right for 3D depth.
- Outer glow pulses gently, color matching the dominant surface hue.

### States

| State | Visual |
|---|---|
| Idle | Shows bold white "8" with drop shadow. Gentle float + breathe. Gradient rotates slowly. |
| Thinking | "8" fades out. Rotating sparkle icon (✨) appears. Wobble animation intensifies. Gradient rotation speeds up slightly. |
| Revealed | Single bright pulse. Glow shifts to coral/teal. Ball settles into gentle breathing while answer card appears below. |

### Animations

- **Float:** `Transform.translate` oscillating ±4px over 4s.
- **Breathe:** Scale 1.0→1.02 over 3s.
- **Shake:** Scale + rotation wobble on physical shake (existing).
- **Gradient rotation:** Gradient angle shifts 0→360deg over 10s (continuous).
- **Glow pulse:** Opacity 0.3→0.6 over 4s, reverse.

---

## Answer Reveal Card

### Placement

- Slides up from below the ball, centered horizontally.
- Top edge sits 24px below the ball's bottom.
- Max width 320px, min height 80px, max height 200px (scrollable if exceeded).

### Visual Style

- Frosted glass appearance: `BackdropFilter` with `ImageFilter.blur(sigmaX: 12, sigmaY: 12)`.
- Background: surface color at 70% opacity.
- Border: 1px solid with primary color at 15% opacity.
- Border radius: 24px.
- Padding: 24px horizontal, 20px vertical.
- Soft drop shadow: primary color at 10% opacity, blur 20px.

### Animation

- **Enter:** Slide up from 40px below + fade in, 400ms, `Curves.easeOutBack`.
- **Text reveal:** Blur(0,5)→0, fade in, scale 0.95→1.0, staggered 150ms after card enter.
- **Exit:** Slide down + fade out, 250ms, `Curves.easeIn`.

---

## Audio Input ("Hey Siri" Style)

### Trigger

- **Mic button** inside the question input field, right side.
- Circular, 40px diameter.
- Idle: teal icon on transparent background.
- Active: coral icon with pulsing background glow.

### Listening State

- Input field expands height slightly (56→64px).
- Shows **pulsing waveform** — 4-5 vertical bars bouncing to simulated audio levels.
- Hint text: "Listening..." in secondary text color.
- Auto-stops after 1.5s of silence.

### Post-Recording Flow

1. Transcribed text populates the input field.
2. 300ms delay so the user sees their question.
3. **Auto-triggers `_onShake()`** — ball animates, thinking state begins.
4. Answer card reveals as normal.

### Edge Cases

- If transcription fails or is empty, show "Didn't catch that — try again?" toast for 2s.
- If microphone permission is denied, show a one-time dialog explaining the feature needs mic access.

---

## Shake Now CTA

### Visibility

- Only shown in `idle` state.
- Hidden during `thinking` and `revealed`.

### Visual Style

- Pill shape, border radius 30px.
- **Gradient border:** coral-to-teal, 2px, achieved via `ShaderMask` or nested `Container`.
- **Background:** semi-transparent surface color with `BackdropFilter` blur.
- Padding: 12px vertical, 24px horizontal.
- Icon: `Icons.vibration_rounded`, 20px, coral.
- Text: "Shake Now", `Inter` 600, 16px, primary text color.

### Animation

- Gentle side-to-side wobble (±3deg, 2s cycle) to suggest motion.
- Scale 0.95→1.0 on tap with `Curves.easeOutBack`.

---

## Background & Ambient Effects

### Pulsing Background

- Radial gradient centered at `(0, 0.15)`.
- Inner color: primary at low opacity (0.05→0.1 pulse).
- Outer color: scaffold background.
- In light mode, the glow is softer and warmer. In dark mode, slightly more saturated.

### Gyroscope Shimmer (TiltGradientWidget)

- White/cream iridescent sheen instead of purple.
- Colors: `Colors.white.withValues(alpha: 0.2)` → transparent → `Colors.white.withValues(alpha: 0.05)`.
- Same gyroscope-driven angle mapping as before.

---

## Question Input

### Refined Style

- Background: surface color at 80% opacity.
- Border: 1.2px, primary at 20% opacity (40% when focused).
- Border radius: 26px.
- Height: 56px normally, 64px when recording.
- Hint: "Ask anything..." (idle), "Listening..." (recording).
- Mic button nested inside, right-aligned.

---

## Home Screen Layout (Idle State)

```
[App Bar]          "Magic 8 Ball" (Nunito 700)  [History] [Theme Toggle]
[Question Input]   "Ask anything..."  [🎤]
[Spacer]
[Ball]             Iridescent bubble with "8"
[Shake Now CTA]    Gradient-border pill
[Bottom Hint]      "Or shake your phone" (small, secondary)
[Bottom Fade]
```

### Revealed State

```
[App Bar]
[Question Input]   (read-only, shows asked question)
[Spacer]
[Ball]             Pulsing gently
[Answer Card]      Frosted glass, multi-line text
[Bottom Hint]      "Tap to ask again" (small)
```

---

## Interaction States Summary

| State | Ball | Input | CTA | Card | Audio |
|---|---|---|---|---|---|
| Idle | Float, breathe, "8" | Active, hint | Visible | Hidden | Ready |
| Thinking | Wobble, sparkle | Disabled | Hidden | Hidden | Disabled |
| Revealed | Gentle pulse glow | Read-only | Hidden | Visible | Disabled |

---

## Accessibility

- All animations respect `MediaQuery.accessibleNavigation` (reduce motion).
- Voice input has a visible alternative (type + shake or tap CTA).
- Answer card text supports dynamic type scaling.
- Sufficient contrast ratios: all text meets WCAG AA on both backgrounds.

---

## Files to Modify / Create

### Modify
- `lib/constants/app_theme.dart` — new colors, fonts, text theme.
- `lib/screens/home_screen.dart` — add mic button, auto-shake flow, CTA visibility, answer card integration.
- `lib/widgets/magic_ball_widget.dart` — iridescent gradient, no triangle, sparkle icon, state visuals.
- `lib/widgets/answer_reveal_widget.dart` — refactor to answer card below ball.
- `lib/widgets/pulsing_background.dart` — warm glow colors.
- `lib/widgets/tilt_gradient_widget.dart` — white iridescent sheen.

### Create
- `lib/widgets/voice_input_button.dart` — mic button with waveform animation.
- `lib/widgets/answer_card_widget.dart` — frosted glass answer card.
- `lib/widgets/shake_now_cta.dart` — gradient-border pill button.
- `lib/services/speech_service.dart` — speech-to-text wrapper.

---

## Dependencies

- `speech_to_text` — for voice input.
- `google_fonts` — already present, ensure `Nunito` and `Inter` are loaded.

---

## Open Questions

None. All sections approved by user.
