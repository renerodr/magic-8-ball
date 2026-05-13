# P10 Design Doc — Living Oracle AI

## Overview

This document turns the P10 roadmap items into concrete, buildable specifications. The goal is to make the AI feel like a character with tone, context, and memory—transforming it from a generic fortune generator into a mystical oracle users want to return to.

---

## Design Principles

- **Character over chatbot.** Each persona should feel like a distinct personality, not just a prompt variation.
- **Context without creepiness.** Use recent history to enrich answers, but never store secrets or private data.
- **Fallback fidelity.** Offline answers should match the category and tone of AI answers.
- **Brevity is mystique.** Short answers feel more oracle-like. Long answers feel like AI rambling.

---

## 1. Oracle Personas

### Why

Users form relationships with characters, not algorithms. Three distinct personas give users agency over their oracle experience.

### Persona Definitions

| Persona | Name | Vibe | Style | Length |
|---------|------|------|-------|--------|
| **Spark** | 🔮 Spark | Playful, energetic | Punchy, optimistic, present tense | 6 words |
| **Luna** | 🌙 Luna | Mystical, enigmatic | Poetic, celestial metaphors, future tense | 8 words |
| **Oracle Pro** | ⚖️ Oracle Pro | Wise, thoughtful | Nuanced, acknowledges complexity | 10 words |

### System Prompt Examples

**Spark:**
```
You are Spark, a playful and energetic Magic 8-Ball oracle.
Style: Short, punchy answers with optimistic energy. Uses exclamation points and present tense.
Tone: Warm and encouraging
Category: Love and relationships

Rules:
- Answer in 6 words max
- No punctuation
- No explanations
- Be cryptic but helpful

User: Will I find love soon?
```

**Luna:**
```
You are Luna, a mystical and enigmatic oracle.
Style: Cryptic, poetic answers with celestial imagery. Uses metaphors and future tense.
Tone: Mysterious, ethereal
Category: Career and work

Rules:
- Answer in 8 words max
- No punctuation
- No explanations
- Speak in metaphors and riddles

User: Should I take the new job?
```

**Oracle Pro:**
```
You are Oracle Pro, a wise and thoughtful advisor.
Style: Balanced, nuanced answers that acknowledge complexity. Uses measured language.
Tone: Professional, grounded, insightful
Category: General fortune

Rules:
- Answer in 10 words max
- No punctuation
- No explanations
- Acknowledge nuance when appropriate

User: What does the future hold?
```

### Persistence

- Selected persona stored in `shared_preferences` under `oracle_persona`
- Defaults to Spark on first launch
- Persists across app sessions

---

## 2. Category Prompt Templates

### Why

A love question deserves a different tone than a career question. Category templates ensure appropriate responses.

### Template Structure

```dart
class CategoryPromptConfig {
  final String style;        // "Love and relationships"
  final int lengthTarget;    // 8 words
  final String tone;         // "Warm, empathetic, romantic"
  final List<String> fallbackSet;  // 20 category-specific answers
}
```

### Category Configurations

| Category | Style | Length | Tone | Example Fallback |
|----------|-------|--------|------|------------------|
| General | General fortune | 8 | Neutral but helpful | "The stars align in your favor" |
| Love | Love and relationships | 8 | Warm, empathetic, romantic | "Love surrounds you" |
| Career | Career and work | 8 | Professional, encouraging | "Success approaches" |
| Yes/No | Yes/No question | 4 | Direct, clear | "Yes" |
| Daily | Daily fortune | 8 | Optimistic, actionable | "Today brings surprises" |

### Fallback Answer Requirements

Each category needs 20 fallback answers that:
- Match the category tone
- Are 4-10 words each
- Have no punctuation
- Feel mystical but actionable
- Avoid generic filler ("Reply hazy")

---

## 3. Answer Quality Guardrails

### Why

AI models tend to ramble, add punctuation, or repeat themselves. Guardrails enforce Magic 8-Ball style.

### Post-Processing Pipeline

```
Raw AI Answer
    ↓
1. Trim to max words (persona + 2)
    ↓
2. Remove filler phrases ("I think", "Perhaps")
    ↓
3. Remove all punctuation
    ↓
4. Normalize whitespace
    ↓
5. Check for recent repeats (last 10)
    ↓
6. If repeat → use category fallback
    ↓
Final Answer
```

### Max Word Calculation

| Persona | Base | Max Allowed |
|---------|------|-------------|
| Spark | 6 | 8 |
| Luna | 8 | 10 |
| Oracle Pro | 10 | 12 |

### Filler Phrase Removal

```dart
final fillerPatterns = [
  r'^(I think|I believe|I feel)\s*',
  r'^(Perhaps|Maybe|Probably)\s*',
  r'^(In my view|From what I see)\s*',
  r'\s+(you know|like|basically|actually)\s*',
];
```

### Recent Repeat Detection

- Track last 10 answers (case-insensitive)
- Exact matches trigger fallback
- Near-duplicates (80% similar) allowed
- Resets on app restart (or persists optionally)

---

## 4. Local Context Memory

### Why

An oracle that remembers feels more alive. But privacy matters—no secrets stored.

### Context Components

```
Context String = Recent Exchanges + Favorite Themes + Streak Info

Example:
"Recent exchanges: Q: 'Will I find love?' → A: 'Open your heart'. 
Q: 'What about my career?' → A: 'Success approaches'. 
User interests: love, career. User is on a 7-day streak."
```

