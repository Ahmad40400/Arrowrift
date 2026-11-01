# Arrowrift 🎯

A polished, Flutter-based arrow-escape puzzle game where every arrow must find its way out of the maze before the timer runs out. Built with a **single-source economy**, **guided onboarding**, **themes**, **custom board shapes**, **rotating events**, **arcade mini-games**, **daily streaks**, **achievements**, and a **local leaderboard** — all fully offline and persistent.

---

## 📖 Table of Contents

- [Gameplay](#-gameplay)
- [Core Features](#-core-features)
- [Game Modes](#-game-modes)
- [Economy System](#-economy-system)
- [Progression & Levels](#-progression--levels)
- [Power-ups](#-power-ups)
- [Themes](#-themes)
- [Custom Board Grids](#-custom-board-grids)
- [Daily Systems](#-daily-systems)
- [Events System](#-events-system)
- [Arcade Mini-games](#-arcade-mini-games)
- [Achievements](#-achievements)
- [Leaderboards](#-leaderboards)
- [Guided Tutorial](#-guided-tutorial)
- [Audio](#-audio)
- [Data & Persistence](#-data--persistence)
- [Project Structure](#-project-structure)
- [Architecture](#-architecture)
- [Getting Started](#-getting-started)
- [Development Conventions](#-development-conventions)
- [Roadmap](#-roadmap)

---

## 🎮 Gameplay

The board is a grid filled with **arrows**. Each arrow occupies a chain of cells and points in one of four directions.

1. **Tap an arrow** — if the path from its head to the board edge is completely clear, it slides out and is removed.
2. **Wrong tap** — if the path is blocked by another arrow, you lose a ❤️ life and the arrow shakes red.
3. **Win** — clear every arrow before the timer reaches zero.
4. **Lose** — run out of time _or_ lose all 3 lives.

The level is **procedurally generated and guaranteed solvable**: the generator only places arrows whose escape ray is free at the time of placement.

### Star rating (Classic)

| Stars  | Condition                                    |
| ------ | -------------------------------------------- |
| ⭐⭐⭐ | Finish with **≥ 30%** of the total time left |
| ⭐⭐   | Finish with **≥ 8%** of the time left        |
| ⭐     | Any other successful clear                   |

**Pro Mode** is stricter: `⭐⭐⭐` needs `≥ 10%` left, `⭐⭐` needs `≥ 3%`.

> **Time Freeze caps stars at 2** (see `Eco.freezeMaxStars`), and **Auto-Solve caps stars at 1** with a **50% reduced reward**.

---

## ✨ Core Features

- 🧩 **Solvable-by-construction puzzle generator** (incl. perfect-fill shaped boards)
- 🏆 **2,000 Classic + 500 Pro levels** with smooth difficulty curves
- 👑 **Boss levels** every 100th level (denser board, no Time Freeze)
- 🎨 **11 Themes** — 1 free classic, 5 regular, 6 premium (with animated backdrops)
- 🔷 **7 Board Shapes** — square + 6 purchasable shapes (circle, diamond, octagon, heart, plus, ring)
- ⏱️ **Time-based star scoring** with NEW BEST tracking
- 🛡️ **Power-ups** — Time Freeze, Extra Life, Auto-Solve
- 🔥 **7-day login streak** with auto-use Streak Freeze
- 🎁 **Daily Lucky Draw** (blind gift) + **Daily Challenge** level
- 📅 **35+ rotating events** (48h duration) with progress, claims, and history
- 🕹️ **3 Arcade mini-games** (5 plays/day)
- 🏅 **30+ Achievements** with diamond rewards + auto-popup toasts
- 📊 **Local leaderboards** (Coins, Speed, Streak)
- 🎓 **9-step guided tutorial** with real spotlight overlay
- 💾 **Dual persistence** (SharedPreferences + file), offline-first
- 🔊 **Background music + SFX** with independent toggles

---

## 🕹️ Game Modes

### Classic Mode

- **2,000 levels** — Easy → Legendary
- Grid size grows from **6×6** to **18×18**
- Timer grows from **12s** to **33s**
- Level unlock costs curve gently (see `getLevelCost`)

### Pro Mode

- **500 levels** — Extreme difficulty
- Grid starts at **15×15** and scales to **20×20**
- Faster timer pressure (`~0.62s per arrow + 4s`)
- **Wrong tap costs 2 seconds** (in addition to a life)
- Higher reward multiplier (`×1.05`) + higher flat bonus (`200`)

### Daily Challenge

- One special level per day (alternates Classic/Pro)
- **20% of next unlock cost** in bonus coins (min 1,000, max 6,000, rounded to 50)
- Classic daily gets **20% less time**
- One claim per calendar day

### Boss Levels

- Every **100th level** (100, 200, 300, …)
- Classic: **grid +2** (max 20) → ~2× arrows
- Pro: **shorter arrows** → ~1.5× arrows
- **Time Freeze disabled**
- Timer scaled to arrow count (same pace as normal)

---

## 💰 Economy System

All numbers live in **`lib/economy/economy_config.dart`** — the **single source of truth**. Change numbers there, nowhere else.

### Reward formula (normal clear)

```
fullReward = (nextLevelCost × starMultiplier) + flatBonus
```

| Modifier              | Value  |
| --------------------- | ------ |
| `star3Mult`           | `1.03` |
| `star2Mult`           | `0.98` |
| `star1Mult`           | `0.90` |
| `classicFlatBonus`    | `100`  |
| `proFlatBonus`        | `200`  |
| `proRewardMult`       | `1.05` |
| `autoSolvePayoutMult` | `0.5`  |

### Replay rewards

| Rule                | Value                               |
| ------------------- | ----------------------------------- |
| Base replay payout  | `30%` of full reward                |
| Min / Max           | `60` / `6,000` coins                |
| Daily replay budget | `12,000` coins                      |
| Improvement bonus   | `max(0, fullReward − previousBest)` |

### Shop prices

| Item          | Cost                                  |
| ------------- | ------------------------------------- |
| Time Freeze   | `1,500` coins                         |
| Extra Life    | `400` coins                           |
| Auto-Solve    | `150,000` coins _or_ `5,000` diamonds |
| Streak Freeze | `5,000` coins (max 3 held)            |
| Regular theme | `10,000` coins                        |
| Premium theme | `15,000+` coins (varies per theme)    |
| Regular grid  | `6,000` coins                         |
| Premium grid  | `10,000` coins                        |

### Diamond exchange

- `300` 💎 → `2,500` coins
- Minimum exchange: `300` diamonds

### Login streak rewards

| Day | Reward           |
| --- | ---------------- |
| 1   | 150 coins        |
| 2   | 250 coins        |
| 3   | 400 coins        |
| 4   | 600 coins        |
| 5   | 900 coins        |
| 6   | 1,400 coins      |
| 7   | **100 diamonds** |

---

## 🧭 Progression & Levels

### Classic grid & time curve

| Levels    | Grid  | Time |
| --------- | ----- | ---- |
| 1–10      | 6×6   | 12s  |
| 11–30     | 7×7   | 15s  |
| 31–60     | 8×8   | 16s  |
| 61–100    | 9×9   | 18s  |
| 101–150   | 10×10 | 21s  |
| 151–250   | 11×11 | 21s  |
| 251–350   | 12×12 | 24s  |
| 351–450   | 13×13 | 27s  |
| 451–700   | 14×14 | 27s  |
| 701–1000  | 15×15 | 29s  |
| 1001–1400 | 16×16 | 31s  |
| 1401–1800 | 17×17 | 31s  |
| 1801–2000 | 18×18 | 33s  |

### Level unlock cost (Classic)

| Levels  | Cost formula                  |
| ------- | ----------------------------- |
| 1       | Free                          |
| 2–50    | `50 + (level − 2) × 30`       |
| 51–200  | `1,490 + (level − 50) × 60`   |
| 201–500 | `10,490 + (level − 200) × 40` |
| 501+    | `22,490 + (level − 500) × 30` |

### Level unlock cost (Pro)

| Levels | Cost formula                  |
| ------ | ----------------------------- |
| 1      | Free                          |
| 2–40   | `100 + (level − 2) × 40`      |
| 41–80  | `1,620 + (level − 40) × 80`   |
| 81–100 | `4,820 + (level − 80) × 120`  |
| 101+   | `7,220 + (level − 100) × 100` |

### Difficulty labels

`Easy` → `Medium` → `Hard` → `Expert` → `Extreme` → `Master` → `Legendary`

---

## ⚡ Power-ups

| Power-up          | Effect                                      | Price                         | Cap                                  |
| ----------------- | ------------------------------------------- | ----------------------------- | ------------------------------------ |
| **Time Freeze**   | Freezes timer for **15 seconds**            | `1,500` coins                 | Max 2 stars; disabled on boss levels |
| **Extra Life**    | Adds 1 heart (max 3)                        | `400` coins                   | Only usable below 3 hearts           |
| **Auto-Solve**    | Instantly clears the board                  | `150,000` coins or `5,000` 💎 | 50% reward, 1 star, no achievements  |
| **Streak Freeze** | Protects streak for 1 missed day (auto-use) | `5,000` coins                 | Max 3 held                           |

Power-ups are stored in inventory when bought, otherwise the price is deducted automatically at use time if you can afford it.

---

## 🎨 Themes

All themes live in **`lib/theme/app_theme.dart`**. Every new player gets **one free 3-minute trial** per theme before they must buy it.

### Regular themes (10,000 coins)

| ID         | Name             | Backdrop |
| ---------- | ---------------- | -------- |
| `classic`  | Classic _(free)_ | None     |
| `midnight` | Midnight Neon    | Stars    |
| `sakura`   | Sakura Blossom   | Petals   |
| `ocean`    | Ocean Breeze     | Bubbles  |
| `forest`   | Emerald Forest   | Leaves   |
| `sunset`   | Golden Sunset    | Sunrays  |

### Premium themes (15,000–25,000 coins)

| ID          | Name            | Price  | Backdrop     |
| ----------- | --------------- | ------ | ------------ |
| `crystal`   | Frozen Crystal  | 15,000 | Crystals     |
| `rosegold`  | Rose Gold Luxe  | 15,000 | Rose shimmer |
| `aurora`    | Aurora Borealis | 18,000 | Aurora       |
| `lava`      | Lava Ember      | 20,000 | Embers       |
| `cyber`     | Cyber Grid      | 22,000 | Cyber grid   |
| `royalgold` | Royal Gold      | 25,000 | Gold dust    |

Themes recolor **the entire app** (backgrounds, cards, text, board, arrows, buttons) through `AppTheme.active`. Premium themes feature **procedurally painted animated-style backdrops** (`ThemeBackdropPainter`).

> A **trial bar** appears at the top of the screen while a trial runs (`ThemePreviewShell`), with live countdown, "UNLOCK" button, and "END TRIAL" close.

---

## 🔷 Custom Board Grids

Grids are **visual board shapes** (not difficulty changes) — the rules, timer, and rewards are identical to the square board. Trial/buy/apply flow matches themes.

### Regular grids (6,000 coins)

- **Circle** — round board with soft edges
- **Diamond** — gem-shaped board
- **Octagon** — square with cut corners

### Premium grids (10,000 coins)

- **Heart** — big heart shape
- **Plus** — bold cross-shaped board
- **Ring** — donut board with empty center

### Perfect-fill shaped generator

For shaped boards, the generator **tiles every playable cell with arrows** (no holes), then **orients each arrow** so a valid escape order exists — guaranteeing a solvable level. If tiling fails after 80 attempts, the game falls back to the original square generator.

> Shapes are **disabled** on tutorial, daily challenge, and boss levels to keep those experiences consistent.

---

## 📅 Daily Systems

### Login Streak

- **7-day cycle** with escalating coin rewards, ending in **100 diamonds**
- **Streak Freeze** auto-consumes when you miss exactly 1 day (configurable up to 3 held)
- Popup shown once per session via `DailyStreakScreen`

### Daily Challenge

- One special level per calendar day (alternates Classic/Pro based on `todayStamp % 2`)
- Level number varies by day: `(todayStamp % 60) + 1` for Classic, `(todayStamp % 40) + 1` for Pro
- Reward: **20% of next unlock cost** (min 1,000, max 6,000, rounded to 50)
- Classic daily gets **20% less time**

### Lucky Draw

- One free pull per day
- Weighted outcomes: Diamonds (100) / Coins (3,000) / Random power-up
- Auto-Solve weighted at ~8.9% (Rare)

### Arcade limit

- **5 mini-game plays per day** — resets at local midnight

---

## 🎯 Events System

**35+ rotating events** with **48-hour duration** and **24-hour grace period**, defined in `EventConfig.allEvents`.

Events rotate automatically based on `(nowMs − 1700000000000) / (48h)` index into the event list.

### Event types

`classic`, `any`, `pro`, `pro_speed`, `speed15`, `speed10`, `perfect`, `no_power`, `tier1`, `tier3`, `tier5`, `time_morning`, `time_night`, `weekend`, `clutch`, `big_grid`, `no_mistake`, `replay`, `coins`, `diamonds`, `daily`, `streak`, `arcade`, `use_freeze`, `use_solve`, `lucky`, `theme`, `buy_shop`, `spend`

### Flow

1. **Start Event** → activates progress tracking
2. **Play levels** (or perform the target action) → progress increments
3. **Claim Reward** → coins + diamonds added, event marked claimed
4. **History** → claimed events appear in the "Completed" timeline on `EventsScreen`

The **Events orb button** on the Home tab shows a red dot when an event is complete but unclaimed.

---

## 🕹️ Arcade Mini-games

**5 plays per day** (resets at local midnight). Each game has its own realistic reward range.

| Game             | Description                                                            | Reward Range | Win condition   |
| ---------------- | ---------------------------------------------------------------------- | ------------ | --------------- |
| **Memory Match** | Match all 6 pairs before time runs out                                 | 25–150 coins | Match all pairs |
| **Tap Target**   | Tap as many targets as possible in 10s                                 | 15–120 coins | Score ≥ 5       |
| **Color Reflex** | Tap the color matching the _ink color_ of the word (not what it says!) | 10–100 coins | Score ≥ 4       |

Arcade stats tracked:

- `arcadePlayTimeSeconds`
- `arcadeGamesWon`
- `maxArcadeCoinsEarned`
- `dailyArcadeGamesWon` (resets daily — feeds achievement `daily_arcade`)

---

## 🏅 Achievements

Achievements are defined in **`lib/screens/progress_screen.dart`** in the `ProgressScreen.achievements` list. Each has:

- `id`, `title`, `description`
- `unlockedIcon`, `color`
- `isUnlocked(game)` predicate
- `progress(game)` 0.0–1.0
- `diamondReward` (optional)
- `category`: `combat` / `arcade` / `daily`

**Diamond-rewarding achievements** must be **claimed** (via `ProgressScreen` → View All → Claim). Daily achievements (e.g. `daily_grind`, `daily_arcade`) reward **`Eco.dailyTaskDiamonds` (10)** each and reset every day.

**Auto-popup toasts** (top-of-screen slide-in) fire via `GameProvider.checkAchievementPopups()` for key milestones: `first_win`, `pro_player`, `arcade_rookie`, `untouchable`, `coin_collector`, `speed_demon`, `daily_grind`, `daily_arcade`.

---

## 🏆 Leaderboards

Three **local** leaderboards (max 10 entries each), stored in `SaveData`:

| Board      | Metric                       | Entry fields                                       |
| ---------- | ---------------------------- | -------------------------------------------------- |
| **Coins**  | Best single-run coin payout  | `coins`, `level`, `isPro`, `stars`, `time`, `date` |
| **Speed**  | Fastest clear (no power-ups) | `time`, `level`, `isPro`, `stars`, `coins`, `date` |
| **Streak** | Longest login streak         | `streak`, `date`                                   |

`ProgressScreen` shows **Top 3** per board with a **"See top 10"** and **"View All"** full-screen sheet.

---

## 🎓 Guided Tutorial

A **9-step** guided tour with a real **spotlight overlay** — the player can only progress by tapping the actual highlighted widget.

| Step | Highlight             | Action                              |
| ---- | --------------------- | ----------------------------------- |
| 1    | PLAY button           | Open mode selection                 |
| 2    | Classic Mode card     | Open level list                     |
| 3    | Level 1 card          | Start level 1                       |
| 4    | First escapable arrow | Tap it (timer frozen until cleared) |
| 5    | Stats tab             | Tap                                 |
| 6    | Arcade tab            | Tap                                 |
| 7    | Shop tab              | Tap                                 |
| 8    | Settings tab          | Tap                                 |
| 9    | _(full dim)_          | Tap "Start Playing"                 |

- **Back-button safe** via `TutorialRouteObserver`
- **Skip link** on the card (configurable via `GuidedTourOverlay(allowSkip: false)`)
- **Restartable** from Settings → How to Play
- **Persisted** flag: `arrowrift_tutorial_completed_v1`

---

## 🔊 Audio

`AudioManager` (singleton) manages two `AudioPlayer` instances:

- **Background music** (`sounds/bg_music.mp3`) — looped, volume `0.6` in menus, `0.15` in game
- **SFX** — `arrow_escape.mp3`, `wrong_tap.mp3`

Both toggles persist in SharedPreferences (`music_enabled`, `sfx_enabled`). Audio auto-pauses when the app goes to background and resumes on foreground.

---

## 💾 Data & Persistence

`SaveStorage` writes to **both**:

1. **SharedPreferences** (key: `arrowrift_save_v1`)
2. **App-private JSON file** (Android: `/data/user/0/<pkg>/files/arrowrift_save_v1.json`)

On load, both are read and the **newest `savedAt`** wins (tiebreak: higher `totalPoints`). Writes use a **write-to-temp + atomic rename** pattern.

### Save schema version: `v17`

Tracks:

- Progress: `classicUnlocked`, `proUnlocked`
- Currencies: `totalPoints`, `totalDiamonds`, `autoSolveInventory`
- Inventory: `freezeItems`, `healthItems`, `streakFreezeHeld`
- Records: `levelRecords` (`Map<int, LevelRecord>`)
- Stats: `totalPlayTimeSeconds`, `totalLevelsCompleted`, `proLevelsCompleted`, `fastestClearSeconds`, `perfectLevelsCount`, `lifetimeCoinsEarned`, etc.
- Themes & Grids: `unlockedThemes`, `activeTheme`, `triedThemes`, `unlockedGrids`, `activeGrid`, `triedGrids`
- Daily: `dailyLevelsCompleted`, `dailyArcadeGamesWon`, `lastDailyTaskDate`, `lastMinigameDate`, `lastLuckyDrawDate`, `lastReplayDate`
- Streak: `streakCount`, `lastStreakDay`, `streakFreezeUsedToday`
- Events: `activeEventId`, `eventProgress`, `claimedEventIds`, `isEventActive`
- Leaderboards: `leaderboardCoins`, `leaderboardSpeed`, `leaderboardStreak`
- `achievementPopupsShown`
- `starterGranted`

`resetProgress()` wipes everything and re-seeds the starter kit.

---

## 📂 Project Structure

```
lib/
├── main.dart                       # App entry — GameProvider init, MaterialApp, routes
├── economy/
│   └── economy_config.dart         # Eco + EventConfig — single source of truth
├── models/
│   └── arrow_model.dart            # ArrowModel, GridCell, ArrowDirection, gameClock
├── providers/
│   └── game_provider.dart          # God object — all game state & logic (~1,800 lines)
├── screens/
│   ├── home_screen.dart            # Animated logo, PLAY button, streak strip
│   ├── mode_selection_screen.dart  # Tabbed shell: Home/Stats/Arcade/Shop/Settings + Events orb
│   ├── level_screen.dart           # Zig-zag level map with best time/coins
│   ├── game_screen.dart            # Board + timer + power-ups + win/lose dialogs
│   ├── daily_streak_screen.dart    # 7-day streak popup
│   ├── events_screen.dart          # Live event hero + completed timeline
│   ├── progress_screen.dart        # Achievements, stats, leaderboards
│   ├── buy_screen.dart             # Shop: power-ups, exchange, lucky draw, themes, grids
│   ├── settings_screen.dart        # Audio toggles, tutorial restart, reset progress
│   ├── arcade_screen.dart          # Carousel of 3 mini-games
│   ├── memory_game_screen.dart     # Memory Match
│   ├── tap_target_screen.dart      # Tap Target
│   └── color_reflex_screen.dart    # Color Reflex
├── services/
│   ├── audio_manager.dart          # Singleton music + SFX
│   ├── save_storage.dart           # SaveData schema + dual-write persistence
│   ├── tutorial_manager.dart       # Steps, GlobalKeys, route names
│   └── tutorial_route_observer.dart# Keeps tutorial in sync on back navigation
├── theme/
│   ├── app_theme.dart              # 11 ArrowTheme palettes + ThemedScaffold
│   ├── grid_styles.dart            # 7 GridStyle masks + buildMask
│   └── theme_preview_bar.dart      # Trial countdown bar for themes & grids
└── widgets/
    ├── arrows_board.dart           # InteractiveViewer + Ticker + GestureDetector
    ├── board_painter.dart          # CustomPainter rendering arrows
    └── guided_tour_overlay.dart    # Spotlight overlay + pointing hand
```

---

## 🏗 Architecture

### Provider-based state

- **`GameProvider`** is a `ChangeNotifier` and the single source of truth for **all** game state.
- Screens use `context.watch<GameProvider>()` for reactive rebuilds or `context.select` for narrow selections (e.g. theme ID).
- `AppTheme.active` is a **static snapshot** updated by the provider before `notifyListeners()`, so static getters (`AppTheme.brand`, `AppTheme.ink`, etc.) always reflect the current theme without requiring a `BuildContext`.

### Generation guarantees

- **Square board:** Arrows are placed center-outward, only where `rayClear` passes. Guaranteed solvable.
- **Shaped board:** Full **perfect-fill tiling** + **orientation peeling** (outside-in). Falls back to square generator if 80 attempts fail.

### Animation

- **`Ticker`** in `ArrowsBoard` repaints only when `hasActiveAnimation` is true (exit animations or shakes).
- **`flutter_animate`** used across cards, banners, and the daily streak dialog for entrance effects.
- **`confetti`** package fires on level complete.

### Tutorial overlay

- Wraps `MaterialApp.builder` via `GuidedTourOverlay`
- Measures target `RenderBox` every frame, **settles** for 0.16s before opening the spotlight (avoids jumping during screen slide-in)
- **Custom-drawn pointing hand** with fingertip anchoring to the exact target point
- **Arrow step**: spotlight hugs the real arrow cells (not a rectangle); only a tap on that arrow is accepted

### Persistence safety

- All writes are serialized through `_saveChain` (a `Future` chain) to prevent race conditions
- On app pause (`didChangeAppLifecycleState`), `saveDataNow()` is called
- Level exit (`_goBack` / `PopScope`) also forces a save

---

## 🚀 Getting Started

### Prerequisites

- Flutter **3.x** (Dart 3)
- Android Studio / Xcode for platform builds

### Run

```bash
flutter pub get
flutter run
```

### Build

```bash
flutter build apk --release
flutter build appbundle --release
flutter build ios --release
```

### Assets required

Place these under `assets/sounds/` and register in `pubspec.yaml`:

- `bg_music.mp3`
- `arrow_escape.mp3`
- `wrong_tap.mp3`

### Dependencies (from imports)

```yaml
dependencies:
  flutter: { sdk: flutter }
  provider: ^6.x
  shared_preferences: ^2.x
  audioplayers: ^5.x
  flutter_animate: ^4.x
  confetti: ^0.7.x
```

---

## 🧑‍💻 Development Conventions

### 🔑 The Golden Rules

1. **All economy numbers live in `Eco`** (`economy_config.dart`). Never hardcode a coin/diamond price in a screen.
2. **All colors come from `AppTheme`** (via `AppTheme.brand`, `AppTheme.ink`, `AppTheme.grey(300)`, `AppTheme.dim(54)`, etc.). Never hardcode `Colors.grey` or `Colors.black54` — use the helpers so themes work everywhere.
3. **All persistent state lives in `GameProvider`** and is saved via `_saveData()`. Add new fields to **both** `GameProvider` and `SaveData`.
4. **Route names** are constants in `TutorialManager` (`levelRouteName`, `gameRouteName`, `modeSelectionRouteName`) so the tutorial observer can reason about navigation.
5. **Tutorial-relevant widgets** need a `GlobalKey` from `TutorialManager` (`playButtonKey`, `classicCardKey`, etc.).

### Adding a new theme

1. Add an `ArrowTheme` constant in `app_theme.dart`.
2. Add it to `AppTheme.all` (respecting `tier` ordering).
3. Pick a `BackdropStyle` (or add a new one + painter method in `ThemeBackdropPainter`).
4. Set `customPrice` if premium-tier pricing should differ from the default.

### Adding a new grid shape

1. Add a `GridKind` enum value.
2. Add a `GridStyle` constant + register it in `GridStyles.all`.
3. Add the `_inside(...)` math in `GridStyles._inside`.
4. Test `GridStyles.buildMask` at multiple `n` values.

### Adding a new event

Add a `GameEvent(...)` entry to `EventConfig.allEvents` with a unique `id`. If it needs a new `type`, wire it up in `GameProvider._onLevelCleared()` or the appropriate action method via `_addEventProgress(type, amount)`.

### Adding a new achievement

Add an `Achievement(...)` entry to `ProgressScreen.achievements`. Track its underlying stat in `GameProvider`. If it should show a popup toast, add a check in `checkAchievementPopups()`.

### Adding a new mini-game

1. Create a new screen with a `START` button + scoring.
2. Call `game.recordMinigamePlayed()`, `game.addMinigameCoins(coins)`, and `game.recordArcadeGameWon(seconds, coins, won: ...)`.
3. Add it to `ArcadeScreen._games` with `id`, `title`, `desc`, `icon`, `color`, `reward`, `screen`.

### Testing save migrations

Bump `SaveData.toJsonString()`'s `'v'` field and add migration logic in `SaveData.tryParse` guarded by `ver < N`.

---

## 🗺 Roadmap

- [ ] Cloud sync (Firebase / Supabase)
- [ ] Global leaderboards
- [ ] Per-game arcade best scores (`Map<String, int> arcadeBestCoins`)
- [ ] Seasonal events with unique cosmetic rewards
- [ ] Sound settings per-channel (music / UI SFX / game SFX)
- [ ] Accessibility pass (screen reader labels, colorblind palettes)
- [ ] Daily login calendar UI polish
- [ ] Haptics preference toggle
- [ ] Level editor / community levels

---

## 📄 License

Proprietary. All rights reserved. _(Update with your chosen license if releasing publicly.)_

---

## 🙏 Credits

- Puzzle design, code, and art: **Arrowrift team**
- Font: **Poppins** (Google Fonts)
- Packages: `provider`, `shared_preferences`, `audioplayers`, `flutter_animate`, `confetti`

---

**Arrowrift — Find the way out.** 🎯

```

```
