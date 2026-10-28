import 'package:flutter/material.dart';

/// Which on-screen widget the tutorial is pointing at.
/// `none` = no hole (full dim + card only, used for the final step).
enum TutorialTarget {
  playButton,
  classicCard,
  level1Card,
  firstArrow,
  statsTab,
  arcadeTab,
  shopTab,
  settingsTab,
  none,
}

/// One step of the guided tour: text, icon and what to highlight.
class TutorialStepData {
  final int step;
  final String title;
  final String description;
  final IconData icon;
  final TutorialTarget target;
  final double holePadding;
  final double holeRadius;
  final bool isFinal;

  const TutorialStepData({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
    required this.target,
    this.holePadding = 8,
    this.holeRadius = 24,
    this.isFinal = false,
  });
}

/// Holds all tutorial step data + the GlobalKeys that screens attach to the
/// widgets which must be highlighted.
///
/// tutorialStep (lives in GameProvider):
///   0 = tutorial off
///   1 = Home            -> tap PLAY
///   2 = Mode selection  -> tap Classic Mode card
///   3 = Level screen    -> tap Level 1 card
///   4 = Game screen     -> tap the highlighted arrow
///   5 = Bottom nav      -> tap Stats
///   6 = Bottom nav      -> tap Arcade
///   7 = Bottom nav      -> tap Shop
///   8 = Bottom nav      -> tap Settings
///   9 = Finish          -> tap "Start Playing"
class TutorialManager {
  TutorialManager._();

  static const int stepOff = 0;
  static const int stepPlay = 1;
  static const int stepClassicMode = 2;
  static const int stepLevel1 = 3;
  static const int stepGameArrow = 4;
  static const int stepStats = 5;
  static const int stepArcade = 6;
  static const int stepShop = 7;
  static const int stepSettings = 8;
  static const int stepFinish = 9;
  static const int totalSteps = 9;

  /// Route name given to ModeSelectionScreen so the tutorial can pop back to it.
  static const String modeSelectionRouteName = 'mode_selection';

  /// Route names for the Level list and the Game screen. TutorialRouteObserver
  /// uses them to put the tour back on the right step if the player presses
  /// the system back button in the middle of the tutorial.
  static const String levelRouteName = 'level_screen';
  static const String gameRouteName = 'game_screen';

  // ---------------- GLOBAL KEYS (one widget each, never reused) ----------------
  static final GlobalKey playButtonKey = GlobalKey(debugLabel: 'tut_play');
  static final GlobalKey classicCardKey = GlobalKey(debugLabel: 'tut_classic');
  static final GlobalKey level1CardKey = GlobalKey(debugLabel: 'tut_level1');
  static final GlobalKey boardKey = GlobalKey(debugLabel: 'tut_board');
  static final GlobalKey statsTabKey = GlobalKey(debugLabel: 'tut_stats');
  static final GlobalKey arcadeTabKey = GlobalKey(debugLabel: 'tut_arcade');
  static final GlobalKey shopTabKey = GlobalKey(debugLabel: 'tut_shop');
  static final GlobalKey settingsTabKey = GlobalKey(debugLabel: 'tut_settings');

  /// Key for a bottom-nav item (index: 0 Home, 1 Stats, 2 Arcade, 3 Shop,
  /// 4 Settings). Home has no key.
  static GlobalKey? navKeyForIndex(int index) {
    switch (index) {
      case 1:
        return statsTabKey;
      case 2:
        return arcadeTabKey;
      case 3:
        return shopTabKey;
      case 4:
        return settingsTabKey;
      default:
        return null;
    }
  }

  /// Which bottom-nav tab index must be tapped on a given tutorial step.
  /// Returns -1 if the step is not a tab step.
  static int tabIndexForStep(int step) {
    switch (step) {
      case stepStats:
        return 1;
      case stepArcade:
        return 2;
      case stepShop:
        return 3;
      case stepSettings:
        return 4;
      default:
        return -1;
    }
  }

