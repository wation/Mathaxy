# Mathaxy Copilot Instructions

**Project**: Mathaxy (数学银河) - iOS Math Learning Game for ages 6-7  
**Tech Stack**: Swift, SwiftUI, MVVM  
**Target**: iOS 18+, iPhone 13+ | Bundle ID: com.beverg.mathaxywt  
**Current Phase**: Phase 1 - 10-level addition-only game (0-9 operands)

---

## Architecture Overview

### Directory Structure
```
Mathaxy/
├── App/               # Entry point (MathaxyApp.swift) + RootView routing
├── Modules/           # MVVM feature modules
│   ├── Login/         # UserProfile model + login flow
│   ├── Game/          # GameSession model + GamePlayViewModel
│   ├── Achievement/   # Badge unlocking + guide character system
│   ├── Settings/      # AppSettings model + language/sound toggles
│   └── Home/          # Level selection + progress display
├── Services/          # Singleton services (6 services)
├── Models/            # GameConstants.swift, LevelConfig.swift
├── Resources/         # Assets, Sounds, Colors
├── Localization/      # 7 languages via .lproj bundles
└── Utils/            # Extensions, Helpers, Views
```

### Six Core Singleton Services

1. **StorageService** (`StorageService.shared`)
   - Dual-layer persistence: FileManager (JSON) + UserDefaults (backup)
   - Methods: `saveUserProfile()`, `loadUserProfile()`, `saveAppSettings()`, `loadAppSettings()`
   - Data: `UserProfile` (nickname, progress, badges), `AppSettings` (language, sound toggles, timestamps)
   - Recovery: If JSON file corrupted, falls back to UserDefaults

2. **LocalizationService** (`LocalizationService.shared`)
   - Single source of truth: `@Published var currentLanguage: AppLanguage`
   - Pattern: `switchLanguage(to:)` → updates UserDefaults → posts `languageDidChange` notification
   - UI Integration: Text views auto-select correct `.lproj/Localizable.strings`

3. **QuestionGenerator** (`QuestionGenerator.shared`)
   - Generates 20 unique addition questions (addend1 + addend2, both 0-9)
   - Algorithm: Pseudo-random pairs, tracks used combinations within level to prevent duplicates
   - Method: `generateQuestions(level:, count:) -> [Question]`

4. **SoundService** (`SoundService.shared`)
   - Plays audio + haptic feedback: correct (light), incorrect/timeout (medium), badge (heavy)
   - Methods: `playCorrectSound()`, `playIncorrectSound()`, `playTimeoutSound()`, `playBadgeSound()`
   - Respects: `isSoundEnabled`, `isHapticEnabled` settings

5. **LoginTrackingService** (`LoginTrackingService.shared`)
   - Tracks consecutive login days for "坚持小达人" badge
   - Logic: Compares `lastLaunchDate` with today; increments streak if consecutive, resets on gap

6. **AdService** (`AdService.shared`)
   - Shows 30s AdMob video on level failure (COPPA-compliant)
   - Trigger: After failed level, user can watch ad for free retry

---

## Game Mechanics

### 10-Level Progression

**Levels 1-5: Total-Time Mode**
- Level 1-5: 300s, 240s, 180s, 120s, 90s respectively (cumulative timer)
- Fail: Reach 0s before completing all 20 questions

**Levels 6-10: Per-Question Mode**
- Level 6-10: 4s, 3.5s, 3s, 2.5s, 2s per question
- Max errors: 10 per level → level fails if exceeded
- Timeout: Auto-advances to next question, counts as error

**Skip Level Mechanic**
- Trigger: 10 consecutive questions ≤ 50% of level's time target
  - Example: Level 3 (9s avg) → 10 consecutive ≤ 4.5s → skip triggered
- Reward: Jump +3 levels + "神速小能手" badge

See [LevelConfig.swift](MathaxyAI/MathaxyAI-iOS/Mathaxy/Models/LevelConfig.swift).

---

## Badge System

| Badge | Earn Condition | Qty | Storage |
|-------|---|---|---|
| `levelComplete` | Pass each level | 10 | JSON + UserDefaults |
| `skipLevel` | Skip triggered | Unlimited | JSON + UserDefaults |
| `perfectLevel` | 20/20 correct in one level | 10 | JSON + UserDefaults |
| `consecutiveLogin` | 7 consecutive daily logins | 1 | UserDefaults + service |

**Character Unlocks**
- Panda: ≥ 3 badges → encouragement messages
- Rabbit: ≥ 7 badges → helpful hints

**Certificate** (after beating Level 10)
- PNG: nickname, total time, badge count + galaxy background
- Actions: Save to camera roll, share to social
- Helper: `CertificateGenerator` in Utils/Helpers/

---

## Key Data Flows

### Progress Persistence
```
User answers → GamePlayViewModel.submitAnswer() 
→ GameSession updated (errors, time)
→ Win/lose/skip check
→ StorageService.saveUserProfile() 
→ Achievement view refreshes
```

