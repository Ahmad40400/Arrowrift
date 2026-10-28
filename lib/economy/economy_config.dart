// ============================================================================
// ARROWRIFT ECONOMY CONFIG  —  single source of truth for every coin/diamond
// number in the game. Change numbers HERE, nowhere else.
//
// Level unlock-cost formulas stay in GameProvider.getLevelCost (unchanged).
// ============================================================================

class Eco {
  Eco._();

  // ---------------------------------------------------------------- REWARDS
  static const double star3Mult = 1.03;
  static const double star2Mult = 0.98;
  static const double star1Mult = 0.90;
  static const int classicFlatBonus = 100;
  static const int proFlatBonus = 200;
  static const double proRewardMult = 1.05;
  static const double autoSolvePayoutMult = 0.5;

  // ----------------------------------------------------------------- REPLAY
  static const double replayPct = 0.30;
  static const int replayMin = 60;
  static const int replayMax = 6000;
  static const int replayDailyBudget = 12000;

  // ------------------------------------------------------- DAILY CHALLENGE
  static const double dailyPctOfNextCost = 0.20;
  static const int dailyMin = 1000;
  static const int dailyMax = 6000;

  static int dailyChallengeReward(int nextUnlockCost) {
    final int raw = (nextUnlockCost * dailyPctOfNextCost).round();
    final int stepped = (raw / 50).round() * 50;
    if (stepped < dailyMin) return dailyMin;
    if (stepped > dailyMax) return dailyMax;
    return stepped;
  }

  // ------------------------------------------------------------------ SHOP
  static const int freezeCoinPrice = 1500;
  static const int healthCoinPrice = 400;
  static const int autoSolveCoinPrice = 150000;
  static const int autoSolveDiamondPrice = 5000;

  // Time Freeze can not give 3 stars
  static const int freezeMaxStars = 2;

  // -------------------------------------------------------------- DIAMONDS
  static const int exchangeDiamonds = 300;
  static const int exchangeCoins = 2500;

  // Repeating daily-task diamonds (was 50 each = 100/day).
  static const int dailyTaskDiamonds = 10;

  // ------------------------------------------------------------ LUCKY DRAW
  static const int luckyDiamonds = 100;
  static const int luckyCoins = 3000;
  static const int luckyAutoSolveKeepOutOf10 = 1;

  // ---------------------------------------------------------------- THEMES
  static const int themePrice = 10000;
  static const int themePreviewSeconds = 180;

  // --------------------------------------------------------- STARTER KIT
  static const int starterFreeze = 1;
  static const int starterHealth = 1;
  static const int starterAutoSolve = 1;

  // ---------------------------------------------------------- LOGIN STREAK
  static const int streakDay1Coins = 150;
  static const int streakDay2Coins = 250;
  static const int streakDay3Coins = 400;
  static const int streakDay4Coins = 600;
  static const int streakDay5Coins = 900;
  static const int streakDay6Coins = 1400;
  static const int streakDay7Diamonds = 100;

  // Streak Freeze item (1 din miss maaf)
  static const int streakFreezeCoinPrice = 5000;
  static const int streakFreezeMaxHeld = 3;

  static int streakCoinForDay(int day) {
    switch (day) {
      case 1:
        return streakDay1Coins;
      case 2:
        return streakDay2Coins;
      case 3:
        return streakDay3Coins;
      case 4:
        return streakDay4Coins;
      case 5:
        return streakDay5Coins;
      case 6:
        return streakDay6Coins;
      default:
        return 0; // Day 7 = diamonds
    }
  }
}

// ============================================================================
// EVENTS SYSTEM CONFIG  (NEW - 35+ Rotating Events)
// ============================================================================

class GameEvent {
  final String id;
  final String title;
  final String description;
  final String type;
  final int target;
  final int rewardCoins;
  final int rewardDiamonds;
  final String icon;

  const GameEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    this.rewardCoins = 0,
    this.rewardDiamonds = 0,
    this.icon = 'trophy',
  });
}

class EventConfig {
  EventConfig._();

  static const int eventDurationHours = 48;
  static const int gracePeriodHours = 24;

