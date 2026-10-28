import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LevelRecord {
  final int bestTimeSeconds;
  final int bestCoins;
  const LevelRecord({this.bestTimeSeconds = 0, this.bestCoins = 0});
  Map<String, dynamic> toJson() => {'t': bestTimeSeconds, 'c': bestCoins};
  static LevelRecord? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final t = raw['t'];
    final c = raw['c'];
    if (t is! num || c is! num) return null;
    return LevelRecord(bestTimeSeconds: t.toInt(), bestCoins: c.toInt());
  }
}

class SaveData {
  final int classicUnlocked;
  final int proUnlocked;
  final int totalPoints;
  final int totalDiamonds;
  final int autoSolveInventory;
  final int savedAt;
  final Map<int, LevelRecord> levelRecords;
  final int lastDailyCompletedDate;
  final int freezeItems;
  final int healthItems;

  // STATS TRACKING
  final int totalPlayTimeSeconds;
  final int totalLevelsCompleted;
  final int proLevelsCompleted;
  final bool hasSpeedRun;
  final bool hasCompletedDaily;
  final bool hasPerfectClear;

  // ARCADE STATS
  final int arcadePlayTimeSeconds;
  final int arcadeGamesWon;
  final int maxArcadeCoinsEarned;

  // MINIGAME DAILY LIMIT
  final int dailyMinigamesPlayed;
  final int lastMinigameDate;

  // NEW TASK CLAIMED TRACKER
  final List<String> claimedTaskIds;

  // NEW LUCKY DRAW
  final int lastLuckyDrawDate;

  // NEW DAILY TASKS
  final int dailyLevelsCompleted;
  final int dailyArcadeGamesWon;
  final int lastDailyTaskDate;

  // LIFETIME STATS
  final int lifetimeCoinsEarned;
  final int perfectLevelsCount;
  final int fastestClearSeconds;

  // ECONOMY GUARDS
  final bool starterGranted;
  final int replayCoinsToday;
  final int lastReplayDate;
  final int lastSeenMs;

  // THEMES
  final List<String> unlockedThemes;
  final String activeTheme;
  final List<String> triedThemes;

  // LOGIN STREAK
  final int streakCount;
  final int lastStreakDay;
  final int streakFreezeHeld;
  final bool streakFreezeUsedToday;

  // EVENTS (NEW)
  final String activeEventId;
  final int eventProgress;
  final List<String> claimedEventIds;
  final bool isEventActive;

  // LEADERBOARD (NEW — Local best runs)
  final List<Map<String, dynamic>> leaderboardCoins;
  final List<Map<String, dynamic>> leaderboardSpeed;
  final List<Map<String, dynamic>> leaderboardStreak;

  // ACHIEVEMENT POPUPS SHOWN (NEW)
  final List<String> achievementPopupsShown;

  const SaveData({
    required this.classicUnlocked,
    required this.proUnlocked,
    required this.totalPoints,
    this.totalDiamonds = 0,
    this.autoSolveInventory = 0,
    required this.savedAt,
    required this.levelRecords,
    required this.lastDailyCompletedDate,
    this.freezeItems = 0,
    this.healthItems = 0,
    this.totalPlayTimeSeconds = 0,
    this.totalLevelsCompleted = 0,
    this.proLevelsCompleted = 0,
    this.hasSpeedRun = false,
    this.hasCompletedDaily = false,
    this.hasPerfectClear = false,
    this.arcadePlayTimeSeconds = 0,
    this.arcadeGamesWon = 0,
    this.maxArcadeCoinsEarned = 0,
    this.dailyMinigamesPlayed = 0,
    this.lastMinigameDate = 0,
    this.claimedTaskIds = const [],
    this.lastLuckyDrawDate = 0,
    this.dailyLevelsCompleted = 0,
    this.dailyArcadeGamesWon = 0,
    this.lastDailyTaskDate = 0,
    this.lifetimeCoinsEarned = 0,
    this.perfectLevelsCount = 0,
    this.fastestClearSeconds = 0,
    this.starterGranted = false,
    this.replayCoinsToday = 0,
    this.lastReplayDate = 0,
    this.lastSeenMs = 0,
    this.unlockedThemes = const ['classic'],
    this.activeTheme = 'classic',
    this.triedThemes = const [],
    this.streakCount = 0,
    this.lastStreakDay = 0,
    this.streakFreezeHeld = 0,
    this.streakFreezeUsedToday = false,
    this.activeEventId = '',
    this.eventProgress = 0,
    this.claimedEventIds = const [],
    this.isEventActive = false,
    this.leaderboardCoins = const [],
    this.leaderboardSpeed = const [],
    this.leaderboardStreak = const [],
    this.achievementPopupsShown = const [],
  });