  /// Key of the widget to highlight for a target (null for firstArrow, which
  /// is computed from the board + arrow cells, and for `none`).
  static GlobalKey? keyForTarget(TutorialTarget target) {
    switch (target) {
      case TutorialTarget.playButton:
        return playButtonKey;
      case TutorialTarget.classicCard:
        return classicCardKey;
      case TutorialTarget.level1Card:
        return level1CardKey;
      case TutorialTarget.statsTab:
        return statsTabKey;
      case TutorialTarget.arcadeTab:
        return arcadeTabKey;
      case TutorialTarget.shopTab:
        return shopTabKey;
      case TutorialTarget.settingsTab:
        return settingsTabKey;
      case TutorialTarget.firstArrow:
      case TutorialTarget.none:
        return null;
    }
  }

  // ---------------- STEP DATA ----------------
  static const List<TutorialStepData> steps = [
    TutorialStepData(
      step: stepPlay,
      title: 'Welcome to Arrowrift',
      description: 'Tap PLAY to begin your adventure.',
      icon: Icons.play_arrow_rounded,
      target: TutorialTarget.playButton,
      holePadding: 12,
      holeRadius: 28,
    ),
    TutorialStepData(
      step: stepClassicMode,
      title: 'Classic Mode',
      description:
          'This is where your levels live. Tap Classic Mode to open them.',
      icon: Icons.grid_view_rounded,
      target: TutorialTarget.classicCard,
      holePadding: 6,
      holeRadius: 28,
    ),
    TutorialStepData(
      step: stepLevel1,
      title: 'Level 1',
      description: "Every journey starts somewhere. Tap Level 1 to begin.",
      icon: Icons.flag_rounded,
      target: TutorialTarget.level1Card,
      holePadding: 8,
      holeRadius: 22,
    ),
    TutorialStepData(
      step: stepGameArrow,
      title: 'Clear the Arrow',
      description: 'Arrows fly the way they point. This one has a clear path, so tap it. A blocked arrow costs a life!',
      icon: Icons.touch_app_rounded,
      target: TutorialTarget.firstArrow,
      holePadding: 6,
      holeRadius: 14,
    ),
    TutorialStepData(
      step: stepStats,
      title: 'Stats',
      description: 'Track your progress and achievements here.',
      icon: Icons.bar_chart_rounded,
      target: TutorialTarget.statsTab,
      holePadding: 4,
      holeRadius: 24,
    ),
    TutorialStepData(
      step: stepArcade,
      title: 'Arcade',
      description: 'Play quick mini-games to earn extra coins.',
      icon: Icons.sports_esports_rounded,
      target: TutorialTarget.arcadeTab,
      holePadding: 4,
      holeRadius: 24,
    ),
    TutorialStepData(
      step: stepShop,
      title: 'Shop',
      description: 'Get power-ups and themes here.',
      icon: Icons.shopping_bag_rounded,
      target: TutorialTarget.shopTab,
      holePadding: 4,
      holeRadius: 24,
    ),
    TutorialStepData(
      step: stepSettings,
      title: 'Settings',
      description: 'Change music and sounds. You can replay this guide anytime from How to Play.',
      icon: Icons.settings_rounded,
      target: TutorialTarget.settingsTab,
      holePadding: 4,
      holeRadius: 24,
    ),
    TutorialStepData(
      step: stepFinish,
      title: "You're Ready!",
      description:
          'Clear every arrow before time runs out. Good luck, Maze Master!',
      icon: Icons.emoji_events_rounded,
      target: TutorialTarget.none,
      isFinal: true,
    ),
  ];

  /// Data for a step number (1..9). Null when the tutorial is off.
  static TutorialStepData? dataFor(int step) {
    if (step < 1 || step > steps.length) return null;
    return steps[step - 1];
  }
}