  static const List<GameEvent> allEvents = [
    GameEvent(
      id: 'e01',
      title: 'Weekend Rush',
      description: 'Clear 10 Classic levels',
      type: 'classic',
      target: 10,
      rewardCoins: 5000,
      rewardDiamonds: 50,
      icon: 'fire',
    ),
    GameEvent(
      id: 'e02',
      title: 'Level Grinder',
      description: 'Clear 20 levels (Any mode)',
      type: 'any',
      target: 20,
      rewardCoins: 8000,
      rewardDiamonds: 0,
      icon: 'trophy',
    ),
    GameEvent(
      id: 'e03',
      title: 'Coin Collector',
      description: 'Earn 10,000 coins',
      type: 'coins',
      target: 10000,
      rewardCoins: 2000,
      rewardDiamonds: 20,
      icon: 'coin',
    ),
    GameEvent(
      id: 'e04',
      title: 'Diamond Hunt',
      description: 'Earn 150 diamonds',
      type: 'diamonds',
      target: 150,
      rewardCoins: 5000,
      rewardDiamonds: 0,
      icon: 'diamond',
    ),
    GameEvent(
      id: 'e05',
      title: 'Speed Demon',
      description: 'Finish 5 levels in under 15s',
      type: 'speed15',
      target: 5,
      rewardCoins: 8000,
      rewardDiamonds: 30,
      icon: 'speed',
    ),
    GameEvent(
      id: 'e06',
      title: 'Lightning Fast',
      description: 'Finish 3 levels in under 10s',
      type: 'speed10',
      target: 3,
      rewardCoins: 12000,
      rewardDiamonds: 50,
      icon: 'speed',
    ),
    GameEvent(
      id: 'e07',
      title: 'Untouchable',
      description: 'Clear 5 levels without losing a life',
      type: 'perfect',
      target: 5,
      rewardCoins: 4000,
      rewardDiamonds: 20,
      icon: 'shield',
    ),
    GameEvent(
      id: 'e08',
      title: 'Flawless Victory',
      description: 'Clear 10 levels without losing a life',
      type: 'perfect',
      target: 10,
      rewardCoins: 10000,
      rewardDiamonds: 60,
      icon: 'shield',
    ),
    GameEvent(
      id: 'e09',
      title: 'No Power-ups',
      description: 'Clear 5 levels without using Freeze/Solve',
      type: 'no_power',
      target: 5,
      rewardCoins: 6000,
      rewardDiamonds: 0,
      icon: 'lock',
    ),
    GameEvent(
      id: 'e10',
      title: 'Pro Marathon',
      description: 'Clear 5 Pro levels',
      type: 'pro',
      target: 5,
      rewardCoins: 0,
      rewardDiamonds: 100,
      icon: 'fire',
    ),
    GameEvent(
      id: 'e11',
      title: 'Extreme Challenge',
      description: 'Clear 10 Pro levels',
      type: 'pro',
      target: 10,
      rewardCoins: 0,
      rewardDiamonds: 200,
      icon: 'fire',
    ),
    GameEvent(
      id: 'e12',
      title: 'Pro Speedrun',
      description: 'Clear 3 Pro levels in under 20s each',
      type: 'pro_speed',
      target: 3,
      rewardCoins: 15000,
      rewardDiamonds: 50,
      icon: 'speed',
    ),
    GameEvent(
      id: 'e13',
      title: 'Arcade Blitz',
      description: 'Win 5 Arcade minigames',
      type: 'arcade',
      target: 5,
      rewardCoins: 3000,
      rewardDiamonds: 30,
      icon: 'gamepad',
    ),
    GameEvent(
      id: 'e14',
      title: 'Daily Champion',
      description: 'Complete the Daily Challenge',
      type: 'daily',
      target: 1,
      rewardCoins: 3000,
      rewardDiamonds: 0,
      icon: 'calendar',
    ),
    GameEvent(
      id: 'e15',
      title: 'Replay Master',
      description: 'Replay 10 previously cleared levels',
      type: 'replay',
      target: 10,
      rewardCoins: 2500,
      rewardDiamonds: 0,
      icon: 'refresh',
    ),
    GameEvent(
      id: 'e16',
      title: 'Early Bird',
      description: 'Clear 10 levels between 1-50',
      type: 'tier1',
      target: 10,
      rewardCoins: 3000,
      rewardDiamonds: 10,
      icon: 'star',
    ),
    GameEvent(
      id: 'e17',
      title: 'Mid-Game Grind',
      description: 'Clear 5 levels between 100-200',
      type: 'tier3',
      target: 5,
      rewardCoins: 5000,
      rewardDiamonds: 20,
      icon: 'star',
    ),
    GameEvent(
      id: 'e18',
      title: 'Endgame Legend',
      description: 'Clear 3 levels above 500',
      type: 'tier5',
      target: 3,
      rewardCoins: 10000,
      rewardDiamonds: 50,
      icon: 'star',
    ),
    GameEvent(
      id: 'e19',
      title: 'Power-up Addict',
      description: 'Use 3 Time Freezes',
      type: 'use_freeze',
      target: 3,
      rewardCoins: 2000,
      rewardDiamonds: 0,
      icon: 'snow',
    ),
    GameEvent(
      id: 'e20',
      title: 'Auto-Pilot',
      description: 'Use 2 Auto-Solves',
      type: 'use_solve',
      target: 2,
      rewardCoins: 3000,
      rewardDiamonds: 10,
      icon: 'auto',
    ),
    GameEvent(
      id: 'e21',
      title: 'Morning Player',
      description: 'Clear 5 levels before 12 PM',
      type: 'time_morning',
      target: 5,
      rewardCoins: 4000,
      rewardDiamonds: 0,
      icon: 'sun',
    ),
    GameEvent(
      id: 'e22',
      title: 'Night Owl',
      description: 'Clear 5 levels after 10 PM',
      type: 'time_night',
      target: 5,
      rewardCoins: 4000,
      rewardDiamonds: 0,
      icon: 'moon',
    ),
    GameEvent(
      id: 'e23',
      title: 'Weekend Warrior',
      description: 'Clear 15 levels on Sat/Sun',
      type: 'weekend',
      target: 15,
      rewardCoins: 6000,
      rewardDiamonds: 0,
      icon: 'calendar',
    ),
    GameEvent(
      id: 'e24',
      title: 'Streak Keeper',
      description: 'Maintain a 3-day login streak',
      type: 'streak',
      target: 3,
      rewardCoins: 5000,
      rewardDiamonds: 20,
      icon: 'fire',
    ),
    GameEvent(
      id: 'e25',
      title: 'Lucky Draw',
      description: 'Open 1 Lucky Draw gift',
      type: 'lucky',
      target: 1,
      rewardCoins: 1000,
      rewardDiamonds: 0,
      icon: 'gift',
    ),
    GameEvent(
      id: 'e26',
      title: 'The 1%',
      description: 'Clear a level with 1 second left',
      type: 'clutch',
      target: 1,
      rewardCoins: 15000,
      rewardDiamonds: 100,
      icon: 'danger',
    ),
    GameEvent(
      id: 'e27',
      title: 'Mega Marathon',
      description: 'Clear 30 levels (Any mode)',
      type: 'any',
      target: 30,
      rewardCoins: 15000,
      rewardDiamonds: 50,
      icon: 'fire',
    ),
    GameEvent(
      id: 'e28',
      title: 'Grid Master',
      description: 'Clear 5 levels with grid size 10+',
      type: 'big_grid',
      target: 5,
      rewardCoins: 6000,
      rewardDiamonds: 15,
      icon: 'grid',
    ),
    GameEvent(
      id: 'e29',
      title: 'No Mistakes',
      description: 'Play 3 levels without a wrong tap',
      type: 'no_mistake',
      target: 3,
      rewardCoins: 4000,
      rewardDiamonds: 0,
      icon: 'target',
    ),
    GameEvent(
      id: 'e30',
      title: 'Theme Explorer',
      description: 'Apply a different theme',
      type: 'theme',
      target: 1,
      rewardCoins: 1000,
      rewardDiamonds: 5,
      icon: 'palette',
    ),
    GameEvent(
      id: 'e31',
      title: 'Shopper',
      description: 'Buy any item from the Shop',
      type: 'buy_shop',
      target: 1,
      rewardCoins: 500,
      rewardDiamonds: 0,
      icon: 'cart',
    ),
    GameEvent(
      id: 'e32',
      title: 'High Roller',
      description: 'Spend 10,000 coins',
      type: 'spend',
      target: 10000,
      rewardCoins: 3000,
      rewardDiamonds: 20,
      icon: 'coin',
    ),
    GameEvent(
      id: 'e33',
      title: 'Coin Rush',
      description: 'Earn 20,000 coins',
      type: 'coins',
      target: 20000,
      rewardCoins: 5000,
      rewardDiamonds: 50,
      icon: 'coin',
    ),
    GameEvent(
      id: 'e34',
      title: 'Diamond Rain',
      description: 'Earn 300 diamonds',
      type: 'diamonds',
      target: 300,
      rewardCoins: 8000,
      rewardDiamonds: 0,
      icon: 'diamond',
    ),
    GameEvent(
      id: 'e35',
      title: 'Legendary Focus',
      description: 'Clear 15 levels (Any mode)',
      type: 'any',
      target: 15,
      rewardCoins: 6000,
      rewardDiamonds: 20,
      icon: 'trophy',
    ),
  ];

  static GameEvent getActiveEvent(int currentTimeMs) {
    final int eventEpoch = 1700000000000;
    final int msSinceEpoch = currentTimeMs - eventEpoch;
    final int index =
        (msSinceEpoch ~/ (eventDurationHours * 3600 * 1000)) % allEvents.length;
    return allEvents[index < 0 ? 0 : index];
  }
}