  static const SaveData empty = SaveData(
    classicUnlocked: 1,
    proUnlocked: 1,
    totalPoints: 0,
    totalDiamonds: 0,
    autoSolveInventory: 0,
    savedAt: 0,
    levelRecords: {},
    lastDailyCompletedDate: 0,
    freezeItems: 0,
    healthItems: 0,
    totalPlayTimeSeconds: 0,
    totalLevelsCompleted: 0,
    proLevelsCompleted: 0,
    hasSpeedRun: false,
    hasCompletedDaily: false,
    hasPerfectClear: false,
    arcadePlayTimeSeconds: 0,
    arcadeGamesWon: 0,
    maxArcadeCoinsEarned: 0,
    dailyMinigamesPlayed: 0,
    lastMinigameDate: 0,
    claimedTaskIds: [],
    lastLuckyDrawDate: 0,
    dailyLevelsCompleted: 0,
    dailyArcadeGamesWon: 0,
    lastDailyTaskDate: 0,
    lifetimeCoinsEarned: 0,
    perfectLevelsCount: 0,
    fastestClearSeconds: 0,
    starterGranted: false,
    replayCoinsToday: 0,
    lastReplayDate: 0,
    lastSeenMs: 0,
    unlockedThemes: ['classic'],
    activeTheme: 'classic',
    triedThemes: [],
    streakCount: 0,
    lastStreakDay: 0,
    streakFreezeHeld: 0,
    streakFreezeUsedToday: false,
    activeEventId: '',
    eventProgress: 0,
    claimedEventIds: [],
    isEventActive: false,
    leaderboardCoins: [],
    leaderboardSpeed: [],
    leaderboardStreak: [],
    achievementPopupsShown: [],
  );

  String toJsonString() => jsonEncode({
    'v': 17,
    'classicUnlocked': classicUnlocked,
    'proUnlocked': proUnlocked,
    'totalPoints': totalPoints,
    'totalDiamonds': totalDiamonds,
    'autoSolveInventory': autoSolveInventory,
    'savedAt': savedAt,
    'records': levelRecords.map((k, v) => MapEntry(k.toString(), v.toJson())),
    'lastDaily': lastDailyCompletedDate,
    'freezeItems': freezeItems,
    'healthItems': healthItems,
    'totalPlayTimeSeconds': totalPlayTimeSeconds,
    'totalLevelsCompleted': totalLevelsCompleted,
    'proLevelsCompleted': proLevelsCompleted,
    'hasSpeedRun': hasSpeedRun,
    'hasCompletedDaily': hasCompletedDaily,
    'hasPerfectClear': hasPerfectClear,
    'arcadePlayTimeSeconds': arcadePlayTimeSeconds,
    'arcadeGamesWon': arcadeGamesWon,
    'maxArcadeCoinsEarned': maxArcadeCoinsEarned,
    'dailyMinigamesPlayed': dailyMinigamesPlayed,
    'lastMinigameDate': lastMinigameDate,
    'claimedTaskIds': claimedTaskIds,
    'lastLuckyDrawDate': lastLuckyDrawDate,
    'dailyLevelsCompleted': dailyLevelsCompleted,
    'dailyArcadeGamesWon': dailyArcadeGamesWon,
    'lastDailyTaskDate': lastDailyTaskDate,
    'lifetimeCoinsEarned': lifetimeCoinsEarned,
    'perfectLevelsCount': perfectLevelsCount,
    'fastestClearSeconds': fastestClearSeconds,
    'starterGranted': starterGranted,
    'replayCoinsToday': replayCoinsToday,
    'lastReplayDate': lastReplayDate,
    'lastSeenMs': lastSeenMs,
    'unlockedThemes': unlockedThemes,
    'activeTheme': activeTheme,
    'triedThemes': triedThemes,
    'streakCount': streakCount,
    'lastStreakDay': lastStreakDay,
    'streakFreezeHeld': streakFreezeHeld,
    'streakFreezeUsedToday': streakFreezeUsedToday,
    'activeEventId': activeEventId,
    'eventProgress': eventProgress,
    'claimedEventIds': claimedEventIds,
    'isEventActive': isEventActive,
    'leaderboardCoins': leaderboardCoins,
    'leaderboardSpeed': leaderboardSpeed,
    'leaderboardStreak': leaderboardStreak,
    'achievementPopupsShown': achievementPopupsShown,
  });

