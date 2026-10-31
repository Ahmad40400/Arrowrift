import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../economy/economy_config.dart';
import '../theme/app_theme.dart';
import '../theme/grid_styles.dart';
import '../models/arrow_model.dart';
import '../services/save_storage.dart';
import '../services/audio_manager.dart';
import '../services/tutorial_manager.dart';

class GameProvider extends ChangeNotifier {
  int currentLevel = 1;
  int classicUnlockedLevel = 1;
  int proUnlockedLevel = 1;
  int gridSize = 6;
  // Boss level se pehle wala normal grid (events/time calc ke liye)
  int baseGridSize = 6;
  bool isLevelComplete = false;
  bool isGameOver = false;
  bool isLevelFailed = false;

  bool isProMode = false;
  bool isDailyChallenge = false;
  int lastDailyCompletedDate = 0;

  bool isDataLoaded = false;

  int totalPoints = 0;
  int totalDiamonds = 0;
  int autoSolveInventory = 0;
  int levelPointsEarned = 0;
  int levelStars = 3;
  bool usedAutoSolve = false;
  bool isReplayReward = false;
  bool usedFreezeThisLevel = false;
  int _freezeToken = 0;
  int timeLeft = 0;
  int totalTime = 0;
  int timeTaken = 0;
  Timer? _timer;

  int lives = 3;
  int moves = 0;
  bool isTimeFrozen = false;

  // ================================================================
  // GUIDED TUTORIAL STATE
  // ================================================================
  static const String _tutorialPrefsKey = 'arrowrift_tutorial_completed_v1';
  int tutorialStep = 0;
  bool tutorialCompleted = false;
  bool tutorialInputLocked = false;
  int tutorialFinishCount = 0;

  // INVENTORY
  int freezeInventory = 0;
  int healthInventory = 0;

  // STATS TRACKING
  int totalPlayTimeSeconds = 0;
  int totalLevelsCompleted = 0;
  int proLevelsCompleted = 0;
  bool hasSpeedRun = false;
  bool hasCompletedDaily = false;
  bool hasPerfectClear = false;
  int lifetimeCoinsEarned = 0;
  int perfectLevelsCount = 0;
  int fastestClearSeconds = 0;

  // ECONOMY GUARDS
  bool starterGranted = false;
  int replayCoinsToday = 0;
  int lastReplayDate = 0;
  int lastSeenMs = 0;
  int replayImprovementBonus = 0;
  bool replayLimitHit = false;

  // ARCADE STATS
  int arcadePlayTimeSeconds = 0;
  int arcadeGamesWon = 0;
  int maxArcadeCoinsEarned = 0;

  // MINIGAME DAILY LIMIT
  int dailyMinigamesPlayed = 0;
  int lastMinigameDate = 0;
  static const int maxMinigamesPerDay = 5;

  List<String> claimedTaskIds = [];
  int lastLuckyDrawDate = 0;

  // ================================================================
  // LOGIN STREAK
  // ================================================================
  int streakCount = 0;
  int lastStreakDay = 0;
  int streakFreezeHeld = 0;
  bool streakFreezeUsedToday = false;
  bool _streakPopupShownThisSession = false;

  // ================================================================
  // EVENTS STATE
  // ================================================================
  String activeEventId = '';
  int eventProgress = 0;
  List<String> claimedEventIds = [];
  bool isEventActive = false;

  // ================================================================
  // LOCAL LEADERBOARD (NEW)
  // ================================================================
  List<Map<String, dynamic>> leaderboardCoins = [];
  List<Map<String, dynamic>> leaderboardSpeed = [];
  List<Map<String, dynamic>> leaderboardStreak = [];

  static const int _leaderboardMaxEntries = 10;

  // ================================================================
  // ACHIEVEMENT POPUP QUEUE (NEW)
  // ================================================================
  List<Map<String, dynamic>> _achievementPopupQueue = [];
  List<Map<String, dynamic>> get achievementPopupQueue =>
      List.unmodifiable(_achievementPopupQueue);

  // Global overlay key for showing achievement toasts anywhere in the app
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  Map<String, dynamic>? _activeGlobalPopup;
  Timer? _popupAutoDismissTimer;

  Set<String> _achievementPopupsShown = {};

  int _lastKnownPerfectCount = 0;
  int _lastKnownFastestClear = 0;
  int _lastKnownTotalLevels = 0;
  int _lastKnownProLevels = 0;
  int _lastKnownArcadeWins = 0;
  int _lastKnownLifetimeCoins = 0;
  int _lastKnownDailyLevels = 0;
  int _lastKnownDailyArcade = 0;

  // Throttling flag for performance
  bool _isCheckingAchievements = false;
  DateTime _lastAchievementCheck = DateTime.fromMillisecondsSinceEpoch(0);

  GameEvent? get currentEvent {
    final event = EventConfig.getActiveEvent(
      DateTime.now().millisecondsSinceEpoch,
    );
    return event.id == activeEventId ? event : null;
  }

  bool get shouldShowStreakPopup {
    if (!isDataLoaded) return false;
    if (_streakPopupShownThisSession) return false;
    final today = todayStamp;
    return lastStreakDay != today;
  }

  int get nextStreakDay {
    final today = todayStamp;
    if (lastStreakDay == today) {
      return streakCount == 0 ? 1 : streakCount;
    }
    if (streakCount == 0) return 1;
    if (streakCount >= 7) return 1;
    return streakCount + 1;
  }

  bool get streakClaimedToday => lastStreakDay == todayStamp;

  int get _daysSinceLastClaim {
    if (lastStreakDay == 0) return 999;
    final now = DateTime.now();
    final todayMid = DateTime(now.year, now.month, now.day);
    final int y = lastStreakDay ~/ 10000;
    final int m = (lastStreakDay ~/ 100) % 100;
    final int d = lastStreakDay % 100;
    final lastMid = DateTime(y, m, d);
    return todayMid.difference(lastMid).inDays;
  }

  bool get isStreakAtRisk {
    final gap = _daysSinceLastClaim;
    return gap == 2;
  }

  bool get isStreakBroken {
    final gap = _daysSinceLastClaim;
    return gap > 2;
  }

  bool get canUseStreakFreeze {
    if (streakFreezeHeld <= 0) return false;
    if (streakClaimedToday) return false;
    return _daysSinceLastClaim == 2;
  }

  Map<String, dynamic>? claimStreakReward() {
    final today = todayStamp;
    if (lastStreakDay == today) return null;

    final gap = _daysSinceLastClaim;
    bool continueStreak = false;
    bool freezeConsumed = false;
    if (streakCount == 0) {
      continueStreak = false;
    } else if (gap <= 1) {
      continueStreak = true;
    } else if (gap == 2 && streakFreezeHeld > 0) {
      streakFreezeHeld--;
      freezeConsumed = true;
      continueStreak = true;
    } else {
      continueStreak = false;
    }

    int newCount;
    if (!continueStreak) {
      newCount = 1;
    } else if (streakCount >= 7) {
      newCount = 1;
    } else {
      newCount = streakCount + 1;
    }

    String rewardType = 'coins';
    int rewardAmount = 0;
    if (newCount == 7) {
      rewardType = 'diamonds';
      rewardAmount = Eco.streakDay7Diamonds;
      totalDiamonds += rewardAmount;
      _addEventProgress('diamonds', rewardAmount);
    } else {
      rewardAmount = Eco.streakCoinForDay(newCount);
      _earnCoins(rewardAmount);
    }

    streakCount = newCount;
    lastStreakDay = today;
    streakFreezeUsedToday = freezeConsumed;

    if (newCount >= 3) _addEventProgress('streak', 1);

    _saveData();
    notifyListeners();

    checkAchievementPopups();

    return {
      'day': newCount,
      'rewardType': rewardType,
      'rewardAmount': rewardAmount,
      'streakFreezeUsed': freezeConsumed,
      'continueStreak': continueStreak,
    };
  }

  bool buyStreakFreeze() {
    if (streakFreezeHeld >= Eco.streakFreezeMaxHeld) return false;
    if (totalPoints < Eco.streakFreezeCoinPrice) return false;
    totalPoints -= Eco.streakFreezeCoinPrice;
    streakFreezeHeld++;

    _addEventProgress('buy_shop', 1);
    _addEventProgress('spend', Eco.streakFreezeCoinPrice);

    _saveData();
    notifyListeners();
    return true;
  }

  void markStreakPopupShown() {
    _streakPopupShownThisSession = true;
    notifyListeners();
  }

  // ================================================================
  // THEMES
  // ================================================================
  List<String> unlockedThemes = ['classic'];
  List<String> triedThemes = [];
  String activeThemeId = 'classic';
  String? previewThemeId;
  final ValueNotifier<int> previewSecondsLeft = ValueNotifier<int>(0);
  Timer? _previewTimer;
  int _previewEndMs = 0;

  ArrowTheme get currentTheme => AppTheme.byId(previewThemeId ?? activeThemeId);

  bool get isPreviewingTheme => previewThemeId != null;

  bool isThemeUnlocked(String id) =>
      id == 'classic' || unlockedThemes.contains(id);

  bool hasTriedTheme(String id) => triedThemes.contains(id);

  void _applyThemeGlobally() {
    AppTheme.active = currentTheme;
  }

