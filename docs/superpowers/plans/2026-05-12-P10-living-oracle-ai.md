# P10 Implementation Plan — Living Oracle AI

## Goal

Transform the AI from a generic fortune generator into a character-driven oracle with personality, memory, and contextual awareness.

## Phase Order

1. Foundation (oracle personas, category-aware prompts)
2. Category-specific fallback answers
3. Answer quality guardrails
4. Local context memory
5. Follow-up prompt suggestions
6. Integration and verification

---

## Task 1: Oracle Personas

### 1.1 Create `lib/models/oracle_persona.dart`

**Spec:** Define three distinct oracle personalities with unique system prompts and answer characteristics.

```dart
enum OraclePersona {
  spark(
    name: 'Spark',
    description: 'Playful and energetic',
    style: 'Short, punchy answers with optimistic energy. Uses exclamation points and present tense.',
    lengthTarget: 6, // words
  ),
  luna(
    name: 'Luna',
    description: 'Mystical and enigmatic',
    style: 'Cryptic, poetic answers with celestial imagery. Uses metaphors and future tense.',
    lengthTarget: 8,
  ),
  oraclePro(
    name: 'Oracle Pro',
    description: 'Wise and thoughtful',
    style: 'Balanced, nuanced answers that acknowledge complexity. Uses measured language.',
    lengthTarget: 10,
  );

  final String name;
  final String description;
  final String style;
  final int lengthTarget;

  const OraclePersona({
    required this.name,
    required this.description,
    required this.style,
    required this.lengthTarget,
  });
}
```

**Acceptance:**
- All three personas compile
- Each has distinct style guidance
- Used by `AiService` for prompt construction

### 1.2 Create `lib/services/oracle_context_service.dart`

**Spec:** Manage persona selection and persistence.

```dart
class OracleContextService {
  OraclePersona _currentPersona = OraclePersona.spark;
  final List<String> _recentQuestions = [];
  final List<String> _recentAnswers = [];
  final Set<String> _favoriteThemes = {};

  OraclePersona get currentPersona => _currentPersona;

  Future<void> setPersona(OraclePersona persona);
  void recordExchange(String question, String answer);
  List<String> get recentQuestions => List.unmodifiable(_recentQuestions);
  List<String> get recentAnswers => List.unmodifiable(_recentAnswers);
  
  void addFavoriteTheme(String theme);
  Set<String> get favoriteThemes => Set.unmodifiable(_favoriteThemes);
}
```

**Acceptance:**
- Persona persists via `shared_preferences`
- Recent questions/answers capped at 10 entries
- Thread-safe for concurrent access

---

## Task 2: Category Prompt Templates

### 2.1 Create `lib/constants/category_prompts.dart`

**Spec:** Define prompt templates for each category with style rules.

```dart
class CategoryPromptTemplates {
  static const Map<QuestionCategory, CategoryPromptConfig> templates = {
    QuestionCategory.general: CategoryPromptConfig(
      style: 'General fortune',
      lengthTarget: 8,
      tone: 'Neutral but helpful',
      fallbackSet: kGeneralFallbacks,
    ),
    QuestionCategory.love: CategoryPromptConfig(
      style: 'Love and relationships',
      lengthTarget: 8,
      tone: 'Warm, empathetic, romantic',
      fallbackSet: kLoveFallbacks,
    ),
    QuestionCategory.career: CategoryPromptConfig(
      style: 'Career and work',
      lengthTarget: 8,
      tone: 'Professional, encouraging, practical',
      fallbackSet: kCareerFallbacks,
    ),
    QuestionCategory.yesNo: CategoryPromptConfig(
      style: 'Yes/No question',
      lengthTarget: 4,
      tone: 'Direct, clear',
      fallbackSet: kYesNoFallbacks,
    ),
    QuestionCategory.daily: CategoryPromptConfig(
      style: 'Daily fortune',
      lengthTarget: 8,
      tone: 'Optimistic, actionable',
      fallbackSet: kDailyFallbacks,
    ),
  };
}

class CategoryPromptConfig {
  final String style;
  final int lengthTarget;
  final String tone;
  final List<String> fallbackSet;

  const CategoryPromptConfig({
    required this.style,
    required this.lengthTarget,
    required this.tone,
    required this.fallbackSet,
  });
}
```

**Acceptance:**
- Each category has distinct tone and style
- Fallback sets are category-appropriate
- Used by `AiService` for prompt construction

### 2.2 Create category-specific fallback lists

**Spec:** Replace single `kClassicAnswers` with category-specific fallback sets.