  static SaveData? tryParse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final dynamic j = jsonDecode(raw);
      if (j is! Map) return null;
      final pts = j['totalPoints'];
      final at = j['savedAt'];
      if (pts is! num) return null;

      List<Map<String, dynamic>> readListOfMaps(dynamic raw) {
        final out = <Map<String, dynamic>>[];
        if (raw is List) {
          for (final item in raw) {
            if (item is Map) {
              out.add(Map<String, dynamic>.from(item));
            }
          }
        }
        return out;
      }

      final int ver = j['v'] is num ? (j['v'] as num).toInt() : 0;
      final int classicUnlockedForMigration = j['classicUnlocked'] is num
          ? (j['classicUnlocked'] as num).toInt()
          : (j['unlockedLevel'] is num
                ? (j['unlockedLevel'] as num).toInt()
                : 1);
      final records = <int, LevelRecord>{};
      final rawRec = j['records'];
      if (rawRec is Map) {
        rawRec.forEach((k, v) {
          int? key = int.tryParse(k.toString());
          if (key == null) return;
          if (ver < 13 &&
              key > 1000 &&
              key <= 1500 &&
              classicUnlockedForMigration <= 1000) {
            key = 10000 + (key - 1000);
          }
          final rec = LevelRecord.tryParse(v);
          if (rec != null) records[key] = rec;
        });
      }
      final lastDaily = j['lastDaily'] is num
          ? (j['lastDaily'] as num).toInt()
          : 0;
      final int classicUnlocked = j['classicUnlocked'] is num
          ? (j['classicUnlocked'] as num).toInt()
          : (j['unlockedLevel'] is num
                ? (j['unlockedLevel'] as num).toInt()
                : 1);
      final int proUnlocked = j['proUnlocked'] is num
          ? (j['proUnlocked'] as num).toInt()
          : 1;
      final int fItems = j['freezeItems'] is num
          ? (j['freezeItems'] as num).toInt()
          : 0;
      final int hItems = j['healthItems'] is num
          ? (j['healthItems'] as num).toInt()
          : 0;

      final List<String> claimed = [];
      if (j['claimedTaskIds'] is List) {
        for (var item in j['claimedTaskIds']) {
          claimed.add(item.toString());
        }
      }

      List<String> readStrList(dynamic raw) {
        final out = <String>[];
        if (raw is List) {
          for (final item in raw) {
            final v = item.toString();
            if (!out.contains(v)) out.add(v);
          }
        }
        return out;
      }

      final List<String> themesOwned = readStrList(j['unlockedThemes']);
      if (!themesOwned.contains('classic')) themesOwned.insert(0, 'classic');
      final List<String> themesTried = readStrList(j['triedThemes']);
      final String themeActive = j['activeTheme'] is String
          ? (j['activeTheme'] as String)
          : 'classic';