### Memory Limits

| Component | Limit | Persistence |
|-----------|-------|-------------|
| Recent questions | 10 | Session only |
| Recent answers | 10 | Session only |
| Favorite themes | 5 | SharedPreferences |
| Streak count | Current | DailyFortuneService |

### Privacy Guardrails

**NEVER store:**
- Full question text beyond 10 recent
- User names, locations, dates
- API keys or prompts
- Sensitive topics (health, legal, financial)

**DO store:**
- Category names (love, career)
- Answer text (for repeat detection)
- Streak count
- Persona preference

### Context Injection

Context appended to system prompt:
```
[System prompt with persona + category rules]

Recent exchanges: Q: "..." → A: "...". User interests: love, career.
User is on a 7-day streak.

User: [actual question]
```

Total prompt must stay under 1000 characters.

---

## 5. Follow-up Prompt Suggestions

### Why

Users sometimes freeze when faced with infinite possibilities. Suggestions reduce friction and encourage engagement.

### UX Flow

```
1. User receives answer
2. Answer card reveals
3. 2-3 suggestion chips appear below card
4. User taps chip
5. Question auto-fills
6. Auto-triggers shake
7. New answer revealed
```

### Suggestion Strategy

| Category | Suggestion 1 | Suggestion 2 | Suggestion 3 |
|----------|--------------|--------------|--------------|
| General | "What should I focus on?" | "Give me a sign" | "What's coming next?" |
| Love | "Will I find love?" | "Is my relationship strong?" | "What should I know?" |
| Career | "Should I change jobs?" | "Will I succeed?" | "What's my next step?" |
| Yes/No | "Ask why" | "What if?" | "Give me more detail" |
| Daily | "What's special about today?" | "Any challenges?" | "Best moment of the day?" |

### Visual Design

- Chips appear below answer card in revealed state
- Same style as category chips but smaller
- Fade in with 200ms delay after card reveal
- Disappear on next shake

---

## 6. Implementation Constraints

### Token Budget

| Component | Max Tokens |
|-----------|------------|
| System prompt | 100 |
| Context | 50 |
| User question | 50 |
| **Total** | **200** |

GPT-3.5-turbo has 4096 token limit—we're well under.

### Latency Budget

| Operation | Max Time |
|-----------|----------|
| API call | 3000ms |
| Post-processing | 50ms |
| Context building | 10ms |
| **Total** | **~3100ms** |

Current AI service already handles 3s timeout.

### Memory Budget

| Component | Max Size |
|-----------|----------|
| Recent Q&A | 10 × 100 chars = 1KB |
| Favorite themes | 5 × 20 chars = 100 bytes |
| Persona pref | 1 enum = 4 bytes |
| **Total** | **~1.1KB** |

Negligible impact.

---

## 7. Testing Strategy

### Unit Tests

- `OracleContextService` — persona persistence, context building
- `AiService` — post-processing, guardrails, fallback selection
- Category fallbacks — all answers match tone, no punctuation

### Widget Tests

- `FollowUpSuggestions` — renders correct suggestions per category
- Persona selector — persists selection

### Integration Tests

- Full shake → answer flow with each persona
- Context appears in prompts (debug logging)
- Repeat answers trigger fallback

### Manual QA

- Each persona feels distinct
- Category tones are appropriate
- No answer exceeds max length
- Follow-up chips trigger correctly

---

## Files to Create/Modify

### New Files

- `lib/models/oracle_persona.dart` — persona enum with metadata
- `lib/services/oracle_context_service.dart` — persona + context management
- `lib/constants/category_prompts.dart` — category prompt templates
- `lib/constants/category_fallbacks.dart` — category-specific fallback answers (5 categories × 20 answers = 100 answers)
- `lib/widgets/follow_up_suggestions.dart` — follow-up question chips
- `lib/widgets/persona_selector.dart` — persona selection UI (optional polish)

### Modified Files

- `lib/services/ai_service.dart` — persona support, guardrails, context injection, post-processing
- `lib/screens/home_screen.dart` — persona selector, follow-up suggestions integration
- `lib/models/question_category.dart` — add prompt template reference

---

## Acceptance Criteria

- [ ] Three personas (Spark, Luna, Oracle Pro) produce meaningfully distinct answer styles
- [ ] Each category has 20 appropriate fallback answers
- [ ] Answers never exceed max word count (persona base + 2)
- [ ] No punctuation in final answers
- [ ] Filler phrases removed ("I think", "Perhaps")
- [ ] Recent repeats (last 10) trigger category fallback
- [ ] Context includes recent exchanges, favorites, streak
- [ ] Context string < 500 characters
- [ ] Follow-up suggestions appear after reveal (2-3 chips)
- [ ] Follow-up chips auto-trigger shake on tap
- [ ] No secrets, API keys, or prompts logged
- [ ] All 37+ existing tests still pass
- [ ] New tests for persona, guardrails, context

---

## Out of Scope for P10

- Voice persona (text-to-speech)
- Answer save/favorite with context
- Multi-turn conversation (follow-up remembers previous answer)
- Cloud sync of persona/context
- A/B testing persona effectiveness

These are P11+ features.

---

*Drafted for approval. No implementation until this doc is approved.*