  bool startThemePreview(String id) {
    if (id == 'classic' || isThemeUnlocked(id) || hasTriedTheme(id)) {
      return false;
    }
    if (!AppTheme.all.any((t) => t.id == id)) return false;
    if (previewThemeId != null) return false;
    _previewTimer?.cancel();
    triedThemes.add(id);
    previewThemeId = id;
    _previewEndMs =
        DateTime.now().millisecondsSinceEpoch + Eco.themePreviewSeconds * 1000;
    previewSecondsLeft.value = Eco.themePreviewSeconds;
    _previewTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final int left =
          ((_previewEndMs - DateTime.now().millisecondsSinceEpoch) / 1000)
              .ceil();
      if (left <= 0) {
        endThemePreview();
      } else {
        previewSecondsLeft.value = left;
      }
    });
    _applyThemeGlobally();
    _saveData();
    notifyListeners();
    return true;
  }

  void endThemePreview() {
    _previewTimer?.cancel();
    _previewTimer = null;
    if (previewThemeId == null) return;
    previewThemeId = null;
    previewSecondsLeft.value = 0;
    _applyThemeGlobally();
    notifyListeners();
  }

  bool buyTheme(String id) {
    if (id == 'classic' || isThemeUnlocked(id)) return false;
    if (!AppTheme.all.any((t) => t.id == id)) return false;
    final int themeCost = AppTheme.byId(id).price; // regular vs premium price
    if (totalPoints < themeCost) return false;
    totalPoints -= themeCost;
    unlockedThemes.add(id);
    activeThemeId = id;
    _previewTimer?.cancel();
    _previewTimer = null;
    previewThemeId = null;
    previewSecondsLeft.value = 0;
    _applyThemeGlobally();

    _addEventProgress('buy_shop', 1);
    _addEventProgress('spend', themeCost);
    _addEventProgress('theme', 1);

    _saveData();
    notifyListeners();
    return true;
  }

  bool setActiveTheme(String id) {
    if (!isThemeUnlocked(id)) return false;
    activeThemeId = id;
    _previewTimer?.cancel();
    _previewTimer = null;
    previewThemeId = null;
    previewSecondsLeft.value = 0;
    _applyThemeGlobally();

    _addEventProgress('theme', 1);

    _saveData();
    notifyListeners();
    return true;
  }

  // ================================================================
  // CUSTOM GRIDS  (visual only — same flow as themes: trial / buy / apply)
  // ================================================================
  List<String> unlockedGrids = [GridStyles.defaultId];
  List<String> triedGrids = [];
  String activeGridId = GridStyles.defaultId;
  String? previewGridId;
  final ValueNotifier<int> gridPreviewSecondsLeft = ValueNotifier<int>(0);
  Timer? _gridPreviewTimer;
  int _gridPreviewEndMs = 0;

  GridStyle get currentGrid => GridStyles.byId(previewGridId ?? activeGridId);

  bool get isPreviewingGrid => previewGridId != null;

  bool isGridUnlocked(String id) =>
      id == GridStyles.defaultId || unlockedGrids.contains(id);

  bool hasTriedGrid(String id) => triedGrids.contains(id);

  bool startGridPreview(String id) {
    if (id == GridStyles.defaultId || isGridUnlocked(id) || hasTriedGrid(id)) {
      return false;
    }
    if (!GridStyles.all.any((g) => g.id == id)) return false;
    if (previewGridId != null) return false;
    _gridPreviewTimer?.cancel();
    triedGrids.add(id);
    previewGridId = id;
    _gridPreviewEndMs =
        DateTime.now().millisecondsSinceEpoch + Eco.gridPreviewSeconds * 1000;
    gridPreviewSecondsLeft.value = Eco.gridPreviewSeconds;
    _gridPreviewTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final int left =
          ((_gridPreviewEndMs - DateTime.now().millisecondsSinceEpoch) / 1000)
              .ceil();
      if (left <= 0) {
        endGridPreview();
      } else {
        gridPreviewSecondsLeft.value = left;
      }
    });
    _saveData();
    notifyListeners();
    return true;
  }

  void endGridPreview() {
    _gridPreviewTimer?.cancel();
    _gridPreviewTimer = null;
    if (previewGridId == null) return;
    previewGridId = null;
    gridPreviewSecondsLeft.value = 0;
    notifyListeners();
  }

  bool buyGrid(String id) {
    if (id == GridStyles.defaultId || isGridUnlocked(id)) return false;
    if (!GridStyles.all.any((g) => g.id == id)) return false;
    final int gridCost = GridStyles.byId(id).price; // regular vs premium price
    if (totalPoints < gridCost) return false;
    totalPoints -= gridCost;
    unlockedGrids.add(id);
    activeGridId = id;
    _gridPreviewTimer?.cancel();
    _gridPreviewTimer = null;
    previewGridId = null;
    gridPreviewSecondsLeft.value = 0;

    _addEventProgress('buy_shop', 1);
    _addEventProgress('spend', gridCost);

    _saveData();
    notifyListeners();
    return true;
  }

  bool setActiveGrid(String id) {
    if (!isGridUnlocked(id)) return false;
    activeGridId = id;
    _gridPreviewTimer?.cancel();
    _gridPreviewTimer = null;
    previewGridId = null;
    gridPreviewSecondsLeft.value = 0;

    _saveData();
    notifyListeners();
    return true;
  }

  int dailyLevelsCompleted = 0;
  int dailyArcadeGamesWon = 0;
  int lastDailyTaskDate = 0;

  List<ArrowModel> arrows = [];
  List<List<int>> owner = [];

  // CUSTOM GRID SHAPE of the board that is on screen right now.
  // Empty mask = normal square board (original behaviour).
  List<List<bool>> boardMask = [];
  String boardShapeId = GridStyles.defaultId;
  bool get hasBoardShape => boardMask.isNotEmpty;
  bool _isVoidCell(int x, int y) => boardMask.isNotEmpty && !boardMask[y][x];
  Map<int, LevelRecord> levelRecords = {};

  int _loadToken = 0;
  static const int maxClassicLevel = 2000;
  static const int maxProLevel = 500;

  final SaveStorage _storage = SaveStorage();
  Future<void> _saveChain = Future<void>.value();

  Future<void> init() async {
    try {
      final saved = await _storage.load();
      totalPoints = saved.totalPoints;
      totalDiamonds = saved.totalDiamonds;
      autoSolveInventory = saved.autoSolveInventory;
      classicUnlockedLevel = saved.classicUnlocked;
      proUnlockedLevel = saved.proUnlocked;
      levelRecords = Map<int, LevelRecord>.from(saved.levelRecords);
      lastDailyCompletedDate = saved.lastDailyCompletedDate;
      freezeInventory = saved.freezeItems;
      healthInventory = saved.healthItems;

      totalPlayTimeSeconds = saved.totalPlayTimeSeconds;
      totalLevelsCompleted = saved.totalLevelsCompleted;
      proLevelsCompleted = saved.proLevelsCompleted;
      hasSpeedRun = saved.hasSpeedRun;
      hasCompletedDaily = saved.hasCompletedDaily;
      hasPerfectClear = saved.hasPerfectClear;

      arcadePlayTimeSeconds = saved.arcadePlayTimeSeconds;
      arcadeGamesWon = saved.arcadeGamesWon;
      maxArcadeCoinsEarned = saved.maxArcadeCoinsEarned;

      dailyMinigamesPlayed = saved.dailyMinigamesPlayed;
      lastMinigameDate = saved.lastMinigameDate;
      claimedTaskIds = List.from(saved.claimedTaskIds);
      lastLuckyDrawDate = saved.lastLuckyDrawDate;
      dailyLevelsCompleted = saved.dailyLevelsCompleted;
      dailyArcadeGamesWon = saved.dailyArcadeGamesWon;
      lastDailyTaskDate = saved.lastDailyTaskDate;

      lifetimeCoinsEarned = saved.lifetimeCoinsEarned;
      perfectLevelsCount = saved.perfectLevelsCount;
      fastestClearSeconds = saved.fastestClearSeconds;
      starterGranted = saved.starterGranted;
      replayCoinsToday = saved.replayCoinsToday;
      lastReplayDate = saved.lastReplayDate;
      lastSeenMs = saved.lastSeenMs;
      unlockedThemes = List<String>.from(saved.unlockedThemes);
      if (!unlockedThemes.contains('classic'))
        unlockedThemes.insert(0, 'classic');
      triedThemes = List<String>.from(saved.triedThemes);
      activeThemeId = isThemeUnlocked(saved.activeTheme)
          ? saved.activeTheme
          : 'classic';
      unlockedGrids = List<String>.from(saved.unlockedGrids);
      if (!unlockedGrids.contains(GridStyles.defaultId)) {
        unlockedGrids.insert(0, GridStyles.defaultId);
      }
      triedGrids = List<String>.from(saved.triedGrids);
      activeGridId = isGridUnlocked(saved.activeGrid)
          ? saved.activeGrid
          : GridStyles.defaultId;
      streakCount = saved.streakCount;
      lastStreakDay = saved.lastStreakDay;
      streakFreezeHeld = saved.streakFreezeHeld;
      streakFreezeUsedToday = saved.streakFreezeUsedToday;

      activeEventId = saved.activeEventId;
      eventProgress = saved.eventProgress;
      claimedEventIds = List.from(saved.claimedEventIds);
      isEventActive = saved.isEventActive;

      leaderboardCoins = List<Map<String, dynamic>>.from(
        saved.leaderboardCoins.map((e) => Map<String, dynamic>.from(e)),
      );
      leaderboardSpeed = List<Map<String, dynamic>>.from(
        saved.leaderboardSpeed.map((e) => Map<String, dynamic>.from(e)),
      );
      leaderboardStreak = List<Map<String, dynamic>>.from(
        saved.leaderboardStreak.map((e) => Map<String, dynamic>.from(e)),
      );
      _achievementPopupsShown = saved.achievementPopupsShown.toSet();

      _applyThemeGlobally();
      if (lifetimeCoinsEarned < totalPoints) lifetimeCoinsEarned = totalPoints;
      if (hasPerfectClear && perfectLevelsCount == 0) perfectLevelsCount = 1;
      if (hasSpeedRun && fastestClearSeconds == 0) fastestClearSeconds = 5;

      _checkMinigameReset();
      _checkDailyTaskReset();

      if (leaderboardCoins.isEmpty && levelRecords.isNotEmpty) {
        _backfillLeaderboardFromHistory();
      }
    } catch (e) {
      debugPrint('GameProvider.init load fail: $e');
    }

    bool starterJustGranted = false;
    if (!starterGranted) {
      final bool freshInstall =
          totalLevelsCompleted == 0 &&
          classicUnlockedLevel == 1 &&
          proUnlockedLevel == 1 &&
          totalPoints == 0 &&
          freezeInventory == 0 &&
          healthInventory == 0 &&
          autoSolveInventory == 0;
      if (freshInstall) {
        freezeInventory = Eco.starterFreeze;
        healthInventory = Eco.starterHealth;
        autoSolveInventory = Eco.starterAutoSolve;
      }
      starterGranted = true;
      starterJustGranted = true;
    }

    if (classicUnlockedLevel < 1) classicUnlockedLevel = 1;
    if (classicUnlockedLevel > maxClassicLevel)
      classicUnlockedLevel = maxClassicLevel;
    if (proUnlockedLevel < 1) proUnlockedLevel = 1;
    if (proUnlockedLevel > maxProLevel) proUnlockedLevel = maxProLevel;
    if (totalPoints < 0) totalPoints = 0;

    await _loadTutorialState();
    if (!tutorialCompleted) {
      final bool isNewPlayer =
          totalLevelsCompleted <= 1 &&
          classicUnlockedLevel <= 2 &&
          proUnlockedLevel <= 1;
      if (isNewPlayer) {
        tutorialStep = TutorialManager.stepPlay;
      } else {
        tutorialCompleted = true;
        _saveTutorialCompleted(true);
      }
    }

    currentLevel = classicUnlockedLevel;
    isProMode = false;
    _setupLevel(currentLevel);
    isDataLoaded = true;

    _rotateEventIfNeeded();

    _lastKnownPerfectCount = perfectLevelsCount;
    _lastKnownFastestClear = fastestClearSeconds;
    _lastKnownTotalLevels = totalLevelsCompleted;
    _lastKnownProLevels = proLevelsCompleted;
    _lastKnownArcadeWins = arcadeGamesWon;
    _lastKnownLifetimeCoins = lifetimeCoinsEarned;
    _lastKnownDailyLevels = dailyLevelsCompleted;
    _lastKnownDailyArcade = dailyArcadeGamesWon;

    if (starterJustGranted) _saveData();
    notifyListeners();
  }

  void _backfillLeaderboardFromHistory() {
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final List<Map<String, dynamic>> coinEntries = [];
    final List<Map<String, dynamic>> streakEntries = [];

    levelRecords.forEach((key, record) {
      if (record.bestCoins > 0) {
        final bool isPro = key > 10000;
        final int level = isPro ? (key - 10000) : key;
        coinEntries.add({
          'coins': record.bestCoins,
          'level': level,
          'isPro': isPro,
          'stars': 3,
          'time': record.bestTimeSeconds,
          'date': nowMs,
        });
      }
    });

    coinEntries.sort(
      (a, b) => (b['coins'] as int).compareTo(a['coins'] as int),
    );
    leaderboardCoins = coinEntries.take(_leaderboardMaxEntries).toList();

    if (streakCount > 0) {
      streakEntries.add({'streak': streakCount, 'date': nowMs});
      leaderboardStreak = streakEntries;
    }

    _saveData();
  }

  int get todayStamp {
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    if (nowMs > lastSeenMs) lastSeenMs = nowMs;
    final d = DateTime.fromMillisecondsSinceEpoch(lastSeenMs);
    return d.year * 10000 + d.month * 100 + d.day;
  }

  int get dailyChallengeReward => Eco.dailyChallengeReward(
    getLevelCost(classicUnlockedLevel + 1, pro: false),
  );

  static int recordKeyFor(int level, bool pro) => pro ? (10000 + level) : level;

  void _checkReplayReset() {
    final int today = todayStamp;
    if (lastReplayDate != today) {
      lastReplayDate = today;
      replayCoinsToday = 0;
    }
  }

  void _checkDailyTaskReset() {
    final int today = todayStamp;
    if (lastDailyTaskDate != today) {
      lastDailyTaskDate = today;
      dailyLevelsCompleted = 0;
      dailyArcadeGamesWon = 0;
      claimedTaskIds.removeWhere((id) => id.startsWith('daily_'));
      _saveData();
    }
  }

  void _checkMinigameReset() {
    final int today = todayStamp;
    if (lastMinigameDate != today) {
      lastMinigameDate = today;
      dailyMinigamesPlayed = 0;
      _saveData();
    }
  }

  bool get canPlayMinigame {
    _checkMinigameReset();
    return dailyMinigamesPlayed < maxMinigamesPerDay;
  }

  void recordMinigamePlayed() {
    _checkMinigameReset();
    if (dailyMinigamesPlayed < maxMinigamesPerDay) {
      dailyMinigamesPlayed++;
      _saveData();
      notifyListeners();
    }
  }

  bool get canPlayLuckyDraw {
    final today = todayStamp;
    return lastLuckyDrawDate != today;
  }

  void _earnCoins(int amount) {
    if (amount <= 0) return;
    totalPoints += amount;
    lifetimeCoinsEarned += amount;

    _addEventProgress('coins', amount);
  }

  Map<String, dynamic> drawLuckyGift() {
    final today = todayStamp;
    lastLuckyDrawDate = today;

    final random = Random();
    final int type = random.nextInt(3);
    String giftTitle = '';
    String giftIcon = '';
    Color giftColor = Colors.amber;

    if (type == 0) {
      totalDiamonds += Eco.luckyDiamonds;
      giftTitle = '${Eco.luckyDiamonds} Diamonds';
      giftIcon = 'diamond';
      giftColor = Colors.cyan;

      _addEventProgress('diamonds', Eco.luckyDiamonds);
    } else if (type == 1) {
      _earnCoins(Eco.luckyCoins);
      giftTitle = '${_fmt(Eco.luckyCoins)} Coins';
      giftIcon = 'coin';
      giftColor = Colors.amber;
    } else {
      final powers = [0, 1, 2];
      powers.shuffle(random);
      int powerType = powers.first;

      if (powerType == 2 &&
          random.nextInt(10) >= Eco.luckyAutoSolveKeepOutOf10) {
        powerType = random.nextBool() ? 0 : 1;
      }

      if (powerType == 0) {
        freezeInventory++;
        giftTitle = 'Time Freeze Power';
        giftIcon = 'freeze';
        giftColor = Colors.lightBlue;
      } else if (powerType == 1) {
        healthInventory++;
        giftTitle = 'Extra Life Power';
        giftIcon = 'health';
        giftColor = Colors.redAccent;
      } else {
        autoSolveInventory++;
        giftTitle = 'Mega Auto-Solve Power';
        giftIcon = 'auto_solve';
        giftColor = Colors.deepPurpleAccent;
      }
    }

    _addEventProgress('lucky', 1);

    _saveData();
    notifyListeners();

    return {'title': giftTitle, 'icon': giftIcon, 'color': giftColor};
  }

  static String _fmt(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  Future<void> _saveData() async {
    final data = SaveData(
      classicUnlocked: classicUnlockedLevel,
      proUnlocked: proUnlockedLevel,
      totalPoints: totalPoints,
      totalDiamonds: totalDiamonds,
      autoSolveInventory: autoSolveInventory,
      savedAt: DateTime.now().millisecondsSinceEpoch,
      levelRecords: levelRecords,
      lastDailyCompletedDate: lastDailyCompletedDate,
      freezeItems: freezeInventory,
      healthItems: healthInventory,
      totalPlayTimeSeconds: totalPlayTimeSeconds,
      totalLevelsCompleted: totalLevelsCompleted,
      proLevelsCompleted: proLevelsCompleted,
      hasSpeedRun: hasSpeedRun,
      hasCompletedDaily: hasCompletedDaily,
      hasPerfectClear: hasPerfectClear,
      arcadePlayTimeSeconds: arcadePlayTimeSeconds,
      arcadeGamesWon: arcadeGamesWon,
      maxArcadeCoinsEarned: maxArcadeCoinsEarned,
      dailyMinigamesPlayed: dailyMinigamesPlayed,
      lastMinigameDate: lastMinigameDate,
      claimedTaskIds: claimedTaskIds,
      lastLuckyDrawDate: lastLuckyDrawDate,
      dailyLevelsCompleted: dailyLevelsCompleted,
      dailyArcadeGamesWon: dailyArcadeGamesWon,
      lastDailyTaskDate: lastDailyTaskDate,
      lifetimeCoinsEarned: lifetimeCoinsEarned,
      perfectLevelsCount: perfectLevelsCount,
      fastestClearSeconds: fastestClearSeconds,
      starterGranted: starterGranted,
      replayCoinsToday: replayCoinsToday,
      lastReplayDate: lastReplayDate,
      lastSeenMs: lastSeenMs,
      unlockedThemes: List<String>.from(unlockedThemes),
      activeTheme: activeThemeId,
      triedThemes: List<String>.from(triedThemes),
      unlockedGrids: List<String>.from(unlockedGrids),
      activeGrid: activeGridId,
      triedGrids: List<String>.from(triedGrids),
      streakCount: streakCount,
      lastStreakDay: lastStreakDay,
      streakFreezeHeld: streakFreezeHeld,
      streakFreezeUsedToday: streakFreezeUsedToday,
      activeEventId: activeEventId,
      eventProgress: eventProgress,
      claimedEventIds: List<String>.from(claimedEventIds),
      isEventActive: isEventActive,
      leaderboardCoins: List<Map<String, dynamic>>.from(
        leaderboardCoins.map((e) => Map<String, dynamic>.from(e)),
      ),
      leaderboardSpeed: List<Map<String, dynamic>>.from(
        leaderboardSpeed.map((e) => Map<String, dynamic>.from(e)),
      ),
      leaderboardStreak: List<Map<String, dynamic>>.from(
        leaderboardStreak.map((e) => Map<String, dynamic>.from(e)),
      ),
      achievementPopupsShown: _achievementPopupsShown.toList(),
    );
    _saveChain = _saveChain
        .then<void>((_) async {
          await _storage.save(data);
          notifyListeners();
        })
        .catchError((Object e) {
          debugPrint('GameProvider save fail: $e');
        });
    return _saveChain;
  }

  Future<void> saveDataNow() => _saveData();

  Future<void> resetProgress() async {
    await _storage.clearAll();
    classicUnlockedLevel = 1;
    proUnlockedLevel = 1;
    totalPoints = 0;
    totalDiamonds = 0;
    autoSolveInventory = 0;
    levelRecords.clear();
    lastDailyCompletedDate = 0;
    freezeInventory = 0;
    healthInventory = 0;
    currentLevel = 1;
    isProMode = false;

    totalPlayTimeSeconds = 0;
    totalLevelsCompleted = 0;
    proLevelsCompleted = 0;
    hasSpeedRun = false;
    hasCompletedDaily = false;
    hasPerfectClear = false;
    arcadePlayTimeSeconds = 0;
    arcadeGamesWon = 0;
    maxArcadeCoinsEarned = 0;
    dailyMinigamesPlayed = 0;
    lastMinigameDate = 0;
    claimedTaskIds.clear();
    lastLuckyDrawDate = 0;
    dailyLevelsCompleted = 0;
    dailyArcadeGamesWon = 0;
    lastDailyTaskDate = 0;
    lifetimeCoinsEarned = 0;
    perfectLevelsCount = 0;
    fastestClearSeconds = 0;
    replayCoinsToday = 0;
    lastReplayDate = 0;
    unlockedThemes = ['classic'];
    triedThemes = [];
    activeThemeId = 'classic';
    _previewTimer?.cancel();
    _previewTimer = null;
    previewThemeId = null;
    previewSecondsLeft.value = 0;
    _applyThemeGlobally();
    unlockedGrids = [GridStyles.defaultId];
    triedGrids = [];
    activeGridId = GridStyles.defaultId;
    _gridPreviewTimer?.cancel();
    _gridPreviewTimer = null;
    previewGridId = null;
    gridPreviewSecondsLeft.value = 0;
    streakCount = 0;
    lastStreakDay = 0;
    streakFreezeHeld = 0;
    streakFreezeUsedToday = false;
    _streakPopupShownThisSession = false;

    activeEventId = '';
    eventProgress = 0;
    claimedEventIds.clear();
    isEventActive = false;

    leaderboardCoins.clear();
    leaderboardSpeed.clear();
    leaderboardStreak.clear();
    _achievementPopupQueue.clear();
    _achievementPopupsShown.clear();

    starterGranted = true;

    _setupLevel(1);
    notifyListeners();
    await _saveData();
  }

  void leaveLevel() {
    _timer?.cancel();
    _loadToken++;
  }

  void loadLevel(int level) {
    isProMode = false;
    isDailyChallenge = false;
    _setupLevel(level);
    _startTimer();
    notifyListeners();
  }

  void loadProLevel(int level) {
    isProMode = true;
    isDailyChallenge = false;
    _setupLevel(level);
    _startTimer();
    notifyListeners();
  }

  void startDailyChallenge(int levelNum, bool isPro) {
    isDailyChallenge = true;
    isProMode = isPro;
    final int cap = isPro ? 40 : 60;
    final int safeLevel = ((levelNum - 1) % cap) + 1;
    _setupLevel(safeLevel);
    _startTimer();
    notifyListeners();
  }

  void _setupLevel(int level) {
    _loadToken++;
    _freezeToken++;
    currentLevel = level;
    isLevelComplete = false;
    isGameOver = false;
    isLevelFailed = false;
    lives = 3;
    moves = 0;
    levelPointsEarned = 0;
    levelStars = 3;
    usedAutoSolve = false;
    isReplayReward = false;
    replayImprovementBonus = 0;
    replayLimitHit = false;
    usedFreezeThisLevel = false;
    timeTaken = 0;
    isTimeFrozen = false;

    if (isProMode) {
      // Daily challenge ka purana formula same rakha hai (koi change nahi).
      // Normal Pro levels: 15 -> 20 poore 500 levels par barabar phailta hai.
      gridSize = isDailyChallenge
          ? min(20, 15 + (level ~/ 20))
          : getProGridSizeForLevel(level);
    } else {
      gridSize = getGridSizeForLevel(level);
    }
    baseGridSize = gridSize;

    // BOSS LEVEL (har 100th level, daily challenge mein nahi):
    // Classic mein grid +2 (max 20) aur chhote arrows => ~2x arrows.
    // Pro mein grid pehle hi bara hai, isliye sirf chhote arrows => ~1.5x.
    if (isBossNow && !isProMode) {
      gridSize = min(20, gridSize + 2);
    }

    _setupBoardShape();
    _generate(level);

    totalTime = _timeForCurrentBoard();
    if (isDailyChallenge && !isProMode) totalTime = (totalTime * 0.8).round();
    timeLeft = totalTime;
  }

  // ---------------- BOSS LEVELS ----------------
  // Har 100th level (100, 200, 300 ...) boss hai. Freeze allowed nahi.
  static bool isBossLevel(int level) => level > 0 && level % 100 == 0;

  bool get isBossNow => !isDailyChallenge && isBossLevel(currentLevel);

  /// Pro grid: level 1 par 15, level 500 par 20 (15,16,17,18,19,20 barabar steps).
  int getProGridSizeForLevel(int level) {
    final int l = level.clamp(1, maxProLevel).toInt();
    return min(20, 15 + ((l - 1) * 6) ~/ maxProLevel);
  }

  int _timeForCurrentBoard() {
    if (isProMode) {
      // Per-arrow time hai, isliye boss ke ziada arrows ko khud time mil jata hai.
      return (arrows.length * 0.62).ceil() + 4;
    }
    final int normalTime =
        getLevelTime(currentLevel) + 2 + (currentLevel ~/ 100);
    if (isBossNow) {
      // Normal board mein ~0.25 * n * n arrows hote hain. Boss ke arrows us
      // hisaab se barhe hain, to time bhi barabar scale hota hai (same pace).
      final double expected = baseGridSize * baseGridSize * 0.25;
      final int scaled = (arrows.length * normalTime / expected).ceil();
      return max(normalTime, scaled);
    }
    return normalTime;
  }

  int getLevelTime(int level) {
    if (level <= 10) return 12;
    if (level <= 30) return 15;
    if (level <= 60) return 16;
    if (level <= 100) return 18;
    if (level <= 200) return 21;
    if (level <= 350) return 24;
    if (level <= 600) return 27;
    if (level <= 1000) return 29;
    if (level <= 1500) return 31;
    return 33;
  }

  int getGridSizeForLevel(int level) {
    if (level <= 10) return 6;
    if (level <= 30) return 7;
    if (level <= 60) return 8;
    if (level <= 100) return 9;
    if (level <= 150) return 10;
    if (level <= 250) return 11;
    if (level <= 350) return 12;
    if (level <= 450) return 13;
    if (level <= 700) return 14;
    if (level <= 1000) return 15;
    if (level <= 1400) return 16;
    if (level <= 1800) return 17;
    return 18;
  }

  String getDifficultyText(int level) {
    if (isProMode) return "EXTREME";
    if (level <= 10) return "Easy";
    if (level <= 30) return "Medium";
    if (level <= 100) return "Hard";
    if (level <= 250) return "Expert";
    if (level <= 700) return "Extreme";
    if (level <= 1200) return "Master";
    return "Legendary";
  }

  int getLevelCost(int level, {bool? pro}) {
    final bool isPro = pro ?? isProMode;
    if (level <= 1) return 0;
    if (isPro) {
      if (level <= 40) return 100 + ((level - 2) * 40);
      if (level <= 80) return 1620 + ((level - 40) * 80);
      if (level <= 100) return 4820 + ((level - 80) * 120);
      return 7220 + ((level - 100) * 100);
    }
    if (level <= 50) return 50 + ((level - 2) * 30);
    if (level <= 200) return 1490 + ((level - 50) * 60);
    if (level <= 500) return 10490 + ((level - 200) * 40);
    return 22490 + ((level - 500) * 30);
  }

  bool get isLastLevel =>
      !isDailyChallenge &&
      currentLevel >= (isProMode ? maxProLevel : maxClassicLevel);

  void _startTimer() {
    _timer?.cancel();
    if (tutorialStep > 0 && currentLevel == 1 && !isProMode) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isTimeFrozen && timeLeft > 0 && !isLevelComplete && !isGameOver) {
        timeLeft--;
        timeTaken++;
        totalPlayTimeSeconds++;
        notifyListeners();
      } else if (timeLeft <= 0 && !isLevelComplete && !isGameOver) {
        timer.cancel();
        isLevelFailed = true;
        notifyListeners();
      }
    });
  }

  bool get isTutorialActive => tutorialStep > 0;

  int? get tutorialTargetArrowId {
    int? best;
    double bestDist = double.infinity;
    final double c = (gridSize - 1) / 2.0;
    for (final a in arrows) {
      if (a.isExiting || !canEscape(a)) continue;
      final GridCell mid = a.cells[a.cells.length ~/ 2];
      final double d = (mid.x - c).abs() + (mid.y - c).abs();
      if (d < bestDist) {
        bestDist = d;
        best = a.id;
      }
    }
    return best;
  }

  Future<void> _loadTutorialState() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 3),
      );
      tutorialCompleted = prefs.getBool(_tutorialPrefsKey) ?? false;
    } catch (e) {
      debugPrint('GameProvider tutorial load fail: $e');
      tutorialCompleted = false;
    }
  }

  Future<void> _saveTutorialCompleted(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_tutorialPrefsKey, value);
    } catch (e) {
      debugPrint('GameProvider tutorial save fail: $e');
    }
  }

  void setTutorialStep(int step) {
    tutorialStep = step;
    tutorialInputLocked = false;
    notifyListeners();
  }

  void onTutorialTabSelected(int tabIndex) {
    if (tutorialStep == 0) return;
    if (TutorialManager.tabIndexForStep(tutorialStep) == tabIndex) {
      setTutorialStep(tutorialStep + 1);
    }
  }

  void completeTutorial() {
    final bool wasPlaying =
        tutorialStep == TutorialManager.stepGameArrow &&
        !isLevelComplete &&
        !isGameOver &&
        !isLevelFailed;
    tutorialStep = TutorialManager.stepOff;
    tutorialInputLocked = false;
    tutorialCompleted = true;
    tutorialFinishCount++;
    _saveTutorialCompleted(true);
    if (wasPlaying) _startTimer();
    notifyListeners();
  }

  void abortTutorial() {
    if (tutorialStep == TutorialManager.stepOff) return;
    tutorialStep = TutorialManager.stepOff;
    tutorialInputLocked = false;
    tutorialCompleted = true;
    tutorialFinishCount++;
    _saveTutorialCompleted(true);
    notifyListeners();
  }

  void restartTutorialFromSettings() {
    tutorialStep = TutorialManager.stepOff;
    tutorialCompleted = false;
    tutorialInputLocked = false;
    _saveTutorialCompleted(false);
    tutorialStep = TutorialManager.stepGameArrow;
    loadLevel(1);
  }

  void _onTutorialArrowCleared() {
    if (tutorialStep != TutorialManager.stepGameArrow) return;
    if (tutorialInputLocked) return;
    tutorialInputLocked = true;
    final int token = _loadToken;
    Future.delayed(const Duration(milliseconds: 650), () {
      if (token != _loadToken) return;
      if (tutorialStep != TutorialManager.stepGameArrow) return;
      _clearRemainingArrowsForTutorial();
    });
  }

  void _clearRemainingArrowsForTutorial() {
    if (isLevelComplete || isGameOver || isLevelFailed) return;
    final now = gameClock.elapsedMilliseconds;
    for (final a in arrows) {
      if (!a.isExiting) {
        for (final c in a.cells) {
          owner[c.y][c.x] = -1;
        }
        a.isExiting = true;
        a.exitStartMs = now;
        a.exitTravelCells = (a.length - 1) + gridSize + 1.0;
        a.exitDurationMs = min(
          1200,
          max(420, (a.exitTravelCells / 26 * 1000).round()),
        );
      }
    }
    notifyListeners();
    _checkWin();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _previewTimer?.cancel();
    _gridPreviewTimer?.cancel();
    _popupAutoDismissTimer?.cancel();
    previewSecondsLeft.dispose();
    gridPreviewSecondsLeft.dispose();
    super.dispose();
  }

  bool buyFreezeItem() {
    if (totalPoints < Eco.freezeCoinPrice) return false;
    totalPoints -= Eco.freezeCoinPrice;
    freezeInventory++;

    _addEventProgress('buy_shop', 1);
    _addEventProgress('spend', Eco.freezeCoinPrice);

    _saveData();
    notifyListeners();
    return true;
  }

  bool buyHealthItem() {
    if (totalPoints < Eco.healthCoinPrice) return false;
    totalPoints -= Eco.healthCoinPrice;
    healthInventory++;

    _addEventProgress('buy_shop', 1);
    _addEventProgress('spend', Eco.healthCoinPrice);

    _saveData();
    notifyListeners();
    return true;
  }

  bool buyAutoSolveItem({required bool withDiamonds}) {
    if (withDiamonds) {
      if (totalDiamonds < Eco.autoSolveDiamondPrice) return false;
      totalDiamonds -= Eco.autoSolveDiamondPrice;
    } else {
      if (totalPoints < Eco.autoSolveCoinPrice) return false;
      totalPoints -= Eco.autoSolveCoinPrice;
    }
    autoSolveInventory++;

    _addEventProgress('buy_shop', 1);
    if (!withDiamonds) _addEventProgress('spend', Eco.autoSolveCoinPrice);

    _saveData();
    notifyListeners();
    return true;
  }

  bool exchangeDiamondsForCoins(int diamonds) {
    final int units = diamonds ~/ Eco.exchangeDiamonds;
    if (units < 1) return false;
    final int spend = units * Eco.exchangeDiamonds;
    if (totalDiamonds < spend) return false;
    totalDiamonds -= spend;
    _earnCoins(units * Eco.exchangeCoins);

    _addEventProgress('spend', units * Eco.exchangeCoins);

    _saveData();
    notifyListeners();
    return true;
  }

  void useTimeFreeze() {
    if (isBossNow) return; // Boss level par freeze allowed nahi
    if (isTimeFrozen || isLevelComplete || isGameOver || isLevelFailed) return;
    if (freezeInventory > 0)
      freezeInventory--;
    else {
      if (totalPoints >= Eco.freezeCoinPrice)
        totalPoints -= Eco.freezeCoinPrice;
      else
        return;
    }
    isTimeFrozen = true;
    usedFreezeThisLevel = true;
    final int token = _freezeToken;

    _addEventProgress('use_freeze', 1);

    _saveData();
    notifyListeners();
    Future.delayed(const Duration(seconds: 15), () {
      if (token != _freezeToken) return;
      isTimeFrozen = false;
      notifyListeners();
    });
  }

  void useHealth() {
    if (lives >= 3 || isLevelComplete || isGameOver || isLevelFailed) return;
    if (healthInventory > 0)
      healthInventory--;
    else {
      if (totalPoints >= Eco.healthCoinPrice)
        totalPoints -= Eco.healthCoinPrice;
      else
        return;
    }
    lives++;
    _saveData();
    notifyListeners();
  }

  void useAutoSolve() {
    if (isLevelComplete || isGameOver || isLevelFailed) return;
    if (autoSolveInventory > 0) {
      autoSolveInventory--;
    } else {
      if (totalDiamonds >= Eco.autoSolveDiamondPrice) {
        totalDiamonds -= Eco.autoSolveDiamondPrice;
      } else if (totalPoints >= Eco.autoSolveCoinPrice) {
        totalPoints -= Eco.autoSolveCoinPrice;
      } else {
        return;
      }
    }

    _addEventProgress('use_solve', 1);

    _saveData();
    autoSolveLevel();
  }

  void autoSolveLevel() {
    if (isLevelComplete || isGameOver || isLevelFailed) return;
    usedAutoSolve = true;
    final now = gameClock.elapsedMilliseconds;
    for (final a in arrows) {
      if (!a.isExiting) {
        for (final c in a.cells) {
          owner[c.y][c.x] = -1;
        }
        a.isExiting = true;
        a.exitStartMs = now;
        a.exitTravelCells = (a.length - 1) + gridSize + 1.0;
        a.exitDurationMs = min(
          1200,
          max(420, (a.exitTravelCells / 26 * 1000).round()),
        );
      }
    }
    notifyListeners();
    _checkWin();
  }

  static const List<int> _dx = [0, 1, 0, -1];
  static const List<int> _dy = [-1, 0, 1, 0];

  /// Picks the board shape for the level that is about to be generated.
  /// Shapes are used only on normal Classic/Pro levels: tutorial, daily
  /// challenge and boss levels always stay on the original square board.
  void _setupBoardShape() {
    boardMask = [];
    boardShapeId = GridStyles.defaultId;
    final GridStyle g = currentGrid;
    if (g.isDefault) return;
    if (isDailyChallenge || isBossNow || tutorialStep > 0) return;
    final mask = GridStyles.buildMask(g, gridSize);
    // safety: shape must keep enough cells to hold a real level
    if (GridStyles.cellCount(mask) <
        max(12, (gridSize * gridSize * 0.4).floor())) {
      return;
    }
    boardMask = mask;
    boardShapeId = g.id;
  }

  // ==========================================================================
  // PERFECT-FILL GENERATOR FOR CUSTOM GRID SHAPES
  // --------------------------------------------------------------------------
  // Pehle arrows random place hote the aur shape ke andar kuch cells khali
  // (holes) reh jate the. Ab shape ko pehle POORI tarah arrows se tile kiya
  // jata hai (har playable cell kisi arrow ka hissa), phir arrows ki head ki
  // taraf aisi chunni jati hai ke level hamesha solvable rahe. Square board
  // (original) par is code ka koi asar nahi - wo purana _generate hi chalata hai.
  // ==========================================================================
  bool _generateShaped(int level) {
    final int n = gridSize;
    if (boardMask.length != n) return false;
    final int shapeIdx =
        1 + GridStyles.all.indexWhere((g) => g.id == boardShapeId);
    const int minLen = 3;
    final int maxLen = isProMode ? 6 : 5;

    for (int attempt = 0; attempt < 80; attempt++) {
      final rnd = Random(
        level * 7919 + 104729 + n * 1000 + shapeIdx * 131 + attempt * 15485863,
      );
      final paths = _tileShape(n, rnd, minLen, maxLen);
      if (paths == null) continue;
      final oriented = _orientPaths(n, paths, rnd);
      if (oriented == null) continue;

      final newOwner = List.generate(n, (_) => List<int>.filled(n, -1));
      final newArrows = <ArrowModel>[];
      for (int i = 0; i < oriented.length; i++) {
        final p = oriented[i];
        final head = p[p.length - 1];
        final prev = p[p.length - 2];
        final dx = head.x - prev.x;
        final dy = head.y - prev.y;
        int dirIndex = 0;
        for (int d = 0; d < 4; d++) {
          if (_dx[d] == dx && _dy[d] == dy) dirIndex = d;
        }
        newArrows.add(
          ArrowModel(
            id: i,
            cells: p,
            direction: ArrowDirection.values[dirIndex],
          ),
        );
        for (final c in p) {
          newOwner[c.y][c.x] = i;
        }
      }

      // safety: har playable cell arrow se bhara hona chahiye
      bool full = true;
      for (int y = 0; y < n && full; y++) {
        for (int x = 0; x < n; x++) {
          if (!_isVoidCell(x, y) && newOwner[y][x] == -1) {
            full = false;
            break;
          }
        }
      }
      if (!full) continue;

      owner = newOwner;
      arrows = newArrows;
      return true;
    }
    return false; // fallback: purana generator
  }

  /// Shape ke har playable cell ko arrow-paths (2..maxLen cells) se cover karta
  /// hai. Sabse tang (kam free padosi wale) cell se shuru hota hai taake
  /// akela cell kabhi na bache.
  List<List<GridCell>>? _tileShape(int n, Random rnd, int minLen, int maxLen) {
    final own = List.generate(n, (_) => List<int>.filled(n, -1));
    final paths = <List<GridCell>>[];
    int remaining = 0;
    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        if (!_isVoidCell(x, y)) remaining++;
      }
    }

    bool free(int x, int y, Set<int>? used) {
      if (x < 0 || y < 0 || x >= n || y >= n) return false;
      if (_isVoidCell(x, y)) return false;
      if (own[y][x] != -1) return false;
      if (used != null && used.contains(y * n + x)) return false;
      return true;
    }

    int freeNb(int x, int y, Set<int>? used) {
      int k = 0;
      for (int d = 0; d < 4; d++) {
        if (free(x + _dx[d], y + _dy[d], used)) k++;
      }
      return k;
    }

    bool adjacent(GridCell c, int x, int y) =>
        (c.x - x).abs() + (c.y - y).abs() == 1;

    while (remaining > 0) {
      int bx = -1, by = -1;
      double bestScore = 1e9;
      for (int y = 0; y < n; y++) {
        for (int x = 0; x < n; x++) {
          if (!free(x, y, null)) continue;
          final double s = freeNb(x, y, null) + rnd.nextDouble();
          if (s < bestScore) {
            bestScore = s;
            bx = x;
            by = y;
          }
        }
      }
      if (bx < 0) break;

      final int target =
          minLen +
          (pow(rnd.nextDouble(), 1.5).toDouble() * (maxLen - minLen + 1))
              .floor();
      final path = <GridCell>[GridCell(bx, by)];
      final used = <int>{by * n + bx};
      int lastD = -1;
      while (path.length < target) {
        final cur = path.last;
        final opts = <int>[];
        for (int d = 0; d < 4; d++) {
          if (free(cur.x + _dx[d], cur.y + _dy[d], used)) opts.add(d);
        }
        if (opts.isEmpty) break;
        int d;
        if (opts.contains(lastD) && rnd.nextDouble() < 0.8) {
          d = lastD;
        } else {
          opts.shuffle(rnd);
          opts.sort(
            (a, b) => freeNb(
              cur.x + _dx[a],
              cur.y + _dy[a],
              used,
            ).compareTo(freeNb(cur.x + _dx[b], cur.y + _dy[b], used)),
          );
          d = rnd.nextDouble() < 0.6
              ? opts.first
              : opts[rnd.nextInt(opts.length)];
        }
        lastD = d;
        final nx = cur.x + _dx[d];
        final ny = cur.y + _dy[d];
        path.add(GridCell(nx, ny));
        used.add(ny * n + nx);
      }

      if (path.length < 2) {
        // akela cell: kisi padosi arrow ke end se jod do
        final nbs = <int>[];
        for (int d = 0; d < 4; d++) {
          final nx = bx + _dx[d];
          final ny = by + _dy[d];
          if (nx < 0 || ny < 0 || nx >= n || ny >= n) continue;
          if (_isVoidCell(nx, ny)) continue;
          if (own[ny][nx] != -1) nbs.add(own[ny][nx]);
        }
        nbs.shuffle(rnd);
        bool done = false;
        for (final j in nbs) {
          final p = paths[j];
          if (adjacent(p.first, bx, by)) {
            p.insert(0, GridCell(bx, by));
            done = true;
          } else if (adjacent(p.last, bx, by)) {
            p.add(GridCell(bx, by));
            done = true;
          }
          if (done) {
            own[by][bx] = j;
            break;
          }
        }
        if (!done) return null;
        remaining--;
        continue;
      }

      final int id = paths.length;
      paths.add(path);
      for (final c in path) {
        own[c.y][c.x] = id;
        remaining--;
      }
    }
    return remaining == 0 ? paths : null;
  }

  /// Har path ki head (kis taraf se nikalna hai) chunta hai. Bahar se andar
  /// ki taraf "peel" karta hai: jis arrow ka raasta saaf ho wo nikal jata hai.
  /// Agar sab nikal jayen to level 100% solvable hai.
  List<List<GridCell>>? _orientPaths(
    int n,
    List<List<GridCell>> paths,
    Random rnd,
  ) {
    final own = List.generate(n, (_) => List<int>.filled(n, -1));
    for (int i = 0; i < paths.length; i++) {
      for (final c in paths[i]) {
        own[c.y][c.x] = i;
      }
    }
    final alive = List<bool>.filled(paths.length, true);
    final result = List<List<GridCell>>.generate(
      paths.length,
      (_) => <GridCell>[],
    );
    int left = paths.length;

    bool rayClear(int i, List<GridCell> p) {
      final head = p[p.length - 1];
      final prev = p[p.length - 2];
      final dx = head.x - prev.x;
      final dy = head.y - prev.y;
      int x = head.x + dx;
      int y = head.y + dy;
      while (x >= 0 && y >= 0 && x < n && y < n) {
        final o = own[y][x];
        if (o != -1 && o != i) return false;
        x += dx;
        y += dy;
      }
      return true;
    }

    bool changed = true;
    while (left > 0 && changed) {
      changed = false;
      for (int i = 0; i < paths.length; i++) {
        if (!alive[i]) continue;
        final fwd = paths[i];
        final rev = fwd.reversed.toList();
        final bool flip = rnd.nextBool();
        final first = flip ? rev : fwd;
        final second = flip ? fwd : rev;
        List<GridCell>? pick;
        if (rayClear(i, first)) {
          pick = first;
        } else if (rayClear(i, second)) {
          pick = second;
        }
        if (pick == null) continue;
        result[i] = pick;
        alive[i] = false;
        left--;
        changed = true;
        for (final c in fwd) {
          own[c.y][c.x] = -1;
        }
      }
    }
    return left == 0 ? result : null;
  }

  void _generate(int level) {
    // Custom grid shape: poori shape arrows se bhari hoti hai (koi hole nahi).
    if (hasBoardShape && _generateShaped(level)) return;
    final int n = gridSize;
    final rnd = Random(
      level * 7919 +
          104729 +
          n * 1000 +
          (boardMask.isNotEmpty
              ? 131 *
                    (1 + GridStyles.all.indexWhere((g) => g.id == boardShapeId))
              : 0),
    );
    owner = List.generate(n, (_) => List<int>.filled(n, -1));
    arrows = [];
    // Boss: chhote arrows (2-3 cells) => board par bohot ziada arrows.
    final bool boss = isBossNow;
    final int minLen = boss ? 2 : 3;
    final int maxLen = boss ? 3 : (isProMode ? 6 : 5);

    bool rayClear(List<GridCell> path) {
      final head = path[path.length - 1];
      final prev = path[path.length - 2];
      final dx = head.x - prev.x;
      final dy = head.y - prev.y;
      final own = <int>{for (final c in path) c.y * n + c.x};
      int x = head.x + dx;
      int y = head.y + dy;
      while (x >= 0 && y >= 0 && x < n && y < n) {
        if (owner[y][x] != -1 || own.contains(y * n + x)) return false;
        x += dx;
        y += dy;
      }
      return true;
    }

    List<GridCell> walk(int sx, int sy, int target) {
      final path = <GridCell>[GridCell(sx, sy)];
      final used = <int>{sy * n + sx};
      int lastD = -1;
      while (path.length < target) {
        final cur = path.last;
        final opts = <int>[];
        for (int d = 0; d < 4; d++) {
          final nx = cur.x + _dx[d];
          final ny = cur.y + _dy[d];
          if (nx < 0 || ny < 0 || nx >= n || ny >= n) continue;
          if (_isVoidCell(nx, ny)) continue; // outside the custom shape
          if (owner[ny][nx] != -1 || used.contains(ny * n + nx)) continue;
          opts.add(d);
        }
        if (opts.isEmpty) break;
        int d;
        if (opts.contains(lastD) && rnd.nextDouble() < 0.85)
          d = lastD;
        else
          d = opts[rnd.nextInt(opts.length)];
        lastD = d;
        final nx = cur.x + _dx[d];
        final ny = cur.y + _dy[d];
        path.add(GridCell(nx, ny));
        used.add(ny * n + nx);
      }
      return path;
    }

    bool tryPlace(int x, int y, int attempts) {
      for (int a = 0; a < attempts; a++) {
        final int target =
            minLen +
            (pow(rnd.nextDouble(), 1.5).toDouble() * (maxLen - minLen + 1))
                .floor();
        final path = walk(x, y, target);
        if (path.length < 2) continue;
        for (final cand in [path, path.reversed.toList()]) {
          if (!rayClear(cand)) continue;
          final head = cand[cand.length - 1];
          final prev = cand[cand.length - 2];
          final dx = head.x - prev.x;
          final dy = head.y - prev.y;
          int dirIndex = 0;
          for (int d = 0; d < 4; d++) {
            if (_dx[d] == dx && _dy[d] == dy) dirIndex = d;
          }
          final id = arrows.length;
          arrows.add(
            ArrowModel(
              id: id,
              cells: cand,
              direction: ArrowDirection.values[dirIndex],
            ),
          );
          for (final c in cand) owner[c.y][c.x] = id;
          return true;
        }
      }
      return false;
    }

    final centre = (n - 1) / 2;
    final keyed = <MapEntry<GridCell, double>>[];
    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        if (_isVoidCell(x, y)) continue; // no arrows outside the shape
        final dist = sqrt(pow(x - centre, 2) + pow(y - centre, 2));
        keyed.add(MapEntry(GridCell(x, y), dist + rnd.nextDouble() * n * 0.3));
      }
    }
    keyed.sort((a, b) => a.value.compareTo(b.value));

    int pass1, pass2;
    if (isProMode) {
      pass1 = 500;
      pass2 = 1500;
    } else {
      final double scale = level / 2000.0;
      pass1 = 20 + (scale * 480).round();
      pass2 = 50 + (scale * 1450).round();
    }

    for (final e in keyed) {
      if (owner[e.key.y][e.key.x] == -1) tryPlace(e.key.x, e.key.y, pass1);
    }
    for (final e in keyed) {
      if (owner[e.key.y][e.key.x] == -1) tryPlace(e.key.x, e.key.y, pass2);
    }
  }

  int get remaining => arrows.where((a) => !a.isExiting).length;

  bool hasActiveAnimation(int nowMs) {
    for (final a in arrows) {
      if (a.isExiting && nowMs - a.exitStartMs < a.exitDurationMs) return true;
      if (a.shakeStartMs >= 0 && nowMs - a.shakeStartMs < shakeDurationMs)
        return true;
    }
    return false;
  }

  static const int shakeDurationMs = 450;

  int? arrowAt(double gx, double gy) {
    final int cx = gx.floor();
    final int cy = gy.floor();
    int? best;
    double bestDist = 0.75;
    for (int y = cy - 1; y <= cy + 1; y++) {
      for (int x = cx - 1; x <= cx + 1; x++) {
        if (x < 0 || y < 0 || x >= gridSize || y >= gridSize) continue;
        final o = owner[y][x];
        if (o == -1) continue;
        final dist = sqrt(pow(gx - (x + 0.5), 2) + pow(gy - (y + 0.5), 2));
        if (dist < bestDist) {
          bestDist = dist;
          best = o;
        }
      }
    }
    return best;
  }

  int _freeRay(ArrowModel a) {
    final h = a.head;
    final dx = a.direction.dx;
    final dy = a.direction.dy;
    int x = h.x + dx, y = h.y + dy;
    int count = 0;
    while (x >= 0 && y >= 0 && x < gridSize && y < gridSize) {
      final o = owner[y][x];
      if (o != -1 && o != a.id) return -1;
      count++;
      x += dx;
      y += dy;
    }
    return count;
  }

  bool canEscape(ArrowModel a) => _freeRay(a) >= 0;

  void tapArrow(int id) {
    if (isLevelComplete || isGameOver || isLevelFailed) return;
    final a = arrows[id];
    if (a.isExiting) return;

    final now = gameClock.elapsedMilliseconds;
    final ray = _freeRay(a);

    if (ray >= 0) {
      moves++;
      HapticFeedback.lightImpact();
      AudioManager().playArrowEscapeSound();

      for (final c in a.cells) owner[c.y][c.x] = -1;
      a.isExiting = true;
      a.exitStartMs = now;
      a.exitTravelCells = (a.length - 1) + ray + 1.0;
      a.exitDurationMs = min(
        1200,
        max(420, (a.exitTravelCells / 26 * 1000).round()),
      );
      _onTutorialArrowCleared();
      notifyListeners();
      _checkWin();
    } else {
      HapticFeedback.heavyImpact();
      AudioManager().playWrongTapSound();
      a.shakeStartMs = now;
      lives--;
      if (tutorialStep == TutorialManager.stepGameArrow && lives < 1) {
        lives = 1;
      }

      if (isProMode && timeLeft > 2) timeLeft -= 2;
      if (lives <= 0) {
        isGameOver = true;
        _timer?.cancel();
      }
      notifyListeners();
    }
  }

  void _checkWin() {
    if (remaining != 0) return;
    final token = _loadToken;

    Future.delayed(const Duration(milliseconds: 200), () {
      if (token != _loadToken) return;
      if (isLevelComplete || isGameOver || isLevelFailed) return;

      isLevelComplete = true;
      _timer?.cancel();

      if (!isDailyChallenge &&
          levelRecords[recordKeyFor(currentLevel, isProMode)] != null) {
        isReplayReward = true;
      }

      _onLevelCleared();

      final double leftRatio = totalTime <= 0 ? 0 : timeLeft / totalTime;
      final double star3 = isProMode ? 0.10 : 0.30;
      final double star2 = isProMode ? 0.03 : 0.08;
      if (usedAutoSolve) {
        levelStars = 1;
      } else if (leftRatio >= star3) {
        levelStars = 3;
      } else if (leftRatio >= star2) {
        levelStars = 2;
      } else {
        levelStars = 1;
      }
      if (!usedAutoSolve &&
          usedFreezeThisLevel &&
          levelStars > Eco.freezeMaxStars) {
        levelStars = Eco.freezeMaxStars;
      }

      final recordKey = recordKeyFor(currentLevel, isProMode);
      final prev = levelRecords[recordKey];

      int fullReward;
      if (isDailyChallenge) {
        fullReward = dailyChallengeReward;
      } else {
        final int nextFee = getLevelCost(currentLevel + 1, pro: isProMode);
        final double mult = levelStars == 3
            ? Eco.star3Mult
            : (levelStars == 2 ? Eco.star2Mult : Eco.star1Mult);
        final int flatBonus = isProMode
            ? Eco.proFlatBonus
            : Eco.classicFlatBonus;
        fullReward = (nextFee * mult).round() + flatBonus;
        if (isProMode) fullReward = (fullReward * Eco.proRewardMult).round();
      }

      if (usedAutoSolve) {
        fullReward = (fullReward * Eco.autoSolvePayoutMult).round();
      }

      int payout;
      replayImprovementBonus = 0;
      replayLimitHit = false;
      if (isDailyChallenge) {
        payout = (lastDailyCompletedDate == todayStamp) ? 0 : fullReward;
      } else if (prev == null) {
        payout = fullReward;
      } else {
        isReplayReward = true;
        final int improvement = max(0, fullReward - prev.bestCoins);
        _checkReplayReset();
        final int base = (fullReward * Eco.replayPct)
            .round()
            .clamp(Eco.replayMin, Eco.replayMax)
            .toInt();
        final int room = max(0, Eco.replayDailyBudget - replayCoinsToday);
        final int baseGiven = min(base, room);
        replayCoinsToday += baseGiven;
        replayLimitHit = baseGiven < base;
        replayImprovementBonus = improvement;
        payout = improvement + baseGiven;
      }

      if (payout < 0) payout = 0;
      levelPointsEarned = payout;
      _earnCoins(payout);

      if (isDailyChallenge) {
        lastDailyCompletedDate = todayStamp;
      }

      if (!isDailyChallenge) {
        final int newBestTime = usedAutoSolve
            ? (prev?.bestTimeSeconds ?? 0)
            : ((prev == null ||
                      prev.bestTimeSeconds == 0 ||
                      timeTaken < prev.bestTimeSeconds)
                  ? timeTaken
                  : prev.bestTimeSeconds);
        final int newBestCoins = (prev == null || fullReward > prev.bestCoins)
            ? fullReward
            : prev.bestCoins;
        levelRecords[recordKey] = LevelRecord(
          bestTimeSeconds: newBestTime,
          bestCoins: newBestCoins,
        );
      }

      totalLevelsCompleted++;
      if (isProMode) proLevelsCompleted++;
      if (isDailyChallenge) hasCompletedDaily = true;
      if (!usedAutoSolve) {
        final int clearSecs = timeTaken < 1 ? 1 : timeTaken;
        if (!usedFreezeThisLevel && tutorialStep == 0) {
          if (fastestClearSeconds == 0 || clearSecs < fastestClearSeconds) {
            fastestClearSeconds = clearSecs;
          }
          if (clearSecs <= 5) hasSpeedRun = true;
        }
        if (lives == 3) {
          hasPerfectClear = true;
          perfectLevelsCount++;
        }
        _checkDailyTaskReset();
        if (!isReplayReward) dailyLevelsCompleted++;
      }

      _recordLeaderboardRun(
        level: currentLevel,
        isPro: isProMode,
        coins: levelPointsEarned,
        stars: levelStars,
        timeSeconds: timeTaken,
        usedFreeze: usedFreezeThisLevel,
        usedAutoSolve: usedAutoSolve,
      );
      recordStreakLeaderboard();

      _saveData();
      HapticFeedback.mediumImpact();
      notifyListeners();

      checkAchievementPopups();
    });
  }

  bool canAffordNextLevel() {
    if (isDailyChallenge) return false;
    if (isProMode) {
      if (currentLevel >= maxProLevel) return false;
      if (currentLevel + 1 > proUnlockedLevel)
        return totalPoints >= getLevelCost(currentLevel + 1);
      return true;
    }
    if (currentLevel >= maxClassicLevel) return false;
    if (currentLevel + 1 > classicUnlockedLevel)
      return totalPoints >= getLevelCost(currentLevel + 1);
    return true;
  }

  bool unlockAndProceedToNextLevel() {
    if (isDailyChallenge) return false;
    if (isProMode) {
      if (currentLevel >= maxProLevel) return false;
      int nextLevel = currentLevel + 1;
      if (nextLevel <= proUnlockedLevel) {
        loadProLevel(nextLevel);
        return true;
      }
      int cost = getLevelCost(nextLevel);
      if (totalPoints >= cost) {
        totalPoints -= cost;
        proUnlockedLevel = nextLevel;
        _saveData();
        loadProLevel(nextLevel);
        return true;
      }
      return false;
    }
    if (currentLevel >= maxClassicLevel) return false;
    int nextLevel = currentLevel + 1;
    if (nextLevel <= classicUnlockedLevel) {
      loadLevel(nextLevel);
      return true;
    }
    int cost = getLevelCost(nextLevel);
    if (totalPoints >= cost) {
      totalPoints -= cost;
      classicUnlockedLevel = nextLevel;
      _saveData();
      loadLevel(nextLevel);
      return true;
    }
    return false;
  }

  bool unlockLevelWithPoints(int level, bool isPro) {
    int unlocked = isPro ? proUnlockedLevel : classicUnlockedLevel;
    if (level <= unlocked) {
      if (isPro)
        loadProLevel(level);
      else
        loadLevel(level);
      return true;
    }
    if (level != unlocked + 1) return false;
    int cost = getLevelCost(level, pro: isPro);
    if (totalPoints >= cost) {
      totalPoints -= cost;
      if (isPro)
        proUnlockedLevel = level;
      else
        classicUnlockedLevel = level;
      _saveData();
      if (isPro)
        loadProLevel(level);
      else
        loadLevel(level);
      return true;
    }
    return false;
  }

  void restartLevel() {
    if (isDailyChallenge) return;
    if (isProMode)
      loadProLevel(currentLevel);
    else
      loadLevel(currentLevel);
  }

  LevelRecord? getRecordForLevel(int level, {bool isPro = false}) {
    return levelRecords[recordKeyFor(level, isPro)];
  }

  static String formatBestTime(int seconds) {
    if (seconds <= 0) return '--:--';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void addMinigameCoins(int amount) {
    _earnCoins(amount);
    _saveData();
    notifyListeners();

    checkAchievementPopups();
  }

  void recordArcadeGameWon(
    int timeSpentSeconds,
    int coinsEarned, {
    bool won = true,
  }) {
    if (won) arcadeGamesWon++;
    arcadePlayTimeSeconds += timeSpentSeconds;
    if (coinsEarned > maxArcadeCoinsEarned) {
      maxArcadeCoinsEarned = coinsEarned;
    }
    _checkDailyTaskReset();
    if (won) dailyArcadeGamesWon++;

    if (won) _addEventProgress('arcade', 1);

    _saveData();
    notifyListeners();

    checkAchievementPopups();
  }

  bool claimTaskReward(String taskId, int diamondReward) {
    if (claimedTaskIds.contains(taskId)) return false;
    claimedTaskIds.add(taskId);
    totalDiamonds += diamondReward;

    _addEventProgress('diamonds', diamondReward);

    _saveData();
    notifyListeners();
    return true;
  }

  // ================================================================
  // EVENTS LOGIC
  // ================================================================
  void _rotateEventIfNeeded() {
    final expected = EventConfig.getActiveEvent(
      DateTime.now().millisecondsSinceEpoch,
    );
    if (activeEventId != expected.id) {
      activeEventId = expected.id;
      eventProgress = 0;
      isEventActive = false;
      claimedEventIds.remove(expected.id);
      _saveData();
    }
  }

  void _addEventProgress(String type, int amount) {
    if (!isEventActive) return;

    _rotateEventIfNeeded();
    final event = currentEvent;
    if (event == null) return;

    if (claimedEventIds.contains(event.id)) return;

    if (event.type != type) {
      return;
    }
    if (amount <= 0) return;

    if (eventProgress < event.target) {
      eventProgress += amount;
      if (eventProgress > event.target) eventProgress = event.target;
      _saveData();
      notifyListeners();
    }
  }

  void _onLevelCleared() {
    _rotateEventIfNeeded();
    final event = currentEvent;
    if (event == null || claimedEventIds.contains(event.id)) return;

    _addEventProgress('classic', isProMode ? 0 : 1);
    _addEventProgress('pro', isProMode ? 1 : 0);
    _addEventProgress('any', 1);

    if (isProMode) {
      if (timeTaken <= 20) _addEventProgress('pro_speed', 1);
    } else {
      if (timeTaken <= 10) _addEventProgress('speed10', 1);
      if (timeTaken <= 15) _addEventProgress('speed15', 1);
    }

    if (lives == 3) _addEventProgress('perfect', 1);
    if (!usedFreezeThisLevel && !usedAutoSolve)
      _addEventProgress('no_power', 1);
    if (isReplayReward) _addEventProgress('replay', 1);
    if (isDailyChallenge) _addEventProgress('daily', 1);

    if (!isProMode) {
      if (currentLevel <= 50) _addEventProgress('tier1', 1);
      if (currentLevel > 100 && currentLevel <= 200)
        _addEventProgress('tier3', 1);
      if (currentLevel > 500) _addEventProgress('tier5', 1);
    }

    if (baseGridSize >= 10) _addEventProgress('big_grid', 1);

    final weekday = DateTime.now().weekday;
    if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
      _addEventProgress('weekend', 1);
    }

    if (timeLeft == 1) _addEventProgress('clutch', 1);

    final int hour = DateTime.now().hour;
    if (hour < 12) _addEventProgress('time_morning', 1);
    if (hour >= 22) _addEventProgress('time_night', 1);
    if (lives == 3) _addEventProgress('no_mistake', 1);
  }

  void startEvent() {
    _rotateEventIfNeeded();
    isEventActive = true;
    _saveData();
    notifyListeners();
  }

  bool claimEventReward() {
    _rotateEventIfNeeded();
    final event = currentEvent;
    if (event == null) return false;
    if (eventProgress < event.target) return false;
    if (claimedEventIds.contains(event.id)) return false;

    claimedEventIds.add(event.id);
    _earnCoins(event.rewardCoins);
    totalDiamonds += event.rewardDiamonds;
    isEventActive = false;

    _saveData();
    notifyListeners();
    return true;
  }

  // ================================================================
  // LOCAL LEADERBOARD — public API + internal helpers (NEW)
  // ================================================================

  void _recordLeaderboardRun({
    required int level,
    required bool isPro,
    required int coins,
    required int stars,
    required int timeSeconds,
    required bool usedFreeze,
    required bool usedAutoSolve,
  }) {
    if (coins <= 0) return;
    final int nowMs = DateTime.now().millisecondsSinceEpoch;

    final Map<String, dynamic> coinEntry = {
      'coins': coins,
      'level': level,
      'isPro': isPro,
      'stars': stars,
      'time': timeSeconds,
      'date': nowMs,
    };
    leaderboardCoins.add(coinEntry);
    leaderboardCoins.sort(
      (a, b) => (b['coins'] as int).compareTo(a['coins'] as int),
    );
    if (leaderboardCoins.length > _leaderboardMaxEntries) {
      leaderboardCoins = leaderboardCoins.take(_leaderboardMaxEntries).toList();
    }

    if (!usedAutoSolve && !usedFreeze && timeSeconds > 0) {
      final Map<String, dynamic> speedEntry = {
        'time': timeSeconds,
        'level': level,
        'isPro': isPro,
        'stars': stars,
        'coins': coins,
        'date': nowMs,
      };
      leaderboardSpeed.add(speedEntry);
      leaderboardSpeed.sort(
        (a, b) => (a['time'] as int).compareTo(b['time'] as int),
      );
      if (leaderboardSpeed.length > _leaderboardMaxEntries) {
        leaderboardSpeed = leaderboardSpeed
            .take(_leaderboardMaxEntries)
            .toList();
      }
    }

    final int today = todayStamp;
    final bool alreadyToday = leaderboardStreak.any((e) {
      final int d = e['date'] as int? ?? 0;
      final DateTime dt = DateTime.fromMillisecondsSinceEpoch(d);
      return dt.year * 10000 + dt.month * 100 + dt.day == today;
    });
    if (!alreadyToday && streakCount > 0) {
      leaderboardStreak.add({'streak': streakCount, 'date': nowMs});
      leaderboardStreak.sort(
        (a, b) => (b['streak'] as int).compareTo(a['streak'] as int),
      );
      if (leaderboardStreak.length > _leaderboardMaxEntries) {
        leaderboardStreak = leaderboardStreak
            .take(_leaderboardMaxEntries)
            .toList();
      }
    }
  }

  void recordStreakLeaderboard() {
    final int today = todayStamp;
    final bool alreadyToday = leaderboardStreak.any((e) {
      final int d = e['date'] as int? ?? 0;
      final DateTime dt = DateTime.fromMillisecondsSinceEpoch(d);
      return dt.year * 10000 + dt.month * 100 + dt.day == today;
    });
    if (alreadyToday) return;
    if (streakCount <= 0) return;
    leaderboardStreak.add({
      'streak': streakCount,
      'date': DateTime.now().millisecondsSinceEpoch,
    });
    leaderboardStreak.sort(
      (a, b) => (b['streak'] as int).compareTo(a['streak'] as int),
    );
    if (leaderboardStreak.length > _leaderboardMaxEntries) {
      leaderboardStreak = leaderboardStreak
          .take(_leaderboardMaxEntries)
          .toList();
    }
    _saveData();
    notifyListeners();
  }

  // ================================================================
  // ACHIEVEMENT POPUP SYSTEM (NEW)
  // ================================================================

  void checkAchievementPopups() {
    if (_isCheckingAchievements) return;

    final now = DateTime.now();
    if (now.difference(_lastAchievementCheck).inMilliseconds < 500) {
      return;
    }
    _isCheckingAchievements = true;
    _lastAchievementCheck = now;

    final List<Map<String, dynamic>> newlyUnlocked = [];

    if (_lastKnownFastestClear == 0 ||
        (fastestClearSeconds > 0 &&
            fastestClearSeconds <= 8 &&
            (_lastKnownFastestClear == 0 || _lastKnownFastestClear > 8))) {
      if (fastestClearSeconds > 0 && fastestClearSeconds <= 8) {
        newlyUnlocked.add({
          'id': 'speed_demon',
          'title': 'Speed Demon',
          'description': 'Completed a level in 8s or less',
          'icon': 'speed',
          'color': 0xFF4CAF50,
        });
      }
    }
    _lastKnownFastestClear = fastestClearSeconds;

    if (_lastKnownPerfectCount == 0 && perfectLevelsCount >= 1) {
      newlyUnlocked.add({
        'id': 'untouchable',
        'title': 'Untouchable',
        'description': 'Completed a level without losing a life',
        'icon': 'shield',
        'color': 0xFF3F51B5,
      });
    }
    _lastKnownPerfectCount = perfectLevelsCount;

    if (_lastKnownTotalLevels == 0 && totalLevelsCompleted >= 1) {
      newlyUnlocked.add({
        'id': 'first_win',
        'title': 'First Win',
        'description': 'Completed your first level!',
        'icon': 'trophy',
        'color': 0xFFFFC107,
      });
    }
    _lastKnownTotalLevels = totalLevelsCompleted;

    if (_lastKnownProLevels == 0 && proLevelsCompleted >= 1) {
      newlyUnlocked.add({
        'id': 'pro_player',
        'title': 'Pro Player',
        'description': 'Completed your first Pro level!',
        'icon': 'fire',
        'color': 0xFF9C27B0,
      });
    }
    _lastKnownProLevels = proLevelsCompleted;

    if (_lastKnownArcadeWins == 0 && arcadeGamesWon >= 1) {
      newlyUnlocked.add({
        'id': 'arcade_rookie',
        'title': 'Arcade Rookie',
        'description': 'Won your first Arcade game!',
        'icon': 'gamepad',
        'color': 0xFFF44336,
      });
    }
    _lastKnownArcadeWins = arcadeGamesWon;

    if (_lastKnownLifetimeCoins < 5000 && lifetimeCoinsEarned >= 5000) {
      newlyUnlocked.add({
        'id': 'coin_collector',
        'title': 'Coin Collector',
        'description': 'Earned 5,000 coins total',
        'icon': 'coin',
        'color': 0xFFFF9800,
      });
    }
    _lastKnownLifetimeCoins = lifetimeCoinsEarned;

    if (_lastKnownDailyLevels < 5 && dailyLevelsCompleted >= 5) {
      newlyUnlocked.add({
        'id': 'daily_grind',
        'title': 'Daily Grind',
        'description': 'Cleared 5 new levels today',
        'icon': 'whatshot',
        'color': 0xFFFF5722,
      });
    }
    _lastKnownDailyLevels = dailyLevelsCompleted;

    if (_lastKnownDailyArcade < 3 && dailyArcadeGamesWon >= 3) {
      newlyUnlocked.add({
        'id': 'daily_arcade',
        'title': 'Daily Arcade',
        'description': 'Won 3 Arcade games today',
        'icon': 'gamepad',
        'color': 0xFFE91E63,
      });
    }
    _lastKnownDailyArcade = dailyArcadeGamesWon;

    for (final a in newlyUnlocked) {
      final String id = a['id'] as String;
      if (_achievementPopupsShown.contains(id)) continue;

      if (!_achievementPopupQueue.any((q) => q['id'] == id)) {
        _achievementPopupQueue.add(a);
      }
    }

    _isCheckingAchievements = false;

    if (newlyUnlocked.isNotEmpty) {
      notifyListeners();
      _triggerGlobalPopupIfReady();
    }
  }

  void popAchievementFromQueue() {
    if (_achievementPopupQueue.isEmpty) return;
    final popped = _achievementPopupQueue.removeAt(0);
    final String id = popped['id'] as String? ?? '';
    if (id == 'first_win' ||
        id == 'pro_player' ||
        id == 'arcade_rookie' ||
        id == 'untouchable' ||
        id == 'coin_collector') {
      _achievementPopupsShown.add(id);
    }
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 300), () {
      _triggerGlobalPopupIfReady();
    });
  }

  // ================================================================
  // GLOBAL POPUP LOGIC (FIXED LAYOUT)
  // ================================================================
  void _triggerGlobalPopupIfReady() {
    if (_activeGlobalPopup != null) return;
    if (_achievementPopupQueue.isEmpty) return;
    if (navigatorKey.currentContext == null) return;

    _activeGlobalPopup = _achievementPopupQueue.first;
    notifyListeners();

    final context = navigatorKey.currentContext!;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Achievement',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, anim1, anim2) {
        // FIX: The popup is now wrapped in a Material widget with transparent
        // color and proper alignment. This prevents the pink background from
        // stretching across the entire screen. It now hugs its content.
        return Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
                child: _buildGlobalAchievementToast(ctx, _activeGlobalPopup!),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1.2),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    ).then((_) {
      _popupAutoDismissTimer?.cancel();
      _popupAutoDismissTimer = null;

      if (_activeGlobalPopup != null) {
        _activeGlobalPopup = null;
        popAchievementFromQueue();
      }
    });

    _popupAutoDismissTimer?.cancel();
    _popupAutoDismissTimer = Timer(const Duration(seconds: 4), () {
      if (_activeGlobalPopup != null && navigatorKey.currentContext != null) {
        Navigator.of(navigatorKey.currentContext!).pop();
      }
    });
  }

  IconData _achievementIconFor(String name) {
    switch (name) {
      case 'speed':
        return Icons.speed_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'trophy':
        return Icons.emoji_events_rounded;
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'gamepad':
        return Icons.sports_esports_rounded;
      case 'coin':
        return Icons.monetization_on_rounded;
      case 'whatshot':
        return Icons.whatshot_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }

  Widget _buildGlobalAchievementToast(
    BuildContext context,
    Map<String, dynamic> achievement,
  ) {
    final Color color = Color(achievement['color'] as int? ?? 0xFFFFC107);
    final IconData icon = _achievementIconFor(
      achievement['icon'] as String? ?? 'trophy',
    );
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        // No width: double.infinity here! It shrinks to fit the screen width minus padding
        // and grows vertically as needed.
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.95), color.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Shrink-wrap horizontally
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Shrink-wrap vertically
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'ACHIEVEMENT UNLOCKED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    achievement['title'] as String? ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    achievement['description'] as String? ?? '',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.close_rounded,
              color: Colors.white.withOpacity(0.8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