      return SaveData(
        classicUnlocked: classicUnlocked,
        proUnlocked: proUnlocked,
        totalPoints: pts.toInt(),
        totalDiamonds: j['totalDiamonds'] is num
            ? (j['totalDiamonds'] as num).toInt()
            : 0,
        autoSolveInventory: j['autoSolveInventory'] is num
            ? (j['autoSolveInventory'] as num).toInt()
            : 0,
        savedAt: at is num ? at.toInt() : 0,
        levelRecords: records,
        lastDailyCompletedDate: lastDaily,
        freezeItems: fItems,
        healthItems: hItems,
        totalPlayTimeSeconds: j['totalPlayTimeSeconds'] is num
            ? (j['totalPlayTimeSeconds'] as num).toInt()
            : 0,
        totalLevelsCompleted: j['totalLevelsCompleted'] is num
            ? (j['totalLevelsCompleted'] as num).toInt()
            : 0,
        proLevelsCompleted: j['proLevelsCompleted'] is num
            ? (j['proLevelsCompleted'] as num).toInt()
            : 0,
        hasSpeedRun: j['hasSpeedRun'] == true,
        hasCompletedDaily: j['hasCompletedDaily'] == true,
        hasPerfectClear: j['hasPerfectClear'] == true,
        arcadePlayTimeSeconds: j['arcadePlayTimeSeconds'] is num
            ? (j['arcadePlayTimeSeconds'] as num).toInt()
            : 0,
        arcadeGamesWon: j['arcadeGamesWon'] is num
            ? (j['arcadeGamesWon'] as num).toInt()
            : 0,
        maxArcadeCoinsEarned: j['maxArcadeCoinsEarned'] is num
            ? (j['maxArcadeCoinsEarned'] as num).toInt()
            : 0,
        dailyMinigamesPlayed: j['dailyMinigamesPlayed'] is num
            ? (j['dailyMinigamesPlayed'] as num).toInt()
            : 0,
        lastMinigameDate: j['lastMinigameDate'] is num
            ? (j['lastMinigameDate'] as num).toInt()
            : 0,
        claimedTaskIds: claimed,
        lastLuckyDrawDate: j['lastLuckyDrawDate'] is num
            ? (j['lastLuckyDrawDate'] as num).toInt()
            : 0,
        dailyLevelsCompleted: j['dailyLevelsCompleted'] is num
            ? (j['dailyLevelsCompleted'] as num).toInt()
            : 0,
        dailyArcadeGamesWon: j['dailyArcadeGamesWon'] is num
            ? (j['dailyArcadeGamesWon'] as num).toInt()
            : 0,
        lastDailyTaskDate: j['lastDailyTaskDate'] is num
            ? (j['lastDailyTaskDate'] as num).toInt()
            : 0,
        lifetimeCoinsEarned: j['lifetimeCoinsEarned'] is num
            ? (j['lifetimeCoinsEarned'] as num).toInt()
            : 0,
        perfectLevelsCount: j['perfectLevelsCount'] is num
            ? (j['perfectLevelsCount'] as num).toInt()
            : 0,
        fastestClearSeconds: j['fastestClearSeconds'] is num
            ? (j['fastestClearSeconds'] as num).toInt()
            : 0,
        starterGranted: j['starterGranted'] == true,
        replayCoinsToday: j['replayCoinsToday'] is num
            ? (j['replayCoinsToday'] as num).toInt()
            : 0,
        lastReplayDate: j['lastReplayDate'] is num
            ? (j['lastReplayDate'] as num).toInt()
            : 0,
        lastSeenMs: j['lastSeenMs'] is num
            ? (j['lastSeenMs'] as num).toInt()
            : 0,
        unlockedThemes: themesOwned,
        activeTheme: themeActive,
        triedThemes: themesTried,
        streakCount: j['streakCount'] is num
            ? (j['streakCount'] as num).toInt()
            : 0,
        lastStreakDay: j['lastStreakDay'] is num
            ? (j['lastStreakDay'] as num).toInt()
            : 0,
        streakFreezeHeld: j['streakFreezeHeld'] is num
            ? (j['streakFreezeHeld'] as num).toInt()
            : 0,
        streakFreezeUsedToday: j['streakFreezeUsedToday'] == true,
        activeEventId: j['activeEventId'] is String
            ? j['activeEventId'] as String
            : '',
        eventProgress: j['eventProgress'] is num
            ? (j['eventProgress'] as num).toInt()
            : 0,
        claimedEventIds: readStrList(j['claimedEventIds']),
        isEventActive: j['isEventActive'] == true,
        leaderboardCoins: readListOfMaps(j['leaderboardCoins']),
        leaderboardSpeed: readListOfMaps(j['leaderboardSpeed']),
        leaderboardStreak: readListOfMaps(j['leaderboardStreak']),
        achievementPopupsShown: readStrList(j['achievementPopupsShown']),
      );
    } catch (_) {
      return null;
    }
  }
}