```dart
// lib/constants/category_fallbacks.dart

const List<String> kGeneralFallbacks = [
  'The stars align in your favor',
  'Trust your intuition',
  'Patience brings clarity',
  'Your path is clear',
  'Embrace the unknown',
];

const List<String> kLoveFallbacks = [
  'Love surrounds you',
  'Open your heart',
  'Connection is near',
  'Trust in love',
  'Romance blooms soon',
];

const List<String> kCareerFallbacks = [
  'Success approaches',
  'Your skills shine',
  'Opportunity knocks',
  'Hard work pays off',
  'New horizons await',
];

const List<String> kYesNoFallbacks = [
  'Yes',
  'No',
  'Maybe',
  'Signs point to yes',
  'Unclear, ask again',
];

const List<String> kDailyFallbacks = [
  'Today brings surprises',
  'Stay open to change',
  'Good energy flows',
  'Embrace the moment',
  'Your day looks bright',
];
```

**Acceptance:**
- Each list has 15-20 answers
- Answers match category tone
- No duplicates across categories

---

## Task 3: Answer Quality Guardrails

### 3.1 Update `lib/services/ai_service.dart`

**Spec:** Add post-processing to enforce answer quality.

```dart
class AiService {
  // ... existing code ...

  String _postProcess(String answer, {
    required QuestionCategory category,
    required OraclePersona persona,
  }) {
    // 1. Trim to max length
    final maxWords = persona.lengthTarget + 2;
    final words = answer.split(' ');
    if (words.length > maxWords) {
      answer = words.take(maxWords).join(' ');
    }

    // 2. Remove common filler phrases
    answer = answer
        .replaceAll(RegExp(r'^(I think|I believe|Perhaps|Maybe),?\s*'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // 3. Remove punctuation (per Magic 8-Ball style)
    answer = answer.replaceAll(RegExp(r'[.,!?;:]'), '');

    // 4. Check for recent repeats
    if (_recentAnswers.contains(answer.toLowerCase())) {
      return _fallbackForCategory(category);
    }

    return answer;
  }

  bool _isRecent(String answer) {
    return _recentAnswers.any(
      (recent) => recent.toLowerCase() == answer.toLowerCase(),
    );
  }
}
```

**Acceptance:**
- Answers never exceed persona length + 2 words
- No punctuation in final answers
- Recent repeats trigger fallback
- Filler phrases removed

### 3.2 Add recent answer tracking

**Spec:** Track last 10 answers to avoid repeats.

```dart
final List<String> _recentAnswers = [];

void _recordAnswer(String answer) {
  _recentAnswers.add(answer.toLowerCase());
  if (_recentAnswers.length > 10) {
    _recentAnswers.removeAt(0);
  }
}
```

**Acceptance:**
- Circular buffer of 10 answers
- Case-insensitive comparison
- Persists across app sessions (optional)

---

## Task 4: Local Context Memory

### 4.1 Enhance `OracleContextService`

**Spec:** Build context object for prompt enrichment.

```dart
class OracleContextService {
  // ... existing code ...

  String buildContextForPrompt() {
    final buffer = StringBuffer();

    // Add recent exchange summary
    if (_recentQuestions.isNotEmpty) {
      buffer.write('Recent exchanges: ');
      for (var i = 0; i < _recentQuestions.length; i++) {
        buffer.write('Q: "${_recentQuestions[i]}" → A: "${_recentAnswers[i]}". ');
      }
    }

    // Add favorite themes
    if (_favoriteThemes.isNotEmpty) {
      buffer.write('User interests: ${_favoriteThemes.join(", ")}. ');
    }

    // Add streak info
    final streak = _getStreak(); // from DailyFortuneService
    if (streak >= 7) {
      buffer.write('User is on a $streak-day streak. ');
    }

    return buffer.toString();
  }
}
```

**Acceptance:**
- Context string < 500 characters
- Includes recent exchanges, favorites, streak
- Used in system prompt

### 4.2 Update AI prompt construction

**Spec:** Inject context into system prompt.

```dart
Future<String> getAnswer({
  required String question,
  QuestionCategory? category,
  OraclePersona? persona,
}) async {
  final personaConfig = persona ?? OraclePersona.spark;
  final categoryConfig = CategoryPromptTemplates.templates[category ?? QuestionCategory.general]!;
  final context = _oracleContextService.buildContextForPrompt();

  final systemPrompt = '''
You are ${personaConfig.name}, a ${personaConfig.description} Magic 8-Ball oracle.
Style: ${personaConfig.style}
Tone: ${categoryConfig.tone}
Category: ${categoryConfig.style}
$context

Rules:
- Answer in ${personaConfig.lengthTarget} words max
- No punctuation
- No explanations
- Be cryptic but helpful
''';

  final prompt = '$systemPrompt\n\nUser: $question';
  // ... rest of API call ...
}
```

