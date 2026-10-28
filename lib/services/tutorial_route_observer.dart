import 'package:flutter/material.dart';

import '../providers/game_provider.dart';
import 'tutorial_manager.dart';

/// Keeps the guided tour on the right step when the player presses the
/// system back button in the middle of it.
///
/// Without this, going back from Level 1 to the level list (or from the mode
/// screen to Home) would leave the tutorial pointing at a button that is not
/// on screen any more ("Getting ready..." forever).
///
///   Game screen   -> back to Level list    : step "Level 1"
///   Game screen   -> back to Mode screen   : tutorial ended (it was opened
///                                            from Settings > How to Play)
///   Level list    -> back to Mode screen   : step "Classic Mode"
///   Mode screen   -> back to Home (step 2) : step "Play"
///   Mode screen   -> back to Home (step 5+): tutorial ended
class TutorialRouteObserver extends NavigatorObserver {
  TutorialRouteObserver._();
  static final TutorialRouteObserver instance = TutorialRouteObserver._();

  /// Set from MyApp.build.
  GameProvider? game;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Dialogs, bottom sheets etc. are not pages: ignore them.
    if (route is! PageRoute) return;

    final GameProvider? g = game;
    if (g == null || !g.isTutorialActive) return;

    final int step = g.tutorialStep;
    final String? prev = previousRoute?.settings.name;
    final bool prevIsHome = previousRoute == null || previousRoute.isFirst;

    int? nextStep;
    bool finish = false;

    if (step == TutorialManager.stepGameArrow) {
      if (prev == TutorialManager.modeSelectionRouteName) {
        finish = true; // game screen was opened from Settings
      } else {
        nextStep = TutorialManager.stepLevel1;
      }
    } else if (step == TutorialManager.stepLevel1) {
      if (prev == TutorialManager.modeSelectionRouteName) {
        nextStep = TutorialManager.stepClassicMode;
      }
    } else if (step == TutorialManager.stepClassicMode) {
      if (prevIsHome) nextStep = TutorialManager.stepPlay;
    } else if (step >= TutorialManager.stepStats) {
      if (prevIsHome) finish = true;
    }

    if (nextStep == null && !finish) return;

    // Never change provider state in the middle of a navigation callback.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (g.tutorialStep != step) return; // something else already moved on
      if (finish) {
        g.abortTutorial();
      } else {
        g.setTutorialStep(nextStep!);
      }
    });
  }
}