class SaveStorage {
  static const String _prefsKey = 'arrowrift_save_v1';
  static const String _fileName = 'arrowrift_save_v1.json';
  static const Duration _timeout = Duration(seconds: 3);

  File? _cachedFile;
  bool _fileResolved = false;
  String prefsRead = '-',
      prefsWrite = '-',
      fileRead = '-',
      fileWrite = '-',
      filePath = '-';

  String get status =>
      'prefs R:$prefsRead W:$prefsWrite | file R:$fileRead W:$fileWrite';

  static String _short(Object e) {
    final t = e.toString().replaceAll('\n', ' ');
    return t.length > 70 ? t.substring(0, 70) : t;
  }

  Future<SaveData> load() async {
    final results = await Future.wait<SaveData?>([_readPrefs(), _readFile()]);
    final found = results.whereType<SaveData>().toList();
    if (found.isEmpty) return SaveData.empty;
    found.sort((a, b) {
      final byTime = b.savedAt.compareTo(a.savedAt);
      if (byTime != 0) return byTime;
      return b.totalPoints.compareTo(a.totalPoints);
    });
    return found.first;
  }

  Future<bool> save(SaveData data) async {
    final json = data.toJsonString();
    final results = await Future.wait<bool>([
      _writePrefs(json),
      _writeFile(json),
    ]);
    return results.any((r) => r);
  }

  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(_timeout);
      await prefs.remove(_prefsKey);
      final file = await _resolveFile();
      if (file != null && await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('SaveStorage clearAll fail: $e');
    }
  }

  Future<SaveData?> _readPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(_timeout);
      final parsed = SaveData.tryParse(prefs.getString(_prefsKey));
      if (parsed != null) {
        prefsRead = 'ok';
        return parsed;
      }
      prefsRead = 'empty';
    } catch (e) {
      prefsRead = 'ERR ${_short(e)}';
    }
    return null;
  }

  Future<bool> _writePrefs(String json) async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(_timeout);
      final ok = await prefs.setString(_prefsKey, json).timeout(_timeout);
      prefsWrite = ok ? 'ok' : 'false';
      return ok;
    } catch (e) {
      prefsWrite = 'ERR ${_short(e)}';
      return false;
    }
  }

  Future<File?> _resolveFile() async {
    if (_fileResolved) return _cachedFile;
    _fileResolved = true;
    try {
      if (!Platform.isAndroid) return null;
      final bytes = await File('/proc/self/cmdline').readAsBytes();
      final nameBytes = bytes.takeWhile((b) => b != 0).toList();
      final processName = utf8.decode(nameBytes, allowMalformed: true).trim();
      if (processName.isEmpty) return null;
      final pkg = processName.split(':').first;
      for (final root in <String>['/data/user/0/$pkg', '/data/data/$pkg']) {
        try {
          final dir = Directory('$root/files');
          if (!await dir.exists()) await dir.create(recursive: true);
          _cachedFile = File('${dir.path}/$_fileName');
          filePath = dir.path;
          return _cachedFile;
        } catch (_) {}
      }
    } catch (e) {
      filePath = 'ERR ${_short(e)}';
    }
    return null;
  }

  Future<SaveData?> _readFile() async {
    try {
      final file = await _resolveFile();
      if (file == null) {
        fileRead = 'nopath';
        return null;
      }
      if (!await file.exists()) {
        fileRead = 'empty';
        return null;
      }
      final d = SaveData.tryParse(await file.readAsString());
      fileRead = d == null ? 'bad' : 'ok';
      return d;
    } catch (e) {
      fileRead = 'ERR ${_short(e)}';
      return null;
    }
  }

  Future<bool> _writeFile(String json) async {
    try {
      final file = await _resolveFile();
      if (file == null) {
        fileWrite = 'nopath';
        return false;
      }
      final tmp = File('${file.path}.tmp');
      await tmp.writeAsString(json, flush: true);
      await tmp.rename(file.path);
      fileWrite = 'ok';
      return true;
    } catch (e) {
      fileWrite = 'ERR ${_short(e)}';
      return false;
    }
  }
}