### Language Switch
```
Settings → LocalizationService.switchLanguage(to:)
→ @Published currentLanguage updates
→ UserDefaults + appSettings.json saved
→ languageDidChange notification posted
→ All Text("key") views reload .lproj
```

---

## MVVM Module Pattern

Each feature (Game, Achievement, Settings, etc.) follows:
```
Modules/Game/
├── Model/
│   ├── GameSession.swift     # State container
│   └── Question.swift        # Immutable question data
├── ViewModel/
│   └── GamePlayViewModel.swift # Business logic
└── View/
    ├── GamePlayView.swift
    ├── QuestionView.swift
    └── ResultView.swift
```

**Pattern**: ViewModel holds `@Published var gameSession: GameSession` ← UI observes single source of truth.

---

## Testing

**Location**: [MathaxyTests/](MathaxyAI/MathaxyAI-iOS/MathaxyTests/)

**Test Classes**
- QuestionGeneratorTests: 20 unique questions, valid operands (0-9)
- StorageServiceTests: File I/O, UserDefaults fallback
- GameSessionTests: Timer accuracy, skip trigger, error counting
- LoginTrackingServiceTests: Consecutive day logic, date edge cases
- UserProfileTests: Badge serialization

**Run**: Xcode (Cmd+U) or terminal (`swift test`)

---

## Localization

**Supported**: 中文(简繁), English, 日本語, 한국어, Español, Português

**Workflow**:
1. Add key to `zh-Hans.lproj/Localizable.strings`: `"badge.skipLevel.title" = "神速小能手";`
2. Export via Xcode (Editor > Export for Localization), add translations to all `.lproj` folders
3. In SwiftUI, use `Text("badge.skipLevel.title")` → auto-selects `.lproj`
4. Language switch: Settings view calls `LocalizationService.switchLanguage(to:)`

---

## Common Tasks

### Add Badge Type
1. Add case to `BadgeType` enum in [GameConstants.swift](MathaxyAI/MathaxyAI-iOS/Mathaxy/Models/GameConstants.swift)
2. Update unlock logic in [AchievementViewModel](MathaxyAI/MathaxyAI-iOS/Mathaxy/Modules/Achievement/ViewModel/)
3. Add localization strings to all `.lproj/Localizable.strings`
4. Add test to [UserProfileTests.swift](MathaxyAI/MathaxyAI-iOS/MathaxyTests/UserProfileTests.swift)

### Modify Level Difficulty
1. Edit [LevelConfig.swift](MathaxyAI/MathaxyAI-iOS/Mathaxy/Models/LevelConfig.swift) switch case
2. If skip threshold changes, update `GamePlayViewModel.checkWin()`
3. Add test to [GameSessionTests.swift](MathaxyAI/MathaxyAI-iOS/MathaxyTests/GameSessionTests.swift)

### Add Color
1. Define in [Resources/Colors/](MathaxyAI/MathaxyAI-iOS/Mathaxy/Resources/Colors/)
2. Use: `Color("ColorName")` in SwiftUI
3. Ref: [plans/UI设计规范.md](plans/UI设计规范.md)

---

## Project Conventions

### Naming
- Services: PascalCase + "Service" (e.g., `StorageService`)
- ViewModels: PascalCase + "ViewModel" (e.g., `GamePlayViewModel`)
- Badge enums: snake_case (e.g., `level_complete`, `skip_level`)
- Localization: dot-separated (e.g., `badge.skipLevel.title`)

### Error Handling
- StorageService: Silent fallback to UserDefaults on file I/O error (print for debugging)
- QuestionGenerator: No error states (bounded 0-9, deterministic)
- UI: Optional/Binding; fallback to defaults, never crash on missing data

### Architecture
- **No Backend**: All local (UserDefaults + FileManager)
- **Offline-First**: No network calls except AdMob ads
- **COPPA**: No tracking/analytics (except AdMob), no data leaves device
- **Phase 1**: Addition only; subtraction/multiplication/leaderboards/AR are Phase 2+

---

## Key Files

| File | Purpose |
|------|---------|
| [MathaxyApp.swift](MathaxyAI/MathaxyAI-iOS/Mathaxy/App/MathaxyApp.swift) | Entry point, services injection |
| [LevelConfig.swift](MathaxyAI/MathaxyAI-iOS/Mathaxy/Models/LevelConfig.swift) | Level 1-10 configs |
| [GameConstants.swift](MathaxyAI/MathaxyAI-iOS/Mathaxy/Models/GameConstants.swift) | Badge thresholds, constants |
| [QuestionGenerator.swift](MathaxyAI/MathaxyAI-iOS/Mathaxy/Services/QuestionGenerator.swift) | Question gen + uniqueness |
| [StorageService.swift](MathaxyAI/MathaxyAI-iOS/Mathaxy/Services/StorageService.swift) | Persistence layer |
| [LocalizationService.swift](MathaxyAI/MathaxyAI-iOS/Mathaxy/Services/LocalizationService.swift) | Language management |
| [GamePlayViewModel.swift](MathaxyAI/MathaxyAI-iOS/Mathaxy/Modules/Game/ViewModel/) | Core game logic |

