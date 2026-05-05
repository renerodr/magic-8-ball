# AGENTS.md

This file provides guidance to LLM Coding Agents when working with code in this repository. Humans can refer to https://claudemd.io/ for other rules

## Project

AI-powered Magic 8-Ball Flutter app. Users shake the phone; the app calls OpenRouter to generate a mystical answer. Falls back to 20 classic responses on network/API failure. Supports dark (Magic 8-Ball) and light (Crystal Ball) themes with shake detection, haptic feedback, spatial audio, gyroscope shimmer, and a History screen.

Implementation plan: `docs/superpowers/plans/2026-05-04-magic-8-ball.md`

@ARCHITECTURE.md

## Tech Stack

- Flutter (Dart) — no native Swift/Kotlin touches needed
- `sensors_plus` — accelerometer (shake) + gyroscope (tilt shimmer)
- `audioplayers` — water slosh sound on shake
- `shared_preferences` — history persistence
- `http` — OpenRouter API calls
- `flutter_animate` — shimmer "thinking" animation
- `mocktail` — test mocking

## Development Commands

```bash
# Install dependencies
flutter pub get

# Run on connected device/simulator (API key via dart-define)
flutter run --dart-define=OPENROUTER_KEY=<your_key>

# Run all tests
flutter test

# Run a single test file
flutter test test/services/ai_service_test.dart

# Static analysis
flutter analyze

# Build release APK
flutter build apk --dart-define=OPENROUTER_KEY=<your_key>
```

## Key Rules for This Project

- **API key:** Never hardcode in source. Always use `--dart-define=OPENROUTER_KEY=...` at run/build time. Read via `String.fromEnvironment('OPENROUTER_KEY')`.
- **Shake threshold:** Default 15 m/s² with 500 ms debounce in `ShakeService`. Adjust `_threshold` if needed; do not change debounce without a good reason.
- **Fallback first:** `AiService` must always return a string — catch all exceptions and return a random classic answer. Never let a network error surface to the UI.
- **State machine:** HomeScreen has three states — `idle`, `thinking`, `revealed`. No state transition is allowed while `thinking`.
- **Sound asset:** `assets/sounds/water_slosh.mp3` must exist before running. If missing, `SoundService.playSlosh()` will throw.
- **Theme:** Dark = Magic 8-Ball (obsidian + indigo). Light = Crystal Ball (white + deep purple). Both defined in `lib/constants/app_theme.dart`.

## Code Style & Quality

- Always prioritize readable code over brevity.
- IMPORTANT: Always match existing code patterns and conventions.
- Always use early returns to reduce nesting.
- Never add comments that restate what code does; only explain non-obvious intent.
- Never abstract prematurely or over-engineer.
- Always use consistent naming conventions throughout.
- Always keep functions small and focused on one task.
- Always prefer explicit code over implicit magic.
- Always minimize token output; avoid repeating unchanged code in responses.
- Always prefer spaces for indentation.
- Always end text files with a trailing newline.
- Always place new files in locations consistent with the existing project structure.

## Problem Solving & Debugging

- Always fix the root cause; never use workarounds.
- Never apply a fix you cannot explain; understand why it works.
- Always fail fast with descriptive, context-rich error messages.
- Always verify changes work as expected before moving on.
- Always checkpoint state before making destructive changes.

## Testing

- Never disable tests to make them pass; fix the underlying issue.
- Always test edge cases and error conditions.
- Always run tests before committing changes.
- Always verify a new test fails before making it pass.

## Planning & Communication

- Drop filler (just, really, basically, actually).
- Drop pleasantries (sure, certainly, happy to).
- No hedging. Short synonyms.
- Technical terms stay exact. Code blocks unchanged.

- Always ask clarifying questions when requirements are ambiguous.
- Always include a recommended answer when asking questions.
- Always wait for confirmation before implementing significant changes.
- Always suggest creating a specification file when planning new projects.
- Always explain your reasoning before making changes.
- Always think through problems step by step, explaining each step before proceeding.

## Documentation

- Always invoke the stop-slop skill before updating README.md or documentation files.
- Always document why important design decisions are made.
- Always update documentation when changing related code.

## Tooling & Environment

- Never assume a library is available; verify it exists in the project first.

## Security & Safety

- Never introduce code that exposes or logs secrets and keys.
- Never commit secrets, API keys, or credentials to the repository.
- Always validate user input at system boundaries.

## Performance

- Never optimize prematurely; wait until performance is a demonstrated problem.
- Always use profiling data to guide optimization; never guess at bottlenecks.
- Always prefer lazy loading for expensive resources.
- Always cache results of expensive computations when appropriate.

## Learning & Integration

- Always follow established patterns in the codebase.

# Tool usage in VS Code workspace

Operate strictly within current VS Code workspace. Never shell out for operations that have native equivalents.

## Forbidden shell commands

- `grep`, `rg`, `ack` → use workspace search / Grep tool / ripgrep tool
- `find`, `ls`, `tree` → use Glob tool / workspace.findFiles
- `cat`, `head`, `tail`, `less` → use Read tool / workspace.fs.readFile
- `sed`, `awk` for in-file edits → use Edit / str_replace tools
- `echo >`, `tee` for writes → use Write / create_file tools
- `pwd`, `cd` → working directory is workspace root, stop checking

## When shell is allowed

- Build/test/lint commands (cargo, npm test, pytest, godot --headless)
- Git operations (status, diff, log, commit)
- Package installs requested by user
- Process inspection (ps, lsof) when debugging
- Anything with no tool equivalent

## Rules

- Never ask permission for read operations inside workspace root
- Never cat a file you could Read
- Never grep a tree you could search via native tool
- Batch file reads in parallel tool calls, not `cat a b c`
- If you reach for bash on a file op, stop. Wrong tool.