**Acceptance:**
- System prompt includes persona, category, context
- Prompt < 1000 characters total
- No secrets/keys logged

---

## Task 5: Follow-up Prompt Suggestions

### 5.1 Create `lib/widgets/follow_up_suggestions.dart`

**Spec:** Show 2-3 suggested follow-up questions after answer reveal.

```dart
class FollowUpSuggestions extends StatelessWidget {
  final QuestionCategory category;
  final ValueChanged<String> onSuggestionTap;

  const FollowUpSuggestions({
    required this.category,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = _getSuggestionsForCategory(category);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((suggestion) =>
        ChoiceChip(
          label: Text(suggestion),
          onSelected: (_) => onSuggestionTap(suggestion),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      ).toList(),
    );
  }

  List<String> _getSuggestionsForCategory(QuestionCategory category) {
    switch (category) {
      case QuestionCategory.general:
        return ['What should I focus on?', 'Give me a sign', 'What\'s coming next?'];
      case QuestionCategory.love:
        return ['Will I find love?', 'Is my relationship strong?', 'What should I know?'];
      case QuestionCategory.career:
        return ['Should I change jobs?', 'Will I succeed?', 'What\'s my next step?'];
      case QuestionCategory.yesNo:
        return ['Ask why', 'What if?', 'Give me more detail'];
      case QuestionCategory.daily:
        return ['What\'s special about today?', 'Any challenges?', 'Best moment of the day?'];
    }
  }
}
```

**Acceptance:**
- Shows 2-3 chips after answer reveal
- Tapping auto-fills question and triggers shake
- Dismisses on next shake

### 5.2 Wire into HomeScreen

**Spec:** Show suggestions below answer card in revealed state.

```dart
if (isRevealed)
  FollowUpSuggestions(
    category: _selectedCategory,
    onSuggestionTap: (suggestion) {
      _questionController.text = suggestion;
      _onShake();
    },
  ),
```

**Acceptance:**
- Appears only in revealed state
- Auto-triggers shake on tap
- Respects reduced motion

---

## Task 6: Integration and Verification

### 6.1 Run static analysis

```bash
flutter analyze
```

**Acceptance:** No errors or warnings.

### 6.2 Run tests

```bash
flutter test
```

**Acceptance:** All existing tests pass. New behavior tested.

### 6.3 Manual QA checklist

- [ ] Each persona produces distinct answer styles
- [ ] Category prompts feel appropriate (love vs career)
- [ ] Fallback answers match category
- [ ] No answer exceeds max word count
- [ ] No punctuation in answers
- [ ] Recent repeats trigger fallback
- [ ] Context appears in prompts (check via debug logging)
- [ ] Follow-up suggestions appear and work
- [ ] No API keys or prompts logged

---

## Files to Create

### New Files
- `lib/models/oracle_persona.dart` — persona enum with metadata
- `lib/services/oracle_context_service.dart` — persona + context management
- `lib/constants/category_prompts.dart` — category prompt templates
- `lib/constants/category_fallbacks.dart` — category-specific fallback answers
- `lib/widgets/follow_up_suggestions.dart` — follow-up question chips

### Modified Files
- `lib/services/ai_service.dart` — persona support, guardrails, context
- `lib/screens/home_screen.dart` — persona selector, follow-up suggestions
- `lib/models/question_category.dart` — add prompt template reference

---

## Acceptance Criteria

- [ ] Three personas (Spark, Luna, Oracle Pro) produce distinct answer styles
- [ ] Each category has appropriate tone and fallback answers
- [ ] Answers never exceed max word count (persona + 2)
- [ ] No punctuation in final answers
- [ ] Recent repeats (last 10) trigger fallback
- [ ] Context includes recent exchanges, favorites, streak
- [ ] Follow-up suggestions appear after reveal
- [ ] No secrets, API keys, or prompts logged
- [ ] All 37+ existing tests still pass

---

## Rollback Plan

If any task introduces regressions:
1. Revert persona/context changes in `AiService`
2. Restore classic fallback answers
3. Remove follow-up suggestions widget
4. Re-run `flutter test` to confirm baseline

---

*Approved for execution.*
